//
//  CAIDemoInstanceListVC.m
//  TCAIDemo
//
//  实例列表页：登录成功后展示实例列表，勾选实例后再创建 TcrSession 进入实例操作页。
//

#import "CAIDemoInstanceListVC.h"
#import "CAIDemoGroupControlVC.h"
#import "CAIDemoUtils.h"
#import "CAIDemoLoadingView.h"
#import "utils/CAIDemoAudioCapturor.h"
#import <AVFoundation/AVFoundation.h>
#import <TCRSDK/TCRSDK.h>

static NSString *const kInstanceCellId = @"CAIDemoInstanceCell";

// 实例列表数据字段
static NSString *const kFieldInstanceId = @"InstanceId";
static NSString *const kFieldName = @"Name";
static NSString *const kFieldState = @"State";

@interface CAIDemoInstanceListVC () <UITableViewDataSource, UITableViewDelegate, TcrSessionObserver>

// 登录态与凭证
@property (nonatomic, copy) NSString *hostBaseUrl;
@property (nonatomic, copy, nullable) NSString *token;
@property (nonatomic, copy, nullable) NSString *accessInfo;
@property (nonatomic, assign) BOOL isTokenMode;     // YES：登录页已带入 Token/AccessInfo，无需再申请

// 列表数据
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *instances;
@property (nonatomic, strong) NSMutableSet<NSString *> *selectedIds;

// UI
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *selectAllBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UILabel *selectionLabel;
@property (nonatomic, strong) UIButton *enterBtn;
@property (nonatomic, strong) CAIDemoLoadingView *loadingView;

// 连接
@property (nonatomic, strong) TcrSession *session;
@property (nonatomic, strong) NSArray<NSString *> *connectingIds;

// 是否演示自定义音频采集（Demo 自采麦克风数据上行）。
// 置 NO 则使用 SDK 内部麦克风采集；开启后 SDK 不再占用麦克风，需调用方自行采集上行。
// 与 AVAudioSession mode 的关系：内部采集的 VPIO 开麦时会启用输入侧，被系统隐式拉为 VoiceChat（此时
// audioSessionMode=Default 传参无效）；自定义采集下 SDK 的采集 VPIO 输入侧禁用，不触发隐式拉回——
// 但若自采采集器自身也用 VPIO（见 CAIDemoAudioCapturor 子类型），其输入启用同样会拉回 VoiceChat。
@property (nonatomic, assign) BOOL enableCustomAudioCapture;

@end

@implementation CAIDemoInstanceListVC

- (instancetype)initWithHostBaseUrl:(NSString *)hostBaseUrl
                              token:(NSString *)token
                         accessInfo:(NSString *)accessInfo
                        instanceIds:(NSArray<NSString *> *)instanceIds {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _hostBaseUrl = [hostBaseUrl copy];
        _token = [token copy];
        _accessInfo = [accessInfo copy];
        _isTokenMode = (token.length > 0 && accessInfo.length > 0);
        _enableCustomAudioCapture = NO;
        _instances = [NSMutableArray new];
        _selectedIds = [NSMutableSet new];
        for (NSString *instanceId in instanceIds) {
            if (instanceId.length > 0) {
                [_instances addObject:@{kFieldInstanceId : instanceId}];
            }
        }
    }
    return self;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initSubviews];
    [self refreshBottomBar];

    // 账号模式下需要向体验服务器查询实例列表
    if (!self.isTokenMode) {
        [self loadInstances];
    } else {
        [self.tableView reloadData];
        [self refreshEmptyState];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    // 页面内已有自定义返回按钮；关闭侧滑返回，避免与实例操作页的左侧边缘手势冲突
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat topInset = self.view.safeAreaInsets.top;
    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
    CGFloat topBarHeight = topInset + 44;
    CGFloat bottomBarHeight = bottomInset + 60;

    self.topBar.frame = CGRectMake(0, 0, width, topBarHeight);
    self.backBtn.frame = CGRectMake(8, topInset, 60, 44);
    self.titleLabel.frame = CGRectMake(80, topInset, width - 160, 44);
    self.selectAllBtn.frame = CGRectMake(width - 88, topInset, 80, 44);

    self.tableView.frame = CGRectMake(0, topBarHeight, width, height - topBarHeight - bottomBarHeight);
    self.emptyLabel.frame = self.tableView.frame;

    self.bottomBar.frame = CGRectMake(0, height - bottomBarHeight, width, bottomBarHeight);
    self.selectionLabel.frame = CGRectMake(16, 0, width - 160, 60);
    self.enterBtn.frame = CGRectMake(width - 148, 10, 132, 40);

    self.loadingView.frame = self.view.bounds;
}

#pragma mark - UI

- (void)initSubviews {
    self.topBar = [[UIView alloc] init];
    self.topBar.backgroundColor = [CAIDemoUtils CAI_colorValue:@"0D2C61"];
    [self.view addSubview:self.topBar];

    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setTitle:@"< 返回" forState:UIControlStateNormal];
    [self.backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.backBtn addTarget:self action:@selector(onBackClick) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar addSubview:self.backBtn];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"实例列表";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.topBar addSubview:self.titleLabel];

    self.selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
    [self.selectAllBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.selectAllBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.selectAllBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.selectAllBtn addTarget:self action:@selector(onSelectAllClick) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar addSubview:self.selectAllBtn];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];

    // 账号模式支持下拉刷新实例列表
    if (!self.isTokenMode) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(loadInstances) forControlEvents:UIControlEventValueChanged];
        self.tableView.refreshControl = refreshControl;
    }

    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = @"暂无实例";
    self.emptyLabel.textColor = [UIColor grayColor];
    self.emptyLabel.font = [UIFont systemFontOfSize:15];
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.hidden = YES;
    self.emptyLabel.userInteractionEnabled = NO;
    [self.view addSubview:self.emptyLabel];

    self.bottomBar = [[UIView alloc] init];
    self.bottomBar.backgroundColor = [UIColor whiteColor];
    self.bottomBar.layer.borderWidth = 0.5;
    self.bottomBar.layer.borderColor = [CAIDemoUtils CAI_colorValue:@"E5E5E5"].CGColor;
    [self.view addSubview:self.bottomBar];

    self.selectionLabel = [[UILabel alloc] init];
    self.selectionLabel.font = [UIFont systemFontOfSize:14];
    self.selectionLabel.textColor = [UIColor darkGrayColor];
    [self.bottomBar addSubview:self.selectionLabel];

    self.enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.enterBtn setTitle:@"进入实例操作" forState:UIControlStateNormal];
    [self.enterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.enterBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.enterBtn.layer.cornerRadius = 6;
    self.enterBtn.layer.masksToBounds = YES;
    [self.enterBtn addTarget:self action:@selector(onEnterClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.enterBtn];

    self.loadingView = [[CAIDemoLoadingView alloc] initWithFrame:self.view.bounds process:0];
    self.loadingView.hidden = YES;
    [self.view addSubview:self.loadingView];
}

// 刷新底部已选数量与按钮可用态
- (void)refreshBottomBar {
    NSUInteger count = self.selectedIds.count;
    self.selectionLabel.text = [NSString stringWithFormat:@"已选择 %lu / %lu 台实例", (unsigned long)count, (unsigned long)self.instances.count];
    BOOL enabled = (count > 0);
    self.enterBtn.enabled = enabled;
    self.enterBtn.backgroundColor = [CAIDemoUtils CAI_colorValue:enabled ? @"006EFF" : @"006EFF20"];

    BOOL allSelected = (self.instances.count > 0 && count == self.instances.count);
    [self.selectAllBtn setTitle:allSelected ? @"取消全选" : @"全选" forState:UIControlStateNormal];
}

- (void)refreshEmptyState {
    self.emptyLabel.hidden = (self.instances.count > 0);
}

#pragma mark - 事件

- (void)onBackClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSelectAllClick {
    if (self.selectedIds.count == self.instances.count) {
        [self.selectedIds removeAllObjects];
    } else {
        for (NSDictionary *instance in self.instances) {
            [self.selectedIds addObject:instance[kFieldInstanceId]];
        }
    }
    [self.tableView reloadData];
    [self refreshBottomBar];
}

- (void)onEnterClick {
    NSArray<NSString *> *ids = [self orderedSelectedIds];
    if (ids.count == 0) {
        [self showToast:@"请先勾选实例"];
        return;
    }
    // 提前申请麦克风权限：开启自定义音频采集或后续点"开麦克风"时都需要，
    // 避免系统在建立带录音的会话时才弹窗打断连接流程。
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            NSLog(@"record permission denied");
        }
    }];
    self.connectingIds = ids;
    self.loadingView.hidden = NO;
    [self.loadingView setProcessValue:0];

    if (self.isTokenMode) {
        // 登录页已带入凭证，直接建立连接
        [self connectInstances:ids];
    } else {
        [self requestAccessTokenForInstanceIds:ids];
    }
}

// 按列表顺序返回已勾选的实例 ID
- (NSArray<NSString *> *)orderedSelectedIds {
    NSMutableArray<NSString *> *ids = [NSMutableArray new];
    for (NSDictionary *instance in self.instances) {
        NSString *instanceId = instance[kFieldInstanceId];
        if ([self.selectedIds containsObject:instanceId]) {
            [ids addObject:instanceId];
        }
    }
    return ids;
}

#pragma mark - 网络请求

#pragma mark +++ 流程(02)：查询实例列表
- (void)loadInstances {
    NSString *url = [self.hostBaseUrl stringByAppendingString:@"/DescribeAndroidInstances"];
    NSDictionary *params = @{
        @"InstanceIds" : @[],
        @"Limit" : @(100),
        @"Offset" : @(0),
        @"RequestId" : [[NSUUID UUID] UUIDString]
    };

    __weak typeof(self) weakSelf = self;
    [CAIDemoUtils CAI_postUrl:url params:params finishBlk:^(NSData *data, NSURLResponse *response, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        NSDictionary *result = [strongSelf parseResponse:data error:error failMsg:@"查询安卓实例失败"];
        if (result == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView.refreshControl endRefreshing];
            });
            return;
        }

#pragma mark +++ 流程(03)：解析Android实例信息
        NSArray *androidInstances = result[@"AndroidInstances"];
        NSMutableArray<NSDictionary *> *instances = [NSMutableArray new];
        for (NSDictionary *item in androidInstances) {
            if (![item isKindOfClass:[NSDictionary class]]) continue;
            NSString *instanceId = item[@"AndroidInstanceId"];
            if (instanceId.length == 0) continue;
            NSMutableDictionary *instance = [NSMutableDictionary new];
            instance[kFieldInstanceId] = instanceId;
            if ([item[@"Name"] isKindOfClass:[NSString class]]) {
                instance[kFieldName] = item[@"Name"];
            }
            if ([item[@"State"] isKindOfClass:[NSString class]]) {
                instance[kFieldState] = item[@"State"];
            }
            [instances addObject:instance];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.instances = instances;
            // 剔除已不存在的勾选项
            NSMutableSet *validIds = [NSMutableSet new];
            for (NSDictionary *instance in instances) {
                [validIds addObject:instance[kFieldInstanceId]];
            }
            [strongSelf.selectedIds intersectSet:validIds];

            [strongSelf.tableView.refreshControl endRefreshing];
            [strongSelf.tableView reloadData];
            [strongSelf refreshBottomBar];
            [strongSelf refreshEmptyState];
        });
    }];
}

#pragma mark +++ 流程(04)：为勾选的实例申请访问凭证
- (void)requestAccessTokenForInstanceIds:(NSArray<NSString *> *)instanceIds {
    NSString *url = [self.hostBaseUrl stringByAppendingString:@"/CreateAndroidInstancesAccessToken"];
    NSDictionary *params = @{
        @"AndroidInstanceIds" : instanceIds,
        @"ExpirationDuration" : @"12h",
        @"RequestId" : [[NSUUID UUID] UUIDString]
    };

    __weak typeof(self) weakSelf = self;
    [CAIDemoUtils CAI_postUrl:url params:params finishBlk:^(NSData *data, NSURLResponse *response, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        NSDictionary *result = [strongSelf parseResponse:data error:error failMsg:@"创建实例访问凭证失败"];
        if (result == nil) {
            [strongSelf stopConnect];
            return;
        }

#pragma mark +++ 流程(05)：获取Token和AccessInfo
        strongSelf.token = result[@"Token"];
        strongSelf.accessInfo = result[@"AccessInfo"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf connectInstances:instanceIds];
        });
    }];
}

// 统一解析体验服务器响应，失败时弹提示并返回 nil
- (NSDictionary *)parseResponse:(NSData *)data error:(NSError *)error failMsg:(NSString *)failMsg {
    if (error != nil || data == nil) {
        [self showToast:[NSString stringWithFormat:@"%@:%@", failMsg, error.userInfo.description]];
        return nil;
    }
    NSError *err = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    if (err != nil || ![json isKindOfClass:[NSDictionary class]]) {
        [self showToast:[NSString stringWithFormat:@"%@:%@", failMsg, err.userInfo.description]];
        return nil;
    }
    NSDictionary *response = ((NSDictionary *)json)[@"Response"];
    if (![response isKindOfClass:[NSDictionary class]]) {
        NSLog(@"%@: %@", failMsg, json);
        [self showToast:failMsg];
        return nil;
    }
    return response;
}

#pragma mark - 建立连接

#pragma mark +++ 流程(06)：给TcrSdk设置Token与AccessInfo，创建Session并连接
- (void)connectInstances:(NSArray<NSString *> *)instanceIds {
    if (self.token.length == 0 || self.accessInfo.length == 0) {
        [self showToast:@"Token 或 AccessInfo 为空"];
        [self stopConnect];
        return;
    }

    TcrConfig *tcrConfig = [[TcrConfig alloc] initWithToken:self.token accessInfo:self.accessInfo];
    NSError *tcrErr = nil;
    [[TcrSdkInstance sharedInstance] setTcrConfig:tcrConfig error:&tcrErr];
    if (tcrErr != nil) {
        [self showToast:[NSString stringWithFormat:@"TcrSdk 初始化失败:%@", tcrErr.userInfo.description]];
        [self stopConnect];
        return;
    }

#pragma mark +++ 流程(07)：创建TcrSession
    NSMutableDictionary *sessionConfig = [NSMutableDictionary dictionary];
    sessionConfig[@"local_audio"] = @(0);
    sessionConfig[@"preferredCodec"] = @"H264";
    sessionConfig[@"idleThreshold"] = @(6000);
    sessionConfig[@"sessionMode"] = @"ExclusiveSession";
    if (self.enableCustomAudioCapture) {
        // 自定义音频采集：声明采集的采样率与声道数后，SDK 不再使用内部麦克风采集，
        // 由 CAIDemoAudioCapturor 采集并通过 sendCustomAudioData:captureTimeNs: 上行。
        // 注意：自定义采集上行需要同时开启 local_audio；此处仅声明参数，
        // 实际采集在用户点"开麦克风"时才开始（onEnableLocalAudio:）。
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSInteger sampleRate = (NSInteger)[audioSession sampleRate];
        NSInteger channelCount = 1;
        [CAIDemoAudioCapturor configureAudioCapturor:sampleRate channelCount:channelCount dumpAudio:NO];
        sessionConfig[@"enableCustomAudioCapture"] = @{@"sampleRate": @(sampleRate), @"useStereoInput": @(channelCount == 2)};
        sessionConfig[@"local_audio"] = @(1);
    }
    self.session = [[TcrSdkInstance sharedInstance] createSessionWithParams:sessionConfig];
    [self.session setTcrSessionObserver:self];

    // 勾选多台时按群控方式接入，单台时按单实例接入
    if (instanceIds.count > 1) {
        [self.session accessWithInstanceIds:instanceIds];
    } else {
        [self.session accessWithInstanceId:instanceIds.firstObject];
    }
}

- (void)onEvent:(TcrEvent)event eventData:(id)eventData {
#pragma mark +++ 流程(08)：跳转到实例操作页面
    if (event == STATE_CONNECTED) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self gotoGroupControlVC];
        });
    } else if (event == STATE_CLOSED) {
        NSInteger code = [eventData respondsToSelector:@selector(integerValue)] ? [eventData integerValue] : 0;
        NSLog(@"[TCR] session closed with code: %ld, eventData: %@", (long)code, eventData);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showToast:[NSString stringWithFormat:@"建立会话失败，错误码:%ld", (long)code]];
            [self stopConnect];
        });
    }
}

- (void)gotoGroupControlVC {
    CAIDemoGroupControlVC *subVC = [[CAIDemoGroupControlVC alloc] initWithTcrSession:self.session
                                                                         instancesId:self.connectingIds
                                                                         loadingView:self.loadingView];
    [self addChildViewController:subVC];
    subVC.view.frame = self.view.bounds;
    [self.view insertSubview:subVC.view belowSubview:self.loadingView];
    [subVC didMoveToParentViewController:self];
    [self.loadingView setProcessValue:80];
    // 会话已交由实例操作页持有，这里释放本页的引用
    self.session = nil;
}

- (void)stopConnect {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TcrSdkInstance sharedInstance] destroySession:self.session];
        self.session = nil;
        self.loadingView.hidden = YES;
    });
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.instances.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kInstanceCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kInstanceCellId];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }

    NSDictionary *instance = self.instances[indexPath.row];
    NSString *instanceId = instance[kFieldInstanceId];
    NSString *name = instance[kFieldName];
    NSString *state = instance[kFieldState];

    cell.textLabel.text = name.length > 0 ? name : instanceId;
    if (name.length > 0 && state.length > 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ · %@", instanceId, state];
    } else if (state.length > 0) {
        cell.detailTextLabel.text = state;
    } else {
        cell.detailTextLabel.text = name.length > 0 ? instanceId : @"";
    }
    cell.accessoryType = [self.selectedIds containsObject:instanceId] ? UITableViewCellAccessoryCheckmark
                                                                     : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *instanceId = self.instances[indexPath.row][kFieldInstanceId];
    if ([self.selectedIds containsObject:instanceId]) {
        [self.selectedIds removeObject:instanceId];
    } else {
        [self.selectedIds addObject:instanceId];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self refreshBottomBar];
}

#pragma mark - 提示

- (void)showToast:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

@end
