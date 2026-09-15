#import "StreamingVC.h"
#import "DemoToast.h"
#import "CAIDemoTextField.h"
#import "CAIDemoSettingView.h"
#import "CAIAudioCapturer.h"
#import "CAIDemoAccessibilityIds.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@interface StreamingVC () <TcrSessionObserver, CAIDemoTextFieldDelegate, CustomDataChannelObserver, CAIDemoSettingViewDelegate,
    TcrRenderViewObserver, UIGestureRecognizerDelegate>

// 本页创建并持有会话，退出时负责销毁
@property (nonatomic, strong) TcrSession *session;
@property (nonatomic, weak) AndroidInstance *androidInstance;
@property (nonatomic, copy) NSString *masterId;
@property (nonatomic, copy) NSArray<NSString *> *slaveIds;
// 是否演示自定义音频采集：置 NO 时由 SDK 内部采集麦克风，置 YES 时 SDK 让出麦克风，
// 改由 CAIAudioCapturer 采集并上行（采集器实现与注意事项见该类）。
@property (nonatomic, assign) BOOL enableCustomAudioCapture;
@property (nonatomic, strong) TcrRenderView *renderView;
@property (nonatomic, assign) CGSize videoStreamSize;
@property (nonatomic, assign) CGRect videoRenderFrame;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftEdgeGesture;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *rightEdgeGesture;
@property (nonatomic, strong) UIButton *settingBtn;
@property (nonatomic, strong) CAIDemoSettingView *settingView;
@property (nonatomic, strong) CAIDemoTextField *hiddenText;
@property (nonatomic, strong) UIView *keyboardBgView;
@property (nonatomic, strong) UILabel *debugLab;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) CustomDataChannel *customChannel;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) PcTouchView *pcTouchView;
@property (nonatomic, strong) MobileTouchView *mobileTouchView;
@property (nonatomic, assign) BOOL isMobile;
@property (nonatomic, assign) BOOL isStopped;
@property (strong, nonatomic) CMMotionManager *motionManager;

@end

@implementation StreamingVC

- (instancetype)initWithMasterId:(NSString *)masterId
                        slaveIds:(NSArray<NSString *> *)slaveIds {
    self = [super init];
    if (self) {
        self.masterId = masterId;
        self.slaveIds = slaveIds ?: @[];
        self.enableCustomAudioCapture = NO;
        self.androidInstance = [[TcrSdkInstance sharedInstance] getAndroidInstance];
    }
    return self;
}

- (void)dealloc {
    // 兜底：teardown 已覆盖所有正常退出路径，这里防的是初始化中途失败等异常情况
    [self destroySession];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    self.isMobile = NO;  // 云端应用为手机应用还是windows应用

    // 会话必须先建好：PcTouchView/MobileTouchView 在构造时就取走 session 弱引用，
    // 传入 nil 会导致触摸操作永久失效。
    [self startSession];

    [self initSettingView];
    [self initControlViews];
    [self initVirtualKeyboard];
    [self initDebugView];
    [self initBackButton];
    [self initLoadingView];
    [self addEdgeSwipeGestures];
    self.motionManager = [[CMMotionManager alloc] init];

    // 图层的层级要注意，影响点击事件的响应
    [self.view addSubview:self.hiddenText];
    self.renderView = [[TcrRenderView alloc] initWithFrame:self.view.bounds];
    self.renderView.accessibilityIdentifier = CAIIdStreamingRender;
    // SDK主控视图
    [self.view addSubview:self.renderView];
    // Demo业务视图
    [self.view addSubview:self.settingView];
    [self.view addSubview:self.settingBtn];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.keyboardBgView];
    [self.view addSubview:self.debugLab];
    [self.view addSubview:self.loadingView];
    [self resetVideoViewWithSize:CGSizeMake(1280, 720)];
    [self.renderView addSubview:self.pcTouchView];
    [self.renderView addSubview:self.mobileTouchView];
    [self.renderView setTcrRenderViewObserver:self];

    // 渲染目标就绪，交给 SDK 输出画面
    [self.session setRenderView:self.renderView];
}

#pragma mark - 会话生命周期

/**
 * 创建会话并接入云端实例。
 *
 * 会话在进入本页时才创建、确认出栈后销毁，上级功能页浏览期间不产生串流连接。
 * 渲染目标在视图创建完成后再通过 setRenderView: 交给 SDK。
 */
- (void)startSession {
    // 提前申请麦克风权限，避免系统在建立带录音的会话时才弹窗打断连接流程
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            NSLog(@"record permission denied");
        }
    }];

    self.session = [[TcrSdkInstance sharedInstance] createSessionWithParams:[self buildSessionConfig]];
    [self.session setTcrSessionObserver:self];

    // 有被控实例时才需要群控连接，单机主控走单实例连接更省资源
    if (self.slaveIds.count > 0) {
        NSMutableArray<NSString *> *ids = [NSMutableArray arrayWithObject:self.masterId];
        [ids addObjectsFromArray:self.slaveIds];
        [self.session accessWithInstanceIds:ids];
    } else {
        [self.session accessWithInstanceId:self.masterId];
    }
}

- (NSDictionary *)buildSessionConfig {
    NSMutableDictionary *sessionConfig = [NSMutableDictionary dictionary];
    sessionConfig[@"local_audio"] = @(0);
    sessionConfig[@"preferredCodec"] = @"H264";
    sessionConfig[@"idleThreshold"] = @(6000);
    sessionConfig[@"sessionMode"] = @"ExclusiveSession";
    if (self.enableCustomAudioCapture) {
        // 自定义音频采集：声明采集的采样率与声道数后，SDK 不再使用内部麦克风采集，
        // 由 CAIAudioCapturer 采集并通过 sendCustomAudioData:captureTimeNs: 上行。
        // 注意：自定义采集上行需要同时开启 local_audio；此处仅声明参数，
        // 实际采集在用户点"开麦克风"时才开始（onEnableLocalAudio:）。
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSInteger sampleRate = (NSInteger)[audioSession sampleRate];
        NSInteger channelCount = 1;
        [CAIAudioCapturer configureWithSampleRate:sampleRate channelCount:channelCount dumpAudio:NO];
        sessionConfig[@"enableCustomAudioCapture"] = @{@"sampleRate": @(sampleRate), @"useStereoInput": @(channelCount == 2)};
        sessionConfig[@"local_audio"] = @(1);
    }
    return sessionConfig;
}

/// 连接成功后下发群控指令：这些指令走会话的数据通道，连接建立前发送无效
- (void)onSessionConnected {
    if (self.slaveIds.count > 0) {
        [self.androidInstance setSyncList:self.slaveIds];
    }
    [self.androidInstance setMasterWithInstanceId:self.masterId];
}

- (void)destroySession {
    if (_session == nil) {
        return;
    }
    // 群控同步依赖会话的数据通道，需在销毁前撤销
    if (self.slaveIds.count > 0) {
        [self.androidInstance setSyncList:nil];
    }
    [[TcrSdkInstance sharedInstance] destroySession:_session];
    _session = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 必须在转场之后再关：UIKit 会在 push 转场收尾时重新配置返回手势，viewWillAppear 里关会被覆盖
    [self setPopGestureEnabled:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 必须在这里恢复：页面出栈后 self.navigationController 已为 nil，取不到手势
    [self setPopGestureEnabled:YES];
}

/**
 * 开关系统的侧滑返回。
 *
 * 本页是全屏串流画面：屏幕边缘滑动要映射为云端的返回键/菜单键，画面中间的滑动
 * 应当作为触摸事件透传给云端应用。系统返回手势一旦介入会直接把本页 pop 掉，
 * 因此进入本页时关闭；退出走左上角返回按钮或设置面板「结束控制」。
 */
- (void)setPopGestureEnabled:(BOOL)enabled {
    UINavigationController *nav = self.navigationController;
    nav.interactivePopGestureRecognizer.enabled = enabled;
    if (@available(iOS 26.0, *)) {
        nav.interactiveContentPopGestureRecognizer.enabled = enabled;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.motionManager stopAccelerometerUpdates];

    // 交互式返回取消时页面仍在导航栈中，不能提前销毁会话
    UINavigationController *navigationController = self.navigationController;
    if (navigationController == nil || ![navigationController.viewControllers containsObject:self]) {
        [self teardown];
    }
}

#pragma mark - 屏幕方向与全屏手势

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

/// 全屏串流页隐藏 Home 指示条，避免遮挡云端画面底部
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

/// 让系统的边缘手势（上滑回主屏、下拉通知中心）需要二次触发，
/// 优先把边缘滑动交给本页的 KEY_BACK / KEY_MENU 手势
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
    return UIRectEdgeAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // 转屏后按新的容器尺寸重排画面，否则渲染区域会停留在旧方向的比例上
        [self resetVideoViewWithSize:self.videoStreamSize];
        [self layoutOverlayViews];
    }];
}

- (void)resetVideoViewWithSize:(CGSize)videoSize {
    if (videoSize.width <= 0 || videoSize.height <= 0) {
        return;
    }
    self.videoStreamSize = videoSize;

    UIInterfaceOrientation vcOrient = [self currentInterfaceOrientation];
    BOOL needRotate = (self.isMobile && vcOrient == UIInterfaceOrientationLandscapeRight);
    UIEdgeInsets safeInsets = self.view.safeAreaInsets;
    CGFloat newWidth = 0;
    CGFloat newHeight = 0;

    if (needRotate) {
        // 手游的视频分辨率只会是 宽 < 高，当手机横屏显示时，需要将 videoView 画面逆时针旋转 90 度，
        // 因此这里按交换后的边长计算可用空间。
        newWidth = self.view.bounds.size.height - safeInsets.left - safeInsets.right;
        newHeight = self.view.bounds.size.width - safeInsets.top - safeInsets.bottom;
    } else {
        newWidth = self.view.bounds.size.width - safeInsets.left - safeInsets.right;
        newHeight = self.view.bounds.size.height - safeInsets.top - safeInsets.bottom;
    }

    // 长边对齐、短边留白，保持视频原始宽高比
    if (newWidth / newHeight < videoSize.width / videoSize.height) {
        newHeight = floor(newWidth * videoSize.height / videoSize.width);
    } else {
        newWidth = floor(newHeight * videoSize.width / videoSize.height);
    }

    self.videoRenderFrame
        = CGRectMake((self.view.bounds.size.width - newWidth) / 2, (self.view.bounds.size.height - newHeight) / 2, newWidth, newHeight);
    // 先复位再设置，避免上一次旋转的 transform 影响 frame 的解释
    self.renderView.transform = CGAffineTransformIdentity;
    [self.renderView setFrame:self.videoRenderFrame];

    [self.mobileTouchView setFrame:self.renderView.bounds];
    [self.pcTouchView setFrame:self.renderView.bounds];

    if (needRotate) {
        self.renderView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
}

/// 当前界面方向：iOS 13 起 statusBarOrientation 已废弃，改用所属 windowScene
- (UIInterfaceOrientation)currentInterfaceOrientation {
    if (@available(iOS 13.0, *)) {
        UIWindowScene *scene = self.view.window.windowScene;
        if (scene != nil) {
            return scene.interfaceOrientation;
        }
    }
    return UIInterfaceOrientationPortrait;
}

/// 重排覆盖在画面之上的操作控件（转屏后需要跟随新的容器尺寸）
- (void)layoutOverlayViews {
    CGFloat width = self.view.bounds.size.width;
    CGFloat topInset = MAX(self.view.safeAreaInsets.top, 20);

    self.backBtn.frame = CGRectMake(MAX(self.view.safeAreaInsets.left, 10), topInset, 44, 44);
    self.settingBtn.frame = CGRectMake(width - MAX(self.view.safeAreaInsets.right, 10) - 40, topInset + 7, 30, 30);
    self.debugLab.frame = CGRectMake(30, CGRectGetMaxY(self.backBtn.frame) + 4, 350, 15);

    self.settingView.frame = self.view.bounds;
    self.keyboardBgView.frame = self.view.bounds;
    self.loadingView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutOverlayViews];
}

- (void)initVirtualKeyboard {
    _hiddenText = [[CAIDemoTextField alloc] initWithFrame:CGRectMake(10, 10, 1, 1)];
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
}

// 控件位置统一由 layoutOverlayViews 计算，这里只做创建
- (void)initSettingView {
    UIButton *btn1 = [[UIButton alloc] init];
    btn1.backgroundColor = [UIColor clearColor];
    [btn1 setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    btn1.accessibilityIdentifier = CAIIdStreamingSetting;
    [btn1 addTarget:self action:@selector(settingBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    _settingView = [[CAIDemoSettingView alloc] initWithFrame:self.view.bounds];
    _settingView.delegate = self;
    _settingView.hidden = YES;

    self.settingBtn = btn1;
    self.settingBtn.hidden = YES;
}
- (void)initDebugView {
    UILabel *lab = [[UILabel alloc] init];
    lab.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
    lab.font = [UIFont systemFontOfSize:10];
    lab.textColor = [UIColor whiteColor];
    lab.textAlignment = NSTextAlignmentLeft;
    lab.accessibilityIdentifier = CAIIdStreamingStats;
    lab.hidden = YES;
    self.debugLab = lab;
}

/// 屏内返回按钮：本页禁用了系统侧滑返回，需要一个明确的退出入口
- (void)initBackButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];
    btn.layer.cornerRadius = 6;
    btn.accessibilityIdentifier = CAIIdStreamingBack;
    [btn addTarget:self action:@selector(onBackClick) forControlEvents:UIControlEventTouchUpInside];
    btn.hidden = YES;   // 首帧渲染后再显示，与设置按钮一致
    self.backBtn = btn;
}

- (void)initLoadingView {
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.loadingView.accessibilityIdentifier = CAIIdLoading;
    [self.loadingView startAnimating];
}

- (void)onBackClick {
    [self stopControl];
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

#pragma mark--- CAIDemoTextFieldDelegate ---
- (void)onClickKey:(int)keycode {
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

#pragma mark--- CAIDemoSettingViewDelegate ---
- (void)settingBtnClick:(id)sender {
    self.settingView.hidden = !self.settingView.isHidden;
}

/**
 * 主动退出串流页：「结束控制」按钮、返回按钮与 STATE_CLOSED 都走这里。
 *
 * 只负责触发出栈，真正的清理放在 teardown（确认页面已出栈后由 viewDidDisappear 驱动），
 * 这样返回按钮与异常关闭都收敛到同一条路径上。
 */
- (void)stopControl {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.navigationController != nil && self.navigationController.topViewController == self) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            // 不在栈顶（极端情况：已被其他页面顶掉）时至少保证会话被回收
            [self teardown];
        }
    });
}

/// 释放本页持有的全部资源，幂等
- (void)teardown {
    if (self.isStopped) {
        return;
    }
    self.isStopped = YES;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[CAIAudioCapturer sharedCapturer] stopAudioCapture];
    [self.motionManager stopAccelerometerUpdates];
    [self.session setRenderView:nil];
    [self.renderView removeFromSuperview];

    self.leftEdgeGesture.delegate = nil;
    self.rightEdgeGesture.delegate = nil;
    self.hiddenText.keyCodedelegate = nil;
    self.settingView.delegate = nil;

    self.renderView = nil;
    self.leftEdgeGesture = nil;
    self.rightEdgeGesture = nil;

    [self.customChannel close];
    self.customChannel = nil;

    // 会话由本页创建，退出即销毁，不把连接留给上级页面
    [self destroySession];
}

#pragma mark 云应用交互测试
- (void)restartCloudApp {
    [self.session restartCloudApp];
}
- (void)pasteText {
    [self.session pasteText:@"123"];
}
- (void)modifyRES {
    [self.session setRemoteDesktopResolution:1080 height:1920];
}

// 分发安装指定包名的App到云手机实例，分发结果通过 DISTRIBUTE_STATUS_CHANGED 事件通知
- (void)distributeApp {
    [self.session distributeApp:@"com.cszc.lywlttt"];
    [DemoToast showInViewController:self message:@"已分发App: com.cszc.lywlttt"];
}

#pragma mark+++ 键鼠与光标
- (void)openKeyboard:(BOOL)isOpen {
    if (isOpen) {
        self.pcTouchView.hidden = NO;
        [self.pcTouchView setCursorTouchMode:TCRMouseCursorTouchMode_RelativeTouch];
        [self.pcTouchView setCursorImage:[UIImage imageNamed:@"default_cursor"] andRemoteFrame:CGRectMake(0, 0, 32, 32)];
        [self.pcTouchView setCursorIsShow:YES];
    } else {
        self.pcTouchView.hidden = YES;
    }
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
        [DemoToast showInViewController:self message:(retCode == 1 ? @"云端打开大写锁定" : @"云端关闭大写锁定")];
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
    int max = 2 * 1024;
    int min = 1 * 1024;
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
            break;
        default:
            break;
    }
    // 保持当前分辨率不变，仅调整帧率与码率；分辨率参数需落在 SDK 要求的 [128,1920] 内
    int width = (int)round(self.videoStreamSize.width);
    int height = (int)round(self.videoStreamSize.height);
    width = MIN(MAX(width, 128), 1920);
    height = MIN(MAX(height, 128), 1920);
    [self.session setRemoteVideoProfile:fps minBitrate:min maxBitrate:max width:width height:height];
}

- (void)pauseResumeControl:(BOOL)doPause {
    doPause ? [self.session pauseStreaming] : [self.session resumeStreaming];
}

- (void)onEnableLocalAudio:(BOOL)enable {
    // 自定义音频采集模式下，开/关麦克风需要同步启停本地采集器；
    // 未启用自定义采集时 sharedCapturer 返回 nil，以下调用为空操作。
    if (enable) {
        [[CAIAudioCapturer sharedCapturer] startAudioCapture:self.session];
    } else {
        [[CAIAudioCapturer sharedCapturer] stopAudioCapture];
    }
    [self.session setEnableLocalAudio:enable];
}

- (void)onEnableLocalVideo:(BOOL)enable {
    [self.session setEnableLocalVideo:enable];
}

- (void)onSwitchCamera:(BOOL)isFrontCamera {
    [self.session setLocalVideoProfile:1280 height:720 fps:30 minBitrate:1000 maxBitrate:5000 isFrontCamera:isFrontCamera];
}

/// 设置面板「旋转画面」：在当前方向基础上把渲染视图再逆时针转 90 度
- (void)onRotateView {
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

#pragma mark--- TCRSessionObserver ---
- (void)onEvent:(TcrEvent)event eventData:(id)eventData {
    // teardown 之后仍会收到事件：destroySession 会触发 SDK 异步投递 STATE_CLOSED，
    // 此时页面已出栈，继续处理会弹出无意义的告警框并操作已失效的视图。
    if (self.isStopped) {
        return;
    }

    NSDictionary *info;
    NSArray *array;
    CGRect rect;
    switch (event) {
        case STATE_CONNECTED:
            NSLog(@"requestId = %@", [_session getRequestId]);
            [DemoToast showInViewController:self message:@"连接成功"];
            [self onSessionConnected];
            break;
        case STATE_RECONNECTING:
            [DemoToast showInViewController:self message:@"重连中"];
            break;
        case STATE_CLOSED: {
            // 会话已终止且不可复用，直接退出串流页销毁会话，避免死会话继续占用云端资源
            NSInteger code = [eventData respondsToSelector:@selector(integerValue)] ? [eventData integerValue] : 0;
            NSLog(@"session closed with code: %ld", (long)code);
            [DemoToast showInViewController:self message:[NSString stringWithFormat:@"会话关闭，错误码:%ld", (long)code]];
            [self stopControl];
            break;
        }
        case VIDEO_STREAM_CONFIG_CHANGED: {
            NSLog(@"ApiTest 分辨率变化:%@", (NSString *)eventData);
            info = (NSDictionary *)eventData;
            CGFloat width = [info[@"width"] doubleValue];
            CGFloat height = [info[@"height"] doubleValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self resetVideoViewWithSize:CGSizeMake(width, height)];
            });
            break;
        }
        case IME_TYPE: {
            info = (NSDictionary *)eventData;
            NSString* imeType = (NSString *)info[@"ime_type"];
            NSLog(@"ApiTest 输入法类型:%@", imeType);
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
        case CURSOR_IMAGE_INFO: {
            info = (NSDictionary *)eventData;
            array = info[@"imageFrame"];
            rect = CGRectMake([array[0] floatValue], [array[1] floatValue], [array[2] floatValue], [array[3] floatValue]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.pcTouchView setCursorImage:info[@"image"] andRemoteFrame:rect];
            });
            break;
        }
        case CLIENT_STATS:
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
        case GAME_START_COMPLETE:
            NSLog(@"ApiTest 游戏拉起:%@", (NSString *)eventData);
            break;
        case DISTRIBUTE_STATUS_CHANGED:
            info = (NSDictionary *)eventData;
            NSLog(@"ApiTest 分发状态变化:%@", info);
            [DemoToast showInViewController:self message:[NSString stringWithFormat:@"分发状态:%@", info[@"state"]]];
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

#pragma mark--- CAICustomTransChannelDelegate ---
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
        self.backBtn.hidden = NO;
        self.settingBtn.hidden = NO;
        self.debugLab.hidden = NO;
        [self.renderView setEnablePinch:YES];
        [self.loadingView stopAnimating];
    });
}

#pragma mark--- 手势操作 ---

/**
 * 边缘滑动映射到云端的返回键与菜单键。
 *
 * 系统侧滑返回已由 setPopGestureEnabled: 关闭，边缘手势归云端独占；
 * 退出本页请使用左上角返回按钮或设置面板的「结束控制」。
 */
- (void)addEdgeSwipeGestures {
    // 左侧滑 -> 返回键
    self.leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgeGesture:)];
    self.leftEdgeGesture.edges = UIRectEdgeLeft;
    self.leftEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:self.leftEdgeGesture];

    // 右侧滑 -> 菜单键
    self.rightEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightEdgeGesture:)];
    self.rightEdgeGesture.edges = UIRectEdgeRight;
    self.rightEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:self.rightEdgeGesture];
}

- (void)handleLeftEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateEnded) {
        return;
    }
    // 只认水平方向的有效滑动，避免竖向滑动被误判为返回
    CGPoint translation = [gesture translationInView:self.view];
    if (fabs(translation.x) > 50 && fabs(translation.x) > fabs(translation.y)) {
        [self onKeyboard:KEY_BACK];
        [self provideHapticFeedback];
    }
}

- (void)handleRightEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self onKeyboard:KEY_MENU];
    }
}

- (void)provideHapticFeedback {
    UIImpactFeedbackGenerator *feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [feedbackGenerator impactOccurred];
}

@end
