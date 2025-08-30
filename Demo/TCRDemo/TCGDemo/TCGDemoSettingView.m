//
//  TCGDemoSettingView.m
//  TCGDemo
//
//  Created by LyleYu on 2020/12/30.
//

#import "TCGDemoSettingView.h"


@interface TCGDemoSettingView ()

@property (nonatomic, strong) UIButton *enableKeyboardBtn;
@property (nonatomic, strong) UIButton *cursorBtn1;
@property (nonatomic, strong) UIButton *cursorBtn2;
@property (nonatomic, strong) UIButton *cursorBtn3;
@property (nonatomic, strong) UIButton *cursorBtn4;
@property (nonatomic, strong) UILabel *cursorSensitiveLab;
@property (nonatomic, strong) UISlider *cursorSlider;
@property (nonatomic, strong) UILabel *volumeLab;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) NSArray<NSString *> *bitrateLevel;
@property (nonatomic, assign) int bitrateLevelIndex;
@property (nonatomic, strong) UIButton *bitrateBtn;
@property (nonatomic, strong) UIButton *restartBtn;
@property (nonatomic, strong) UIButton *pauseBtn;
@property (nonatomic, strong) UIButton *stopGameBtn;
@property (nonatomic, strong) UIButton *clearKeyBtn;
@property (nonatomic, strong) UIButton *capsLockBtn;
@property (nonatomic, strong) UIButton *rotateViewBtn;
@property (nonatomic, strong) UIButton *touchViewBtn;
@property (nonatomic, strong) UIButton *sensorBtn;
@property (nonatomic, strong) UIButton *enableLocalAudioBtn;
@property (nonatomic, strong) UIButton *enableLocalVideoBtn;
@property (nonatomic, strong) UIButton *switchCamera;
@property (nonatomic, strong) UIButton *patseTextBtn;
@property (nonatomic, strong) UIButton *changeResBtn;
@property (nonatomic, strong) UIButton *createDCBtn;
@property (nonatomic, strong) UIButton *sendDCDataBtn;
@property (nonatomic, strong) UIButton *sendHomeKeyBtn;
@property (nonatomic, strong) UIButton *sendBackKeyBtn;
@property (nonatomic, strong) UIButton *sendMenuKeyBtn;
@property (nonatomic, strong) UIButton *sendVolumeUpKeyBtn;
@property (nonatomic, strong) UIButton *sendVolumeDownKeyBtn;
@property (nonatomic, strong) UIButton *startProxyBtn;
@property (nonatomic, strong) UIButton *stopProxyBtn;
@property (nonatomic, strong) UILabel *allInfo;
@property (nonatomic, assign) BOOL isFrontCamera;

@end

@implementation TCGDemoSettingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
        [self initSubViews];
    }
    return self;
}

- (UIButton *)createBtnFrame:(CGRect)frame title:(NSString *)title {
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    btn.backgroundColor = [UIColor clearColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:0 alpha:1] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(controlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)initSubViews {
    CGFloat selfWidth = self.frame.size.width;
    CGFloat selfHeight = self.frame.size.height;
    // TODO 监测自适应全面屏与非全面屏
    //    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    CGFloat left = 48;  // window.safeAreaInsets.top;
    self.enableKeyboardBtn = [self createBtnFrame:CGRectMake(left + 10, 60, 70, 25) title:@"使用键鼠"];
    self.cursorBtn1 = [self createBtnFrame:CGRectMake(left + 90, 60, 70, 25) title:@"触控"];
    self.cursorBtn2 = [self createBtnFrame:CGRectMake(left + 180, 60, 70, 25) title:@"滑鼠点击"];
    self.cursorBtn3 = [self createBtnFrame:CGRectMake(left + 270, 60, 70, 25) title:@"滑屏"];
    self.cursorBtn4 = [self createBtnFrame:CGRectMake(left + 360, 60, 70, 25) title:@"切成右键"];
    self.cursorBtn1.enabled = NO;
    self.cursorBtn2.enabled = NO;
    self.cursorBtn3.enabled = NO;
    self.cursorBtn4.enabled = NO;

    UILabel *cursorlab = [[UILabel alloc] initWithFrame:CGRectMake(left + 10, 100, 150, 25)];
    cursorlab.backgroundColor = [UIColor clearColor];
    cursorlab.font = [UIFont systemFontOfSize:15];
    cursorlab.textColor = [UIColor blackColor];
    cursorlab.text = @"鼠标滑动灵敏度:1.0";
    cursorlab.textAlignment = NSTextAlignmentLeft;
    UISlider *cursorSlider = [[UISlider alloc] initWithFrame:CGRectMake(left + 170, 100, 200, 15)];
    cursorSlider.minimumValue = 0.1f;
    cursorSlider.maximumValue = 2.0f;
    cursorSlider.value = 1.0f;
    cursorSlider.continuous = NO;
    cursorSlider.enabled = NO;
    [cursorSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.cursorSensitiveLab = cursorlab;
    self.cursorSlider = cursorSlider;

    UILabel *volumelab = [[UILabel alloc] initWithFrame:CGRectMake(left + 10, 140, 150, 25)];
    volumelab.backgroundColor = [UIColor clearColor];
    volumelab.font = [UIFont systemFontOfSize:15];
    volumelab.textColor = [UIColor blackColor];
    volumelab.text = @"音量增益系数:1.0";
    volumelab.textAlignment = NSTextAlignmentLeft;
    UISlider *volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(left + 170, 140, 200, 15)];
    volumeSlider.minimumValue = 0.1f;
    volumeSlider.maximumValue = 10.0f;
    volumeSlider.value = 1.0f;
    volumeSlider.continuous = NO;
    [volumeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.volumeLab = volumelab;
    self.volumeSlider = volumeSlider;

    self.bitrateLevel = @[@"1M30fps", @"4M45fps", @"8M60fps"];
    self.bitrateLevelIndex = 1;
    self.bitrateBtn = [self createBtnFrame:CGRectMake(left + 10, 180, 70, 25) title:[self.bitrateLevel objectAtIndex:self.bitrateLevelIndex]];
    self.clearKeyBtn = [self createBtnFrame:CGRectMake(left + 10, 220, 70, 25) title:@"按键清除"];
    self.rotateViewBtn = [self createBtnFrame:CGRectMake(left + 10, 260, 70, 25) title:@"旋转视图"];
    self.patseTextBtn = [self createBtnFrame:CGRectMake(left + 10, 300, 70, 25) title:@"复制文本"];
    self.sendHomeKeyBtn = [self createBtnFrame:CGRectMake(left + 10, 340, 70, 25) title:@"Home键"];
    self.sendBackKeyBtn = [self createBtnFrame:CGRectMake(left + 90, 340, 70, 25) title:@"返回键"];
    self.sendMenuKeyBtn = [self createBtnFrame:CGRectMake(left + 170, 340, 70, 25) title:@"菜单键"];
    self.sendVolumeUpKeyBtn = [self createBtnFrame:CGRectMake(left + 250, 340, 70, 25) title:@"音量加"];
    self.sendVolumeDownKeyBtn = [self createBtnFrame:CGRectMake(left + 250, 380, 70, 25) title:@"音量减"];
    self.startProxyBtn = [self createBtnFrame:CGRectMake(left + 10, 380, 70, 25) title:@"开始代理"];
    self.stopProxyBtn = [self createBtnFrame:CGRectMake(left + 90, 380, 70, 25) title:@"停止代理"];

    self.capsLockBtn = [self createBtnFrame:CGRectMake(left + 90, 220, 70, 25) title:@"查询大写"];
    self.touchViewBtn = [self createBtnFrame:CGRectMake(left + 90, 260, 70, 25) title:@"禁用触屏"];
    self.changeResBtn = [self createBtnFrame:CGRectMake(left + 90, 300, 70, 25) title:@"改变分辨率"];

    self.enableLocalVideoBtn = [self createBtnFrame:CGRectMake(left + 170, 220, 70, 25) title:@"开摄像头"];
    self.sensorBtn = [self createBtnFrame:CGRectMake(left + 170, 260, 70, 25) title:@"开传感器"];
    self.createDCBtn = [self createBtnFrame:CGRectMake(left + 170, 300, 70, 25) title:@"创建数据通道"];

    self.restartBtn = [self createBtnFrame:CGRectMake(selfWidth - 80, 80, 70, 25) title:@"重启游戏"];
    self.pauseBtn = [self createBtnFrame:CGRectMake(selfWidth - 80, 120, 70, 25) title:@"挂起游戏"];
    self.stopGameBtn = [self createBtnFrame:CGRectMake(selfWidth - 80, 160, 70, 25) title:@"结束游戏"];
    self.switchCamera = [self createBtnFrame:CGRectMake(selfWidth - 80, 220, 70, 25) title:@"切换前后"];
    self.isFrontCamera = true;
    self.enableLocalAudioBtn = [self createBtnFrame:CGRectMake(selfWidth - 80, 260, 70, 25) title:@"开麦克风"];
    
    self.sendDCDataBtn = [self createBtnFrame:CGRectMake(left + 250, 300, 70, 25) title:@"发送数据"];
    self.allInfo = [[UILabel alloc] initWithFrame:CGRectMake(left + 10, selfHeight - 80, 600, 70)];
    self.allInfo.backgroundColor = [UIColor clearColor];
    self.allInfo.font = [UIFont systemFontOfSize:10];
    self.allInfo.textColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    self.allInfo.textAlignment = NSTextAlignmentLeft;
    self.allInfo.numberOfLines = 0;
    self.allInfo.lineBreakMode = NSLineBreakByWordWrapping;

    [self addSubview:self.enableKeyboardBtn];
    [self addSubview:self.restartBtn];
    [self addSubview:self.pauseBtn];
    [self addSubview:self.stopGameBtn];
    [self addSubview:self.allInfo];
    [self addSubview:self.clearKeyBtn];
    [self addSubview:self.capsLockBtn];
    [self addSubview:self.rotateViewBtn];
    [self addSubview:self.touchViewBtn];
    [self addSubview:self.cursorBtn1];
    [self addSubview:self.cursorBtn2];
    [self addSubview:self.cursorBtn3];
    [self addSubview:self.cursorBtn4];
    [self addSubview:self.cursorSensitiveLab];
    [self addSubview:self.cursorSlider];
    [self addSubview:self.volumeLab];
    [self addSubview:self.volumeSlider];
    [self addSubview:self.bitrateBtn];
    [self addSubview:self.enableLocalAudioBtn];
    [self addSubview:self.enableLocalVideoBtn];
    [self addSubview:self.switchCamera];
    [self addSubview:self.changeResBtn];
    [self addSubview:self.patseTextBtn];
    [self addSubview:self.createDCBtn];
    [self addSubview:self.sendDCDataBtn];
    [self addSubview:self.sensorBtn];
    [self addSubview:self.sendHomeKeyBtn];
    [self addSubview:self.sendBackKeyBtn];
    [self addSubview:self.sendMenuKeyBtn];
    [self addSubview:self.sendVolumeUpKeyBtn];
    [self addSubview:self.sendVolumeDownKeyBtn];
    [self addSubview:self.startProxyBtn];
    [self addSubview:self.stopProxyBtn];
}

- (void)controlBtnClick:(id)sender {
    if (sender == self.enableKeyboardBtn) {
        if ([self.enableKeyboardBtn.titleLabel.text isEqualToString:@"使用键鼠"]) {
            [self.enableKeyboardBtn setTitle:@"禁用键鼠" forState:UIControlStateNormal];
            [self.delegate openKeyboard:true];
            self.cursorBtn1.enabled = YES;
            self.cursorBtn2.enabled = YES;
            self.cursorBtn2.selected = YES;
            self.cursorBtn3.enabled = YES;
            self.cursorBtn4.enabled = YES;
            self.cursorSlider.enabled = YES;
        } else {
            [self.enableKeyboardBtn setTitle:@"使用键鼠" forState:UIControlStateNormal];
            [self.delegate openKeyboard:false];
            self.cursorBtn1.enabled = NO;
            self.cursorBtn2.enabled = NO;
            self.cursorBtn3.enabled = NO;
            self.cursorBtn4.enabled = NO;
            [self.cursorBtn1 setSelected:NO];
            [self.cursorBtn2 setSelected:NO];
            [self.cursorBtn3 setSelected:NO];
            self.cursorSlider.enabled = NO;
        }
    } else if (sender == self.stopGameBtn) {
        self.hidden = YES;
        [self.delegate stopGame];
    } else if (sender == self.restartBtn) {
        [self.delegate restartGame];
    } else if (sender == self.clearKeyBtn) {
        [self.delegate clearAllKeys];
    } else if (sender == self.cursorBtn1) {
        [self.cursorBtn1 setSelected:YES];
        [self.cursorBtn2 setSelected:NO];
        [self.cursorBtn3 setSelected:NO];
        self.cursorBtn4.enabled = NO;
        [self.delegate onSetCursorTouchMode:0];
    } else if (sender == self.cursorBtn2) {
        [self.cursorBtn1 setSelected:NO];
        [self.cursorBtn2 setSelected:YES];
        [self.cursorBtn3 setSelected:NO];
        self.cursorBtn4.enabled = YES;
        [self.delegate onSetCursorTouchMode:1];
    } else if (sender == self.cursorBtn3) {
        [self.cursorBtn1 setSelected:NO];
        [self.cursorBtn2 setSelected:NO];
        [self.cursorBtn3 setSelected:YES];
        self.cursorBtn4.enabled = YES;
        [self.delegate onSetCursorTouchMode:2];
    } else if (sender == self.cursorBtn4) {
        NSString *titleText = @"切成左键";
        BOOL isLeft = YES;
        if ([self.cursorBtn4.titleLabel.text isEqualToString:titleText]) {
            [self.cursorBtn4 setTitle:@"切成右键" forState:UIControlStateNormal];
        } else {
            [self.cursorBtn4 setTitle:titleText forState:UIControlStateNormal];
            isLeft = NO;
        }
        [self.delegate onSetCursorClickType:isLeft];
    } else if (sender == self.bitrateBtn) {
        self.bitrateLevelIndex = self.bitrateLevelIndex >= 2 ? 0 : (self.bitrateLevelIndex + 1);
        [self.bitrateBtn setTitle:[self.bitrateLevel objectAtIndex:self.bitrateLevelIndex] forState:UIControlStateNormal];
        [self.delegate onSetBitrateLevel:self.bitrateLevelIndex];
    } else if (sender == self.pauseBtn) {
        NSString *titleText = @"恢复游戏";
        BOOL isPause = YES;
        if ([self.pauseBtn.titleLabel.text isEqualToString:titleText]) {
            titleText = @"挂起游戏";
            isPause = NO;
        }
        [self.pauseBtn setTitle:titleText forState:UIControlStateNormal];
        [self.delegate pauseResumeGame:isPause];
    } else if (sender == self.enableLocalAudioBtn) {
        NSString *titleText = @"关麦克风";
        BOOL enable = YES;
        if ([self.enableLocalAudioBtn.titleLabel.text isEqualToString:titleText]) {
            titleText = @"开麦克风";
            enable = NO;
        }
        [self.enableLocalAudioBtn setTitle:titleText forState:UIControlStateNormal];
        [self.delegate onEnableLocalAudio:enable];
    } else if (sender == self.enableLocalVideoBtn) {
        NSString *titleText = @"关摄像头";
        BOOL enable = YES;
        if ([self.enableLocalVideoBtn.titleLabel.text isEqualToString:titleText]) {
            titleText = @"开摄像头";
            enable = NO;
        }
        [self.enableLocalVideoBtn setTitle:titleText forState:UIControlStateNormal];
        [self.delegate onEnableLocalVideo:enable];
    } else if (sender == self.switchCamera) {
        _isFrontCamera = !_isFrontCamera;
        [self.delegate onSwitchCamera:_isFrontCamera];
    } else if (sender == self.capsLockBtn) {
        [self.delegate checkCapsLock];
        return;
    } else if (sender == self.rotateViewBtn) {
        [self.delegate onRotateView];
        return;
    } else if (sender == self.changeResBtn) {
        [self.delegate modifyRES];
        return;
    } else if (sender == self.patseTextBtn) {
        [self.delegate pasteText];
        return;
    } else if (sender == self.createDCBtn) {
        [self.delegate onCreateDataChannel];
        return;
    } else if (sender == self.sendDCDataBtn) {
        [self.delegate onDataChannelSend];
        return;
    } else if (sender == self.touchViewBtn) {
        NSString *titleText = @"禁用触屏";
        BOOL isOpen = YES;
        if ([self.touchViewBtn.titleLabel.text isEqualToString:titleText]) {
            titleText = @"使用触屏";
            isOpen = NO;
        }
        [self.touchViewBtn setTitle:titleText forState:UIControlStateNormal];
        [self.delegate openTouchView:isOpen];
        return;
    } else if (sender == self.sensorBtn) {
        NSString *titleText = @"关传感器";
        BOOL enable = YES;
        if ([self.sensorBtn.titleLabel.text isEqualToString:titleText]) {
            titleText = @"开传感器";
            enable = NO;
        }
        [self.sensorBtn setTitle:titleText forState:UIControlStateNormal];
        [self.delegate enableCoreMotion:enable];
        return;
    } else if (sender == self.sendHomeKeyBtn) {
        [self.delegate onKeyboard:KEY_HOME];
    } else if (sender == self.sendBackKeyBtn) {
        [self.delegate onKeyboard:KEY_BACK];
    } else if (sender == self.sendMenuKeyBtn) {
        [self.delegate onKeyboard:KEY_MENU];
    } else if (sender == self.sendVolumeUpKeyBtn) {
        [self.delegate onKeyboard:KEYCODE_VOLUME_UP];
    } else if (sender == self.sendVolumeDownKeyBtn) {
        [self.delegate onKeyboard:KEYCODE_VOLUME_DOWN];
    } else if (sender == self.startProxyBtn) {
        [self.delegate onStartProxy];
    } else if (sender == self.stopProxyBtn) {
        [self.delegate onStopProxy];
    }
}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    if (slider == self.cursorSlider) {
        self.cursorSensitiveLab.text = [NSString stringWithFormat:@"鼠标滑动灵敏度:%.1f", slider.value];
        [self.delegate onSetCursorSensitive:slider.value];
    } else if (slider == self.volumeSlider) {
        self.volumeLab.text = [NSString stringWithFormat:@"音量增益系数:%.1f", slider.value];
        [self.delegate onSetVolume:slider.value];
    }
}

- (void)setAllDebugInfo:(NSDictionary *)allInfo {
    NSString *all = [[allInfo description] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    //    NSNumber *requestID = [allInfo objectForKey:@"requestID"];
    //    NSNumber *serverIP = [allInfo objectForKey:@"ServerIP"];
    //    NSNumber *region = [allInfo objectForKey:@"Region"];
    //    NSNumber *cpuUsage = [allInfo objectForKey:@"CpuUsage"];
    //    NSString *gpuUsage = [allInfo objectForKey:@"GpuUsage"];
    //    NSNumber *rttMS = [allInfo objectForKey:@"RTT"];
    //    NSNumber *fps = [allInfo objectForKey:@"FPS"];
    //    NSNumber *screenHeight = [allInfo objectForKey:@"Width"];
    //    NSNumber *screenWidth = [allInfo objectForKey:@"Height"];
    //    NSNumber *videoDelay = [allInfo objectForKey:@"VideoDelay"];
    //    NSNumber *videoLost = [allInfo objectForKey:@"VideoLost"];
    //    NSNumber *videoJitterBuffer = [allInfo objectForKey:@"VideoJitterBuffer"];
    //    NSNumber *videoNack = [allInfo objectForKey:@"VideoNack"];
    //    NSNumber *audioDelay = [allInfo objectForKey:@"AudioDelay"];
    //    NSNumber *audioLost = [allInfo objectForKey:@"AudioLost"];
    //    NSNumber *audioJitterBuffer = [allInfo objectForKey:@"AudioJitterBuffer"];

    self.allInfo.text = all;
}

@end
