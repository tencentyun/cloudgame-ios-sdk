//
//  ViewController.m
//  simpleDemo
//
//  Created by xxhape on 2023/10/9.
//

#import "ViewController.h"

#import <TCRSDK/TCRSDK.h>

typedef void (^httpResponseBlk)(NSData *data, NSURLResponse *response, NSError *error);

@interface ViewController () <TcrSessionObserver, TcrRenderViewObserver, TCRLogDelegate>
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) TcrSession *session;
@property (nonatomic, strong) TcrRenderView *renderView;
@property (nonatomic, strong) PcTouchView *touchView;
@property (nonatomic, assign) UIInterfaceOrientation screenConfig;
@property (nonatomic, strong) NSDictionary* videoStreamSizeConfig;
@property (nonatomic, assign) BOOL screenConfigChanged;
@property (nonatomic, assign) BOOL videoSizeChanged;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TcrSdkInstance setLogger:self withMinLevel:TCRLogLevelInfo];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    UIButton *startBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 100, 45)];
    [startBtn setTitle:@"Start" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    UIButton *stopBtn = [[UIButton alloc] initWithFrame:CGRectMake(150, 50, 100, 45)];
    [stopBtn setTitle:@"Stop" forState:UIControlStateNormal];
    [stopBtn addTarget:self action:@selector(stopGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    [self.view addSubview:stopBtn];
    self.userId = @"test";
}

- (void)initSession {
    self.session = [[TcrSession alloc] initWithParams:nil andDelegate:self];
    self.renderView = [[TcrRenderView alloc] initWithFrame:self.view.frame];
    [self.renderView setTcrRenderViewObserver:self];
    [self.session setRenderView:self.renderView];
    self.touchView = [[PcTouchView alloc] initWithFrame:self.view.frame session:self.session];
    [self.view insertSubview:self.renderView atIndex:0];

    [self.touchView setCursorIsShow:YES];

    [self.touchView setCursorTouchMode:TCRMouseCursorTouchMode_AbsoluteTouch];
    [self.renderView addSubview:self.touchView];
}

- (void)postUrl:(NSString *)url params:(NSDictionary *)params finishBlk:(httpResponseBlk)finishBlk {
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:url]];
    [request setHTTPMethod:@"POST"];
    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    if (error != nil || body == nil) {
        NSLog(@"JSON serialization error:%@", error);
        if (finishBlk) {
            finishBlk(nil, nil, error);
        }
        return;
    }
    [request setHTTPBody:body];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [[session dataTaskWithRequest:request completionHandler:finishBlk] resume];
}

- (void)getRemoteSessionWithLocalSession:(NSString *)localSession {
    // TODO: 这里的接口地址仅供Demo体验，请及时更换为自己的业务后台接口
    // 云应用将StartGame替换为StartProject
    NSString *requestID = [[NSUUID UUID] UUIDString];
    NSString *createSessionUrl = @"";
    NSDictionary *params = @{
        @"RequestId": requestID,
        @"UserId": self.userId,
        @"clientSession": localSession,
    };

    [self postUrl:createSessionUrl params:params finishBlk:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil || data == nil) {
            NSLog(@"申请云端机器失败:%@", error.userInfo.description);
            return;
        }
        NSError *err = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (err != nil || ![json isKindOfClass:[NSDictionary class]]) {
            NSLog(@"返回结果解析失败:%@", error.userInfo.description);
            return;
        }
        NSDictionary *jsonObj = (NSDictionary *)json;
        NSString *serverSession = [jsonObj objectForKey:@"ServerSession"];
        if (serverSession.length == 0) {
            NSLog(@"返回结果异常:%@", jsonObj);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startGameWithRemoteSession:serverSession];
        });
    }];
}

- (void)startGame {
    [self initSession];
}

- (void)startGameWithRemoteSession:(NSString *)remoteSession {
    NSLog(@"从业务后台成功申请到云端机器");
    NSError *error;
    [self.session start:remoteSession];
    NSLog(@"start game %@", error);
}

- (void)stopGame {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.touchView removeFromSuperview];
        self.touchView = nil;
        [self.renderView removeFromSuperview];
        [self.session releaseSession];
        self.session = nil;
        // TODO: 业务后台需要及时向腾讯云后台释放机器，避免资源浪费
        NSString *releaseSession = @"";

        NSDictionary *params = @ { @"UserId": self.userId };
        [self postUrl:releaseSession params:params finishBlk:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error != nil || data == nil) {
                NSLog(@"释放云端机器失败:%@", error.userInfo.description);
                return;
            }
            NSLog(@"已释放云端机器");
        }];
    });
}

- (void)resetVideoOrientation {
    if (_screenConfig == UIInterfaceOrientationPortrait) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    } else {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeRight] forKey:@"orientation"];
    }
}

- (void)updateRotation {
    if (!_screenConfigChanged || !_videoSizeChanged) {
        return;
    }
    // 视频流    云端Activity                客户端处理
    // 宽>高            竖屏            设置竖屏。渲染时旋转画面90度。
    // 宽>高            横屏            设置横屏。渲染时直接画面。
    // 宽<高            竖屏            设置竖屏。渲染时直接画面。
    // 宽<高            横屏            设置横屏。渲染时旋转画面270度。
    CGFloat angle = 0; // 角度以弧度为单位
    if ([_videoStreamSizeConfig[@"width"] intValue] > [_videoStreamSizeConfig[@"height"] intValue]) {
        if (_screenConfig == UIInterfaceOrientationPortrait) {
            angle = M_PI_2;
        }
    } else {
        if (_screenConfig == UIInterfaceOrientationLandscapeRight) {
            angle = -M_PI_2;
        }
    }
    self.renderView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
}

- (void)onEvent:(TcrEvent)event eventData:(id)eventData {
    NSLog(@"EVNET%@", @(event));
    NSDictionary* info;
    NSArray* array;
    CGRect rect;
    switch (event) {
        case STATE_INITED:
            [self getRemoteSessionWithLocalSession:(NSString *)eventData];
            break;
        case STATE_CONNECTED:
            //;
            break;
        case VIDEO_STREAM_CONFIG_CHANGED:
            _videoSizeChanged = YES;
            _videoStreamSizeConfig = (NSDictionary *)eventData;
            [self updateRotation];
            break;
        case SCREEN_CONFIG_CHANGE:
            _screenConfig = (UIInterfaceOrientation)eventData;
            [self resetVideoOrientation];
            _screenConfigChanged = YES;
            [self updateRotation];
            break;
        case CURSOR_IMAGE_INFO:
            info = (NSDictionary*)eventData;
            array = info[@"imageFrame"];
            rect = CGRectMake([array[0] floatValue], [array[1] floatValue], [array[2] floatValue], [array[3] floatValue]);
            [self.touchView setCursorImage:info[@"image"] andRemoteFrame:rect];
            break;
        default:
            break;
    }
}

- (void)onFirstFrameRendered {
    NSLog(@"首帧渲染");
}
- (void)logWithLevel:(TCRLogLevel)logLevel log:(NSString *)log {
    NSLog(@"[TCRSDK] %zu, %@", logLevel, log);
}

@end
