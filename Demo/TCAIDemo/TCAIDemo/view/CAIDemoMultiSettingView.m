//
//  CAIDemoMultiSettingView.m
//  CAIDemo
//
//  Created by xxhape on 2023/10/11.
//

#import "CAIDemoMultiSettingView.h"
#import "CAIDemoTextField.h"
@interface CAIDemoMultiSettingView () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *hostHeadLab;
@property (nonatomic, strong) UILabel *guestHeadLab;
@property (nonatomic, strong) UIButton *requestPlayerBtn;
@property (nonatomic, strong) UIButton *requestViewerBtn;
@property (nonatomic, strong) UIButton *changePlayerBtn;
@property (nonatomic, strong) UIButton *changeViewerBtn;
@property (nonatomic, strong) UIButton *sysncRoomInfoBtn;
@property (nonatomic, strong) UIButton *muteUserBtn;
@property (nonatomic, strong) UITextField *userIDTF;
@property (nonatomic, strong) UITextField *indexTF;

@end
@implementation CAIDemoMultiSettingView

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

- (UILabel *)createLabFrame:(CGRect)frame title:(NSString *)title {
    UILabel *lab = [[UILabel alloc] initWithFrame:frame];
    lab.backgroundColor = [UIColor clearColor];
    lab.font = [UIFont systemFontOfSize:15];
    lab.textColor = [UIColor blackColor];
    lab.textAlignment = NSTextAlignmentLeft;
    lab.text = title;
    return lab;
}

- (void)initSubViews {
    CGFloat selfWidth = self.frame.size.width;
    CGFloat selfHeight = self.frame.size.height;
    // TODO 监测自适应全面屏与非全面屏
    CGFloat left = 48;  // window.safeAreaInsets.top;

    self.userIDTF = [[UITextField alloc] initWithFrame:CGRectMake(left + 10, 60, 70, 25)];
    self.userIDTF.borderStyle = UITextBorderStyleRoundedRect;
    self.userIDTF.placeholder = @"输入id";
    self.userIDTF.delegate = self;
    self.indexTF = [[UITextField alloc] initWithFrame:CGRectMake(left + 180, 60, 70, 25)];
    self.indexTF.borderStyle = UITextBorderStyleRoundedRect;
    self.indexTF.placeholder = @"输入坐席";

    self.indexTF.delegate = self;

    self.hostHeadLab = [self createLabFrame:CGRectMake(left + 10, 100, 70, 25) title:@"我是房主:"];
    self.changePlayerBtn = [self createBtnFrame:CGRectMake(left + 110, 100, 90, 25) title:@"切换为玩家"];
    self.changeViewerBtn = [self createBtnFrame:CGRectMake(left + 210, 100, 90, 25) title:@"切换为观众"];

    self.guestHeadLab = [self createLabFrame:CGRectMake(left + 10, 140, 70, 25) title:@"我是访客:"];
    self.requestPlayerBtn = [self createBtnFrame:CGRectMake(left + 110, 140, 90, 25) title:@"申请为玩家"];
    self.requestViewerBtn = [self createBtnFrame:CGRectMake(left + 210, 140, 90, 25) title:@"申请为观众"];

    self.muteUserBtn = [self createBtnFrame:CGRectMake(left + 10, 180, 70, 25) title:@"静音玩家"];
    self.sysncRoomInfoBtn = [self createBtnFrame:CGRectMake(left + 110, 180, 130, 25) title:@"刷新房间信息"];
    [self addSubview:self.hostHeadLab];
    [self addSubview:self.guestHeadLab];
    [self addSubview:self.requestPlayerBtn];
    [self addSubview:self.requestViewerBtn];
    [self addSubview:self.changePlayerBtn];
    [self addSubview:self.changeViewerBtn];
    [self addSubview:self.muteUserBtn];
    [self addSubview:self.userIDTF];
    [self addSubview:self.indexTF];
    [self addSubview:self.sysncRoomInfoBtn];
}

- (void)controlBtnClick:(id)sender {
    if (sender == self.sysncRoomInfoBtn) {
        [self.delegate onSyscRoomInfo];
        return;
    }
    NSString *userID = self.userIDTF.text;
    NSString *indexS = self.indexTF.text;
    if (userID == nil || indexS == nil) {
        return;
    }
    int index = [indexS intValue];
    // 判断sender ，传入参数调用delegate
    if (sender == self.changePlayerBtn) {
        [self.delegate onSeatChange:userID index:index role:@"player"];
    } else if (sender == self.changeViewerBtn) {
        [self.delegate onSeatChange:userID index:index role:@"viewer"];
    } else if (sender == self.requestPlayerBtn) {
        [self.delegate onApplySeatChange:userID index:index role:@"player"];
    } else if (sender == self.requestViewerBtn) {
        [self.delegate onApplySeatChange:userID index:index role:@"viewer"];
    } else if (sender == self.muteUserBtn) {
        NSString *titleText = @"静音玩家";
        BOOL enable = YES;
        if ([self.muteUserBtn.titleLabel.text isEqualToString:titleText]) {
            titleText = @"解禁玩家";
            enable = NO;
        }
        [self.delegate onsetMicMute:userID enable:enable];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
