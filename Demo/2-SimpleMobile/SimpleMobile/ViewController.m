//
//  ViewController.m
//  SimpleMobile
//
//  Created by LyleYu on 2021/10/19.
//  Copyright © 2021 yujunlei. All rights reserved.
//

#import "ViewController.h"
#import <TCGSDK/TCGSDK.h>

typedef void (^httpResponseBlk)(NSData * data, NSURLResponse * response, NSError * error);

@interface ViewController ()<TCGGamePlayerDelegate>

@property(nonatomic, copy) NSString *userId;
@property(nonatomic, strong) TCGGamePlayer *gamePlayer;
@property(nonatomic, weak) TCGGameController *gameController;
@property(nonatomic, strong) TCGRemoteTouchScreen *mobileTouch;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleStatusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createGamePlayer {
    if (self.gamePlayer) {
        return;
    }
    self.gamePlayer = [[TCGGamePlayer alloc] initWithParams:nil andDelegate:self];
    [self.gamePlayer setConnectTimeout:10];
    [self.gamePlayer setStreamBitrateMix:1000 max:3000 fps:30];
    self.gameController = self.gamePlayer.gameController;

    [self.gamePlayer.videoView setFrame:self.view.bounds];
    [self.view insertSubview:self.gamePlayer.videoView atIndex:0];

    self.mobileTouch = [[TCGRemoteTouchScreen alloc] initWithFrame:self.gamePlayer.videoView.bounds controller:self.gameController];
    [self.gamePlayer.videoView addSubview:self.mobileTouch];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopGame];
}

- (void)getRemoteSessionWithLocalSession:(NSString *)localSession {
    // TODO: 这里的接口地址仅供Demo体验，请及时更换为自己的业务后台接口
    NSString *createSession = @"https://service-dn0r2sec-1304469412.gz.apigw.tencentcs.com/release/StartCloudGame";
    self.userId = [NSString stringWithFormat:@"SimplePC-%@", [[NSUUID UUID] UUIDString]];
    NSDictionary *params = @{@"GameId":@"game-0qo599jg", @"UserId":self.userId, @"ClientSession":localSession};
    [self postUrl:createSession params:params finishBlk:^(NSData *data, NSURLResponse *response, NSError *error) {
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
        NSDictionary *jsonObj = (NSDictionary *) json;
        NSString *code = [jsonObj objectForKey:@"code"];
        if ([code intValue] != 0) {
            NSLog(@"返回结果异常:%@", jsonObj);
            return;
        }
        NSDictionary *dataDic = [jsonObj objectForKey:@"data"];
        NSString *serverSession = [dataDic objectForKey:@"ServerSession"];
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
    [self createGamePlayer];
}

- (void)startGameWithRemoteSession:(NSString *)remoteSession {
    NSLog(@"从业务后台成功申请到云端机器");
    NSError *error;
    [self.gamePlayer startGameWithRemoteSession:remoteSession error:&error];
    NSLog(@"start game %@", error);
}

- (void)stopGame {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.gamePlayer == nil) {
            return;
        }
        [self.gamePlayer.videoView removeFromSuperview];
        [self.gamePlayer stopGame];
        self.gamePlayer = nil;
        if (self.userId.length == 0) {
            return;
        }
        // TODO: 业务后台需要及时向腾讯云后台释放机器，避免资源浪费
        NSString *releaseSession = @"https://service-dn0r2sec-1304469412.gz.apigw.tencentcs.com/release/StopCloudGame";
        NSDictionary *params = @{@"UserId":self.userId};
        [self postUrl:releaseSession params:params finishBlk:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error != nil || data == nil) {
                NSLog(@"释放云端机器失败:%@", error.userInfo.description);
                return;
            }
            NSLog(@"已释放云端机器");
        }];
    });
}

- (void)onInitSuccess:(NSString *)localSession {
    NSLog(@"SimpleMobile onInitSuccess， 本地初始化成功");
    [self getRemoteSessionWithLocalSession:localSession];
}

- (void)onVideoSizeChanged:(CGSize)videoSize {
    UIInterfaceOrientation vcOrient = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat newWidth = 100;
    CGFloat newHeight = 100;
    if (vcOrient == UIInterfaceOrientationLandscapeRight) {
        // 当手机横屏显示时，需要将videoView画面逆时钟旋转90度。
        newWidth = self.view.frame.size.height;
        newHeight = self.view.frame.size.width - [self.view safeAreaInsets].left;
    } else {
        newWidth = self.view.frame.size.width;
        newHeight = self.view.frame.size.height - [self.view safeAreaInsets].top;
    }
    // 游戏画面固定为竖屏、设置游戏画面居中显示类似 UIViewContentModeScaleAspectFit
    if (newWidth/newHeight > videoSize.width/videoSize.height) {
        newHeight = floor(newWidth * videoSize.height / videoSize.width);
    } else {
        newWidth = floor(newHeight * videoSize.width / videoSize.height);
    }
    self.gamePlayer.videoView.frame = CGRectMake((self.view.frame.size.width - newWidth) / 2,
                                                 (self.view.frame.size.height - newHeight) / 2,
                                                 newWidth, newHeight);
    [self.mobileTouch setFrame:self.gamePlayer.videoView.bounds];

    if (vcOrient == UIInterfaceOrientationLandscapeRight) {
        self.gamePlayer.videoView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
    }
}

- (void)handleStatusBarOrientationChange:(NSNotification *)notification {
    self.gamePlayer.videoView.center = self.view.center;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIInterfaceOrientationPortrait:{
            self.gamePlayer.videoView.transform = CGAffineTransformIdentity;
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            self.gamePlayer.videoView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
        }
            break;
        default:
            break;
    }
}

- (void)onVideoOrientationChanged:(UIInterfaceOrientation)orientation {
    NSLog(@"onVideoOrientationChanged 游戏画面内容朝向改变:%tu", orientation);
}

- (void)onVideoShow {
    NSLog(@"SimpleMobile onVideoShow, 游戏开始有画面");
}

- (void)onConnectionFailure:(TCGErrorType)errorCode msg:(NSError *)errorMsg {
    NSLog(@"SimpleMobile onConnectionFailure");
}

- (void)onInitFailure:(TCGErrorType)errorCode msg:(NSError *)errorMsg {
    NSLog(@"SimpleMobile onInitFailure");
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

@end
