#import "LoginVC.h"
#import "ExpServerRequest.h"
#import "DemoToast.h"
#import "InstanceListVC.h"
#import "CAIDemoAccessibilityIds.h"

// 输入框的默认值，留空表示不回填。调试时可填上自己的凭证，省去每次手输。
//
// 账号密码用于登录本 Demo 所用的体验服务器，由体验服务器代为申请 Token/AccessInfo，
// 仅用于体验，不是 TcrSdk 的接入方式。
//
// 正式接入时 Token/AccessInfo 应由 App 向自己的业务后台申请（业务后台调用云 API
// CreateAndroidInstancesAccessToken 获取），不要硬编码在客户端。
static NSString *const kDefaultUserId = @"";
static NSString *const kDefaultPassword = @"";
static NSString *const kDefaultToken = @"";
static NSString *const kDefaultAccessInfo = @"";

@interface LoginVC ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UISegmentedControl *modeSwitch;
@property (nonatomic, strong) UIStackView *accountFields;  // 账号密码输入区
@property (nonatomic, strong) UIStackView *tokenFields;    // Token/AccessInfo 输入区
@property (nonatomic, strong) UITextField *userIdField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextField *tokenField;
@property (nonatomic, strong) UITextView *accessInfoView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

// Token 模式下从 AccessInfo 解析出的实例 ID，传给实例列表页
@property (nonatomic, strong) NSArray<NSString *> *instanceIds;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupSubviews];

    // 键盘遮挡输入框时，用 contentInset 把内容顶上去
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 界面

- (void)setupSubviews {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];

    UILabel *title = [[UILabel alloc] init];
    title.text = @"云手机 Demo";
    title.font = [UIFont boldSystemFontOfSize:22];
    title.textAlignment = NSTextAlignmentCenter;

    // 两种取凭证方式：账号密码走体验服务器换取，Token 模式直接填已有凭证
    self.modeSwitch = [[UISegmentedControl alloc] initWithItems:@[@"账号登录", @"Token 登录"]];
    self.modeSwitch.selectedSegmentIndex = 0;
    self.modeSwitch.accessibilityIdentifier = CAIIdLoginModeSwitch;
    [self.modeSwitch addTarget:self action:@selector(onModeChanged) forControlEvents:UIControlEventValueChanged];

    self.userIdField = [self fieldWithPlaceholder:@"用户名" value:kDefaultUserId secure:NO];
    self.userIdField.accessibilityIdentifier = CAIIdLoginUserId;
    self.passwordField = [self fieldWithPlaceholder:@"密码" value:kDefaultPassword secure:YES];
    self.passwordField.accessibilityIdentifier = CAIIdLoginPassword;
    self.accountFields = [self fieldGroupWithViews:@[self.userIdField, self.passwordField]];

    self.tokenField = [self fieldWithPlaceholder:@"Token" value:kDefaultToken secure:NO];
    self.tokenField.accessibilityIdentifier = CAIIdLoginToken;
    self.accessInfoView = [self accessInfoTextView];
    self.accessInfoView.accessibilityIdentifier = CAIIdLoginAccessInfo;
    self.tokenFields = [self fieldGroupWithViews:@[self.tokenField, self.accessInfoView]];
    self.tokenFields.hidden = YES;

    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [startBtn setTitle:@"启动" forState:UIControlStateNormal];
    startBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    startBtn.backgroundColor = [UIColor systemBlueColor];
    [startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startBtn.layer.cornerRadius = 6;
    startBtn.accessibilityIdentifier = CAIIdLoginStart;
    [startBtn addTarget:self action:@selector(onStartClick) forControlEvents:UIControlEventTouchUpInside];
    [startBtn.heightAnchor constraintEqualToConstant:44].active = YES;

    UIStackView *content = [[UIStackView alloc] initWithArrangedSubviews:@[
        title, self.modeSwitch, self.accountFields, self.tokenFields, startBtn
    ]];
    content.axis = UILayoutConstraintAxisVertical;
    content.spacing = 20;
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:content];

    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.loadingView.accessibilityIdentifier = CAIIdLoading;
    self.loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loadingView];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor],

        [content.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:40],
        [content.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:24],
        [content.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-24],
        [content.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-40],
        [content.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-48],

        [self.loadingView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.loadingView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.loadingView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.loadingView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    // 点击空白处收起键盘；cancelsTouchesInView=NO 保证按钮仍可点击
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (UITextField *)fieldWithPlaceholder:(NSString *)placeholder value:(NSString *)value secure:(BOOL)secure {
    UITextField *field = [[UITextField alloc] init];
    field.placeholder = placeholder;
    field.text = value;
    field.secureTextEntry = secure;
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.font = [UIFont systemFontOfSize:15];
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [field.heightAnchor constraintEqualToConstant:40].active = YES;
    return field;
}

/// AccessInfo 是很长的 Base64 文本，用可滚动的 UITextView
- (UITextView *)accessInfoTextView {
    UITextView *textView = [[UITextView alloc] init];
    textView.text = kDefaultAccessInfo;
    textView.font = [UIFont systemFontOfSize:12];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textView.layer.borderWidth = 0.5;
    textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textView.layer.cornerRadius = 6;
    [textView.heightAnchor constraintEqualToConstant:90].active = YES;
    return textView;
}

- (UIStackView *)fieldGroupWithViews:(NSArray<UIView *> *)views {
    UIStackView *group = [[UIStackView alloc] initWithArrangedSubviews:views];
    group.axis = UILayoutConstraintAxisVertical;
    group.spacing = 12;
    return group;
}

- (BOOL)isTokenMode {
    return self.modeSwitch.selectedSegmentIndex == 1;
}

- (void)onModeChanged {
    self.accountFields.hidden = [self isTokenMode];
    self.tokenFields.hidden = ![self isTokenMode];
    [self.view endEditing:YES];
}

- (void)keyboardWillChangeFrame:(NSNotification *)note {
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat overlap = CGRectGetMaxY(self.view.bounds) - [self.view convertRect:keyboardFrame fromView:nil].origin.y;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, MAX(overlap, 0), 0);
}

#pragma mark - 登录

- (void)onStartClick {
    [self.view endEditing:YES];
    if ([self isTokenMode]) {
        [self handleTokenLogin];
    } else {
        [self handleAccountLogin];
    }
}

#pragma mark +++ 流程(01)：账号登录，由体验服务器换取访问凭证
- (void)handleAccountLogin {
    if (self.userIdField.text.length == 0 || self.passwordField.text.length == 0) {
        [DemoToast showInViewController:self message:@"请输入用户名与密码"];
        return;
    }
    [self.loadingView startAnimating];

    NSDictionary *params = @{
        @"UserId": self.userIdField.text,
        @"Password": self.passwordField.text,
        @"RequestId": [[NSUUID UUID] UUIDString]
    };

    __weak typeof(self) weakSelf = self;
    [ExpServerRequest postPath:@"/Login" params:params completion:^(NSDictionary *response, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) return;

        [strongSelf stopLoading];
        if (error != nil) {
            [DemoToast showInViewController:strongSelf message:[NSString stringWithFormat:@"登录失败：%@", error.localizedDescription]];
            return;
        }

#pragma mark +++ 流程(02)：登录成功，进入实例列表页（实例查询与凭证申请都在列表页完成）
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf gotoInstanceListVC];
        });
    }];
}

/// Token 模式：凭证已在手上，只需解析出实例 ID 就能进入列表页
- (void)handleTokenLogin {
    if (self.tokenField.text.length == 0 || self.accessInfoView.text.length == 0) {
        [DemoToast showInViewController:self message:@"请输入 Token 与 AccessInfo"];
        return;
    }
    NSArray<NSString *> *ids = [self parseInstanceIdsFromAccessInfo:self.accessInfoView.text];
    if (ids.count == 0) {
        [DemoToast showInViewController:self message:@"无法从 AccessInfo 中解析实例 ID"];
        return;
    }
    self.instanceIds = ids;
    [self gotoInstanceListVC];
}

/// 从 AccessInfo（JSON 或 Base64 编码的 JSON）中解析实例 ID 列表
- (NSArray<NSString *> *)parseInstanceIdsFromAccessInfo:(NSString *)accessInfo {
    NSString *payload = [accessInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![payload hasPrefix:@"{"]) {
        NSData *decoded = [[NSData alloc] initWithBase64EncodedString:payload
                                                             options:NSDataBase64DecodingIgnoreUnknownCharacters];
        payload = decoded != nil ? [[NSString alloc] initWithData:decoded encoding:NSUTF8StringEncoding] : nil;
    }
    id json = [payload dataUsingEncoding:NSUTF8StringEncoding] != nil
        ? [NSJSONSerialization JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil]
        : nil;
    if (![json isKindOfClass:[NSDictionary class]]) {
        return @[];
    }

    NSMutableArray<NSString *> *ids = [NSMutableArray new];
    for (NSDictionary *zoneInfo in json[@"AccessInfo"]) {
        if (![zoneInfo isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        for (NSString *instanceId in zoneInfo[@"InstanceIds"]) {
            if ([instanceId isKindOfClass:[NSString class]] && instanceId.length > 0 && ![ids containsObject:instanceId]) {
                [ids addObject:instanceId];
            }
        }
    }
    return ids;
}

- (void)gotoInstanceListVC {
    BOOL tokenMode = [self isTokenMode];
    InstanceListVC *listVC = [[InstanceListVC alloc] initWithToken:tokenMode ? self.tokenField.text : nil
                                                        accessInfo:tokenMode ? self.accessInfoView.text : nil
                                                       instanceIds:tokenMode ? self.instanceIds : nil];
    [self.navigationController pushViewController:listVC animated:YES];
}

- (void)stopLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView stopAnimating];
    });
}

@end
