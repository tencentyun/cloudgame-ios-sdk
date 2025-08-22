//
//  TCGDemoExperienceVC.m
//  TCGDemo
//
//  Created by LyleYu on 2021/6/22.
//

#import "TCGDemoExperienceVC.h"
#import "TCGDemoExperienceInputText.h"
#import "TCGDemoUtils.h"
#import "TCGDemoBitrateInputText.h"
#import "TCGDemoPickerView.h"
#import "TCGDemoRaidoButton.h"
#import "TCGDemoGamePlayVC.h"
#import "TCGDemoLoadingView.h"
#import "TCGDemoInputDelegate.h"
#import "../audio_capture/TCGDemoAudioCapturor.h"
#import <AVFoundation/AVFoundation.h>


//#define TEST_EXPERI 0
#ifdef TEST_EXPERI
static NSString *kHostBaseUrl = @"https://code-test.cloud-gaming.myqcloud.com/";
#else
static NSString *kHostBaseUrl = @"https://code.cloud-gaming.myqcloud.com/";
#endif
@interface TCGDemoExperienceVC()<TcrSessionObserver, TCGDemoInputDelegate, TCRAudioSessionDelegate, TCRLogDelegate> {
    UIImageView *_bgView;
    UIView *_loginWindowView;
    CAGradientLayer *_loginBgLayer;
    UIView *_keyboardBgView;
    NSMutableDictionary *_experienceCfg;

    BOOL _isSimpleMode;
    UIButton *_simpleModeBtn;
    UIButton *_advanceModeBtn;

    UIScrollView *_inputScrollView;
    TCGDemoExperienceInputText *_simpleCodeTxt;
    
    CGFloat _keyboardTop;
    UIView *_currentInputView;
    UIView *_advanceContentView;
    TCGDemoExperienceInputText *_advanceCodeTxt;
    TCGDemoExperienceInputText *_advanceGameId;
    TCGDemoExperienceInputText *_advanceFps;
    TCGDemoBitrateInputText *_advanceBitrate;
    TCGDemoExperienceInputText *_advanceGroupId;
    TCGDemoExperienceInputText *_advanceSetNo;
    TCGDemoExperienceInputText *_advanceUserId;
    TCGDemoExperienceInputText *_advanceHostUserId;
    TCGDemoRaidoButton *_advanceResolution;
    TCGDemoRaidoButton *_advanceRole;
    TCGDemoRaidoButton *_advanceEnv;
    TCGDemoPickerView *_advanceArea;
    TCGDemoLoadingView *_loadingView;
    NSString *_userId;
    NSString *_experienceCode;
    BOOL _enableCustomAudioCapture;
    BOOL _enableCustomVideoCapture;
    int _captureWidth;
    int _captureHeight;
    int _captureFps;
    BOOL _enableSendCustomVideo;
    NSNumber* _idleThreshold;
    
    UIButton *_startBtn;
}
@property(nonatomic, strong) TcrSession *session;

@end

@implementation TCGDemoExperienceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _experienceCfg = [self loadConfig];
    [self initSubviews];
    [self keyboardWillHide:nil];    // 更新StartBtn的背景色
    
    [TcrSdkInstance setLogger:self withMinLevel:TCRLogLevelDebug];
    
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
    _loginBgLayer.colors = @[(__bridge id)[TCGDemoUtils tcg_colorValue:@"1B4C9A"].CGColor,
                        (__bridge id)[TCGDemoUtils tcg_colorValue:@"0D2C61"].CGColor];
    _loginBgLayer.locations = @[@(0.0f), @(1.0f)];
    [_loginWindowView.layer addSublayer:_loginBgLayer];
    _loginWindowView.center = self.view.center;
    _loginWindowView.backgroundColor = [UIColor clearColor];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tcg_cloud"]];
    iconView.frame = CGRectMake(41.5, 5, 192.5, 60);
    [_loginWindowView addSubview:iconView];

    _simpleModeBtn = [self createTabBtn:@"快速体验" icon:@"simple_mode"];
    _simpleModeBtn.frame = CGRectMake(67.5, 75, 70, 21);
    [_loginWindowView addSubview:_simpleModeBtn];
    [_simpleModeBtn addTarget:self action:@selector(showMode:) forControlEvents:UIControlEventTouchUpInside];

    _advanceModeBtn = [self createTabBtn:@"高级模式" icon:@"simple_mode"];
    _advanceModeBtn.frame = CGRectMake(137.5, 75, 70, 21);
    [_loginWindowView addSubview:_advanceModeBtn];
    [_advanceModeBtn addTarget:self action:@selector(showMode:) forControlEvents:UIControlEventTouchUpInside];
    
    _simpleModeBtn.backgroundColor = [TCGDemoUtils tcg_colorValue:@"006EFF"];
    _isSimpleMode = YES;

    NSString *simpleCode = [[_experienceCfg objectForKey:@"simple"] objectForKey:@"ExperienceCode"];
    _simpleCodeTxt = [[TCGDemoExperienceInputText alloc] initWithFrame:CGRectMake(0, 0, 225, 22.5)
                                                                  name:@"体验码"
                                                               oldValue:simpleCode];
    _simpleCodeTxt.inputDelegate = self;
    
    _inputScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(25, 121, 225, 22.5)];
    _inputScrollView.contentSize = _simpleCodeTxt.bounds.size;
    [_inputScrollView addSubview:_simpleCodeTxt];
    [_loginWindowView addSubview:_inputScrollView];
    [self initAdvanceInput];

    _startBtn = [[UIButton alloc] initWithFrame:CGRectMake(25, 168.5, 225, 22.5)];
    _startBtn.backgroundColor = [TCGDemoUtils tcg_colorValue:@"006EFF"];
    [_startBtn setTitle:@"启动" forState:UIControlStateNormal];
    [_startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_startBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:8]];
    [_startBtn addTarget:self action:@selector(startExpericence) forControlEvents:UIControlEventTouchUpInside];
    [_loginWindowView addSubview:_startBtn];
    _startBtn.backgroundColor = [TCGDemoUtils tcg_colorValue:@"006EFF20"];

    _keyboardBgView = [[UIView alloc] initWithFrame:self.view.bounds];
    _keyboardBgView.backgroundColor = [UIColor clearColor];
    _keyboardBgView.userInteractionEnabled = YES;
    _keyboardBgView.hidden = YES;

    UITapGestureRecognizer *singleClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboard:)];
    [_keyboardBgView addGestureRecognizer:singleClick];
    
    _loadingView = [[TCGDemoLoadingView alloc] initWithFrame:self.view.bounds process:0];
    _loadingView.hidden = YES;
    _enableCustomAudioCapture = true;
    _enableCustomVideoCapture = true;
}

- (void)initAdvanceInput {
    CGFloat top = 0;
    CGFloat inputHeight = 22.5;
    _advanceContentView = [[UIView alloc] initWithFrame:CGRectZero];
    _advanceContentView.backgroundColor = [UIColor clearColor];
    
    NSDictionary *advanceCfg = [_experienceCfg objectForKey:@"advance"];
    _advanceCodeTxt = [[TCGDemoExperienceInputText alloc] initWithFrame:CGRectMake(0, top, 225, inputHeight)
                                                                   name:@"体验码"
                                                                oldValue:[advanceCfg objectForKey:@"ExperienceCode"]];
    _advanceCodeTxt.inputDelegate = self;
    [_advanceContentView addSubview:_advanceCodeTxt];
    
    top += inputHeight + 0.5;
    _advanceGameId = [[TCGDemoExperienceInputText alloc] initWithFrame:CGRectMake(0, top, 225, inputHeight)
                                                                  name:@"GameId"
                                                               oldValue:[advanceCfg objectForKey:@"GameId"]];
    _advanceGameId.inputDelegate = self;
    [_advanceContentView addSubview:_advanceGameId];
    
    top += inputHeight + 0.5;
    _advanceFps = [[TCGDemoExperienceInputText alloc] initWithFrame:CGRectMake(0, top, 225, inputHeight)
                                                               name:@"帧率"
                                                            oldValue:[[advanceCfg objectForKey:@"Fps"] stringValue]];
    _advanceFps.inputDelegate = self;
    [_advanceContentView addSubview:_advanceFps];
    
    top += inputHeight + 0.5;
    _advanceBitrate = [[TCGDemoBitrateInputText alloc] initWithFrame:CGRectMake(0, top, 225, inputHeight)
                                                                name:@"码率" min:[advanceCfg objectForKey:@"MinBitrate"] max:[advanceCfg objectForKey:@"MaxBitrate"]];
    _advanceBitrate.inputDelegate = self;
    [_advanceContentView addSubview:_advanceBitrate];
    
    top += inputHeight + 0.5;
    _advanceGroupId = [[TCGDemoExperienceInputText alloc] initWithFrame:CGRectMake(0, top, 225, inputHeight)
                                                                   name:@"GroupId"
                                                                oldValue:[advanceCfg objectForKey:@"GroupId"]];
    _advanceGroupId.inputDelegate = self;
    [_advanceContentView addSubview:_advanceGroupId];

    top += inputHeight + 0.5;
    _advanceSetNo = [[TCGDemoExperienceInputText alloc] initWithFrame:CGRectMake(0, top, 225, inputHeight)
                                                                   name:@"SetNo"
                                                                oldValue:[[advanceCfg objectForKey:@"SetNo"] stringValue]];
    _advanceSetNo.inputDelegate = self;
    [_advanceContentView addSubview:_advanceSetNo];
    
    top += inputHeight + 0.5;
    _advanceUserId = [[TCGDemoExperienceInputText alloc] initWithFrame:CGRectMake(0, top, 225, inputHeight)
                                                                   name:@"UserId"
                                                              oldValue:[advanceCfg objectForKey:@"UserId"]];
    _advanceUserId.inputDelegate = self;
    [_advanceContentView addSubview:_advanceUserId];
    
    top += inputHeight + 0.5;
    _advanceHostUserId = [[TCGDemoExperienceInputText alloc] initWithFrame:CGRectMake(0, top, 225, inputHeight)
                                                                   name:@"HostUserId"
                                                                oldValue:[advanceCfg objectForKey:@"HostUserId"]];
    _advanceHostUserId.inputDelegate = self;
    [_advanceContentView addSubview:_advanceHostUserId];
    
    top += inputHeight + 0.5;
    _advanceRole = [[TCGDemoRaidoButton alloc] initWithFrame:CGRectMake(0, top, 225, inputHeight)
                                                              name:@"角色"
                                                             items:@[@"Player",@"Viewer"]];
    if ([advanceCfg objectForKey:@"Role"]) {
        [_advanceRole setSeletedValue:[advanceCfg objectForKey:@"Role"]];
    } else {
        [_advanceRole setSeletedValue:@"Viewer"];
    }
    [_advanceContentView addSubview:_advanceRole];

    top += inputHeight + 0.5;
    _advanceEnv = [[TCGDemoRaidoButton alloc] initWithFrame:CGRectMake(0, top, 225, inputHeight)
                                                              name:@"后台环境"
                                                             items:@[@"正式",@"测试"]];
    [_advanceEnv setSeletedValue:@"正式"];
    [_advanceContentView addSubview:_advanceEnv];

    top += inputHeight + 0.5;
    _advanceResolution = [[TCGDemoRaidoButton alloc] initWithFrame:CGRectMake(0, top, 225, inputHeight)
                                                              name:@"分辨率"
                                                             items:@[@"1080p",@"720p"]];
    if ([advanceCfg objectForKey:@"Resolution"]) {
        [_advanceResolution setSeletedValue:[advanceCfg objectForKey:@"Resolution"]];
    } else {
        [_advanceResolution setSeletedValue:[advanceCfg objectForKey:@"1080p"]];
    }
    [_advanceContentView addSubview:_advanceResolution];
    
    top += inputHeight + 0.5;
    _advanceArea = [[TCGDemoPickerView alloc] initWithFrame:CGRectMake(0, top, 225, inputHeight)
                                                       name:@"地区"
                                                     parent:self.view
                                                      items:@[@{@"title":@"北京", @"value":@"ap-beijing"},
                                                              @{@"title":@"上海", @"value":@"ap-shanghai"},
                                                              @{@"title":@"广州", @"value":@"ap-guangzhou"},
                                                              @{@"title":@"南京", @"value":@"ap-nanjing"},
                                                              @{@"title":@"成都", @"value":@"ap-chengdu"}]];
    if ([advanceCfg objectForKey:@"GameRegion"]) {
        [_advanceArea setSeletedValue:[advanceCfg objectForKey:@"GameRegion"]];
    }
    [_advanceContentView addSubview:_advanceArea];
    _advanceContentView.frame = CGRectMake(0, 0, 225, top + inputHeight + 100);
    _advanceContentView.hidden = YES;
    [_inputScrollView addSubview:_advanceContentView];
}

- (void)showMode:(id)sender {
    BOOL isSimple = YES;
    if (sender == _advanceModeBtn) {
        _simpleModeBtn.backgroundColor = [TCGDemoUtils tcg_colorValue:@"3064B0"];
        _advanceModeBtn.backgroundColor = [TCGDemoUtils tcg_colorValue:@"006EFF"];
        isSimple = NO;
    } else {
        _simpleModeBtn.backgroundColor = [TCGDemoUtils tcg_colorValue:@"006EFF"];
        _advanceModeBtn.backgroundColor = [TCGDemoUtils tcg_colorValue:@"3064B0"];
    }
    _isSimpleMode = isSimple;
    __weak typeof(self)weakSelf = self;
    CGPoint center = self.view.center;
    [UIView animateWithDuration:0.35 animations:^{
        __strong typeof(self)strongSelf = weakSelf;
        CGRect scrollFrame = strongSelf->_inputScrollView.frame;
        if (isSimple) {
            strongSelf->_loginWindowView.frame = CGRectMake(0, 0, 275, 216);
            strongSelf->_startBtn.frame = CGRectMake(25, 168.5, 225, 22.5);
            scrollFrame.size.height = strongSelf->_simpleCodeTxt.frame.size.height;
            strongSelf->_inputScrollView.contentSize = strongSelf->_simpleCodeTxt.frame.size;
        } else {
            strongSelf->_loginWindowView.frame = CGRectMake(0, 0, 275, 345);
            strongSelf->_startBtn.frame = CGRectMake(25, 297.5, 225, 22.5);
            scrollFrame.size.height = 166.5;
            strongSelf->_inputScrollView.contentSize = strongSelf->_advanceContentView.frame.size;
        }
        strongSelf->_inputScrollView.frame = scrollFrame;
        strongSelf->_advanceContentView.hidden = isSimple;
        strongSelf->_simpleCodeTxt.hidden = !isSimple;
        strongSelf->_loginBgLayer.frame = strongSelf->_loginWindowView.bounds;
        strongSelf->_loginWindowView.center = center;
    }];
}

- (UIButton *)createTabBtn:(NSString *)name icon:(NSString *)icon {
    UIButton *btn = [UIButton new];
    btn.frame = CGRectMake(0, 0, 70, 21);
    btn.backgroundColor = [TCGDemoUtils tcg_colorValue:@"3064B0"];
    btn.layer.borderWidth = 0.5;
    btn.layer.borderColor = [TCGDemoUtils tcg_colorValue:@"006EFF"].CGColor;
    [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [btn setTitle:name forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:10]];
    CGRect titleFrame = btn.titleLabel.frame;
    CGRect imageFrame = btn.imageView.frame;
    CGRect imageTagetFrame = CGRectMake(5, 6, 10, 10);
    CGRect titleTagetFrame = CGRectMake(21.5, 3.5, 40, 14);
    UIEdgeInsets imgInsets = UIEdgeInsetsMake(imageTagetFrame.origin.y - imageFrame.origin.y,
                                              imageTagetFrame.origin.x - imageFrame.origin.x,
                                              imageFrame.origin.y + imageFrame.size.height - imageTagetFrame.origin.y - imageTagetFrame.size.height,
                                              imageFrame.origin.x + imageFrame.size.width - imageTagetFrame.origin.x - imageTagetFrame.size.width);
    UIEdgeInsets txtInsets = UIEdgeInsetsMake(titleTagetFrame.origin.y - titleFrame.origin.y,
                                              titleTagetFrame.origin.x - titleFrame.origin.x,
                                              titleFrame.origin.y + titleFrame.size.height - titleTagetFrame.origin.y - titleTagetFrame.size.height,
                                              titleFrame.origin.x + titleFrame.size.width - titleTagetFrame.origin.x - titleTagetFrame.size.width);
    [btn setImageEdgeInsets:imgInsets];
    [btn setTitleEdgeInsets:txtInsets];
    return btn;
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
    NSString *code = _isSimpleMode ? [_simpleCodeTxt text] : [_advanceCodeTxt text];
    if ([code length] == 8) {
        _startBtn.backgroundColor = [TCGDemoUtils tcg_colorValue:@"006EFF"];
        [_startBtn setEnabled:YES];
    } else {
        _startBtn.backgroundColor = [TCGDemoUtils tcg_colorValue:@"006EFF20"];
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
    [self createGamePlayer];
}

- (void)createExperienceSession:(NSString *)localSession {
    NSMutableDictionary *params = [NSMutableDictionary new];
    _userId = [[NSUUID UUID] UUIDString];
    [params setObject:_userId forKey:@"UserId"];
    [params setObject:localSession forKey:@"ClientSession"];
    [params setObject:_userId forKey:@"RequestId"];
    _experienceCode = nil;
    NSString *tmpExperienceCode = nil;
    NSString *saveKey = @"simple";
    // wegame 英雄联盟默认体验码 49GTGD6L
    if (_isSimpleMode) {
        tmpExperienceCode = [_simpleCodeTxt text];
    } else {
        tmpExperienceCode = [_advanceCodeTxt text];
        // https://git.woa.com/cloud_video_product_private/cloud_gaming/issues/303
        if ([[_advanceFps text] length] > 0) {
            [params setObject:@([[_advanceFps text] intValue]) forKey:@"Fps"];
        }
        if ([[_advanceArea seletedValue] length] > 0) {
            [params setObject:[_advanceArea seletedValue] forKey:@"GameRegion"];
        }
        if ([[_advanceGameId text] length] > 0) {
            [params setObject:[_advanceGameId text] forKey:@"GameId"];
        }
        if ([[_advanceGroupId text] length] > 0) {
            [params setObject:[_advanceGroupId text] forKey:@"GroupId"];
        }
        if ([[_advanceSetNo text] length] > 0) {
            [params setObject:@([[_advanceSetNo text] intValue]) forKey:@"SetNo"];
        }
        if ([[_advanceUserId text] length] > 0) {
            _userId = [_advanceUserId text];
            [params setObject:[_advanceUserId text] forKey:@"UserId"];
        }
        if ([[_advanceHostUserId text] length] > 0) {
            [params setObject:[_advanceHostUserId text] forKey:@"HostUserId"];
            [params setObject:[_advanceRole seletedValue] forKey:@"Role"];
        }
        if ([[_advanceResolution seletedValue] length] > 0) {
            [params setObject:[_advanceResolution seletedValue] forKey:@"Resolution"];
        }
        if ([[_advanceEnv seletedValue] isEqualToString:@"测试"]) {
            kHostBaseUrl = @"https://code.cloud-gaming.myqcloud.com/";
        }
        float minBit = [_advanceBitrate minBitrate];
        float maxBit = [_advanceBitrate maxBitrate];
        if (minBit > 0 && maxBit > 0) {
            [params setObject:@(minBit) forKey:@"MinBitrate"];
            [params setObject:@(maxBit) forKey:@"MaxBitrate"];
            if (minBit == maxBit) {
                [params setObject:@(minBit) forKey:@"Bitrate"];
            }
        }
        saveKey = @"advance";
    }
    [params setObject:tmpExperienceCode forKey:@"ExperienceCode"];
    [_experienceCfg setObject:params forKey:saveKey];
    [self saveConfig:_experienceCfg];

    NSString *createSession = [kHostBaseUrl stringByAppendingString:@"CreateExperienceSession"];
    [TCGDemoUtils tcg_postUrl:createSession params:params finishBlk:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil || data == nil) {
            [self showToast:[NSString stringWithFormat:@"申请机器失败:%@", error.userInfo.description]];
            [self stopGame];
            return;
        }
        NSError *err = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (err != nil || ![json isKindOfClass:[NSDictionary class]]) {
            [self showToast:[NSString stringWithFormat:@"申请机器失败:%@", err.userInfo.description]];
            [self stopGame];
            return;
        }
        NSDictionary *jsonObj = (NSDictionary *) json;
        // parse code
        id code = jsonObj[@"Code"];
        if (![code isKindOfClass:[NSNumber class]]) {
            NSLog(@"CreateExperienceSession bad code:%@", jsonObj);
            [self showToast:[NSString stringWithFormat:@"申请机器失败:%@", code]];
            [self stopGame];
            return;
        }
        NSNumber *codeObj = (NSNumber *) code;
        if ([codeObj integerValue] != 0) {
            NSLog(@"CreateExperienceSession return code %@", jsonObj);
            [self showToast:[NSString stringWithFormat:@"申请机器失败:%@", jsonObj[@"Message"]]];
            [self stopGame];
            return;
        }
        self->_experienceCode = tmpExperienceCode;
        NSString *serverSession = [jsonObj objectForKey:@"ServerSession"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self gotoGameplayVC:serverSession];
        });
    }];
}

- (void)stopExperienceSession {
    __weak TCGDemoLoadingView *weakLoadingView = _loadingView;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakLoadingView.hidden = YES;
    });
    if (_experienceCode.length == 0) {
        return;
    }
    NSDictionary *messageDic = @{@"ExperienceCode":_experienceCode,
                                 @"UserId":_userId};
    NSString *stopSession = [kHostBaseUrl stringByAppendingString:@"StopExperienceSession"];
    [TCGDemoUtils tcg_postUrl:stopSession params:messageDic finishBlk:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"释放云端游戏资源");
    }];
}

- (void)gotoGameplayVC:(NSString *)remoteSession {
    TCGDemoGamePlayVC *subVC;
    if (_enableCustomVideoCapture) {
        subVC = [[TCGDemoGamePlayVC alloc] initWithPlay:self.session
                                         remoteSession:remoteSession
                                            loadingView:_loadingView enableSendCustomVideo:_enableCustomVideoCapture enableSendCustomAudio:_enableCustomAudioCapture captureWidth:_captureWidth captureHeight:_captureHeight captureFps:_captureFps];
    } else {
        subVC = [[TCGDemoGamePlayVC alloc] initWithPlay:self.session
                                                             remoteSession:remoteSession
                                                               loadingView:_loadingView];
    }

    [self addChildViewController:subVC];
    subVC.view.frame = self.view.bounds;
    [self.view insertSubview:subVC.view belowSubview:_loadingView];
    [subVC didMoveToParentViewController:self];
    __weak typeof(self)weakSelf = self;
    [subVC setGameStopBlk:^{
        [weakSelf stopGame];
    }];
    [_loadingView setProcessValue:80];
    // 这里可以释放对SDK的实例retain
    self.session = nil;
}


- (NSMutableDictionary *)loadConfig {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *cfgDic = [user objectForKey:@"TCGDEMO_EXPERIENCE_CFG"];
    if (cfgDic == nil || ![cfgDic isKindOfClass:[NSDictionary class]]) {
        cfgDic = [NSDictionary new];
    }
    return [cfgDic mutableCopy];
}

- (void)saveConfig:(NSDictionary *)cfgDic {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:cfgDic forKey:@"TCGDEMO_EXPERIENCE_CFG"];
}

- (void)createGamePlayer {
    if (self.session != nil) {
        [self.session releaseSession];
        self.session = nil;
    }
    _idleThreshold = @(6000); // 6秒无操作视为空闲
    NSMutableDictionary *tcrConfig = [NSMutableDictionary dictionary];
    tcrConfig[@"local_audio"] = @(0);
    tcrConfig[@"preferredCodec"] = @"H264";
    tcrConfig[@"idleThreshold"] = _idleThreshold;
#pragma mark +++ 流程(01)：创建TCGGamePlayer，等待初始化成功
    if (_enableCustomAudioCapture) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *error;
        NSInteger sampleRate = [audioSession sampleRate];
        NSInteger channelCount = 1;
        [[TCGDemoAudioCapturor shared]configureWithSampleRate:sampleRate channelCount:channelCount dumpAudio:false];
        [tcrConfig setValue:@{@"sampleRate":@(sampleRate), @"useStereoInput":@(channelCount == 2)} forKey:@"enableCustomAudioCapture"];
    }
    if (_enableCustomVideoCapture) {
        _captureWidth = 720;
        _captureHeight = 1280;
        _captureFps = 30;
        [tcrConfig setValue:@{@"captureWidth":@(_captureWidth), @"captureHeight":@(_captureHeight), @"captureFps":@(_captureFps)} forKey:@"enableCustomVideoCapture"];
    }

    self.session = [[TcrSession alloc] initWithParams:tcrConfig andDelegate:self];
}

- (void)stopGame {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.session releaseSession];
        self.session = nil;
        self->_loadingView.hidden = YES;
        [self stopExperienceSession];
    });
}

-(void)onEvent:(TcrEvent)event eventData:(id)eventData {
    if (event == STATE_INITED) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createExperienceSession:(NSString *)eventData];
        });
    }
}

- (void)logWithLevel:(TCRLogLevel)logLevel log:(NSString *_Nullable)log {
    // 获取当前时间戳字符串
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    
    switch (logLevel) {
        case TCRLogLevelDebug:
            // NSLog(@"[TCRSDK] %@ [DEBUG]: %@", timestamp, log);
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
