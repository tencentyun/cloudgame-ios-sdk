//
//  CAIDemoExperienceVC.m
//  CAIDemo
//
//  Created by LyleYu on 2021/6/22.
//

#import "CAIDemoLoginVC.h"
#import "CAIDemoLoginInputText.h"
#import "CAIDemoUtils.h"
#import "CAIDemoMasterControlVC.h"
#import "CAIDemoLoadingView.h"
#import "CAIDemoInstanceListVC.h"
#import <TCRSDK/TCRSDK.h>


// 体验服务器（测试环境），路径前缀 /external 与 Android 端 ExpServerRequest 对齐
static NSString *kHostBaseUrl = @"https://test-cai-experience-server.crtrcloud.com/external";

@interface CAIDemoLoginVC()<CAIDemoInputDelegate, TCRLogDelegate> {
    UIImageView *_bgView;
    UIView *_loginWindowView;
    CAGradientLayer *_loginBgLayer;
    UIView *_keyboardBgView;
    NSMutableDictionary *_experienceCfg;

    BOOL _isSimpleMode;

    // 登录模式：NO=账号密码登录，YES=Token+AccessInfo登录
    BOOL _isTokenMode;
    UIButton *_accountModeBtn;   // 账号密码模式
    UIButton *_tokenModeBtn;     // Token模式
    UIView *_accountContentView; // 账号密码输入区
    UIView *_tokenContentView;   // Token/AccessInfo输入区

    UIScrollView *_usernameInputScrollView;
    CAIDemoLoginInputText *_usernameTxt;
    
    UIScrollView *_passwordInputScrollView;
    CAIDemoLoginInputText *_passwordCodeTxt;

    UIScrollView *_tokenInputScrollView;
    CAIDemoLoginInputText *_tokenTxt;

    UIScrollView *_accessInfoInputScrollView;
    CAIDemoLoginInputText *_accessInfoTxt;
    
    CGFloat _keyboardTop;
    UIView *_currentInputView;
    UIView *_advanceContentView;
    CAIDemoLoadingView *_loadingView;
    NSString *_userId;
    NSNumber* _idleThreshold;
    NSString *_token;
    NSString *_accessInfo;
    NSMutableArray* instanceIds;
    
    UIButton *_startBtn;
}

// 登录模式切换
- (void)setupLoginModeUI;
- (void)switchLoginMode:(BOOL)tokenMode;

// Token 登录：解析 AccessInfo 中的实例 ID
- (void)handleTokenLogin;
- (NSMutableArray *)parseInstanceIdsFromAccessInfo:(NSString *)accessInfo;

// 登录完成后进入实例列表页
- (void)gotoInstanceListVC;

@end

@implementation CAIDemoLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _experienceCfg = [self loadConfig];
    [self initSubviews];
    [self keyboardWillHide:nil];    // 更新StartBtn的背景色
    
    [TcrSdkInstance setLogger:self withMinLevel:TCRLogLevelInfo];
    
    [self.view addSubview:_bgView];
    [self.view addSubview:_loginWindowView];
    [self.view addSubview:_keyboardBgView];
    [self.view addSubview:_loadingView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)dealloc {

}

- (void)initSubviews {
    _bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_bg"]];
    _bgView.frame = self.view.bounds;

    _loginWindowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 275, 300)];
    _loginBgLayer = [CAGradientLayer layer];
    _loginBgLayer.frame = _loginWindowView.bounds;
    _loginBgLayer.startPoint = CGPointMake(0, 0);
    _loginBgLayer.endPoint = CGPointMake(0, 1);
    _loginBgLayer.colors = @[(__bridge id)[CAIDemoUtils CAI_colorValue:@"1B4C9A"].CGColor,
                        (__bridge id)[CAIDemoUtils CAI_colorValue:@"0D2C61"].CGColor];
    _loginBgLayer.locations = @[@(0.0f), @(1.0f)];
    [_loginWindowView.layer addSublayer:_loginBgLayer];
    _loginWindowView.center = self.view.center;
    _loginWindowView.backgroundColor = [UIColor clearColor];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CAI_cloud"]];
    iconView.frame = CGRectMake(41.5, 8, 192.5, 60);
    [_loginWindowView addSubview:iconView];

    // 登录模式切换
    [self setupLoginModeUI];

    // ===== 账号密码登录输入区 =====
    _accountContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 275, 90)];
    [_loginWindowView addSubview:_accountContentView];

    // 账号（上次登录成功后本地保存，首次启动为空）
    NSString *username = [[_experienceCfg objectForKey:@"user"] objectForKey:@"UserId"];
    _usernameTxt = [[CAIDemoLoginInputText alloc] initWithFrame:CGRectMake(0, 0, 225, 22.5)
                                                                  name:@"用户名"
                                                               oldValue:username];
    _usernameTxt.inputDelegate = self;
    _usernameInputScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(25, 0, 225, 22.5)];
    _usernameInputScrollView.contentSize = _usernameTxt.bounds.size;
    [_usernameInputScrollView addSubview:_usernameTxt];
    [_accountContentView addSubview:_usernameInputScrollView];
    
    // 密码（上次登录成功后本地保存，首次启动为空）
    NSString *password = [[_experienceCfg objectForKey:@"user"] objectForKey:@"Password"];
    _passwordCodeTxt = [[CAIDemoLoginInputText alloc] initWithFrame:CGRectMake(0, 0, 225, 22.5)
                                                                  name:@"密码"
                                                               oldValue:password];
    _passwordCodeTxt.inputDelegate = self;
    _passwordInputScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(25, 32, 225, 22.5)];
    _passwordInputScrollView.contentSize = _passwordCodeTxt.bounds.size;
    [_passwordInputScrollView addSubview:_passwordCodeTxt];
    [_accountContentView addSubview:_passwordInputScrollView];

    // ===== Token + AccessInfo 登录输入区 =====
    _tokenContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 275, 130)];
    _tokenContentView.hidden = YES;
    [_loginWindowView addSubview:_tokenContentView];

    // 默认无凭证，请填入业务侧申请到的 Token/AccessInfo
    NSString *defaultToken = @"";
    NSString *defaultAccessInfo = @"";

    _tokenTxt = [[CAIDemoLoginInputText alloc] initWithFrame:CGRectMake(0, 0, 225, 22.5)
                                                          name:@"Token"
                                                     oldValue:defaultToken];
    _tokenTxt.inputDelegate = self;
    _tokenInputScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(25, 0, 225, 22.5)];
    _tokenInputScrollView.contentSize = _tokenTxt.bounds.size;
    [_tokenInputScrollView addSubview:_tokenTxt];
    [_tokenContentView addSubview:_tokenInputScrollView];

    // AccessInfo 为多行长文本，使用支持多行的输入框
    _accessInfoTxt = [[CAIDemoLoginInputText alloc] initWithFrame:CGRectMake(0, 0, 225, 95)
                                                               name:@"AccessInfo"
                                                          oldValue:defaultAccessInfo
                                                           height:95
                                                        multiline:YES];
    _accessInfoTxt.inputDelegate = self;
    _accessInfoInputScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(25, 32, 225, 95)];
    _accessInfoInputScrollView.contentSize = _accessInfoTxt.bounds.size;
    [_accessInfoInputScrollView addSubview:_accessInfoTxt];
    [_tokenContentView addSubview:_accessInfoInputScrollView];

    // ===== 启动按钮 =====
    _startBtn = [[UIButton alloc] initWithFrame:CGRectMake(25, 258, 225, 22.5)];
    _startBtn.backgroundColor = [CAIDemoUtils CAI_colorValue:@"006EFF20"];
    [_startBtn setTitle:@"启动" forState:UIControlStateNormal];
    [_startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_startBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:8]];
    [_startBtn addTarget:self action:@selector(startExpericence) forControlEvents:UIControlEventTouchUpInside];
    [_loginWindowView addSubview:_startBtn];
    _startBtn.backgroundColor = [CAIDemoUtils CAI_colorValue:@"006EFF20"];

    _keyboardBgView = [[UIView alloc] initWithFrame:self.view.bounds];
    _keyboardBgView.backgroundColor = [UIColor clearColor];
    _keyboardBgView.userInteractionEnabled = YES;
    _keyboardBgView.hidden = YES;

    UITapGestureRecognizer *singleClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboard:)];
    [_keyboardBgView addGestureRecognizer:singleClick];
    
    _loadingView = [[CAIDemoLoadingView alloc] initWithFrame:self.view.bounds process:0];
    _loadingView.hidden = YES;
}

// 登录模式切换 UI（账号密码 / Token+AccessInfo）
- (void)setupLoginModeUI {
    UIFont *modeFont = [UIFont systemFontOfSize:12];

    _accountModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_accountModeBtn setTitle:@"账号登录" forState:UIControlStateNormal];
    [_accountModeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _accountModeBtn.titleLabel.font = modeFont;
    [_accountModeBtn setImage:[UIImage imageNamed:@"login_radio_selected"] forState:UIControlStateNormal];
    _accountModeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_accountModeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
    [_accountModeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_accountModeBtn addTarget:self action:@selector(switchToAccountMode) forControlEvents:UIControlEventTouchUpInside];

    _tokenModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_tokenModeBtn setTitle:@"Tok登录" forState:UIControlStateNormal];
    [_tokenModeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _tokenModeBtn.titleLabel.font = modeFont;
    [_tokenModeBtn setImage:[UIImage imageNamed:@"login_radio_unselected"] forState:UIControlStateNormal];
    _tokenModeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_tokenModeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
    [_tokenModeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_tokenModeBtn addTarget:self action:@selector(switchToTokenMode) forControlEvents:UIControlEventTouchUpInside];

    // 显式约束按钮尺寸，避免 StackView 下 intrinsic size 过大
    [_accountModeBtn.widthAnchor constraintEqualToConstant:96].active = YES;
    [_accountModeBtn.heightAnchor constraintEqualToConstant:28].active = YES;
    [_tokenModeBtn.widthAnchor constraintEqualToConstant:96].active = YES;
    [_tokenModeBtn.heightAnchor constraintEqualToConstant:28].active = YES;
    _accountModeBtn.imageView.bounds = CGRectMake(0, 0, 18, 18);
    _tokenModeBtn.imageView.bounds = CGRectMake(0, 0, 18, 18);

    // 用水平 StackView 排布，按钮尺寸已由上面约束固定，避免显示过大
    UIStackView *modeSwitch = [[UIStackView alloc] initWithArrangedSubviews:@[_accountModeBtn, _tokenModeBtn]];
    modeSwitch.axis = UILayoutConstraintAxisHorizontal;
    modeSwitch.spacing = 14;
    modeSwitch.alignment = UIStackViewAlignmentCenter;
    modeSwitch.distribution = UIStackViewDistributionEqualCentering;
    modeSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    // 先加入视图层级，再激活约束，避免“无共同祖先”崩溃
    [_loginWindowView addSubview:modeSwitch];
    [modeSwitch.arrangedSubviews enumerateObjectsUsingBlock:^(UIView *v, NSUInteger idx, BOOL *stop) {
        [v setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }];
    [modeSwitch.widthAnchor constraintLessThanOrEqualToConstant:240].active = YES;
    [modeSwitch.centerXAnchor constraintEqualToAnchor:_loginWindowView.centerXAnchor].active = YES;
    [modeSwitch.topAnchor constraintEqualToAnchor:_loginWindowView.topAnchor constant:74].active = YES;
}

// 切换到账号密码登录模式
- (void)switchToAccountMode {
    [self switchLoginMode:NO];
}

// 切换到 Token 登录模式
- (void)switchToTokenMode {
    [self switchLoginMode:YES];
}

- (void)switchLoginMode:(BOOL)tokenMode {
    _isTokenMode = tokenMode;
    [_accountModeBtn setImage:[UIImage imageNamed:tokenMode ? @"login_radio_unselected" : @"login_radio_selected"]
                     forState:UIControlStateNormal];
    [_tokenModeBtn setImage:[UIImage imageNamed:tokenMode ? @"login_radio_selected" : @"login_radio_unselected"]
                   forState:UIControlStateNormal];
    _accountContentView.hidden = tokenMode;
    _tokenContentView.hidden = !tokenMode;
    [self keyboardWillHide:nil];
}

- (void)onBeginEditing:(UIView *)view {
    if (_keyboardTop != 0) {
        [self moveView:view toTopKeyboard:_keyboardTop];
    } else {
        _currentInputView = view;
    }
}

- (void)moveView:(UIView *)view toTopKeyboard:(CGFloat)keyboardTop {
    CGRect frame = [view convertRect:view.frame toView:self.view];
    CGFloat bottom = frame.origin.y + frame.size.height;
    if (bottom > keyboardTop) {
        CGFloat offset = bottom - keyboardTop;
        _loginWindowView.transform = CGAffineTransformMakeTranslation(0, -offset);
    }
    _currentInputView = nil;
    _keyboardTop = 0;
}

- (void)keyboardWillShow:(NSNotification *)notificationP {
    NSValue *aValue = [notificationP.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyTop = keyboardRect.origin.y;
    if (_currentInputView != nil) {
        [self moveView:_currentInputView toTopKeyboard:keyTop];
    } else {
        _keyboardTop = keyTop;
    }
    _keyboardBgView.hidden = NO;
}

- (void)keyboardWillHide:(NSNotification *)notificationP {
    _keyboardBgView.hidden = YES;
    BOOL canStart = NO;
    if (_isTokenMode) {
        canStart = ([[_tokenTxt text] length] > 0 && [[_accessInfoTxt text] length] > 0);
    } else {
        canStart = ([[_usernameTxt text] length] > 0 && [[_passwordCodeTxt text] length] > 0);
    }
    if (canStart) {
        _startBtn.backgroundColor = [CAIDemoUtils CAI_colorValue:@"006EFF"];
        [_startBtn setEnabled:YES];
    } else {
        _startBtn.backgroundColor = [CAIDemoUtils CAI_colorValue:@"006EFF20"];
        [_startBtn setEnabled:NO];
    }
    _loginWindowView.transform = CGAffineTransformIdentity;
}

- (void)hiddenKeyboard:(UITapGestureRecognizer *)tapGesture
{
    [_loginWindowView endEditing:YES];
}

- (void)showToast:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        int duration = 2; // duration in seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (void)startExpericence {
    _loadingView.hidden = NO;
    [_loadingView setProcessValue:0];

    if (_isTokenMode) {
        // Token + AccessInfo 登录：解析 AccessInfo 中的实例 ID 后直接进入实例列表页
        [self handleTokenLogin];
        return;
    }

    NSString *username = [_usernameTxt text];
    NSString *password = [_passwordCodeTxt text];
    
    // 记住账号信息
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:username forKey:@"UserId"];
    [params setObject:password forKey:@"Password"];
    [_experienceCfg setObject:params forKey:@"user"];
    [self saveConfig:_experienceCfg];
    
    [params setObject:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
    
    __weak typeof(self) weakSelf = self;
#pragma mark +++ 流程(01)：登录云手机平台
    NSString *loginUrl = [kHostBaseUrl stringByAppendingString:@"/Login"];
    [CAIDemoUtils CAI_postUrl:loginUrl params:params finishBlk:^(NSData *data, NSURLResponse *response, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (error != nil || data == nil) {
            [strongSelf showToast:[NSString stringWithFormat:@"登录云手机平台失败:%@", error.userInfo.description]];
            [strongSelf stopLoading];
            return;
        }
        NSError *err = nil;
        id dataJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (err != nil || ![dataJson isKindOfClass:[NSDictionary class]]) {
            [strongSelf showToast:[NSString stringWithFormat:@"登录云手机平台失败:%@", err.userInfo.description]];
            [strongSelf stopLoading];
            return;
        }

        NSDictionary *dataObj = (NSDictionary *) dataJson;
        NSDictionary *loginResp = dataObj[@"Response"];
        if (![loginResp isKindOfClass:[NSDictionary class]] || loginResp[@"Error"] != nil) {
            NSLog(@"Login failed: %@", dataObj);
            [strongSelf showToast:@"登录云手机平台失败，请检查账号与密码"];
            [strongSelf stopLoading];
            return;
        }
        NSLog(@"Login success: %@", dataObj);

#pragma mark +++ 流程(02)：登录成功，进入实例列表页（实例查询与会话创建都在列表页完成）
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf stopLoading];
            [strongSelf gotoInstanceListVC];
        });
    }];
}

#pragma mark +++ Token 登录：解析 AccessInfo 中的实例 ID 后进入实例列表页

- (void)handleTokenLogin {
    NSString *token = [_tokenTxt text];
    NSString *accessInfo = [_accessInfoTxt text];
    if (token.length == 0) {
        [self showToast:@"请输入 Token"];
        [self stopLoading];
        return;
    }
    if (accessInfo.length == 0) {
        [self showToast:@"请输入 AccessInfo"];
        [self stopLoading];
        return;
    }
    NSMutableArray *ids = [self parseInstanceIdsFromAccessInfo:accessInfo];
    if (ids.count == 0) {
        [self showToast:@"无法从 AccessInfo 中解析实例 ID"];
        [self stopLoading];
        return;
    }
    _token = token;
    _accessInfo = accessInfo;
    instanceIds = ids;
    [self stopLoading];
    [self gotoInstanceListVC];
}

// 从 AccessInfo（JSON 或 Base64 编码 JSON）中解析实例 ID 列表
- (NSMutableArray *)parseInstanceIdsFromAccessInfo:(NSString *)accessInfo {
    NSMutableArray *ids = [NSMutableArray new];
    if (accessInfo.length == 0) {
        return ids;
    }
    NSString *jsonPayload = [accessInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![jsonPayload hasPrefix:@"{"]) {
        // 尝试 Base64 解码
        NSData *decoded = [[NSData alloc] initWithBase64EncodedString:accessInfo
                                                              options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (decoded != nil) {
            jsonPayload = [[NSString alloc] initWithData:decoded encoding:NSUTF8StringEncoding];
        }
    }
    NSData *jsonData = [jsonPayload dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData == nil) {
        return ids;
    }
    NSError *err = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
    if (err != nil || ![jsonObj isKindOfClass:[NSDictionary class]]) {
        NSLog(@"解析 AccessInfo 失败: %@", err.userInfo.description);
        return ids;
    }
    NSArray *accessArray = jsonObj[@"AccessInfo"];
    if (![accessArray isKindOfClass:[NSArray class]]) {
        return ids;
    }
    for (NSDictionary *zoneInfo in accessArray) {
        if (![zoneInfo isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSArray *instanceIdArray = zoneInfo[@"InstanceIds"];
        if (![instanceIdArray isKindOfClass:[NSArray class]]) {
            continue;
        }
        for (NSString *instanceId in instanceIdArray) {
            if (instanceId.length > 0 && ![ids containsObject:instanceId]) {
                [ids addObject:instanceId];
            }
        }
    }
    return ids;
}


#pragma mark +++ 进入实例列表页（实例勾选与会话创建均由列表页负责）
- (void)gotoInstanceListVC {
    CAIDemoInstanceListVC *listVC = [[CAIDemoInstanceListVC alloc] initWithHostBaseUrl:kHostBaseUrl
                                                                                 token:_isTokenMode ? _token : nil
                                                                            accessInfo:_isTokenMode ? _accessInfo : nil
                                                                           instanceIds:_isTokenMode ? instanceIds : nil];
    if (self.navigationController != nil) {
        [self.navigationController pushViewController:listVC animated:YES];
    } else {
        listVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:listVC animated:YES completion:nil];
    }
}

- (NSMutableDictionary *)loadConfig {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *cfgDic = [user objectForKey:@"CAIDEMO_EXPERIENCE_CFG"];
    if (cfgDic == nil || ![cfgDic isKindOfClass:[NSDictionary class]]) {
        cfgDic = [NSDictionary new];
    }
    return [cfgDic mutableCopy];
}

- (void)saveConfig:(NSDictionary *)cfgDic {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:cfgDic forKey:@"CAIDEMO_EXPERIENCE_CFG"];
}

- (void)stopLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_loadingView.hidden = YES;
    });
}

- (void)logWithLevel:(TCRLogLevel)logLevel log:(NSString *_Nullable)log {
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


@end
