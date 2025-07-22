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
#import "CAIDemoGroupControlVC.h"
#import "utils/CAIDemoAudioCapturor.h"
#import <AVFoundation/AVFoundation.h>
#import <TCRSDK/TCRSDK.h>


#define TEST_EXPERI 1
#ifdef TEST_EXPERI
static NSString *kHostBaseUrl = @"https://test-cai-server.cloud-device.crtrcloud.com";
#else
static NSString *kHostBaseUrl = @"https://cai-server.cloud-device.crtrcloud.com";
#endif
@interface CAIDemoLoginVC()<CAIDemoInputDelegate, TCRAudioSessionDelegate, TCRLogDelegate, TcrSessionObserver> {
    UIImageView *_bgView;
    UIView *_loginWindowView;
    CAGradientLayer *_loginBgLayer;
    UIView *_keyboardBgView;
    NSMutableDictionary *_experienceCfg;

    BOOL _isSimpleMode;
    UIButton *_simpleModeBtn;
    UIButton *_advanceModeBtn;

    UIScrollView *_usernameInputScrollView;
    CAIDemoLoginInputText *_usernameTxt;
    
    UIScrollView *_passwordInputScrollView;
    CAIDemoLoginInputText *_passwordCodeTxt;
    
    CGFloat _keyboardTop;
    UIView *_currentInputView;
    UIView *_advanceContentView;
    CAIDemoLoadingView *_loadingView;
    NSString *_userId;
    BOOL _enableCustomAudioCapture;
    NSNumber* _idleThreshold;
    NSString *_token;
    NSString *_accessInfo;
    NSMutableArray* instanceIds;
    
    UIButton *_startBtn;
}
@property(nonatomic, strong) TcrSession *session;

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

    _loginWindowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 275, 216)];
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
    iconView.frame = CGRectMake(41.5, 5, 192.5, 60);
    [_loginWindowView addSubview:iconView];

    NSString *username = [[_experienceCfg objectForKey:@"user"] objectForKey:@"UserId"];
    _usernameTxt = [[CAIDemoLoginInputText alloc] initWithFrame:CGRectMake(0, 0, 225, 22.5)
                                                                  name:@"用户名"
                                                               oldValue:username];
    _usernameTxt.inputDelegate = self;
    
    _usernameInputScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(25, 100, 300, 22.5)];
    _usernameInputScrollView.contentSize = _usernameTxt.bounds.size;
    [_usernameInputScrollView addSubview:_usernameTxt];
    [_loginWindowView addSubview:_usernameInputScrollView];
    
    NSString *password = [[_experienceCfg objectForKey:@"user"] objectForKey:@"Password"];
    _passwordCodeTxt = [[CAIDemoLoginInputText alloc] initWithFrame:CGRectMake(0, 0, 300, 22.5)
                                                                  name:@"密码"
                                                               oldValue:password];
    _passwordCodeTxt.inputDelegate = self;
    
    _passwordInputScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(25, 130, 225, 22.5)];
    _passwordInputScrollView.contentSize = _passwordCodeTxt.bounds.size;
    [_passwordInputScrollView addSubview:_passwordCodeTxt];
    [_loginWindowView addSubview:_passwordInputScrollView];

    _startBtn = [[UIButton alloc] initWithFrame:CGRectMake(25, 165, 225, 22.5)];
    _startBtn.backgroundColor = [CAIDemoUtils CAI_colorValue:@"006EFF"];
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
    _enableCustomAudioCapture = true;
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
    if ([[_usernameTxt text] length] > 0 && [[_passwordCodeTxt text] length] > 0) {
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
            [strongSelf stopConnectCAI];
            return;
        }
        NSError *err = nil;
        id dataJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (err != nil || ![dataJson isKindOfClass:[NSDictionary class]]) {
            [strongSelf showToast:[NSString stringWithFormat:@"登录云手机平台失败:%@", err.userInfo.description]];
            [strongSelf stopConnectCAI];
            return;
        }
        
        NSDictionary *dataObj = (NSDictionary *) dataJson;
        NSLog(@"Login success: %@", dataObj);
        
#pragma mark +++ 流程(02)：查询实例列表
        NSString *describeAndroidInstancesUrl = [kHostBaseUrl stringByAppendingString:@"/DescribeAndroidInstances"];
        NSDictionary *describeAndroidInstancesParams = @{
            @"InstanceIds":@[],
            @"Limit":@(100),
            @"Offset":@(0),
            @"AndroidInstanceZone":@"ap-hangzhou-ec-1",
            @"RequestId":[[NSUUID UUID] UUIDString]
        };
        NSLog(@"describeAndroidInstancesParams: %@", describeAndroidInstancesParams);
        [CAIDemoUtils CAI_postUrl:describeAndroidInstancesUrl params:describeAndroidInstancesParams finishBlk:^(NSData *data, NSURLResponse *response, NSError *error) {
            __strong typeof(weakSelf) strongSelf2 = weakSelf;
            if (!strongSelf2) return;
            
            if (error != nil || data == nil) {
                [strongSelf2 showToast:[NSString stringWithFormat:@"查询安卓实例失败:%@", error.userInfo.description]];
                [strongSelf2 stopConnectCAI];
                return;
            }
            NSError *err = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            if (err != nil || ![json isKindOfClass:[NSDictionary class]]) {
                [strongSelf2 showToast:[NSString stringWithFormat:@"查询安卓实例失败:%@", err.userInfo.description]];
                [strongSelf2 stopConnectCAI];
                return;
            }
            NSDictionary *jsonObj = (NSDictionary *) json;
            // 请求失败
            if ([jsonObj objectForKey:@"Response"] == nil) {
                NSLog(@"DescribeAndroidInstances failed: %@", jsonObj);
                return;
            }
            
            NSLog(@"DescribeAndroidInstances success: %@", jsonObj);
            jsonObj = jsonObj[@"Response"];
            
#pragma mark +++ 流程(03)：解析Android实例ID
            NSNumber* instancesCount = jsonObj[@"TotalCount"];
            NSArray *androidInstances = jsonObj[@"AndroidInstances"];
            strongSelf2->instanceIds = [NSMutableArray new];
            for (int i = 0; i < androidInstances.count; ++i) {
                [strongSelf2->instanceIds addObject:androidInstances[i][@"AndroidInstanceId"]];
            }
            
#pragma mark +++ 流程(04)：调用 CreateAndroidInstancesAccessToken 请求
            NSString *createAndroidInstancesAccessTokenUrl = [kHostBaseUrl stringByAppendingString:@"/CreateAndroidInstancesAccessToken"];
            NSMutableDictionary *createAndroidInstancesAccessTokenParams = [NSMutableDictionary new];
            [createAndroidInstancesAccessTokenParams setObject:strongSelf2->instanceIds forKey:@"AndroidInstanceIds"];
            [createAndroidInstancesAccessTokenParams setObject:@"12h" forKey:@"ExpirationDuration"];
            [createAndroidInstancesAccessTokenParams setObject:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
            NSLog(@"createAndroidInstancesAccessTokenParams: %@", createAndroidInstancesAccessTokenParams);
            
            [CAIDemoUtils CAI_postUrl:createAndroidInstancesAccessTokenUrl params:createAndroidInstancesAccessTokenParams finishBlk:^(NSData *data, NSURLResponse *response, NSError *error) {
                __strong typeof(weakSelf) strongSelf3 = weakSelf;
                if (!strongSelf3) return;
                
                if (error != nil || data == nil) {
                    [strongSelf3 showToast:[NSString stringWithFormat:@"创建安卓实例失败:%@", error.userInfo.description]];
                    [strongSelf3 stopConnectCAI];
                    return;
                }
                NSError *err = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
                if (err != nil || ![json isKindOfClass:[NSDictionary class]]) {
                    [strongSelf3 showToast:[NSString stringWithFormat:@"创建安卓实例失败:%@", err.userInfo.description]];
                    [strongSelf3 stopConnectCAI];
                    return;
                }
                NSDictionary *jsonObj = (NSDictionary *) json;
                // 请求失败
                if ([jsonObj objectForKey:@"Response"] == nil) {
                    NSLog(@"CreateAndroidInstancesAccessToken failed: %@", jsonObj);
                    return;
                }
                
                NSLog(@"CreateAndroidInstancesAccessToken success: %@", jsonObj);
                jsonObj = jsonObj[@"Response"];
                
#pragma mark +++ 流程(05)：获取Token和AccessInfo
                strongSelf3->_token = jsonObj[@"Token"];
                strongSelf3->_accessInfo = jsonObj[@"AccessInfo"];
                
#pragma mark +++ 流程(06)：给TcrSdk设置Token与AccessInfo，用于云手机请求
                TcrConfig* tcrConfig = [[TcrConfig alloc] initWithToken:strongSelf3->_token accessInfo:strongSelf3->_accessInfo];
                NSError *tcrErr = nil;
                [[TcrSdkInstance sharedInstance] setTcrConfig:tcrConfig error:&tcrErr];
                if (tcrErr != nil) {
                    [strongSelf3 showToast:[NSString stringWithFormat:@"TcrSdk 设置AccessInfo和Token失败:%@", tcrErr.userInfo.description]];
                    [strongSelf3 stopConnectCAI];
                    return;
                }
                NSLog(@"TcrSdk setTcrConfig success.");
                
#pragma mark +++ 流程(07)：创建TcrSession
                NSMutableDictionary *tcrSessionConfig = [NSMutableDictionary dictionary];
                tcrSessionConfig[@"local_audio"] = @(0);
                tcrSessionConfig[@"preferredCodec"] = @"H264";
                tcrSessionConfig[@"idleThreshold"] = @(6000);
                strongSelf3.session = [[TcrSdkInstance sharedInstance] createSessionWithParams:tcrSessionConfig];
                [strongSelf3.session setTcrSessionObserver:strongSelf3];
                
                // 如果超过10个InstanceId先连接10个（仅Demo演示，并非SDK限制）
                strongSelf3->instanceIds = [[strongSelf3->instanceIds subarrayWithRange:NSMakeRange(0, MIN(10, strongSelf3->instanceIds.count))] mutableCopy];
                [strongSelf3.session accessWithInstanceIds:strongSelf3->instanceIds];
            }];
        }];
    }];
}

-(void)onEvent:(TcrEvent)event eventData:(id)eventData {
#pragma mark +++ 流程(08)：跳转到云手机页面
    if (event == STATE_CONNECTED) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self gotoGroupControlVC];
        });
    }
}

- (void)gotoGroupControlVC {
    CAIDemoGroupControlVC *subVC = [[CAIDemoGroupControlVC alloc] initWithTcrSession:self.session
                                                                         instancesId:self->instanceIds loadingView:_loadingView];
    [self addChildViewController:subVC];
    subVC.view.frame = self.view.bounds;
    [self.view insertSubview:subVC.view belowSubview:_loadingView];
    [subVC didMoveToParentViewController:self];
    [_loadingView setProcessValue:80];
    // 这里可以释放对SDK的实例retain
    self.session = nil;
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

- (void)stopConnectCAI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TcrSdkInstance sharedInstance] destroySession:self.session];
        self.session = nil;
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
