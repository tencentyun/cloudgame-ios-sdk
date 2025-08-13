//
//  TCGDemoGamelistVC.m
//  TCGDemo
//
//  Created by LyleYu on 2021/6/21.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TCGDemoGameListVC.h"
#import "TCGDemoGameListView.h"
#import "TCGDemoGamePlayVC.h"
#import "TCGDemoUtils.h"

@interface TCGDemoGameListVC () <TcrSessionObserver, TCGDemoGameListViewDelegate>

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, strong) NSNumber *setNo;
@property (nonatomic, strong) TcrSession *session;
@property (nonatomic, strong) TCGDemoGameListView *gameListView;
@property (nonatomic, strong) NSDictionary *sesssionParams;

@end

@implementation TCGDemoGameListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initSelectView];
}

- (void)initSelectView {
    TCGDemoGameListView *list = [[TCGDemoGameListView alloc] initWithFrame:CGRectMake(0, 0, 600, 400)];
    list.delegate = self;
    self.gameListView = list;
    [self.view addSubview:list];
    self.gameListView.center = self.view.center;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)dealloc {
    [self stopGame];
}

#pragma mark+++ 流程(01)：创建TcrSession，等待初始化成功
- (void)createGamePlayer {
    if (self.session != nil) {
        // TCGSDK同时只支持一个游戏实例
        [self.session releaseSession];
        self.session = nil;
    }
    self.session = [[TcrSession alloc] initWithParams:nil andDelegate:self];
}

- (void)stopGame {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.session releaseSession];
        self.session = nil;
        [self.gameListView reset];
        [self stopRemoteSession];
    });
}

- (void)showToast:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
    int duration = 2;  // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)tryLock:(NSString *)localSession {
    NSString *userId = [[NSUUID UUID] UUIDString];
    NSMutableDictionary *requestData = [NSMutableDictionary dictionaryWithDictionary:@{
        @"GameId": self.gameId,
        @"UserId": userId,
        @"Appid": @([self.appId longLongValue]),
        @"ClientSession": localSession,
        @"Resolution": @"720p",
        @"SetNo": self.setNo
    }];
    NSString *tryLock = @"https://test-cloud-gaming.myqcloud.com/cloudapi/try_lock";
    [TCGDemoUtils tcg_postUrl:tryLock params:requestData finishBlk:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"try_lock response %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (error != nil) {
            NSLog(@"try_lock error %@", error);
            [self stopGame];
            return;
        }
        NSError *err = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (err != nil || ![json isKindOfClass:[NSDictionary class]]) {
            NSLog(@"try_lock bad response error:%@ data:%@", error, data);
            [self stopGame];
            return;
        }
        NSDictionary *jsonObj = (NSDictionary *)json;

        // parse code
        id code = jsonObj[@"code"];
        if (![code isKindOfClass:[NSNumber class]]) {
            NSLog(@"try_lock bad code:%@", code);
            [self stopGame];
            return;
        }
        NSNumber *codeObj = (NSNumber *)code;
        if ([codeObj integerValue] != 0) {
            NSLog(@"try_lock return code %@", codeObj);
            [self showToast:@"暂时没有可用的机器"];
            [self stopGame];
            return;
        }
        [self getSignature:requestData];
    }];
}

- (void)getSignature:(NSDictionary *)params {
    self.sesssionParams = nil;
    NSString *getSignature = @"https://test-cloud-gaming.myqcloud.com/cloudapi/get_signature";
    [TCGDemoUtils tcg_postUrl:getSignature params:params finishBlk:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"GetSignature response %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (error != nil) {
            NSLog(@"GetSignature error %@", error);
            [self showToast:@"暂时没有可用的机器"];
            [self stopGame];
            return;
        }
        error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error != nil || ![json isKindOfClass:[NSDictionary class]]) {
            NSLog(@"GetSignature bad response error:%@ data:%@", error, data);
            [self stopGame];
            return;
        }
        NSDictionary *jsonObj = (NSDictionary *)json;

        // parse code
        id code = jsonObj[@"code"];
        if (![code isKindOfClass:[NSNumber class]]) {
            NSLog(@"GetSignature bad code:%@", code);
            [self stopGame];
            return;
        }
        NSNumber *codeObj = (NSNumber *)code;
        if ([codeObj integerValue] != 0) {
            NSLog(@"GetSignature return code %@", codeObj);
            [self showToast:@"暂时没有可用的机器"];
            [self stopGame];
            return;
        }

        // parse data
        id dataValue = jsonObj[@"data"];
        if (![dataValue isKindOfClass:[NSDictionary class]]) {
            NSLog(@"GetSignature bad data %@", dataValue);
            [self stopGame];
            return;
        }

        NSDictionary *dataObj = (NSDictionary *)dataValue;
        id serverSession = dataObj[@"ServerSession"];
        if (![serverSession isKindOfClass:[NSString class]]) {
            NSLog(@"GetSignature bad ServerSession %@", serverSession);
            [self stopGame];
            return;
        }
        self.sesssionParams = params;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self gotoGameplayVC:serverSession];
        });
    }];
}

- (void)stopRemoteSession {
    NSString *stopGame = @"https://test-cloud-gaming.myqcloud.com/cloudapi/stopgame";
    if (self.sesssionParams.count == 0) {
        return;
    }
    [TCGDemoUtils tcg_postUrl:stopGame params:self.sesssionParams finishBlk:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"释放云端游戏资源");
    }];
}

- (void)applyRemoteSessionWithLocalSession:(NSString *)localSession {
    [self tryLock:localSession];
    [self.gameListView setTips:@"申请云设备中..."];
}

#pragma mark+++ 流程(02)：初始化成功，用本地session向后台申请remoteSession
- (void)onInitSuccess:(NSString *)localSession {
    [self applyRemoteSessionWithLocalSession:localSession];
}

- (void)onEvent:(TcrEvent)event eventData:(NSDictionary *)eventData {
    if (event == STATE_INITED) {
        [self applyRemoteSessionWithLocalSession:eventData[@"session"]];
    }
}

#pragma mark+++ 流程(03)：设置remoteSession，开始与后台建立连接
- (void)gotoGameplayVC:(NSString *)remoteSession {
    [self.gameListView reset];

    TCGDemoGamePlayVC *subVC = [[TCGDemoGamePlayVC alloc] initWithPlay:self.session remoteSession:remoteSession];
    [self addChildViewController:subVC];
    subVC.view.frame = self.view.bounds;
    [self.view addSubview:subVC.view];
    [subVC didMoveToParentViewController:self];
    // 这里可以释放对SDK的实例retain
    self.session = nil;
    __weak typeof(self) weakSelf = self;
    [subVC setGameStopBlk:^{
        [weakSelf stopRemoteSession];
    }];
}

#pragma mark--- TCGDemoGameListViewDelegate ---
- (void)onGameItemClick:(NSDictionary *)gameInfo {
    self.gameId = [gameInfo objectForKey:@"gameid"];
    self.appId = [gameInfo objectForKey:@"appid"];
    NSString *setno = [gameInfo objectForKey:@"setno"];
    if (setno.length > 0) {
        self.setNo = @([setno longLongValue]);
    } else {
        self.setNo = @(0);
    }
    [self createGamePlayer];
}

@end
