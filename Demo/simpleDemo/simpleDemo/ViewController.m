//
//  ViewController.m
//  simpleDemo
//
//  Created by xxhape on 2023/10/9.
//

#import "ViewController.h"

#import <TCRSDK/TCRSDK.h>

typedef void (^httpResponseBlk)(NSData * data, NSURLResponse * response, NSError * error);

@interface ViewController ()<TcrSessionObserver>
@property(nonatomic, copy) NSString *userId;
@property(nonatomic, strong) TcrSession *session;
@property(nonatomic, strong) TcrRenderView *renderView;
@property(nonatomic, strong) PcTouchView *touchView; // 云端为PC时添加该view到最上层
@property(nonatomic, strong) MobileTouchView *mobileTouchView;// 云端为手机容器时添加该view到最上层
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
    self.userId = @"test";
}

- (void)initSession{
    self.session = [[TcrSession alloc] initWithParams:nil andDelegate:self];
    self.renderView = [[TcrRenderView alloc] initWithFrame:self.view.frame];
    [self.session setRenderView:self.renderView];
    self.touchView = [[PcTouchView alloc] initWithFrame:self.view.frame session:self.session];
    [self.view addSubview:self.renderView];
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
        @"RequestId"     : requestID,
        @"UserId"        : self.userId,
        @"GameId"        : @"game-xxx",
        @"clientSession" : localSession,
//        @"TimeStamp"     : timeStamp,
//        @"Sign"          : sign
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
        NSDictionary *jsonObj = (NSDictionary *) json;
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


- (void)onEvent:(TcrEvent)event eventData:(NSDictionary * _Nullable)eventData { 
    switch (event) {
        case STATE_INITED:
            [self getRemoteSessionWithLocalSession:(NSString*)eventData];
            break;
        default:
            break;
    }
}


@end