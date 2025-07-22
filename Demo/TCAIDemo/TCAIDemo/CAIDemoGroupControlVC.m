//
//  CAIDemoGroupControlVC.m
//  TCAIDemo
//
//  Created by Junfeng Gao on 2025/7/10.
//

#import <Foundation/Foundation.h>
#import "CAIDemoLoadingView.h"
#import "CAIDemoGroupControlVC.h"
#import <CoreMotion/CoreMotion.h>
#import "CAIDemoMasterControlVC.h"

// 自定义日志宏
#define ApiTestNSLog(format, ...) do { \
    NSString *message = [NSString stringWithFormat:format, ##__VA_ARGS__]; \
    NSLog(@"[GroupControlApiTest] %@", message); \
} while(0)

@implementation ComponentCloudPhoneCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 配置图片视图 (9:16)
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor lightGrayColor];
        
        // 配置文本标签
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:10];
        _textLabel.numberOfLines = 0;
        _textLabel.textColor = [UIColor darkTextColor];
        
        // 添加加载指示器
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        
        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_textLabel];
        [self.contentView addSubview:_activityIndicator];
        
        // 添加约束
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        
        // 添加主控按钮
         _masterButton = [UIButton buttonWithType:UIButtonTypeSystem];
         [_masterButton setTitle:@"设为主控" forState:UIControlStateNormal];
         [_masterButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
         [_masterButton setTitle:@"主控中" forState:UIControlStateSelected];
         [_masterButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
         _masterButton.titleLabel.font = [UIFont systemFontOfSize:12];
         _masterButton.layer.borderWidth = 1;
         _masterButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
         _masterButton.layer.cornerRadius = 4;
         [_masterButton addTarget:self action:@selector(masterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
         
         // 添加被控复选框
         _slaveCheckbox = [UIButton buttonWithType:UIButtonTypeCustom];
         [_slaveCheckbox setImage:[UIImage systemImageNamed:@"square"] forState:UIControlStateNormal];
         [_slaveCheckbox setImage:[UIImage systemImageNamed:@"checkmark.square.fill"] forState:UIControlStateSelected];
         [_slaveCheckbox setTitle:@" 被控" forState:UIControlStateNormal];
         [_slaveCheckbox setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
         _slaveCheckbox.titleLabel.font = [UIFont systemFontOfSize:12];
         [_slaveCheckbox addTarget:self action:@selector(slaveCheckboxTapped:) forControlEvents:UIControlEventTouchUpInside];
         
         // 创建控制容器
         UIStackView *controlStack = [[UIStackView alloc] initWithArrangedSubviews:@[_masterButton, _slaveCheckbox]];
         controlStack.axis = UILayoutConstraintAxisHorizontal;
         controlStack.distribution = UIStackViewDistributionFillEqually;
         controlStack.spacing = 8;
         
         [self.contentView addSubview:controlStack];
         
         // 布局约束
         controlStack.translatesAutoresizingMaskIntoConstraints = NO;
         [NSLayoutConstraint activateConstraints:@[
            [_imageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
            [_imageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8],
            [_imageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8],
            [_imageView.heightAnchor constraintEqualToAnchor:_imageView.widthAnchor multiplier:16.0/9.0],
            
            [_textLabel.topAnchor constraintEqualToAnchor:_imageView.bottomAnchor constant:8],
            [_textLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8],
            [_textLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8],
            
            [controlStack.topAnchor constraintEqualToAnchor:_textLabel.bottomAnchor constant:8],
            [controlStack.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8],
            [controlStack.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8],
            [controlStack.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
            [controlStack.heightAnchor constraintEqualToConstant:30],
            
            [_activityIndicator.centerXAnchor constraintEqualToAnchor:_imageView.centerXAnchor],
            [_activityIndicator.centerYAnchor constraintEqualToAnchor:_imageView.centerYAnchor],

         ]];
    }
    return self;
}

- (void)masterButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cellDidSelectMasterForInstanceId:)]) {
        [self.delegate cellDidSelectMasterForInstanceId:_instanceId];
    }
}

- (void)slaveCheckboxTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(cell:didChangeSlaveState:forInstanceId:)]) {
        [self.delegate cell:self didChangeSlaveState:sender.selected forInstanceId:_instanceId];
    }
}

@end

// CAIDemoGroupControlVC.m

#import "CAIDemoGroupControlVC.h"

@interface CAIDemoGroupControlVC () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TcrSessionObserver, ComponentCloudPhoneCellDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) CAIDemoLoadingView *loadingView;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftEdgeGesture;

@property (strong, nonatomic) NSMutableDictionary *dataDict; // 改为字典存储
@property (strong, nonatomic) NSMutableArray *orderedKeys;   // 保持顺序的键数组
@property (strong, nonatomic) NSMutableDictionary *cloudPhoneView;
@property (strong, nonatomic) NSMutableArray *instanceIds;
@property (strong, nonatomic) TcrSession* session;
@property (strong, nonatomic) NSString* masterId;
@property (nonatomic, strong) NSMutableSet *slaveInstanceIds;

@property (strong, nonatomic) dispatch_queue_t imageEventQueue;
@property (strong, nonatomic) dispatch_queue_t imageFetchQueue;

@property (assign, nonatomic) BOOL isScreenShotVisible;
@property (weak, nonatomic) AndroidInstance* androidInstance;

@property (strong, nonatomic) UIButton *settingsButton;
@property (strong, nonatomic) UIView *settingsMenuView;
@property (assign, nonatomic) BOOL isMenuVisible;
@property (strong, nonatomic) UIScrollView *menuScrollView;
@property (strong, nonatomic) NSArray<NSDictionary *> *apiActions;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (assign, nonatomic) BOOL isEnableSensor;

@end

@implementation CAIDemoGroupControlVC

- (instancetype)initWithTcrSession:(TcrSession *)session instancesId:(NSArray *)instanceIds loadingView:(UIView *)loadingView {
    self = [super init];
    if (self) {
        self.instanceIds = [NSMutableArray new];
        [self.instanceIds addObjectsFromArray:instanceIds];
        self.session = session;
        self.loadingView = (CAIDemoLoadingView *)loadingView;
        self.androidInstance = [[TcrSdkInstance sharedInstance] getAndroidInstance];
        self.motionManager = [[CMMotionManager alloc] init];
        self.isEnableSensor = false;
        // self.masterId = @"cai-1300056159-fe2dw5OoAn9";
        self.slaveInstanceIds = [NSMutableSet new];
        [self.slaveInstanceIds addObjectsFromArray:instanceIds];
        self.isScreenShotVisible = false;

        _imageEventQueue = dispatch_queue_create("com.tencent.tcr.demo.image_event", DISPATCH_QUEUE_SERIAL);
        _imageFetchQueue = dispatch_queue_create("com.tencent.tcr.demo.image_fetch", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgeGesture:)];
    self.leftEdgeGesture.edges = UIRectEdgeLeft;
    self.leftEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:self.leftEdgeGesture];
    
    // 初始化数据源
    _dataDict = [NSMutableDictionary dictionary];
    _orderedKeys = [NSMutableArray array];
    
    // 创建瀑布流布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 12;     // 行间距
    layout.minimumInteritemSpacing = 8; // 列间距
    layout.sectionInset = UIEdgeInsetsMake(12, 12, 12, 12);
    
    // 创建集合视图
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[ComponentCloudPhoneCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:_collectionView];
    
    [self createCustomSettingsButton];
    
    // 初始加载数据
    [self loadMoreData];
}

- (void)loadMoreData {
    // 设置TcrSession事件监听回调
    [self.session setTcrSessionObserver:self];

    // 开始群控
    [self.androidInstance setSyncList:self.instanceIds];

    // 设置截图回调setImageEventWithInterval
    [self.androidInstance setImageEventWithInterval:1000 quality:@20 screenshotWidth:720 screenshotHeight:1280];
    
    for (int i = 0; i < _instanceIds.count; i++) {
        NSString *key = _instanceIds[i];
        UIImage *image = [self generatePlaceholderImage];
        
        self.dataDict[key] = @{@"image": image};
        [self.orderedKeys addObject:key];
    }
    [self.collectionView reloadData];
}

- (UIImage *)generatePlaceholderImage {
    // 创建占位图
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

#pragma mark - 销毁TcrSession连接
- (void)releaseSession {
    // 停止截图回调
    [self.androidInstance stopImageEvent];
    // 停止群控操作
    [self.androidInstance setSyncList:nil];
    // 销毁实例连接
    [[TcrSdkInstance sharedInstance] destroySession:self.session];
    self.session = nil;
    self.androidInstance = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self willMoveToParentViewController:self.parentViewController];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    });
}


#pragma mark - TcrEvent
- (void)onEvent:(TcrEvent)event eventData:(id)eventData {
    switch (event) {
        case CAI_IMAGE_EVENT: {
            // 处理图片事件
            dispatch_async(_imageEventQueue, ^{
                if ([eventData isKindOfClass:[NSDictionary class]]) {
                    NSDictionary<NSString*, NSString*> *imageData = (NSDictionary *)eventData;
                    [imageData enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull urlString, BOOL * _Nonnull stop) {
                        NSURL *url = [NSURL URLWithString:urlString];
                        UIImage *imgFromUrl = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:url]];
                        if (imgFromUrl == nil) {
                            NSLog(@"imgFromUrl:%@ is nil", urlString);
                            return;
                        }
                        self.dataDict[key] = @{@"image": imgFromUrl};
                        
                        // 如果键不存在于有序数组中，添加它
                        if (![self.orderedKeys containsObject:key]) {
                            [self.orderedKeys addObject:key];
                        }
                    }];
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 刷新单元格
                        [self.dataDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                            NSUInteger index = [self.orderedKeys indexOfObject:key];
                            if (index != NSNotFound) {
                                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                                [UIView performWithoutAnimation:^{
                                    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                                }];
                            }
                        }];
                        
                        if (self.isScreenShotVisible == false) {
                            [self.loadingView setProcessValue:100];
                            self.isScreenShotVisible = true;
                            self.loadingView.hidden = YES;
                        }
                    });
                }
            });
            break;
        }
        case CAI_CLIPBOARD:
            ApiTestNSLog(@"CAI_CLIPBOARD: %@", (NSString *)eventData);
            break;
        case CAI_NOTIFICATION:
            ApiTestNSLog(@"CAI_NOTIFICATION: %@", (NSString *)eventData);
            break;
        case CAI_SYSTEM_USAGE:
            ApiTestNSLog(@"CAI_SYSTEM_USAGE: %@", (NSString *)eventData);
            break;
        case CAI_SYSTEM_STATUS:
            ApiTestNSLog(@"CAI_SYSTEM_STATUS: %@", (NSString *)eventData);
            break;
        case CAI_TRANS_MESSAGE:
            ApiTestNSLog(@"CAI_TRANS_MESSAGE: %@", (NSString *)eventData);
            break;
        default:
            break;
    }
}

#pragma mark - Cell Delegate
- (void)cellDidSelectMasterForInstanceId:(NSString *)instanceId {
    [_loadingView setProcessValue:0];
    _loadingView.hidden = NO;
    
    // 设置新的主控
    self.masterId = instanceId;
    ComponentCloudPhoneCell *currentCell = [self cellForInstanceId:instanceId];
    currentCell.masterButton.selected = YES;
    
    ApiTestNSLog(@"masterId = %@", self.masterId);
    
    [self.androidInstance setSyncList:[self.slaveInstanceIds allObjects]];
    [self.androidInstance setMasterWithInstanceId:self.masterId];
    
    // 启动主控界面
    [self gotoMasterControlVC];
}

- (void)cell:(ComponentCloudPhoneCell *)cell didChangeSlaveState:(BOOL)isSlave forInstanceId:(NSString *)instanceId {
    if (isSlave) {
        [self.slaveInstanceIds addObject:instanceId];
    } else {
        [self.slaveInstanceIds removeObject:instanceId];
    }
    
    ApiTestNSLog(@"slaveInstanceIds = %@", self.slaveInstanceIds);
}

- (ComponentCloudPhoneCell *)cellForInstanceId:(NSString *)instanceId {
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        ComponentCloudPhoneCell *cell = (ComponentCloudPhoneCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if ([cell.instanceId isEqualToString:instanceId]) {
            return cell;
        }
    }
    return nil;
}

- (void)gotoMasterControlVC {

    CAIDemoMasterControlVC *subVC = [[CAIDemoMasterControlVC alloc] initWithPlay:self.session
                                                           loadingView:_loadingView];
    [self addChildViewController:subVC];
    subVC.view.frame = self.view.bounds;
    [self.view insertSubview:subVC.view belowSubview:_loadingView];
    [subVC didMoveToParentViewController:self];
    __weak typeof(self)weakSelf = self;
    [subVC setStopControlBlk:^{
        [weakSelf stopMasterControl];
    }];
    [_loadingView setProcessValue:80];
}

- (void)stopMasterControl {
    [self.session setTcrSessionObserver:self];
    // 取消之前的主控状态
    if (self.masterId) {
        ComponentCloudPhoneCell *prevCell = [self cellForInstanceId:self.masterId];
        prevCell.masterButton.selected = NO;
        self.masterId = nil;
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.orderedKeys.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ComponentCloudPhoneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    // 通过有序键获取数据
    NSString *key = self.orderedKeys[indexPath.item];
    NSDictionary *item = self.dataDict[key];
    
    // 配置单元格
    cell.imageView.image = item[@"image"];
    cell.textLabel.text = key; // 使用键作为文本
    
    cell.instanceId = key;
    cell.delegate = self;
    
    cell.masterButton.selected = [key isEqualToString:self.masterId];
    cell.slaveCheckbox.selected = [self.slaveInstanceIds containsObject:key];
    
    // 设置圆角
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
    
    // 计算单元格宽度（iphone每行2个，ipad每行8个）
    CGFloat cellWidth = (screenWidth - 12 * 2 - 8) / devicesPerRow; // 12为左右内边距，8为列间距
    
    // 根据图片比例计算高度 (9:16)
    CGFloat imageHeight = cellWidth * 16.0 / 9.0;
    
    // 计算文本高度
    NSString *key = self.orderedKeys[indexPath.item];
    CGFloat textHeight = [key boundingRectWithSize:CGSizeMake(cellWidth - padding*2, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                          context:nil].size.height;
    
    // 总高度 = 图片高度 + 文本高度 + 内边距
    CGFloat totalHeight = padding + imageHeight + padding + textHeight + padding;
    
    return CGSizeMake(cellWidth, totalHeight);
}

#pragma mark - 设置菜单
- (void)createCustomSettingsButton {
    // 创建按钮
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingsButton.frame = CGRectMake(self.view.bounds.size.width - 60, 40, 40, 40);
    
    // 设置按钮图片
    UIImage *settingsImage = [UIImage systemImageNamed:@"gear"];
    [self.settingsButton setImage:settingsImage forState:UIControlStateNormal];
    self.settingsButton.tintColor = [UIColor systemBlueColor];
    
    // 设置按钮背景
    self.settingsButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    self.settingsButton.layer.cornerRadius = 20;
    self.settingsButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.settingsButton.layer.shadowOffset = CGSizeMake(0, 2);
    self.settingsButton.layer.shadowOpacity = 0.3;
    self.settingsButton.layer.shadowRadius = 4;
    
    // 添加点击事件
    [self.settingsButton addTarget:self action:@selector(toggleSettingsMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.settingsButton];
}

- (void)toggleSettingsMenu {
    if (!self.settingsMenuView) {
        [self createSettingsMenu];
    }
    
    if (self.isMenuVisible) {
        [self hideSettingsMenu];
    } else {
        [self showSettingsMenu];
    }
    
    self.isMenuVisible = !self.isMenuVisible;
}

- (void)showSettingsMenu {
    if (!self.settingsMenuView) {
        [self createSettingsMenu];
    }
    
    self.settingsMenuView.hidden = NO;
    self.settingsMenuView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.settingsMenuView.alpha = 1;
    }];
}

- (void)hideSettingsMenu {
    [UIView animateWithDuration:0.3 animations:^{
        self.settingsMenuView.alpha = 0;
    } completion:^(BOOL finished) {
        self.settingsMenuView.hidden = YES;
    }];
}

- (void)createSettingsMenu {
    // 创建半透明背景
    self.settingsMenuView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.settingsMenuView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    self.settingsMenuView.hidden = YES;
    [self.view addSubview:self.settingsMenuView];
    
    // 添加点击背景关闭的手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSettingsMenu)];
    [self.settingsMenuView addGestureRecognizer:tapGesture];
    
    // 创建菜单容器
    CGFloat menuWidth = MIN(self.view.bounds.size.width * 0.8, 300);
    CGFloat menuHeight = MIN(self.view.bounds.size.height * 0.7, 500);
    UIView *menuContainer = [[UIView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - menuWidth)/2,
                                                                     (self.view.bounds.size.height - menuHeight)/2,
                                                                     menuWidth, menuHeight)];
    menuContainer.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    menuContainer.layer.cornerRadius = 12;
    menuContainer.clipsToBounds = YES;
    [self.settingsMenuView addSubview:menuContainer];
    
    // 添加标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, menuWidth, 50)];
    titleLabel.text = @"云手机操作";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [menuContainer addSubview:titleLabel];
    
    // 添加分隔线
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(20, 50, menuWidth-40, 1)];
    divider.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [menuContainer addSubview:divider];
    
    // 创建滚动视图
    self.menuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 51, menuWidth, menuHeight-51)];
    [menuContainer addSubview:self.menuScrollView];
    
    // 创建API操作按钮
    [self createAPIActionButtons];
}

- (void)createAPIActionButtons {
    // 定义API操作（按功能分组）
    self.apiActions = @[
        // ======================= 截图相关操作 =======================
        @{@"title": @"获取截图", @"category": @"截图", @"action": @"getInstanceImage"},
        @{@"title": @"获取截图（720P分辨率）", @"category": @"截图", @"action": @"getInstanceImage720P"},
        
        // ======================= 文件传输操作 =======================
        @{@"title": @"上传文件", @"category": @"文件", @"action": @"uploadFile"},
        @{@"title": @"上传媒体文件", @"category": @"文件", @"action": @"uploadMediaFile"},
        @{@"title": @"获取下载地址", @"category": @"文件", @"action": @"getDownloadAddress"},
        @{@"title": @"获取日志地址", @"category": @"文件", @"action": @"getLogcatAddress"},
        
        // ======================= 设备控制操作 =======================
        @{@"title": @"设置位置", @"category": @"设备", @"action": @"setLocation"},
        @{@"title": @"设置分辨率", @"category": @"设备", @"action": @"setResolution"},
        @{@"title": @"重启设备", @"category": @"设备", @"action": @"rebootDevice"},
        @{@"title": @"设置静音", @"category": @"设备", @"action": @"muteDevice"},
        @{@"title": @"查询实例属性", @"category": @"设备", @"action": @"describeInstanceProperties"},
        @{@"title": @"修改实例属性", @"category": @"设备", @"action": @"modifyInstanceProperties"},
        
        // ======================= 剪贴板操作 =======================
        @{@"title": @"粘贴文本", @"category": @"剪贴板", @"action": @"pasteText"},
        @{@"title": @"修改剪贴板内容", @"category": @"剪贴板", @"action": @"sendClipboard"},
        
        // ======================= 传感器操作 =======================
        @{@"title": @"摇一摇", @"category": @"传感器", @"action": @"shakeDevice"},
        @{@"title": @"吹一吹", @"category": @"传感器", @"action": @"blowDevice"},
        @{@"title": @"修改传感器", @"category": @"传感器", @"action": @"setSensorData"},
        
        // ======================= 应用管理操作 =======================
        @{@"title": @"启动应用（Google Play）", @"category": @"应用", @"action": @"startApp"},
        @{@"title": @"停止应用（Google Play）", @"category": @"应用", @"action": @"stopApp"},
        @{@"title": @"卸载应用", @"category": @"应用", @"action": @"uninstallApp"},
        @{@"title": @"清除应用数据（Google Play）", @"category": @"应用", @"action": @"clearAppData"},
        @{@"title": @"启用应用（Google Play）", @"category": @"应用", @"action": @"enableApp"},
        @{@"title": @"禁用应用（Google Play）", @"category": @"应用", @"action": @"disableApp"},
        @{@"title": @"查询第三方应用列表", @"category": @"应用", @"action": @"listUserApps"},
        @{@"title": @"查询所有应用列表", @"category": @"应用", @"action": @"listAllApps"},
        @{@"title": @"发送应用消息", @"category": @"应用", @"action": @"sendAppMessage"},
        @{@"title": @"关闭应用到后台", @"category": @"应用", @"action": @"moveAppBackground"},
        
        // ======================= 摄像头操作 =======================
        @{@"title": @"播放摄像头视频", @"category": @"摄像头", @"action": @"startCameraMediaPlay"},
        @{@"title": @"停止摄像头视频", @"category": @"摄像头", @"action": @"stopCameraMediaPlay"},
        @{@"title": @"查询播放状态", @"category": @"摄像头", @"action": @"describeCameraMediaPlayStatus"},
        @{@"title": @"显示摄像头图片", @"category": @"摄像头", @"action": @"displayCameraImage"},
        
        // ======================= 前台保活管理 =======================
        @{@"title": @"修改前台应用保活状态", @"category": @"前台保活", @"action": @"modifyFrontKeepAlive"},
        @{@"title": @"查询前台应用保活状态", @"category": @"前台保活", @"action": @"describeFrontKeepAlive"},
        
        // ======================= 后台保活管理 =======================
        @{@"title": @"添加后台保活", @"category": @"后台保活", @"action": @"addKeepAliveList"},
        @{@"title": @"移除后台保活", @"category": @"后台保活", @"action": @"removeKeepAliveList"},
        @{@"title": @"设置后台保活", @"category": @"后台保活", @"action": @"setKeepAliveList"},
        @{@"title": @"查询后台保活", @"category": @"后台保活", @"action": @"describeKeepAliveList"},
        @{@"title": @"清空后台保活", @"category": @"后台保活", @"action": @"clearKeepAliveList"},
        
        // ======================= 黑名单管理 =======================
        @{@"title": @"添加黑名单", @"category": @"黑名单", @"action": @"addAppInstallBlackList"},
        @{@"title": @"移除黑名单", @"category": @"黑名单", @"action": @"removeAppInstallBlackList"},
        @{@"title": @"设置黑名单", @"category": @"黑名单", @"action": @"setAppInstallBlackList"},
        @{@"title": @"查询黑名单", @"category": @"黑名单", @"action": @"describeAppInstallBlackList"},
        @{@"title": @"清空黑名单", @"category": @"黑名单", @"action": @"clearAppInstallBlackList"},
        
        // ======================= 媒体库操作 =======================
        @{@"title": @"搜索媒体文件", @"category": @"媒体库", @"action": @"mediaSearch"},
        
        // ======================= 系统信息操作 =======================
        @{@"title": @"获取导航栏状态", @"category": @"系统信息", @"action": @"getNavVisibleStatus"},
        @{@"title": @"获取媒体音量", @"category": @"系统信息", @"action": @"getSystemMusicVolume"},
    ];
    
    // 按类别分组
    NSMutableDictionary *categories = [NSMutableDictionary dictionary];
    for (NSDictionary *action in self.apiActions) {
        NSString *category = action[@"category"];
        if (!categories[category]) {
            categories[category] = [NSMutableArray array];
        }
        [categories[category] addObject:action];
    }
    
    CGFloat yOffset = 10;
    CGFloat buttonHeight = 40;
    CGFloat spacing = 10;
    
    // 添加类别标题和按钮
    for (NSString *category in categories.allKeys) {
        // 添加类别标题
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, yOffset, self.menuScrollView.bounds.size.width-30, 30)];
        categoryLabel.text = category;
        categoryLabel.textColor = [UIColor lightGrayColor];
        categoryLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.menuScrollView addSubview:categoryLabel];
        yOffset += 30;
        
        // 添加该类别下的按钮
        for (NSDictionary *action in categories[category]) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = CGRectMake(20, yOffset, self.menuScrollView.bounds.size.width-40, buttonHeight);
            [button setTitle:action[@"title"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
            button.layer.cornerRadius = 8;
            button.tag = [self.apiActions indexOfObject:action];
            [button addTarget:self action:@selector(apiButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.menuScrollView addSubview:button];
            
            yOffset += buttonHeight + spacing;
        }
        
        yOffset += 15; // 类别间距
    }
    
    // 设置滚动视图内容大小
    self.menuScrollView.contentSize = CGSizeMake(self.menuScrollView.bounds.size.width, yOffset);
}

- (void)apiButtonTapped:(UIButton *)sender {
    NSDictionary *action = self.apiActions[sender.tag];
    NSString *actionName = action[@"action"];
    
    // 隐藏菜单
    [self hideSettingsMenu];
    
    // 延迟执行API调用，让菜单有动画时间
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performAPIAction:actionName];
    });
}

- (void)performAPIAction:(NSString *)actionName {
    if ([actionName isEqualToString:@"getInstanceImage"]) {
        [self getInstanceImageWithInstanceId:self.instanceIds[0]];
    }
    else if ([actionName isEqualToString:@"getInstanceImage720P"]) {
        [self getInstanceImageWithInstanceId:self.instanceIds[0] quality:20 screenshotWidth:720 screenshotHeight:1280];
    }
    else if ([actionName isEqualToString:@"uploadFile"]) {
        [self uploadWithInstanceId:self.instanceIds[0]];
    }
    else if ([actionName isEqualToString:@"uploadMediaFile"]) {
        [self uploadMediaWithInstanceId:self.instanceIds[0]];
    }
    else if ([actionName isEqualToString:@"getDownloadAddress"]) {
        [self getInstanceDownloadAddressWithInstanceId:self.instanceIds[0] path:@"/sdcard/media/picture.jpg"];
    }
    else if ([actionName isEqualToString:@"getLogcatAddress"]) {
        [self getInstanceDownloadLogcatAddressWithInstanceId:self.instanceIds[0] recentDay:1];
    }
    else if ([actionName isEqualToString:@"setLocation"]) {
        [self setLocationWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"setResolution"]) {
        [self setResolutionWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"pasteText"]) {
        [self pasteTextWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"sendClipboard"]) {
        [self sendClipboardWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"shakeDevice"]) {
        [self shakeDeviceWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"blowDevice"]) {
        [self blowDeviceWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"setSensorData"]) {
        [self enableCoreMotion:!self.isEnableSensor];
    }
    else if ([actionName isEqualToString:@"sendAppMessage"]) {
        [self sendAppMessageWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"describeInstanceProperties"]) {
        [self describeInstancePropertiesWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"listUserApps"]) {
        [self listUserAppsWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"modifyInstanceProperties"]) {
        [self modifyInstancePropertiesWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"modifyFrontKeepAlive"]) {
        [self modifyKeepFrontAppStatusWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"describeFrontKeepAlive"]) {
        [self describeKeepFrontAppStatusWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"uninstallApp"]) {
        [self uninstallAppWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"startApp"]) {
        [self startAppWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"stopApp"]) {
        [self stopAppWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"clearAppData"]) {
        [self clearAppDataWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"enableApp"]) {
        [self enableAppWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"disableApp"]) {
        [self disableAppWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"startCameraMediaPlay"]) {
        [self startCameraMediaPlayWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"stopCameraMediaPlay"]) {
        [self stopCameraMediaPlayWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"describeCameraMediaPlayStatus"]) {
        [self describeCameraMediaPlayStatusWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"displayCameraImage"]) {
        [self displayCameraImageWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"modifyKeepFrontAppStatus"]) {
        [self modifyKeepFrontAppStatusWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"describeKeepFrontAppStatus"]) {
        [self describeKeepFrontAppStatusWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"addKeepAliveList"]) {
        [self addKeepAliveListWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"removeKeepAliveList"]) {
        [self removeKeepAliveListWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"setKeepAliveList"]) {
        [self setKeepAliveListWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"describeKeepAliveList"]) {
        [self describeKeepAliveListWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"clearKeepAliveList"]) {
        [self clearKeepAliveListWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"muteDevice"]) {
        [self muteDeviceWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"mediaSearch"]) {
        [self mediaSearchWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"rebootDevice"]) {
        [self rebootDeviceWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"listAllApps"]) {
        [self listAllAppsWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"moveAppBackground"]) {
        [self moveAppBackgroundWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"addAppInstallBlackList"]) {
        [self addAppInstallBlackListWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"removeAppInstallBlackList"]) {
        [self removeAppInstallBlackListWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"setAppInstallBlackList"]) {
        [self setAppInstallBlackListWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"describeAppInstallBlackList"]) {
        [self describeAppInstallBlackListWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"clearAppInstallBlackList"]) {
        [self clearAppInstallBlackListWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"getNavVisibleStatus"]) {
        [self getNavVisibleStatusWithInstanceIds:self.instanceIds];
    }
    else if ([actionName isEqualToString:@"getSystemMusicVolume"]) {
        [self getSystemMusicVolumeWithInstanceIds:self.instanceIds];
    }
    else {
        ApiTestNSLog(@"未实现的API操作: %@", actionName);
        [self showToast:@"未实现的API操作"];
    }
}

#pragma mark - API 测试
// 加入群控
- (void) joinGroupWithInstanceId:(NSArray *)instanceIds {
    [self.instanceIds addObjectsFromArray:instanceIds];
    [self.androidInstance joinGroupControlWithInstanceIds:instanceIds clientSessions:nil];
}

#pragma mark API 测试 -> 单设备接口
/**
 * 获取实例截图信息，quality默认20，分辨率720x1280
 *
 * @param instanceId 实例Id
 * @return 截图URL
 */
- ( NSString * _Nullable )getInstanceImageWithInstanceId:(NSString *_Nonnull)instanceId {
    NSString * imageUrl = [self.androidInstance getInstanceImageWithInstanceId:instanceId];
    ApiTestNSLog(@"getInstanceImageWithInstanceId: %@, url: %@", instanceId, imageUrl);
    return imageUrl;
}

/**
 * 获取实例截图信息
 * @param instanceId 实例Id
 * @param quality 截图质量（0-100，可选，默认20）
 * @param screenshotWidth 截图宽度
 * @param screenshotHeight 截图高度
 *
 * @return 截图URL
 */
- ( NSString * _Nullable )getInstanceImageWithInstanceId:(NSString *_Nonnull)instanceId
                                        quality:(int)quality screenshotWidth:(int)screenshotWidth screenshotHeight:(int)screenshotHeight {
    NSString * imageUrl = [self.androidInstance getInstanceImageWithInstanceId:instanceId quality:quality screenshotWidth:screenshotWidth screenshotHeight:screenshotHeight];
    ApiTestNSLog(@"getInstanceImageWithInstanceId: %@, url: %@", instanceId, imageUrl);
    return imageUrl;
}

/**
 * 向云端实例上传文件
 */
- (void)uploadWithInstanceId:(NSString *_Nonnull)instanceId {
    NSMutableArray<CaiUploadFileItem*>* array = [NSMutableArray new];
    CaiUploadFileItem* itemMp4 = [CaiUploadFileItem new];
    itemMp4.fileName = @"movie.mp4";
    itemMp4.filePath = @"/sdcard/media";
    itemMp4.fileData = [self dataForAssetNamed:@"movie" ofType:@"mp4"];
    [array addObject:itemMp4];
    
    CaiUploadFileItem* itemJpg = [CaiUploadFileItem new];
    itemJpg.fileName = @"picture.jpg";
    itemJpg.filePath = @"/sdcard/media";
    itemJpg.fileData = [self dataForAssetNamed:@"picture" ofType:@"jpg"];
    [array addObject:itemJpg];
    
    CaiUploadFileItem* itemApk = [CaiUploadFileItem new];
    itemApk.fileName = @"app-release.apk";
    itemApk.filePath = @"/sdcard/media";
    itemApk.fileData = [self dataForAssetNamed:@"app-release" ofType:@"apk"];
    [array addObject:itemApk];
    [self.androidInstance uploadWithInstanceId:instanceId files:array completion:^(CaiUploadResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"上传文件失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"上传文件失败: [%ld] %@", (long)response.code, response.msg);
            [self showToast:@"上传文件失败"];
            return;
        }

        ApiTestNSLog(@"上传文件成功: %@", response.fileStatus);
        [self showToast:@"上传文件成功"];
    }];
    return;
}

/**
 * 向云端实例上传文件
 *
 * @param instanceId  实例 Id
 */
- (void)uploadMediaWithInstanceId:(NSString *_Nonnull)instanceId {
    NSMutableArray<CaiUploadMediaFileItem*>* array = [NSMutableArray new];
    CaiUploadMediaFileItem* itemMp4 = [CaiUploadMediaFileItem new];
    itemMp4.fileName = @"movie.mp4";
    itemMp4.fileData = [self dataForAssetNamed:@"movie" ofType:@"mp4"];
    [array addObject:itemMp4];
    
    CaiUploadMediaFileItem* itemJpg = [CaiUploadMediaFileItem new];
    itemJpg.fileName = @"picture.jpg";
    itemJpg.fileData = [self dataForAssetNamed:@"picture" ofType:@"jpg"];
    [array addObject:itemJpg];
    [self.androidInstance uploadMediaWithInstanceId:instanceId files:array completion:^(CaiUploadMediaFilesResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"上传媒体文件失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"上传媒体文件失败: [%ld] %@", (long)response.code, response.msg);
            [self showToast:@"上传媒体文件失败"];
            return;
        }

        [self showToast:@"上传媒体文件成功"];
    }];
    return;
}

/**
 * 获取实例下载地址
 *
 * @param instanceId  实例 Id
 * @param path 下载路径
 *
 * @returns response address - 下载地址
 */
- (NSString *_Nonnull)getInstanceDownloadAddressWithInstanceId:(NSString *_Nonnull)instanceId path:(NSString *_Nonnull)path {
    NSString * url = [self.androidInstance getInstanceDownloadAddressWithInstanceId:instanceId path:path];
    ApiTestNSLog(@"getInstanceDownloadAddressWithInstanceId: %@, url: %@", instanceId, url);
    return url;
}

/**
 * 获取logcat日志下载地址
 *
 * @param instanceId  实例 Id
 * @param recentDay 最近几天的日志
 *
 * @returns response address - 下载地址
 */
- (NSString *_Nonnull)getInstanceDownloadLogcatAddressWithInstanceId:(NSString *_Nonnull)instanceId recentDay:(int)recentDay {
    NSString * url = [self.androidInstance getInstanceDownloadLogcatAddressWithInstanceId:instanceId recentDay:recentDay];
    ApiTestNSLog(@"getInstanceDownloadLogcatAddressWithInstanceId: %@, url: %@", instanceId, url);
    return url;
}


#pragma mark API 测试 -> 批量接口
// 设置设备位置
- (void)setLocationWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"Longitude": @(121.4737), // 上海经度
            @"Latitude": @(31.2304)     // 上海纬度
        } forKey:instanceId];
    }
    
    [self.androidInstance setLocationWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"设置位置失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"设置位置失败"];
            return;
        }

        ApiTestNSLog(@"位置设置成功: %@", response.deviceResponses);
        [self showToast:@"位置已设置为上海"];
    }];
}

// 设置设备分辨率
- (void)setResolutionWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"Width": @720,
            @"Height": @1280,
            @"DPI": @240
        } forKey:instanceId];
    }
    
    [self.androidInstance setResolutionWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"设置分辨率失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"设置分辨率失败"];
            return;
        }

        ApiTestNSLog(@"分辨率设置成功: %@", response.deviceResponses);
        [self showToast:@"分辨率已设置为720x1280"];
    }];
}

// 粘贴文本
- (void)pasteTextWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"Text": @"粘贴测试文本"
        } forKey:instanceId];
    }
    
    [self.androidInstance pasteWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"粘贴失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"粘贴失败"];
            return;
        }

        ApiTestNSLog(@"粘贴成功: %@", response.deviceResponses);
        [self showToast:@"文本已粘贴"];
    }];
}

// 设置剪贴板内容
- (void)sendClipboardWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"Text": @"剪贴板测试内容"
        } forKey:instanceId];
    }
    
    [self.androidInstance sendClipboardWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"设置剪贴板失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"设置剪贴板失败"];
            return;
        }

        ApiTestNSLog(@"剪贴板设置成功: %@", response.deviceResponses);
        [self showToast:@"剪贴板内容已设置"];
    }];
}

// 摇一摇设备
- (void)shakeDeviceWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance shakeWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"摇一摇失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"摇一摇失败"];
            return;
        }

        ApiTestNSLog(@"摇一摇成功: %@", response.deviceResponses);
        [self showToast:@"设备已摇动"];
    }];
}

// 吹一吹数据
- (void)blowDeviceWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance blowWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"吹一吹失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"吹一吹失败"];
            return;
        }

        ApiTestNSLog(@"吹一吹成功: %@", response.deviceResponses);
        [self showToast:@"吹一吹成功"];
    }];
}

- (void)enableCoreMotion:(BOOL)enable {
    self.isEnableSensor = enable;
    if (enable) {
        if (self.motionManager.isAccelerometerAvailable) {
            [self showToast:@"开启传感器"];
            self.motionManager.accelerometerUpdateInterval = 0.1; // 设置更新间隔
            [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                                      withHandler:^(CMAccelerometerData *data, NSError *error) {
                if (error) {
                    NSLog(@"Error: %@", error);
                    return;
                }

                CMAcceleration acceleration = data.acceleration;
                [self setSensorDataWithInstanceIds: self.instanceIds acceleration:acceleration];
            }];
        } else {
            [self showToast:@"传感器不可用"];
        }
    } else {
        [self.motionManager stopAccelerometerUpdates];
        [self showToast:@"关闭传感器"];
    }
}

// 设置传感器数据
- (void)setSensorDataWithInstanceIds:(NSArray *)instanceIds acceleration:(CMAcceleration) acceleration {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"Type": @"accelerometer",
            @"Values": @[@(acceleration.x), @(acceleration.y), @(acceleration.z)]
        } forKey:instanceId];
    }
    
    [self.androidInstance setSensorWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"设置传感器失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"设置传感器失败"];
            return;
        }

        ApiTestNSLog(@"传感器设置成功: %@", response.deviceResponses);
    }];
}



// 发送应用消息
- (void)sendAppMessageWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"PackageName": @"com.android.vending",
            @"Msg": @"测试消息"
        } forKey:instanceId];
    }
    
    [self.androidInstance sendTransMessageWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"发送消息失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"发送消息失败"];
            return;
        }

        ApiTestNSLog(@"消息发送成功: %@", response.deviceResponses);
        [self showToast:@"应用消息已发送"];
    }];
}

// 查询实例属性
- (void)describeInstancePropertiesWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance describeInstancePropertiesWithParams:params completion:^(CaiDescribeInstancePropertiesResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"查询属性失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"查询属性失败"];
            return;
        }

        ApiTestNSLog(@"属性查询成功: %@", response.deviceResponses);
        [self showToast:@"实例属性已获取"];
    }];
}

// 查询已安装应用
- (void)listUserAppsWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance listUserAppsWithParams:params completion:^(CaiListUserAppsResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"查询应用失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"查询应用失败"];
            return;
        }

        ApiTestNSLog(@"应用列表查询成功: %@", response.deviceResponses);
        [self showToast:@"已安装应用列表已获取"];
    }];
}

// 修改设备属性
- (void)modifyInstancePropertiesWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"DeviceInfo": @{
                @"Brand": @"Samsung",
                @"Model": @"Galaxy S24"
            },
            @"ProxyInfo": @{
                @"Enabled": @YES,
                @"Protocol": @"socks5",
                @"Host": @"proxy.example.com",
                @"Port": @1080,
                @"User": @"user123",
                @"Password": @"pass123"
            },
            @"SIMInfo": @{
              @"State": @5
            },
        } forKey:instanceId];
    }
    
    [self.androidInstance modifyInstancePropertiesWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"修改属性失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"修改属性失败"];
            return;
        }

        ApiTestNSLog(@"属性修改成功: %@", response.deviceResponses);
        [self showToast:@"设备属性已修改"];
    }];
}

// 卸载应用
- (void)uninstallAppWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"PackageName": @"com.autonavi.minimap"
        } forKey:instanceId];
    }
    
    [self.androidInstance unInstallByPackageNameWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"卸载应用失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"卸载应用失败"];
            return;
        }

        ApiTestNSLog(@"应用卸载成功: %@", response.deviceResponses);
        [self showToast:@"应用已卸载"];
    }];
}

// 启动应用
- (void)startAppWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"PackageName": @"com.android.vending",
            @"ActivityName": @"com.iapp.app.logoActivity"
        } forKey:instanceId];
    }
    
    [self.androidInstance startAppWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"启动应用失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"启动应用失败"];
            return;
        }

        ApiTestNSLog(@"应用启动成功: %@", response.deviceResponses);
        [self showToast:@"应用已启动"];
    }];
}

// 停止应用
- (void)stopAppWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"PackageName": @"com.android.vending"
        } forKey:instanceId];
    }
    
    [self.androidInstance stopAppWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"停止应用失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"停止应用失败"];
            return;
        }

        ApiTestNSLog(@"应用停止成功: %@", response.deviceResponses);
        [self showToast:@"应用已停止"];
    }];
}

// 清除应用数据
- (void)clearAppDataWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"PackageName": @"com.android.vending"
        } forKey:instanceId];
    }
    
    [self.androidInstance clearAppDataWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"清除数据失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"清除数据失败"];
            return;
        }

        ApiTestNSLog(@"应用数据清除成功: %@", response.deviceResponses);
        [self showToast:@"应用数据已清除"];
    }];
}

// 启用应用
- (void)enableAppWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"PackageName": @"com.android.vending"
        } forKey:instanceId];
    }
    
    [self.androidInstance enableAppWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"启用应用失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"启用应用失败"];
            return;
        }

        ApiTestNSLog(@"应用启用成功: %@", response.deviceResponses);
        [self showToast:@"应用已启用"];
    }];
}

// 禁用应用
- (void)disableAppWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"PackageName": @"com.android.vending"
        } forKey:instanceId];
    }
    
    [self.androidInstance disableAppWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"禁用应用失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"禁用应用失败"];
            return;
        }

        ApiTestNSLog(@"应用禁用成功: %@", response.deviceResponses);
        [self showToast:@"应用已禁用"];
    }];
}

// 播放摄像头媒体
- (void)startCameraMediaPlayWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"FilePath": @"/sdcard/media/movie.mp4",
            @"Loops": @(-1)
        } forKey:instanceId];
    }
    
    [self.androidInstance startCameraMediaPlayWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"播放媒体失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"播放媒体失败"];
            return;
        }

        ApiTestNSLog(@"媒体播放成功: %@", response.deviceResponses);
        [self showToast:@"摄像头媒体播放已开始"];
    }];
}

// 停止摄像头媒体播放
- (void)stopCameraMediaPlayWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance stopCameraMediaPlayWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"停止媒体失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"停止媒体失败"];
            return;
        }

        ApiTestNSLog(@"媒体停止成功: %@", response.deviceResponses);
        [self showToast:@"摄像头媒体播放已停止"];
    }];
}

// 查询摄像头播放状态
- (void)describeCameraMediaPlayStatusWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance describeCameraMediaPlayStatusWithParams:params completion:^(CaiDescribeCameraMediaPlayStatusResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"查询状态失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"查询状态失败"];
            return;
        }

        ApiTestNSLog(@"播放状态查询成功: %@", response.deviceResponses);
        [self showToast:@"摄像头播放状态已获取"];
    }];
}

// 在摄像头显示图片
- (void)displayCameraImageWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"FilePath": @"/sdcard/media/picture.jpg"
        } forKey:instanceId];
    }
    
    [self.androidInstance displayCameraImageWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"显示图片失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"显示图片失败"];
            return;
        }

        ApiTestNSLog(@"图片显示成功: %@", response.deviceResponses);
        [self showToast:@"摄像头图片已显示"];
    }];
}

// 修改前台应用保活状态
- (void)modifyKeepFrontAppStatusWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"PackageName": @"com.android.vending",
            @"Enable": @NO,
            @"RestartInterValSeconds": @5
        } forKey:instanceId];
    }
    
    [self.androidInstance modifyKeepFrontAppStatusWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"修改保活失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"修改保活失败"];
            return;
        }

        ApiTestNSLog(@"保活设置成功: %@", response.deviceResponses);
        [self showToast:@"前台应用保活已设置"];
    }];
}

// 查询前台应用保活状态
- (void)describeKeepFrontAppStatusWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance describeKeepFrontAppStatusWithParams:params completion:^(CaiDescribeKeepFrontAppStatusResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"查询保活失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"查询保活失败"];
            return;
        }

        ApiTestNSLog(@"保活状态查询成功: %@", response.deviceResponses);
        [self showToast:@"前台应用保活状态已获取"];
    }];
}

// 添加后台保活应用
- (void)addKeepAliveListWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"AppList": @[@"com.yodo1.SkiSafari.TXYYB_01"]
        } forKey:instanceId];
    }
    
    [self.androidInstance addKeepAliveListWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"添加保活失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"添加保活失败"];
            return;
        }

        ApiTestNSLog(@"保活添加成功: %@", response.deviceResponses);
        [self showToast:@"后台保活应用已添加"];
    }];
}

// 移除后台保活应用
- (void)removeKeepAliveListWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"AppList": @[@"com.yodo1.SkiSafari.TXYYB_01"]
        } forKey:instanceId];
    }
    
    [self.androidInstance removeKeepAliveListWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"移除保活失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"移除保活失败"];
            return;
        }

        ApiTestNSLog(@"保活移除成功: %@", response.deviceResponses);
        [self showToast:@"后台保活应用已移除"];
    }];
}

// 设置后台保活列表
- (void)setKeepAliveListWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"AppList": @[@"com.android.vending", @"com.tencent.android.qqdownloader"]
        } forKey:instanceId];
    }
    
    [self.androidInstance setKeepAliveListWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"设置保活失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"设置保活失败"];
            return;
        }

        ApiTestNSLog(@"保活设置成功: %@", response.deviceResponses);
        [self showToast:@"后台保活列表已设置"];
    }];
}

// 查询后台保活列表
- (void)describeKeepAliveListWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance describeKeepAliveListWithParams:params completion:^(CaiDescribeKeepAliveListResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"查询保活失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"查询保活失败"];
            return;
        }

        ApiTestNSLog(@"保活列表查询成功: %@", response.deviceResponses);
        [self showToast:@"后台保活列表已获取"];
    }];
}

// 清空后台保活列表
- (void)clearKeepAliveListWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance clearKeepAliveListWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"清空保活失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"清空保活失败"];
            return;
        }

        ApiTestNSLog(@"保活清空成功: %@", response.deviceResponses);
        [self showToast:@"后台保活列表已清空"];
    }];
}

// 设置设备静音
- (void)muteDeviceWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"Mute": @YES
        } forKey:instanceId];
    }
    
    [self.androidInstance muteWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"设置静音失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"设置静音失败"];
            return;
        }

        ApiTestNSLog(@"静音设置成功: %@", response.deviceResponses);
        [self showToast:@"设备已静音"];
    }];
}

// 搜索媒体库文件
- (void)mediaSearchWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"Keyword": @"movie"
        } forKey:instanceId];
    }
    
    [self.androidInstance mediaSearchWithParams:params completion:^(CaiMediaSearchResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"搜索媒体失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"搜索媒体失败"];
            return;
        }

        ApiTestNSLog(@"媒体搜索成功: %@", response.deviceResponses);
        [self showToast:@"媒体搜索已完成"];
    }];
}

// 重启设备
- (void)rebootDeviceWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance rebootWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"重启失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"重启失败"];
            return;
        }

        ApiTestNSLog(@"设备重启成功: %@", response.deviceResponses);
        [self showToast:@"设备正在重启"];
    }];
}

// 查询所有应用
- (void)listAllAppsWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance listAllAppsWithParams:params completion:^(CaiListAllAppsResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"查询应用失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"查询应用失败"];
            return;
        }

        ApiTestNSLog(@"应用列表查询成功: %@", response.deviceResponses);
        [self showToast:@"所有应用列表已获取"];
    }];
}

// 关闭应用到后台
- (void)moveAppBackgroundWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance moveAppBackgroundWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"关闭应用失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"关闭应用失败"];
            return;
        }

        ApiTestNSLog(@"应用关闭成功: %@", response.deviceResponses);
        [self showToast:@"应用已关闭到后台"];
    }];
}

// 新增应用安装黑名单
- (void)addAppInstallBlackListWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"AppList": @[@"com.unwanted.app"]
        } forKey:instanceId];
    }
    
    [self.androidInstance addAppInstallBlackListWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"添加黑名单失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"添加黑名单失败"];
            return;
        }

        ApiTestNSLog(@"黑名单添加成功: %@", response.deviceResponses);
        [self showToast:@"应用安装黑名单已添加"];
    }];
}

// 移除应用安装黑名单
- (void)removeAppInstallBlackListWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"AppList": @[@"com.unwanted.app"]
        } forKey:instanceId];
    }
    
    [self.androidInstance removeAppInstallBlackListWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"移除黑名单失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"移除黑名单失败"];
            return;
        }

        ApiTestNSLog(@"黑名单移除成功: %@", response.deviceResponses);
        [self showToast:@"应用安装黑名单已移除"];
    }];
}

// 覆盖应用安装黑名单
- (void)setAppInstallBlackListWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{
            @"AppList": @[@"com.unwanted1.app", @"com.unwanted2.app"]
        } forKey:instanceId];
    }
    
    [self.androidInstance setAppInstallBlackListWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"设置黑名单失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"设置黑名单失败"];
            return;
        }

        ApiTestNSLog(@"黑名单设置成功: %@", response.deviceResponses);
        [self showToast:@"应用安装黑名单已设置"];
    }];
}

// 查询应用安装黑名单
- (void)describeAppInstallBlackListWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance describeAppInstallBlackListWithParams:params completion:^(CaiDescribeAppInstallBlackListResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"查询黑名单失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"查询黑名单失败"];
            return;
        }

        ApiTestNSLog(@"黑名单查询成功: %@", response.deviceResponses);
        [self showToast:@"应用安装黑名单已获取"];
    }];
}

// 清空应用安装黑名单
- (void)clearAppInstallBlackListWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance clearAppInstallBlackListWithParams:params completion:^(CaiBatchTaskResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"清空黑名单失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"清空黑名单失败"];
            return;
        }

        ApiTestNSLog(@"黑名单清空成功: %@", response.deviceResponses);
        [self showToast:@"应用安装黑名单已清空"];
    }];
}

// 获取导航栏可见状态
- (void)getNavVisibleStatusWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance getNavVisibleStatusWithParams:params completion:^(CaiGetNavVisibleStatusResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"查询导航栏失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"查询导航栏失败"];
            return;
        }

        ApiTestNSLog(@"导航栏状态查询成功: %@", response.deviceResponses);
        [self showToast:@"导航栏状态已获取"];
    }];
}

// 获取系统媒体音量
- (void)getSystemMusicVolumeWithInstanceIds:(NSArray *)instanceIds {
    NSMutableDictionary *params = [NSMutableDictionary new];
    for (NSString *instanceId in instanceIds) {
        [params setObject:@{} forKey:instanceId];
    }
    
    [self.androidInstance getSystemMusicVolumeWithParams:params completion:^(CaiGetSystemMusicVolumeResponse * _Nonnull response, NSError * _Nullable error) {
        if (error) {
            ApiTestNSLog(@"系统错误: %@", error);
            [self showToast:@"查询音量失败"];
            return;
        }

        if (response.code != 0) {
            ApiTestNSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
            [self showToast:@"查询音量失败"];
            return;
        }

        ApiTestNSLog(@"媒体音量查询成功: %@", response.deviceResponses);
        [self showToast:@"媒体音量已获取"];
    }];
}

#pragma mark - 辅助方法

- (void)showToast:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 创建并显示Toast提示
        UILabel *toastLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        toastLabel.text = message;
        toastLabel.textColor = [UIColor whiteColor];
        toastLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        toastLabel.textAlignment = NSTextAlignmentCenter;
        toastLabel.layer.cornerRadius = 8;
        toastLabel.clipsToBounds = YES;
        toastLabel.alpha = 0;
        
        // 计算大小
        [toastLabel sizeToFit];
        CGRect frame = toastLabel.frame;
        frame.size.width += 40;
        frame.size.height += 20;
        frame.origin.x = (self.view.bounds.size.width - frame.size.width) / 2;
        frame.origin.y = self.view.bounds.size.height - 100;
        toastLabel.frame = frame;
        
        [self.view addSubview:toastLabel];
        
        // 显示动画
        [UIView animateWithDuration:0.3 animations:^{
            toastLabel.alpha = 1;
        } completion:^(BOOL finished) {
            // 隐藏动画
            [UIView animateWithDuration:0.3 delay:2.0 options:0 animations:^{
                toastLabel.alpha = 0;
            } completion:^(BOOL finished) {
                [toastLabel removeFromSuperview];
            }];
        }];
    });
}

- (NSData *)dataForAssetNamed:(NSString *)name ofType:(NSString *)type {
    // 1. 尝试使用 NSDataAsset
    if (@available(iOS 9.0, *)) {
        NSDataAsset *dataAsset = [[NSDataAsset alloc] initWithName:name];
        if (dataAsset.data) {
            return dataAsset.data;
        }
    }
    
    // 2. 尝试使用 NSBundle
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    if (filePath) {
        return [NSData dataWithContentsOfFile:filePath];
    }
    
    // 3. 尝试读取图片资源
    UIImage *image = [UIImage imageNamed:name];
    if (image) {
        // 根据类型决定格式
        if ([type isEqualToString:@"png"]) {
            return UIImagePNGRepresentation(image);
        } else {
            return UIImageJPEGRepresentation(image, 1.0);
        }
    }
    
    return nil;
}

- (void)handleLeftEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        // 获取滑动距离
        CGPoint translation = [gesture translationInView:self.view];
        
        // 确认是有效的水平滑动
        if (fabs(translation.x) > 50 && fabs(translation.x) > fabs(translation.y)) {
            [self releaseSession];
            
            // 添加触觉反馈增强用户体验
            UIImpactFeedbackGenerator *feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
            [feedbackGenerator impactOccurred];
        }
    }
}

@end
