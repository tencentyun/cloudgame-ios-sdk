#import "InstanceListVC.h"
#import "InstanceControlVC.h"
#import "ExpServerRequest.h"
#import "DemoToast.h"
#import "CAIDemoAccessibilityIds.h"
#import <TCRSDK/TCRSDK.h>

static NSString *const kInstanceCellId = @"CAIDemoInstanceCell";

// 实例列表数据字段
static NSString *const kFieldInstanceId = @"InstanceId";
static NSString *const kFieldName = @"Name";
static NSString *const kFieldState = @"State";

@interface InstanceListVC () <UITableViewDataSource, UITableViewDelegate>

// 登录态与凭证
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
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

// 本次进入功能页的实例
@property (nonatomic, strong) NSArray<NSString *> *connectingIds;

@end

@implementation InstanceListVC

- (instancetype)initWithToken:(NSString *)token
                   accessInfo:(NSString *)accessInfo
                  instanceIds:(NSArray<NSString *> *)instanceIds {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _token = [token copy];
        _accessInfo = [accessInfo copy];
        _isTokenMode = (token.length > 0 && accessInfo.length > 0);
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
    [self.loadingView stopAnimating];
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
    self.topBar.backgroundColor = [UIColor systemBlueColor];
    [self.view addSubview:self.topBar];

    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setTitle:@"< 返回" forState:UIControlStateNormal];
    [self.backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.backBtn.accessibilityIdentifier = CAIIdListBack;
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
    self.selectAllBtn.accessibilityIdentifier = CAIIdListSelectAll;
    [self.selectAllBtn addTarget:self action:@selector(onSelectAllClick) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar addSubview:self.selectAllBtn];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60;
    self.tableView.accessibilityIdentifier = CAIIdListTable;
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
    self.emptyLabel.accessibilityIdentifier = CAIIdListEmpty;
    self.emptyLabel.hidden = YES;
    self.emptyLabel.userInteractionEnabled = NO;
    [self.view addSubview:self.emptyLabel];

    self.bottomBar = [[UIView alloc] init];
    self.bottomBar.backgroundColor = [UIColor whiteColor];
    self.bottomBar.layer.borderWidth = 0.5;
    self.bottomBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:self.bottomBar];

    self.selectionLabel = [[UILabel alloc] init];
    self.selectionLabel.font = [UIFont systemFontOfSize:14];
    self.selectionLabel.textColor = [UIColor darkGrayColor];
    self.selectionLabel.accessibilityIdentifier = CAIIdListSelectionInfo;
    [self.bottomBar addSubview:self.selectionLabel];

    self.enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.enterBtn setTitle:@"进入实例操作" forState:UIControlStateNormal];
    [self.enterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.enterBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.enterBtn.layer.cornerRadius = 6;
    self.enterBtn.layer.masksToBounds = YES;
    self.enterBtn.accessibilityIdentifier = CAIIdListEnter;
    [self.enterBtn addTarget:self action:@selector(onEnterClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.enterBtn];

    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.loadingView.accessibilityIdentifier = CAIIdLoading;
    [self.view addSubview:self.loadingView];
}

// 刷新底部已选数量与按钮可用态
- (void)refreshBottomBar {
    NSUInteger count = self.selectedIds.count;
    self.selectionLabel.text = [NSString stringWithFormat:@"已选择 %lu / %lu 台实例", (unsigned long)count, (unsigned long)self.instances.count];
    BOOL enabled = (count > 0);
    self.enterBtn.enabled = enabled;
    self.enterBtn.backgroundColor = enabled ? [UIColor systemBlueColor]
                                            : [[UIColor systemBlueColor] colorWithAlphaComponent:0.3];

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
        [DemoToast showInViewController:self message:@"请先勾选实例"];
        return;
    }
    self.connectingIds = ids;
    [self.loadingView startAnimating];

    if (self.isTokenMode) {
        // 登录页已带入凭证，直接进入功能页
        [self initSdkAndGotoInstanceControlVC:ids];
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
    NSDictionary *params = @{
        @"InstanceIds" : @[],
        @"Limit" : @(100),
        @"Offset" : @(0),
        @"RequestId" : [[NSUUID UUID] UUIDString]
    };

    __weak typeof(self) weakSelf = self;
    [ExpServerRequest postPath:@"/DescribeAndroidInstances" params:params completion:^(NSDictionary *result, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        if (error != nil) {
            [DemoToast showInViewController:strongSelf message:[NSString stringWithFormat:@"查询实例失败：%@", error.localizedDescription]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView.refreshControl endRefreshing];
            });
            return;
        }

#pragma mark +++ 流程(03)：解析Android实例信息
        NSMutableArray<NSDictionary *> *instances = [NSMutableArray new];
        for (NSDictionary *item in result[@"AndroidInstances"]) {
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
    NSDictionary *params = @{
        @"AndroidInstanceIds" : instanceIds,
        @"ExpirationDuration" : @"12h",
        @"RequestId" : [[NSUUID UUID] UUIDString]
    };

    __weak typeof(self) weakSelf = self;
    [ExpServerRequest postPath:@"/CreateAndroidInstancesAccessToken" params:params completion:^(NSDictionary *result, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        if (error != nil) {
            [DemoToast showInViewController:strongSelf message:[NSString stringWithFormat:@"申请访问凭证失败：%@", error.localizedDescription]];
            [strongSelf stopLoading];
            return;
        }

#pragma mark +++ 流程(05)：获取Token和AccessInfo
        strongSelf.token = result[@"Token"];
        strongSelf.accessInfo = result[@"AccessInfo"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf initSdkAndGotoInstanceControlVC:instanceIds];
        });
    }];
}

#pragma mark - 进入功能页

#pragma mark +++ 流程(06)：给TcrSdk设置Token与AccessInfo
/**
 * 初始化 SDK 凭证并进入功能页。
 *
 * 这里只做 setAccessToken：截图、文件、应用管理等实例操作接口都只依赖凭证走 HTTP，
 * 不需要 TcrSession。串流会话推迟到进入串流页 StreamingVC 时才创建，
 * 避免用户只浏览实例列表与画面时就建立串流连接。
 */
- (void)initSdkAndGotoInstanceControlVC:(NSArray<NSString *> *)instanceIds {
    if (self.token.length == 0 || self.accessInfo.length == 0) {
        [DemoToast showInViewController:self message:@"Token 或 AccessInfo 为空"];
        [self stopLoading];
        return;
    }

    NSError *tcrErr = nil;
    [[TcrSdkInstance sharedInstance] setAccessToken:self.accessInfo token:self.token error:&tcrErr];
    if (tcrErr != nil) {
        [DemoToast showInViewController:self message:[NSString stringWithFormat:@"TcrSdk 初始化失败:%@", tcrErr.userInfo.description]];
        [self stopLoading];
        return;
    }

#pragma mark +++ 流程(07)：进入功能页（截图轮询，无连接）
    [self gotoInstanceControlVC];
}

- (void)gotoInstanceControlVC {
    [self stopLoading];
    InstanceControlVC *functionVC = [[InstanceControlVC alloc] initWithInstanceIds:self.connectingIds];
    [self.navigationController pushViewController:functionVC animated:YES];
}

- (void)stopLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView stopAnimating];
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
    // 用实例 ID 作为标识，UI 测试可直接定位到指定实例，失败信息里也能看出是哪一台
    cell.accessibilityIdentifier = instanceId;
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

@end
