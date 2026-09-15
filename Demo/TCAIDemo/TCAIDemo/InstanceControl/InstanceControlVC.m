#import "InstanceControlVC.h"
#import "StreamingVC.h"
#import "CAICloudPhoneCell.h"
#import "CAIDemoIcon.h"
#import "InstanceApiMenuView.h"
#import "CAIDemoAccessibilityIds.h"

@interface InstanceControlVC () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CAICloudPhoneCellDelegate>
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *backBtn;

@property (strong, nonatomic) NSMutableDictionary *dataDict;
@property (strong, nonatomic) NSMutableArray *orderedKeys;   // 保持展示顺序的实例 ID
@property (strong, nonatomic) NSMutableArray *instanceIds;
@property (strong, nonatomic) NSString* masterId;   // 非空表示正在主控中
@property (nonatomic, strong) NSMutableSet *slaveInstanceIds;

@property (strong, nonatomic) dispatch_queue_t imageEventQueue;

// 截图轮询：无会话状态下用 HTTP 截图接口刷新预览画面
@property (strong, nonatomic) dispatch_source_t previewTimer;
@property (strong, nonatomic) NSURLSession *previewUrlSession;
@property (strong, nonatomic) NSMutableSet<NSString *> *fetchingInstanceIds;

@property (assign, nonatomic) BOOL isScreenShotVisible;
@property (weak, nonatomic) AndroidInstance* androidInstance;

@property (strong, nonatomic) UIButton *settingsButton;
/// 实例操作菜单：懒加载，接口清单与调用示例都在 InstanceApiMenuView 内
@property (strong, nonatomic) InstanceApiMenuView *apiMenuView;

@end

@implementation InstanceControlVC

- (instancetype)initWithInstanceIds:(NSArray<NSString *> *)instanceIds {
    self = [super init];
    if (self) {
        self.instanceIds = [NSMutableArray new];
        [self.instanceIds addObjectsFromArray:instanceIds];
        self.androidInstance = [[TcrSdkInstance sharedInstance] getAndroidInstance];
        self.slaveInstanceIds = [NSMutableSet new];
        [self.slaveInstanceIds addObjectsFromArray:instanceIds];
        self.isScreenShotVisible = false;
        self.fetchingInstanceIds = [NSMutableSet new];

        _imageEventQueue = dispatch_queue_create("com.tencent.tcr.demo.image_event", DISPATCH_QUEUE_SERIAL);

        NSURLSessionConfiguration *urlCfg = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        urlCfg.timeoutIntervalForRequest = 5;
        _previewUrlSession = [NSURLSession sessionWithConfiguration:urlCfg];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopPreviewPolling];
    [self.previewUrlSession invalidateAndCancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    _dataDict = [NSMutableDictionary dictionary];
    _orderedKeys = [NSMutableArray array];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 12;     // 行间距
    layout.minimumInteritemSpacing = 8; // 列间距
    layout.sectionInset = UIEdgeInsetsMake(12, 12, 12, 12);

    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.accessibilityIdentifier = CAIIdControlGrid;
    [_collectionView registerClass:[CAICloudPhoneCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:_collectionView];

    [self createBackButton];
    [self createCustomSettingsButton];
    [self createLoadingView];

    // 退到后台时截图请求必然失败，暂停轮询（切后台不会触发 viewWillDisappear）
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [self loadPlaceholders];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 从串流页返回：清除主控标记，cell 会重新渲染为未主控态
    if (self.masterId != nil) {
        self.masterId = nil;
        [self.collectionView reloadData];
    }
    // 首次进入与从串流页返回都走这里：预览画面走 HTTP 截图轮询，不需要串流连接
    [self startPreviewPolling];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 进入串流页（画面改由串流提供）或本页出栈，都应停止轮询，避免与串流争抢带宽
    [self stopPreviewPolling];
    if (self.isMovingFromParentViewController) {
        self.androidInstance = nil;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat topInset = self.view.safeAreaInsets.top;
    self.collectionView.frame = self.view.bounds;
    self.collectionView.contentInset = UIEdgeInsetsMake(topInset + 44, 0, self.view.safeAreaInsets.bottom, 0);
    self.backBtn.frame = CGRectMake(8, topInset, 70, 44);
    self.settingsButton.frame = CGRectMake(self.view.bounds.size.width - 60, topInset, 40, 40);
    self.loadingView.frame = self.view.bounds;
}

- (void)onAppDidEnterBackground {
    [self stopPreviewPolling];
}

- (void)onAppWillEnterForeground {
    // 只有本页正在显示时才恢复：停在串流页或已出栈时 window 为空
    if (self.view.window != nil) {
        [self startPreviewPolling];
    }
}

- (void)loadPlaceholders {
    for (NSString *key in self.instanceIds) {
        self.dataDict[key] = @{@"image": [self generatePlaceholderImage]};
        [self.orderedKeys addObject:key];
    }
    [self.collectionView reloadData];
}

#pragma mark - 截图轮询（无会话）

/**
 * 启动预览轮询。
 *
 * 这里没有使用 SDK 的 setImageEventWithInterval：该接口虽然内部也是 HTTP 拉取截图，
 * 但结果要经 TcrSession 的 CAI_IMAGE_EVENT 回调，会强制本页依赖一条串流连接。
 * 改由本页直接调用 getInstanceImageWithInstanceId（纯 HTTP，只依赖凭证），
 * 用户停留在本页时就不会建立串流连接。
 */
- (void)startPreviewPolling {
    if (self.previewTimer != nil) {
        return;
    }
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.imageEventQueue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0), 1 * NSEC_PER_SEC, 100 * NSEC_PER_MSEC);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        [weakSelf fetchPreviewImages];
    });
    self.previewTimer = timer;
    dispatch_resume(timer);
}

- (void)stopPreviewPolling {
    if (self.previewTimer != nil) {
        dispatch_source_cancel(self.previewTimer);
        self.previewTimer = nil;
    }
}

- (void)fetchPreviewImages {
    for (NSString *instanceId in [self.instanceIds copy]) {
        // 上一轮尚未回来的实例跳过，避免弱网下请求堆积
        @synchronized (self.fetchingInstanceIds) {
            if ([self.fetchingInstanceIds containsObject:instanceId]) {
                continue;
            }
            [self.fetchingInstanceIds addObject:instanceId];
        }

        NSString *urlString = [self.androidInstance getInstanceImageWithInstanceId:instanceId
                                                                           quality:20
                                                                   screenshotWidth:720
                                                                  screenshotHeight:1280];
        NSURL *url = urlString.length > 0 ? [NSURL URLWithString:urlString] : nil;
        if (url == nil) {
            @synchronized (self.fetchingInstanceIds) {
                [self.fetchingInstanceIds removeObject:instanceId];
            }
            continue;
        }

        __weak typeof(self) weakSelf = self;
        NSURLSessionDataTask *task = [self.previewUrlSession dataTaskWithURL:url
                                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf == nil) return;
            @synchronized (strongSelf.fetchingInstanceIds) {
                [strongSelf.fetchingInstanceIds removeObject:instanceId];
            }
            if (error != nil || data == nil) {
                return;
            }
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (image == nil) {
                return;
            }
            [strongSelf updatePreviewImage:image forInstanceId:instanceId];
        }];
        [task resume];
    }
}

- (void)updatePreviewImage:(UIImage *)image forInstanceId:(NSString *)instanceId {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataDict[instanceId] = @{@"image": image};
        NSUInteger index = [self.orderedKeys indexOfObject:instanceId];
        if (index != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [UIView performWithoutAnimation:^{
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
        }
        // 首张截图到达即认为本页就绪
        if (self.isScreenShotVisible == false) {
            self.isScreenShotVisible = true;
            [self.loadingView stopAnimating];
        }
    });
}

- (UIImage *)generatePlaceholderImage {
    UIGraphicsBeginImageContext(CGSizeMake(100, 100));
    [[UIColor colorWithRed:arc4random_uniform(255)/255.0
                    green:arc4random_uniform(255)/255.0
                     blue:arc4random_uniform(255)/255.0
                    alpha:1.0] setFill];
    UIRectFill(CGRectMake(0, 0, 100, 100));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - 退出本页

- (void)onBackClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Cell Delegate

/**
 * 点击「设为主控」：进入串流页，由串流页创建会话并接入云端。
 *
 * 本页只做预览，不接触 TcrSession，用户浏览期间不会建立串流连接。
 */
- (void)cellDidSelectMasterForInstanceId:(NSString *)instanceId {
    if (self.masterId != nil) {
        NSLog(@"已在主控中，忽略重复请求");
        return;
    }

    self.masterId = instanceId;
    CAICloudPhoneCell *currentCell = [self cellForInstanceId:instanceId];
    currentCell.masterButton.selected = YES;
    NSLog(@"masterId = %@", self.masterId);

    // 轮询由 viewWillDisappear 统一停止
    [self gotoStreamingVC];
}

/// 勾选为被控的实例（不含主控自身）
- (NSArray<NSString *> *)orderedSlaveIds {
    NSMutableArray<NSString *> *ids = [NSMutableArray new];
    for (NSString *instanceId in self.instanceIds) {
        if (![instanceId isEqualToString:self.masterId] && [self.slaveInstanceIds containsObject:instanceId]) {
            [ids addObject:instanceId];
        }
    }
    return ids;
}

- (void)cell:(CAICloudPhoneCell *)cell didChangeSlaveState:(BOOL)isSlave forInstanceId:(NSString *)instanceId {
    if (isSlave) {
        [self.slaveInstanceIds addObject:instanceId];
    } else {
        [self.slaveInstanceIds removeObject:instanceId];
    }
    NSLog(@"slaveInstanceIds = %@", self.slaveInstanceIds);
}

- (CAICloudPhoneCell *)cellForInstanceId:(NSString *)instanceId {
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        CAICloudPhoneCell *cell = (CAICloudPhoneCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if ([cell.instanceId isEqualToString:instanceId]) {
            return cell;
        }
    }
    return nil;
}

- (void)gotoStreamingVC {
    StreamingVC *playVC = [[StreamingVC alloc] initWithMasterId:self.masterId slaveIds:[self orderedSlaveIds]];
    [self.navigationController pushViewController:playVC animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.orderedKeys.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CAICloudPhoneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    NSString *key = self.orderedKeys[indexPath.item];
    cell.imageView.image = self.dataDict[key][@"image"];
    cell.textLabel.text = key;
    cell.instanceId = key;
    // 用实例 ID 作为标识，UI 测试可定位到指定实例的主控/被控按钮
    cell.accessibilityIdentifier = key;
    cell.delegate = self;
    cell.masterButton.selected = [key isEqualToString:self.masterId];
    cell.slaveCheckbox.selected = [self.slaveInstanceIds containsObject:key];
    cell.layer.cornerRadius = 8;
    cell.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat padding = 8;
    CGFloat screenWidth = self.view.bounds.size.width;

    CGFloat devicesPerRow = 2.0f;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        devicesPerRow = 8.0f;
    }

    // 12 为左右内边距，8 为列间距
    CGFloat cellWidth = (screenWidth - 12 * 2 - 8) / devicesPerRow;
    CGFloat imageHeight = cellWidth * 16.0 / 9.0;
    CGFloat textHeight = [self.orderedKeys[indexPath.item] boundingRectWithSize:CGSizeMake(cellWidth - padding * 2, CGFLOAT_MAX)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                                                       context:nil].size.height;

    return CGSizeMake(cellWidth, padding + imageHeight + padding + textHeight + padding);
}

#pragma mark - 顶部控件

/// 返回按钮：与系统侧滑返回等价，二者都会走 viewWillDisappear 停止轮询
- (void)createBackButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.accessibilityIdentifier = CAIIdControlBack;
    [btn addTarget:self action:@selector(onBackClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    self.backBtn = btn;
}

/// 首张截图到达前显示等待动画，之后由 updatePreviewImage 停止
- (void)createLoadingView {
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.loadingView.accessibilityIdentifier = CAIIdLoading;
    [self.loadingView startAnimating];
    [self.view addSubview:self.loadingView];
}

#pragma mark - 设置菜单

/// 设置按钮：点击弹出实例操作菜单，接口清单与调用示例都在 InstanceApiMenuView 内
- (void)createCustomSettingsButton {
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingsButton setImage:[CAIDemoIcon imageWithSystemName:@"gear" fallbackAssetName:@"setting"]
                         forState:UIControlStateNormal];
    self.settingsButton.tintColor = [UIColor systemBlueColor];
    self.settingsButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    self.settingsButton.layer.cornerRadius = 20;
    self.settingsButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.settingsButton.layer.shadowOffset = CGSizeMake(0, 2);
    self.settingsButton.layer.shadowOpacity = 0.3;
    self.settingsButton.layer.shadowRadius = 4;
    self.settingsButton.accessibilityIdentifier = CAIIdControlSettings;
    [self.settingsButton addTarget:self action:@selector(onSettingsClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingsButton];
}

- (void)onSettingsClick {
    if (self.apiMenuView == nil) {
        self.apiMenuView = [[InstanceApiMenuView alloc] initWithAndroidInstance:self.androidInstance
                                                                   instanceIds:self.instanceIds];
        self.apiMenuView.accessibilityIdentifier = CAIIdControlApiMenu;
    }
    [self.apiMenuView showInView:self.view];
}

@end
