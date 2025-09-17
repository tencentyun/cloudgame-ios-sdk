//
//  TCGDemoVC.m
//  tcgsdk-demo
//
//  Created by LyleYu on 2020/12/11.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TCGDemoGamePlayVC.h"
#import "TCGDemoTextField.h"
#import "TCGDemoGameListView.h"
#import "TCGDemoSettingView.h"
#import "TCGDemoLoadingView.h"
#import "TCGDemoMultiSettingView.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioQueuePlay.h"
#import "TCGDemoAudioCapturor.h"
#import <TCRVkey/TCRVKeyGamepad.h>
#import <CoreMotion/CoreMotion.h>
#import "video_capture/TCGCameraVideoCapturer.h"

@interface TCGDemoGamePlayVC () <TcrSessionObserver, TCGDemoTextFieldDelegate, CustomDataChannelObserver, TCGDemoSettingViewDelegate, TCRLogDelegate,
    VideoSink, AudioSink, TcrRenderViewObserver, TCGDemoMultiSettingViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *remoteSession;
@property (nonatomic, strong) NSDictionary *experienceCode;
@property (nonatomic, strong) TcrSession *session;
@property (nonatomic, strong) TcrRenderView *renderView;
@property (nonatomic, assign) CGSize videoStreamSize;
@property (nonatomic, assign) CGRect videoRenderFrame;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftEdgeGesture;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *rightEdgeGesture;
@property (nonatomic, strong) UIButton *settingBtn;
@property (nonatomic, strong) UIButton *multiSettingBtn;
@property (nonatomic, strong) TCGDemoSettingView *settingView;
@property (nonatomic, strong) TCGDemoMultiSettingView *multiSettingView;
@property (nonatomic, strong) TCGDemoTextField *hiddenText;
@property (nonatomic, strong) UIView *keyboardBgView;
@property (nonatomic, strong) UILabel *debugLab;
@property (nonatomic, strong) NSTimer *debugLabTimer;
@property (nonatomic, assign) BOOL reconnect;
@property (nonatomic, assign) BOOL usingGamepad;
@property (nonatomic, assign) BOOL usingCursor;
@property (nonatomic, strong) CustomDataChannel *customChannel;
@property (nonatomic, strong) TCGDemoLoadingView *loadingView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) AudioQueuePlay *audioPlayer;
@property (nonatomic, strong) dispatch_queue_t audioPlayerQueue;
@property (nonatomic, strong) PcTouchView *pcTouchView;
@property (nonatomic, strong) MobileTouchView *mobileTouchView;
@property (nonatomic, assign) BOOL isFirstRender;
@property (nonatomic, strong) TCRVKeyGamepad *gamepad;
@property (nonatomic, assign) BOOL isMobile;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic, strong) TCGCameraVideoCapturer *videoCapturer;
@property (nonatomic, assign) BOOL isFrontCamera;
@property (nonatomic, assign) int captureWidth;
@property (nonatomic, assign) int captureHeight;
@property (nonatomic, assign) int captureFps;
@property (nonatomic, assign) BOOL enableSendCustomVideo;
@property (nonatomic, assign) BOOL enableSendCustomAudio;
@end

@implementation TCGDemoGamePlayVC

- (instancetype)initWithPlay:(TcrSession *)play remoteSession:(NSString *)remoteSession {
    return [self initWithPlay:play remoteSession:remoteSession loadingView:nil];
}

- (instancetype)initWithPlay:(TcrSession *)play remoteSession:(NSString *)remoteSession loadingView:(UIView *)loadingView {
    self = [super init];
    if (self) {
        self.session = play;
        self.isFirstRender = NO;
        self.remoteSession = remoteSession;
        self.loadingView = (TCGDemoLoadingView *)loadingView;
        self.captureWidth = 720;
        self.captureHeight = 1280;
        self.captureFps = 20;
        [self.session setTcrSessionObserver:self];
    }
    return self;
}

- (instancetype)initWithPlay:(TcrSession *)play remoteSession:(NSString *)remoteSession loadingView:(UIView *)loadingView enableSendCustomVideo:(BOOL)enableSendCustomVideo enableSendCustomAudio:(BOOL)enableSendCustomAudio captureWidth:(int)captureWidth captureHeight:(int)captureHeight captureFps:(int)captureFps; {
    self = [super init];
    if (self) {
        self.session = play;
        self.isFirstRender = NO;
        self.remoteSession = remoteSession;
        self.loadingView = (TCGDemoLoadingView *)loadingView;
        self.captureWidth = captureWidth;
        self.captureHeight = captureHeight;
        self.captureFps = captureFps;
        self.enableSendCustomVideo = enableSendCustomVideo;
        self.enableSendCustomAudio = enableSendCustomAudio;
        [self.session setTcrSessionObserver:self];
    }
    return self;
}

- (instancetype)initWithPlay:(TcrSession *)play experienceCode:(NSDictionary *)params {
    self = [super init];
    if (self) {
        self.session = play;
        self.experienceCode = params;
    }
    return self;
}

- (instancetype)initWithPlay:(TcrSession *)play loadingView:(UIView *)loadingView {
    self = [super init];
    if (self) {
        self.session = play;
        self.isFirstRender = NO;
        self.loadingView = (TCGDemoLoadingView *)loadingView;
        [self.session setTcrSessionObserver:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"init ver:%@", TCRSDKVersion);
    self.view.backgroundColor = [UIColor whiteColor];
    [self initGamePlayView];
    [self initSettingView];
    [self initMultiSettingView];
    [self initControlViews];
    [self initVirtualKeyboard];
    [self initDebugView];
    [self addEdgeSwipeGestures];
    self.motionManager = [[CMMotionManager alloc] init];

    dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0);
    _audioPlayerQueue = dispatch_queue_create("com.media.audioplayer", attr);
    // 图层的层级要注意，影响点击事件的响应
    [self.view addSubview:self.hiddenText];
    self.renderView = [[TcrRenderView alloc] initWithFrame:self.view.frame];
    // SDK游戏视图
    [self.view addSubview:self.renderView];
    // Demo业务视图
    [self.view addSubview:self.settingView];
    [self.view addSubview:self.settingBtn];
    [self.view addSubview:self.multiSettingView];
    [self.view addSubview:self.multiSettingBtn];
    [self.view addSubview:self.keyboardBgView];
    [self.view addSubview:self.debugLab];
    [self resetVideoViewWithSize:CGSizeMake(1280, 720)];
    [self.renderView addSubview:self.pcTouchView];
    [self.renderView addSubview:self.mobileTouchView];
    [TcrSdkInstance setLogger:self withMinLevel:TCRLogLevelInfo];
    [self.session setRenderView:_renderView];
    [self.renderView addSubview:self.gamepad];
    [self.renderView setTcrRenderViewObserver:self];
    //    [self.session setVideoSink:self];
    //    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    //    [self.view addSubview:self.imageView];
    self.isMobile = NO;  // 云端应用为手机应用还是windows应用
    
    [[TCGDemoAudioCapturor shared]setAudioDataHandler:^(NSData * _Nonnull data, uint64_t timestamp) {
        
        if ([self.session sendCustomAudioData:data captureTimeNs:timestamp]) {
            NSLog(@"send custom audio data");
        } else {
            NSLog(@"send custom audio data failed.");
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    if (self.session != nil && self.remoteSession.length > 0) {
#pragma mark+++ 流程(03)：设置remoteSession，开始与后台建立连接
        [self.session start:self.remoteSession];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.motionManager stopAccelerometerUpdates];
}

- (void)initGamePlayView {
    [self.renderView setEnablePinch:YES];
}

- (void)resetVideoViewWithSize:(CGSize)videoSize {
    self.videoStreamSize = videoSize;

    UIInterfaceOrientation vcOrient = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat newWidth = 0;
    CGFloat newHeight = 0;

    newWidth = self.view.frame.size.width;
    newHeight = self.view.frame.size.height;
    newHeight -= [self.view safeAreaInsets].top + [self.view safeAreaInsets].bottom;
    if (self.isMobile && vcOrient == UIInterfaceOrientationLandscapeRight) {
        // 手游的视频分辨率只会是 宽 < 高，当手机横屏显示时，需要将videoView画面逆时钟旋转90度。
        newWidth = self.view.frame.size.height;
        newHeight = self.view.frame.size.width;
        newHeight -= [self.view safeAreaInsets].left + [self.view safeAreaInsets].right;
    }

    // 游戏画面强制横屏、长边对齐，短边留白 可考虑在viewSafeAreaInsetsDidChange之后再创建subview
    newWidth -= [self.view safeAreaInsets].left + [self.view safeAreaInsets].right;
    if (newWidth / newHeight < videoSize.width / videoSize.height) {
        newHeight = floor(newWidth * videoSize.height / videoSize.width);
    } else {
        newWidth = floor(newHeight * videoSize.width / videoSize.height);
    }

    self.videoRenderFrame
        = CGRectMake((self.view.frame.size.width - newWidth) / 2, (self.view.frame.size.height - newHeight) / 2, newWidth, newHeight);
    [self.renderView setFrame:self.videoRenderFrame];
    
    [self.mobileTouchView setFrame:self.renderView.bounds];
    [self.pcTouchView setFrame:self.renderView.bounds];

    if (self.isMobile && [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        self.renderView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
    }
}

- (void)initVirtualKeyboard {
    _hiddenText = [[TCGDemoTextField alloc] initWithFrame:CGRectMake(10, 10, 1, 1)];
    _hiddenText.keyCodedelegate = self;

    _keyboardBgView = [[UIView alloc] initWithFrame:self.view.bounds];
    _keyboardBgView.backgroundColor = [UIColor clearColor];
    _keyboardBgView.userInteractionEnabled = YES;
    _keyboardBgView.hidden = YES;

    UITapGestureRecognizer *singleClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleClickAction:)];
    [_keyboardBgView addGestureRecognizer:singleClick];
}

- (void)initControlViews {
    // 触摸转鼠标: 创建一个与renderView大小位置相同的pcTouchView
    self.pcTouchView = [[PcTouchView alloc] initWithFrame:CGRectMake(0, 0, self.videoRenderFrame.size.width, self.videoRenderFrame.size.height)
                                                  session:self.session];
    self.pcTouchView.hidden = YES;

    // 触摸转windows触摸: 创建一个与renderView大小位置相同的mobileTouchView
    self.mobileTouchView =
        [[MobileTouchView alloc] initWithFrame:CGRectMake(0, 0, self.videoRenderFrame.size.width, self.videoRenderFrame.size.height)
                                       session:self.session];
    self.mobileTouchView.hidden = NO;

    // 虚拟按键视图加载
    self.gamepad = [[TCRVKeyGamepad alloc] initWithFrame:self.view.frame session:self.session];
    [self.gamepad showKeyGamepad:[self readJsonFromFile:@"tcg_default_ps4"]];
    self.gamepad.hidden = YES;
}

- (void)initSettingView {
    // 调试视图的初始化
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 50, 30, 30)];
    btn1.backgroundColor = [UIColor clearColor];
    [btn1 setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(settingBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    _settingView = [[TCGDemoSettingView alloc] initWithFrame:self.view.bounds];
    _settingView.delegate = self;
    _settingView.hidden = YES;

    self.settingBtn = btn1;
    self.settingBtn.hidden = YES;
}
- (void)initMultiSettingView {
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(50, 30, 30, 30)];
    btn1.backgroundColor = [UIColor clearColor];
    [btn1 setImage:[UIImage imageNamed:@"login_radio_unselected"] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(multiSesstingBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    _multiSettingView = [[TCGDemoMultiSettingView alloc] initWithFrame:self.view.bounds];
    _multiSettingView.delegate = self;
    _multiSettingView.hidden = YES;

    self.multiSettingBtn = btn1;
    self.multiSettingBtn.hidden = YES;
}
- (void)initDebugView {
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(30, self.videoRenderFrame.origin.y, 350, 15)];
    lab.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
    lab.font = [UIFont systemFontOfSize:10];
    lab.textColor = [UIColor whiteColor];
    lab.textAlignment = NSTextAlignmentLeft;
    lab.hidden = YES;
    self.debugLab = lab;
}

- (void)enableUpdateDebugInfo:(BOOL)isEnable {
    [self.debugLabTimer invalidate];
    self.debugLabTimer = nil;
    if (!isEnable) {
        return;
    }
    self.debugLabTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateDebugInfo) userInfo:nil repeats:true];
}

- (void)updateDebugInfo:(NSDictionary *)info {
    NSNumber *rtt = [info objectForKey:@"RTT"];
    NSNumber *fps = [info objectForKey:@"FPS"];
    NSNumber *videoDelay = [info objectForKey:@"VideoDelay"];
    NSNumber *videoNack = [info objectForKey:@"VideoPacketNack"];
    NSNumber *videoBitrateKbps = [info objectForKey:@"VideoBitrateRecvKb"];
    NSNumber *audioDelay = [info objectForKey:@"AudioDelay"];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.debugLab.text = [NSString stringWithFormat:@"rtt:%@, fps:%@, v_delay:%@, v_nack:%@, a_delay:%@ v_bitrate:%@kbps", rtt, fps, videoDelay,
                                       videoNack, audioDelay, videoBitrateKbps];
        [self.settingView setAllDebugInfo:info];
    });
}

- (NSString *)readJsonFromFile:(NSString *)fileName {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"cfg"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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

#pragma mark--- TCGDemoTextFieldDelegate ---
- (void)onClickKey:(int)keycode {
    NSLog(@"onClickKey:%d", keycode);
    static int shiftKeycode = 16;
    if (keycode >= 'A' && keycode <= 'Z') {
        keycode = keycode - 'A' + 65;
        [[self.session getKeyboard] onKeyboard:shiftKeycode down:YES];
        [[self.session getKeyboard] onKeyboard:keycode down:YES];
        [[self.session getKeyboard] onKeyboard:keycode down:NO];
        [[self.session getKeyboard] onKeyboard:shiftKeycode down:NO];
    }
    if (keycode >= 'a' && keycode <= 'z') {
        keycode = keycode - 'a' + 65;
        [[self.session getKeyboard] onKeyboard:keycode down:YES];
        [[self.session getKeyboard] onKeyboard:keycode down:NO];
    }
    if (keycode >= '0' && keycode <= '9') {
        keycode = keycode - '0' + 48;
        [[self.session getKeyboard] onKeyboard:keycode down:YES];
        [[self.session getKeyboard] onKeyboard:keycode down:NO];
    }
    if (keycode == 8) {  // 删除按键
        [[self.session getKeyboard] onKeyboard:keycode down:YES];
        [[self.session getKeyboard] onKeyboard:keycode down:NO];
    }
}

- (void)singleClickAction:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture.state == UIGestureRecognizerStateRecognized) {
        [_hiddenText resignFirstResponder];
    }
}

- (void)keyboardWillShow:(NSNotification *)notificationP {
    self.keyboardBgView.hidden = NO;
}

- (void)keyboardWillHide:(NSNotification *)notificationP {
    self.keyboardBgView.hidden = YES;
}

#pragma mark--- TCGDemoSettingViewDelegate ---

- (void)settingBtnClick:(id)sender {
    self.settingView.hidden = !self.settingView.isHidden;
}

- (void)multiSesstingBtnClick:(id)sender {
    self.multiSettingView.hidden = !self.multiSettingView.isHidden;
}

- (void)stopGame {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.debugLabTimer invalidate];
        [self.renderView removeFromSuperview];
        [self.audioPlayer stop];
        [self.videoCapturer stopCapture];
        [self.session releaseSession];
        if (self.gameStopBlk) {
            self.gameStopBlk();
        }

        [self willMoveToParentViewController:self.parentViewController];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    });
}

#pragma mark 云应用交互测试
- (void)restartGame {
    [self.session restartCloudApp];
}
- (void)pasteText {
    [self.session pasteText:@"123"];
}
- (void)modifyRES {
    [self.session setRemoteDesktopResolution:1080 height:1920];
}

#pragma mark+++ 流程(05)：等有画面后，再设置控制器
- (void)openKeyboard:(BOOL)isOpen {
    if (isOpen) {
        self.pcTouchView.hidden = NO;
        [self.pcTouchView setCursorTouchMode:TCRMouseCursorTouchMode_RelativeTouch];
        [self.pcTouchView setCursorImage:[UIImage imageNamed:@"default_cursor"] andRemoteFrame:CGRectMake(0, 0, 32, 32)];
        [self.pcTouchView setCursorIsShow:YES];
    } else {
        self.pcTouchView.hidden = YES;
    }
    self.usingCursor = isOpen;
}

- (void)clearAllKeys {
    [[self.session getKeyboard] resetKeyboard];
}

- (void)checkCapsLock {
    [[self.session getKeyboard] checkKeyboardCapsLock:^(int retCode) {
        if (retCode < 0) {
            NSLog(@"check capslock failed:%d", retCode);
            return;
        }
        [self showToast:(retCode == 1 ? @"云端打开大写锁定" : @"云端关闭大写锁定")];
    }];
}
#pragma mark 数据通道测试
- (void)onCreateDataChannel {
    self.customChannel = [self.session createCustomDataChannel:6665 observer:self];
}

- (void)onDataChannelSend {
    int value = 123;
    NSNumber *number = [NSNumber numberWithInt:value];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:number requiringSecureCoding:YES error:nil];
    [self.customChannel send:data];
}
#pragma mark 触摸转鼠标设置项
- (void)onSetCursorTouchMode:(int)mode {
    [self.pcTouchView setCursorTouchMode:(TCRMouseCursorTouchMode)mode];
}

- (void)onSetCursorSensitive:(CGFloat)sensitive {
    [self.pcTouchView setCursorSensitive:sensitive];
}

- (void)onSetCursorClickType:(BOOL)isLeft {
    [self.pcTouchView setClickTypeIsLeft:isLeft];
}

#pragma mark--- 音视频传输测试 ---
- (void)onSetVolume:(CGFloat)volume {
    [self.session setRemoteAudioProfile:volume];
}

- (void)onSetBitrateLevel:(int)level {
    int max = 2;
    int min = 1;
    int fps = 30;
    switch (level) {
        case 0:
            min = 1 * 1024;
            max = 2 * 1024;
            fps = 30;
            break;
        case 1:
            min = 3 * 1024;
            max = 4 * 1024;
            fps = 45;
            break;
        case 2:
            min = 7 * 1024;
            max = 8 * 1024;
            fps = 60;
        default:
            break;
    }
    [self.session setRemoteVideoProfile:fps minBitrate:min maxBitrate:max];
}

- (void)pauseResumeGame:(BOOL)doPause {
    doPause ? [self.session pauseStreaming] : [self.session resumeStreaming];
}

- (void)onEnableLocalAudio:(BOOL)enable {
    if (_enableSendCustomAudio) {
        if (enable) {
            [[TCGDemoAudioCapturor shared] startCapture];
        } else {
            [[TCGDemoAudioCapturor shared] stopCapture];
        }
    }
    [self.session setEnableLocalAudio:enable];
}

- (void)openGamepad:(BOOL)isOpen {
    if (isOpen) {
        [[self.session getGamepad] connectGamepad];
        self.gamepad.hidden = NO;
    } else {
        [[self.session getGamepad] disconnectGamepad];
        self.gamepad.hidden = YES;
    }
}

- (void)onEnableLocalVideo:(BOOL)enable {
    if (_enableSendCustomVideo) {
        if (enable) {
            AVCaptureDevice *device = [self selectDevice];
            AVCaptureDeviceFormat *format = [self selectFormatForDevice:device];
            if (_videoCapturer == nil) {
                _videoCapturer = [[TCGCameraVideoCapturer alloc] initWithTcrSession:self.session];
            }
            [_videoCapturer startCaptureWithDevice:device format:format fps:_captureFps];

        } else {
            [_videoCapturer stopCapture];
        }
    }

    [self.session setEnableLocalVideo:enable];
}

- (void)onSwitchCamera:(BOOL)isFrontCamera {
    [self.session setLocalVideoProfile:_captureWidth height:_captureHeight fps:_captureFps minBitrate:1000 maxBitrate:5000 isFrontCamera:isFrontCamera];
}

- (void)onRotateView {
    CGRect oldRect = self.renderView.frame;
    CGAffineTransform scaleTrans = CGAffineTransformMakeScale(oldRect.size.height / oldRect.size.width, oldRect.size.width / oldRect.size.height);
    CGAffineTransform rotateTrans = CGAffineTransformRotate(self.renderView.transform, -M_PI_2);
    NSLog(@"onRotateView self.gamePlayer.videoView.frame:%@", NSStringFromCGRect(self.renderView.frame));
    self.renderView.transform = CGAffineTransformRotate(self.renderView.transform, -M_PI_2);
}

- (void)openTouchView:(BOOL)isOpen {
    self.mobileTouchView.hidden = !isOpen;
}

- (void)enableCoreMotion:(BOOL)enable {
    if (enable) {
        if (self.motionManager.isAccelerometerAvailable) {
            self.motionManager.accelerometerUpdateInterval = 0.1; // 设置更新间隔
            [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                                      withHandler:^(CMAccelerometerData *data, NSError *error) {
                if (error) {
                    NSLog(@"Error: %@", error);
                    return;
                }
                CMAcceleration acceleration = data.acceleration;
                if (self.session != nil) {
                    [self.session.getMotionSensor onSensorData:ACCELEROMETER x:acceleration.x y:acceleration.y z:acceleration.z];
                    [self.session.getMotionSensor onLocationChanged:113.94 latitude:22.52];
                }
            }];
        } else {
            NSLog(@"加速度计不可用");
        }
    } else {
        [self.motionManager stopAccelerometerUpdates];
    }
}

#pragma mark--- 按键测试 ---
- (void)onKeyboard:(int)keycode {
    [[self.session getKeyboard] onKeyboard:keycode down:true];
    [[self.session getKeyboard] onKeyboard:keycode down:false];
}


#pragma mark--- TCRLogDelegate ---
- (void)logWithLevel:(TCRLogLevel)logLevel log:(NSString *)log {
    // 获取当前时间戳字符串
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];

    switch (logLevel) {
        case TCRLogLevelDebug:
            NSLog(@"[TCRSDK] %@ [DEBUG]: %@", timestamp, log);
            break;
        case TCRLogLevelInfo:
            NSLog(@"[TCRSDK] %@ [INFO]: %@", timestamp, log);
            break;
        case TCRLogLevelWarning:
            NSLog(@"[TCRSDK] %@ [WARNING]: %@", timestamp, log);
            break;
        case TCRLogLevelError:
            NSLog(@"[TCRSDK] %@ [ERROR]: %@", timestamp, log);
            break;

        default:
            break;
    }
}

#pragma mark--- TCRSessionObserver ---
- (void)onEvent:(TcrEvent)event eventData:(id)eventData {
    NSDictionary *info;
    NSArray *array;
    CGRect rect;
    switch (event) {
        case STATE_CONNECTED: {
            NSLog(@"ApiTest STATE_CONNECTED:%@", (NSString *)eventData);
            NSLog(@"requestId = %@", [_session getRequestId]);
            dispatch_async(dispatch_get_main_queue(), ^{
              [self showToast:@"连接成功"];
              self.pcTouchView.hidden = NO;
            });
            break;
        }
        case STATE_RECONNECTING:
            [self showToast:@"重连中"];
            break;
        case STATE_CLOSED:
            [self showToast:@"会话关闭"];
            break;
        case VIDEO_STREAM_CONFIG_CHANGED:
            NSLog(@"ApiTest 分辨率变化:%@", (NSString *)eventData);
            info = (NSDictionary *)eventData;
            CGFloat width = [info[@"width"] doubleValue];
            CGFloat height = [info[@"height"] doubleValue];
            [self resetVideoViewWithSize:CGSizeMake(width, height)];
            break;
        case IME_TYPE: {
            info = (NSDictionary *)eventData;
            NSString* imeType = (NSString *)info[@"ime_type"];
            NSLog(@"gaogao 输入法类型:%@", imeType);
            break;
        }
        case SCREEN_CONFIG_CHANGE:
            NSLog(@"ApiTest 横竖屏变化:%@", (NSString *)eventData);
            break;
        case MULTI_USER_SEAT_INFO:
            NSLog(@"ApiTest 房间信息变化:%@", (NSString *)eventData);
            break;
        case MULTI_USER_ROLE_APPLY:
            NSLog(@"ApiTest 收到坐席请求:%@", (NSString *)eventData);
            break;
        case CLIENT_STATS:
            info = (NSDictionary *)eventData;
            NSLog(@"ApiTest CLIENT_STATS: %@", info);
            [self updateDebugInfo:eventData];
            break;
        case CLIENT_IDLE:
            NSLog(@"ApiTest TCRSDK 操作空闲");
            break;
        case INPUT_STATE_CHANGE:
            info = (NSDictionary *)eventData;
            NSLog(@"ApiTest INPUT_STATE_CHANGE: %@", info);
            if ([info[@"field_type"] isEqualToString:@"normal_input"]) {
                [self checkKBOpen];
            }
            break;
        case GAME_START_COMPLETE: {
            NSLog(@"ApiTest 游戏拉起:%@", (NSString *)eventData);
            break;
        }
        case CAMERA_STATUS_CHANGED: {
            info = (NSDictionary *)eventData;
            NSLog(@"ApiTest 摄像头状态切换:%@", info);
            NSString* status = info[@"status"];
            if ([status isEqualToString:@"close"]) {
                [self onEnableLocalVideo:false];
            } else {
                _isFrontCamera = [status isEqualToString:@"open_front"];
                [self onEnableLocalVideo:true];
                [self.session setLocalVideoProfile:_captureWidth height:_captureHeight fps:_captureFps minBitrate:1000 maxBitrate:15000 isFrontCamera:_isFrontCamera];
            }
            break;
        }
        case MIC_STATUS_CHANGED: {
            info = (NSDictionary *)eventData;
            NSLog(@"ApiTest 麦克风状态切换:%@", info);
            [self onEnableLocalAudio:[info[@"status"] isEqualToString:@"open"]];
            break;
        }
        case CURSOR_STATE_CHANGE: {
            NSLog(@"ApiTest CURSOR_STATE_CHANGE:%@", (NSString *)eventData);
            [self.pcTouchView setCursorTouchMode:TCRMouseCursorTouchMode_RelativeTouch];
            [self.pcTouchView setCursorIsShow:[eventData boolValue]];
            break;
        }
        case CURSOR_IMAGE_INFO:
            info = (NSDictionary *)eventData;
            array = info[@"imageFrame"];
            rect = CGRectMake([array[0] floatValue], [array[1] floatValue], [array[2] floatValue], [array[3] floatValue]);
            [self.pcTouchView setCursorImage:info[@"image"] andRemoteFrame:rect];
            break;
        default:
            break;
    }
}

- (void)checkKBOpen {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.hiddenText canBecomeFirstResponder]) {
            [self.hiddenText becomeFirstResponder];
        } else {
            NSLog(@"键盘拉起失败");
        }
    });
}

#pragma mark--- TCGCustomTransChannelDelegate ---
- (void)onConnected:(NSInteger)port {
    NSLog(@"onConnSuccessAtRemotePort %ld", (long)port);
}
- (void)onError:(NSInteger)port code:(NSInteger)code message:(NSString *)msg {
    NSLog(@"onError:port:%ld code:%ld msg:%@", (long)port, (long)code, msg);
}
- (void)onMessage:(NSInteger)port buffer:(NSData *)buffer {
    NSString *msg = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
    NSLog(@"onReceiveData:%@ port:%ld", msg, (long)port);
}

#pragma mark--- TcrRenderViewObserver ---
- (void)onFirstFrameRendered {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.settingBtn.hidden = NO;
        self.multiSettingBtn.hidden = NO;
        self.debugLab.hidden = NO;
        [self.renderView setEnablePinch:YES];
        [self.loadingView setProcessValue:100];
    });
}

#pragma mark--- 音视频数据回调 ---
- (void)onRenderVideoFrame:(TCRVideoFrame *)frame {
    CVPixelBufferRef pixelBuffer = frame.pixelBuffer;
    if (!self.isFirstRender) {
        self.isFirstRender = YES;
        [self.loadingView setProcessValue:100];
    }
    //    NSLog(@"xxhape onframe %d*%d",frame.width,frame.height);
    if (!frame.pixelBuffer) {
        NSLog(@"onframe frame=nil");
        return;
    }
    CFRetain(pixelBuffer);
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        TCGDemoGamePlayVC *strongSelf = weakSelf;
        if (!strongSelf) {
            CFRelease(pixelBuffer);
            return;
        }
        UIImageView *videoView = strongSelf.imageView;
        videoView.image = [UIImage imageWithCIImage:[CIImage imageWithCVImageBuffer:pixelBuffer]];
        videoView.contentMode = UIViewContentModeScaleAspectFit;
        CFRelease(pixelBuffer);
    });
}

- (void)onAudioData:(TCRAudioFrame *)data {
    if (!self.audioPlayer) {
        self.audioPlayer = [[AudioQueuePlay alloc] initWithFrame:data];
    }
    __weak typeof(self) weakSelf = self;
    NSData *data1 = data.data;
    dispatch_async(_audioPlayerQueue, ^{
      [weakSelf.audioPlayer playWithData:data1];
    });
}
#pragma mark--- 多人互动 ---
- (void)onApplySeatChange:(nonnull NSString *)userid index:(int)index role:(nonnull NSString *)role {
    [self.session requestChangeSeat:userid targetRole:role targetPlayerIndex:index blk:^(int retCode) {
        if (retCode < 0) {
            NSLog(@"check capslock failed:%d", retCode);
            return;
        }
        NSLog(@"申请席位结果:%d", retCode);
    }];
}

- (void)onSeatChange:(nonnull NSString *)userid index:(int)index role:(nonnull NSString *)role {
    [self.session changeSeat:userid targetRole:role targetPlayerIndex:index blk:^(int retCode) {
        if (retCode < 0) {
            NSLog(@"check capslock failed:%d", retCode);
            return;
        }
        NSLog(@"切换席位结果:%d", retCode);
    }];
}

- (void)onSyscRoomInfo {
    [self.session syncRoomInfo];
}

- (void)onsetMicMute:(nonnull NSString *)userid enable:(BOOL)index {
    [self.session setMicMute:userid micStatus:index blk:^(int retCode) {
        if (retCode < 0) {
            NSLog(@"check capslock failed:%d", retCode);
            return;
        }
        NSLog(@"禁言结果:%d", retCode);
    }];
}
    
- (AVCaptureDevice *)selectDevice {
    AVCaptureDevicePosition position = _isFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    NSArray<AVCaptureDevice *> *captureDevices;
    if (@available(iOS 10.0, *)) {
        AVCaptureDeviceDiscoverySession *session =
            [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo
                                                                    position:AVCaptureDevicePositionUnspecified];
        captureDevices = session.devices;
    } else {
        captureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    }
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == position) {
            return device;
        }
    }
    return captureDevices[0];
}
- (AVCaptureDeviceFormat *)selectFormatForDevice:(AVCaptureDevice *)device {
    NSArray<AVCaptureDeviceFormat *> *formats = device.formats;
    AVCaptureDeviceFormat *selectedFormat = nil;
    int currentDiff = INT_MAX;
    for (AVCaptureDeviceFormat *format in formats) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        FourCharCode pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription);
        int diff = abs(_captureWidth - dimension.width) + abs(_captureHeight - dimension.height);
        if (diff <= currentDiff) {
            selectedFormat = format;
            currentDiff = diff;
        } else if (_videoCapturer != nil && diff == currentDiff && pixelFormat == [_videoCapturer preferredOutputPixelFormat]) {
            selectedFormat = format;
        }
    }
    return selectedFormat;
}

#pragma mark - 手势操作
- (void)addEdgeSwipeGestures {
    // 左侧滑手势 - 返回键
    self.leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgeGesture:)];
    self.leftEdgeGesture.edges = UIRectEdgeLeft;
    self.leftEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:self.leftEdgeGesture];
    
    // 右侧滑手势 - 菜单键 (根据需求可选)
    self.rightEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightEdgeGesture:)];
    self.rightEdgeGesture.edges = UIRectEdgeRight;
    self.rightEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:self.rightEdgeGesture];
    
    // 设置手势优先级高于其他手势
    [self setGesturePriorities];
}

- (void)setGesturePriorities {
    // 确保侧滑手势优先级高于其他可能的手势
    NSArray *gestures = self.view.gestureRecognizers;
    for (UIGestureRecognizer *gesture in gestures) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]] && gesture != self.leftEdgeGesture && gesture != self.rightEdgeGesture) {
            [gesture requireGestureRecognizerToFail:self.leftEdgeGesture];
        }
    }
}

#pragma mark - Gesture Handlers

- (void)handleLeftEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        // 获取滑动距离
        CGPoint translation = [gesture translationInView:self.view];
        
        // 确认是有效的水平滑动
        if (fabs(translation.x) > 50 && fabs(translation.x) > fabs(translation.y)) {
            // 发送KEY_BACK
            [self onKeyboard:KEY_BACK];
            
            // 添加触觉反馈
            [self provideHapticFeedback];
        }
    }
}

- (void)handleRightEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        // 发送菜单键 (可选)
        [self onKeyboard:KEY_MENU];
    }
}

- (void)provideHapticFeedback {
    // 添加触觉反馈增强用户体验
    UIImpactFeedbackGenerator *feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [feedbackGenerator impactOccurred];
}

@end
