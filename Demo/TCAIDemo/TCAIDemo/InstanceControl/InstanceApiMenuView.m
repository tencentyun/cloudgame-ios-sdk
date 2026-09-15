#import "InstanceApiMenuView.h"
#import "DemoToast.h"
#import <CoreMotion/CoreMotion.h>

#define ApiTestNSLog(format, ...) do { \
    NSString *message = [NSString stringWithFormat:format, ##__VA_ARGS__]; \
    NSLog(@"[GroupControlApiTest] %@", message); \
} while(0)

/// 菜单项点击后执行的接口调用，title 用于日志与提示，避免在调用处重复写一遍名字
typedef void (^ApiActionHandler)(NSString *title);

/// 演示用的目标应用包名，改成实例上已安装的任意应用即可
static NSString *const kDemoPackageName = @"com.android.vending";

@interface InstanceApiMenuView ()

@property (nonatomic, weak) AndroidInstance *androidInstance;
@property (nonatomic, copy) NSArray<NSString *> *instanceIds;
/// 浮层与提示的载体
@property (nonatomic, weak) UIView *hostView;
@property (nonatomic, strong) UIView *menuContainer;
@property (nonatomic, strong) UIScrollView *menuScrollView;
@property (nonatomic, strong) NSArray<NSDictionary *> *apiActions;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (assign, nonatomic) BOOL isEnableSensor;

@end

@implementation InstanceApiMenuView

- (instancetype)initWithAndroidInstance:(AndroidInstance *)androidInstance
                            instanceIds:(NSArray<NSString *> *)instanceIds {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _androidInstance = androidInstance;
        _instanceIds = instanceIds ?: @[];
        _motionManager = [[CMMotionManager alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_motionManager stopAccelerometerUpdates];
}

#pragma mark - 显示与隐藏

- (void)showInView:(UIView *)view {
    self.hostView = view;
    self.frame = view.bounds;
    if (self.menuContainer == nil) {
        [self buildMenu];
    }
    if (self.superview != view) {
        [view addSubview:self];
    }
    self.hidden = NO;
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

/// 半透明背景 + 居中面板，面板内是可滚动的接口按钮列表
- (void)buildMenu {
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self addGestureRecognizer:tapGesture];

    CGFloat menuWidth = MIN(self.bounds.size.width * 0.8, 300);
    CGFloat menuHeight = MIN(self.bounds.size.height * 0.7, 500);
    self.menuContainer = [[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width - menuWidth)/2,
                                                                  (self.bounds.size.height - menuHeight)/2,
                                                                  menuWidth, menuHeight)];
    self.menuContainer.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    self.menuContainer.layer.cornerRadius = 12;
    self.menuContainer.clipsToBounds = YES;
    [self addSubview:self.menuContainer];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, menuWidth, 50)];
    titleLabel.text = @"云手机操作";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.menuContainer addSubview:titleLabel];

    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(20, 50, menuWidth-40, 1)];
    divider.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [self.menuContainer addSubview:divider];

    self.menuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 51, menuWidth, menuHeight-51)];
    [self.menuContainer addSubview:self.menuScrollView];

    [self createAPIActionButtons];
}

#pragma mark - 接口清单

- (void)createAPIActionButtons {
    __weak typeof(self) weakSelf = self;
    NSString *firstId = self.instanceIds.firstObject;

    self.apiActions = @[
        // ======================= 截图 =======================
        // 截图接口返回的是一个 URL，交给图片库加载即可（本页的预览轮询就是这么刷新的）
        @{@"title": @"获取截图", @"category": @"截图", @"handler": ^(NSString *title) {
            ApiTestNSLog(@"%@: %@", title, [weakSelf.androidInstance getInstanceImageWithInstanceId:firstId]);
        }},
        @{@"title": @"获取截图（720P）", @"category": @"截图", @"handler": ^(NSString *title) {
            NSString *url = [weakSelf.androidInstance getInstanceImageWithInstanceId:firstId
                                                                            quality:20
                                                                    screenshotWidth:720
                                                                   screenshotHeight:1280];
            ApiTestNSLog(@"%@: %@", title, url);
        }},

        // ======================= 文件 =======================
        @{@"title": @"上传文件", @"category": @"文件", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance uploadWithInstanceId:firstId
                                                    files:[weakSelf uploadFileItems]
                                               completion:^(CaiUploadResponse *response, NSError *error) {
                if (error != nil || response.code != 0) {
                    ApiTestNSLog(@"%@失败: %@ / [%ld] %@", title, error, (long)response.code, response.msg);
                    [DemoToast showInView:weakSelf.hostView message:[title stringByAppendingString:@"失败"]];
                    return;
                }
                ApiTestNSLog(@"%@成功: %@", title, response.fileStatus);
                [DemoToast showInView:weakSelf.hostView message:[title stringByAppendingString:@"成功"]];
            }];
        }},
        @{@"title": @"上传媒体文件", @"category": @"文件", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance uploadMediaWithInstanceId:firstId
                                                         files:[weakSelf uploadMediaFileItems]
                                                    completion:^(CaiUploadMediaFilesResponse *response, NSError *error) {
                if (error != nil || response.code != 0) {
                    ApiTestNSLog(@"%@失败: %@ / [%ld] %@", title, error, (long)response.code, response.msg);
                    [DemoToast showInView:weakSelf.hostView message:[title stringByAppendingString:@"失败"]];
                    return;
                }
                [DemoToast showInView:weakSelf.hostView message:[title stringByAppendingString:@"成功"]];
            }];
        }},
        @{@"title": @"获取下载地址", @"category": @"文件", @"handler": ^(NSString *title) {
            NSString *url = [weakSelf.androidInstance getInstanceDownloadAddressWithInstanceId:firstId
                                                                                         path:@"/sdcard/media/picture.jpg"];
            ApiTestNSLog(@"%@: %@", title, url);
        }},
        @{@"title": @"获取日志地址", @"category": @"文件", @"handler": ^(NSString *title) {
            NSString *url = [weakSelf.androidInstance getInstanceDownloadLogcatAddressWithInstanceId:firstId recentDay:1];
            ApiTestNSLog(@"%@: %@", title, url);
        }},

        // ======================= 设备 =======================
        @{@"title": @"设置位置（上海）", @"category": @"设备", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance setLocationWithParams:[weakSelf paramsForAllInstances:@{
                @"Longitude": @(121.4737),
                @"Latitude": @(31.2304)
            }] completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"设置分辨率（720x1280）", @"category": @"设备", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance setResolutionWithParams:[weakSelf paramsForAllInstances:@{
                @"Width": @720,
                @"Height": @1280,
                @"DPI": @240
            }] completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"重启设备", @"category": @"设备", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance rebootWithParams:[weakSelf paramsForAllInstances:@{}]
                                            completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"设置静音", @"category": @"设备", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance muteWithParams:[weakSelf paramsForAllInstances:@{@"Mute": @YES}]
                                          completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"查询实例属性", @"category": @"设备", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance describeInstancePropertiesWithParams:[weakSelf paramsForAllInstances:@{}]
                                                               completion:^(CaiDescribeInstancePropertiesResponse *response, NSError *error) {
                if (![weakSelf reportBatchResult:response error:error action:title]) {
                    return;
                }
                // 查询类接口的结果在 deviceResponses 里，按 instanceId 取对应实例的数据
                [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *instanceId,
                                                                             CaiInstancePropertiesResponseItem *item,
                                                                             BOOL *stop) {
                    ApiTestNSLog(@"%@ %@: 品牌=%@ 型号=%@", title, instanceId, item.deviceInfo.brand, item.deviceInfo.model);
                }];
            }];
        }},
        @{@"title": @"修改实例属性", @"category": @"设备", @"handler": ^(NSString *title) {
            // 本接口一次可改多组属性，只下发要改的组即可，这里演示全部可改项。
            // RequestID 是本接口特有的必填项，每台实例各自一个，由调用方生成
            NSMutableDictionary<NSString *, NSDictionary *> *params = [NSMutableDictionary dictionary];
            for (NSString *instanceId in weakSelf.instanceIds) {
                params[instanceId] = @{
                    @"RequestID": [[NSUUID UUID] UUIDString],
                    // 设备指纹。Model 不能含空格，否则服务端会丢弃整个请求且仍返回成功
                    @"DeviceInfo": @{ @"Brand": @"Samsung", @"Model": @"SM-S9210" },
                    // 让实例经代理出网
                    @"ProxyInfo": @{
                        @"Enabled": @YES,
                        @"Protocol": @"socks5",
                        @"Host": @"proxy.example.com",
                        @"Port": @1080,
                        @"User": @"user123",
                        @"Password": @"pass123"
                    },
                    // 实例内定位到的位置
                    @"GPSInfo": @{ @"Longitude": @(121.4737), @"Latitude": @(31.2304) },
                    // SIM 卡状态，State 0=未激活 1=已激活
                    @"SIMInfo": @{
                        @"State": @1,
                        @"PhoneNumber": @"13812345678",
                        @"IMSI": @"460001234567890",
                        @"ICCID": @"89860123456789012345"
                    },
                    @"LocaleInfo": @{ @"Timezone": @"Asia/Shanghai" },
                    @"LanguageInfo": @{ @"Language": @"zh", @"Country": @"CN" },
                    // 透传给实例的自定义键值对
                    @"ExtraProperties": @[ @{ @"Key": @"custom_key", @"Value": @"custom_value" } ]
                };
            }
            [weakSelf.androidInstance modifyInstancePropertiesWithParams:params
                                                             completion:[weakSelf batchCompletion:title]];
        }},

        // ======================= 剪贴板 =======================
        @{@"title": @"粘贴文本", @"category": @"剪贴板", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance pasteWithParams:[weakSelf paramsForAllInstances:@{@"Text": @"粘贴测试文本"}]
                                           completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"修改剪贴板内容", @"category": @"剪贴板", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance sendClipboardWithParams:[weakSelf paramsForAllInstances:@{@"Text": @"剪贴板测试内容"}]
                                                  completion:[weakSelf batchCompletion:title]];
        }},

        // ======================= 传感器 =======================
        @{@"title": @"摇一摇", @"category": @"传感器", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance shakeWithParams:[weakSelf paramsForAllInstances:@{}]
                                           completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"吹一吹", @"category": @"传感器", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance blowWithParams:[weakSelf paramsForAllInstances:@{}]
                                          completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"上报本机加速度计", @"category": @"传感器", @"handler": ^(NSString *title) {
            [weakSelf enableCoreMotion:!weakSelf.isEnableSensor];
        }},

        // ======================= 应用 =======================
        @{@"title": @"启动应用", @"category": @"应用", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance startAppWithParams:[weakSelf paramsForAllInstances:@{
                @"PackageName": kDemoPackageName,
                @"ActivityName": @"com.iapp.app.logoActivity"
            }] completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"停止应用", @"category": @"应用", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance stopAppWithParams:[weakSelf paramsForAllInstances:@{@"PackageName": kDemoPackageName}]
                                             completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"卸载应用", @"category": @"应用", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance unInstallByPackageNameWithParams:[weakSelf paramsForAllInstances:@{
                @"PackageName": kDemoPackageName
            }] completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"清除应用数据", @"category": @"应用", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance clearAppDataWithParams:[weakSelf paramsForAllInstances:@{@"PackageName": kDemoPackageName}]
                                                 completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"启用应用", @"category": @"应用", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance enableAppWithParams:[weakSelf paramsForAllInstances:@{@"PackageName": kDemoPackageName}]
                                              completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"禁用应用", @"category": @"应用", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance disableAppWithParams:[weakSelf paramsForAllInstances:@{@"PackageName": kDemoPackageName}]
                                               completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"关闭应用到后台", @"category": @"应用", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance moveAppBackgroundWithParams:[weakSelf paramsForAllInstances:@{}]
                                                      completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"发送应用消息", @"category": @"应用", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance sendTransMessageWithParams:[weakSelf paramsForAllInstances:@{
                @"PackageName": kDemoPackageName,
                @"Msg": @"测试消息"
            }] completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"查询第三方应用列表", @"category": @"应用", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance listUserAppsWithParams:[weakSelf paramsForAllInstances:@{}]
                                                 completion:^(CaiListUserAppsResponse *response, NSError *error) {
                if (![weakSelf reportBatchResult:response error:error action:title]) {
                    return;
                }
                ApiTestNSLog(@"%@: %@", title, response.deviceResponses);
            }];
        }},
        @{@"title": @"查询所有应用列表", @"category": @"应用", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance listAllAppsWithParams:[weakSelf paramsForAllInstances:@{}]
                                                completion:^(CaiListAllAppsResponse *response, NSError *error) {
                if (![weakSelf reportBatchResult:response error:error action:title]) {
                    return;
                }
                ApiTestNSLog(@"%@: %@", title, response.deviceResponses);
            }];
        }},

        // ======================= 摄像头 =======================
        // 用实例内的媒体文件伪装摄像头画面，路径来自上面的「上传媒体文件」
        @{@"title": @"播放摄像头视频", @"category": @"摄像头", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance startCameraMediaPlayWithParams:[weakSelf paramsForAllInstances:@{
                @"FilePath": @"/sdcard/media/movie.mp4",
                @"Loops": @(-1)     // -1 表示循环播放
            }] completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"停止摄像头视频", @"category": @"摄像头", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance stopCameraMediaPlayWithParams:[weakSelf paramsForAllInstances:@{}]
                                                        completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"查询播放状态", @"category": @"摄像头", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance describeCameraMediaPlayStatusWithParams:[weakSelf paramsForAllInstances:@{}]
                                                                  completion:^(CaiDescribeCameraMediaPlayStatusResponse *response, NSError *error) {
                if (![weakSelf reportBatchResult:response error:error action:title]) {
                    return;
                }
                ApiTestNSLog(@"%@: %@", title, response.deviceResponses);
            }];
        }},
        @{@"title": @"显示摄像头图片", @"category": @"摄像头", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance displayCameraImageWithParams:[weakSelf paramsForAllInstances:@{
                @"FilePath": @"/sdcard/media/picture.jpg"
            }] completion:[weakSelf batchCompletion:title]];
        }},

        // ======================= 前台保活 =======================
        @{@"title": @"修改前台应用保活", @"category": @"前台保活", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance modifyKeepFrontAppStatusWithParams:[weakSelf paramsForAllInstances:@{
                @"PackageName": kDemoPackageName,
                @"Enable": @NO,
                @"RestartInterValSeconds": @5
            }] completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"查询前台应用保活", @"category": @"前台保活", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance describeKeepFrontAppStatusWithParams:[weakSelf paramsForAllInstances:@{}]
                                                               completion:^(CaiDescribeKeepFrontAppStatusResponse *response, NSError *error) {
                if (![weakSelf reportBatchResult:response error:error action:title]) {
                    return;
                }
                ApiTestNSLog(@"%@: %@", title, response.deviceResponses);
            }];
        }},

        // ======================= 后台保活 =======================
        @{@"title": @"添加后台保活", @"category": @"后台保活", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance addKeepAliveListWithParams:[weakSelf paramsForAllInstances:@{
                @"AppList": @[kDemoPackageName]
            }] completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"移除后台保活", @"category": @"后台保活", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance removeKeepAliveListWithParams:[weakSelf paramsForAllInstances:@{
                @"AppList": @[kDemoPackageName]
            }] completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"覆盖后台保活列表", @"category": @"后台保活", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance setKeepAliveListWithParams:[weakSelf paramsForAllInstances:@{
                @"AppList": @[kDemoPackageName, @"com.tencent.android.qqdownloader"]
            }] completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"查询后台保活", @"category": @"后台保活", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance describeKeepAliveListWithParams:[weakSelf paramsForAllInstances:@{}]
                                                          completion:^(CaiDescribeKeepAliveListResponse *response, NSError *error) {
                if (![weakSelf reportBatchResult:response error:error action:title]) {
                    return;
                }
                ApiTestNSLog(@"%@: %@", title, response.deviceResponses);
            }];
        }},
        @{@"title": @"清空后台保活", @"category": @"后台保活", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance clearKeepAliveListWithParams:[weakSelf paramsForAllInstances:@{}]
                                                       completion:[weakSelf batchCompletion:title]];
        }},

        // ======================= 安装黑名单 =======================
        @{@"title": @"添加黑名单", @"category": @"黑名单", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance addAppInstallBlackListWithParams:[weakSelf paramsForAllInstances:@{
                @"AppList": @[@"com.unwanted.app"]
            }] completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"移除黑名单", @"category": @"黑名单", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance removeAppInstallBlackListWithParams:[weakSelf paramsForAllInstances:@{
                @"AppList": @[@"com.unwanted.app"]
            }] completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"覆盖黑名单", @"category": @"黑名单", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance setAppInstallBlackListWithParams:[weakSelf paramsForAllInstances:@{
                @"AppList": @[@"com.unwanted1.app", @"com.unwanted2.app"]
            }] completion:[weakSelf batchCompletion:title]];
        }},
        @{@"title": @"查询黑名单", @"category": @"黑名单", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance describeAppInstallBlackListWithParams:[weakSelf paramsForAllInstances:@{}]
                                                                completion:^(CaiDescribeAppInstallBlackListResponse *response, NSError *error) {
                if (![weakSelf reportBatchResult:response error:error action:title]) {
                    return;
                }
                ApiTestNSLog(@"%@: %@", title, response.deviceResponses);
            }];
        }},
        @{@"title": @"清空黑名单", @"category": @"黑名单", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance clearAppInstallBlackListWithParams:[weakSelf paramsForAllInstances:@{}]
                                                             completion:[weakSelf batchCompletion:title]];
        }},

        // ======================= 媒体库与系统信息 =======================
        @{@"title": @"搜索媒体文件", @"category": @"系统", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance mediaSearchWithParams:[weakSelf paramsForAllInstances:@{@"Keyword": @"movie"}]
                                                completion:^(CaiMediaSearchResponse *response, NSError *error) {
                if (![weakSelf reportBatchResult:response error:error action:title]) {
                    return;
                }
                ApiTestNSLog(@"%@: %@", title, response.deviceResponses);
            }];
        }},
        @{@"title": @"获取导航栏状态", @"category": @"系统", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance getNavVisibleStatusWithParams:[weakSelf paramsForAllInstances:@{}]
                                                        completion:^(CaiGetNavVisibleStatusResponse *response, NSError *error) {
                if (![weakSelf reportBatchResult:response error:error action:title]) {
                    return;
                }
                ApiTestNSLog(@"%@: %@", title, response.deviceResponses);
            }];
        }},
        @{@"title": @"获取媒体音量", @"category": @"系统", @"handler": ^(NSString *title) {
            [weakSelf.androidInstance getSystemMusicVolumeWithParams:[weakSelf paramsForAllInstances:@{}]
                                                         completion:^(CaiGetSystemMusicVolumeResponse *response, NSError *error) {
                if (![weakSelf reportBatchResult:response error:error action:title]) {
                    return;
                }
                ApiTestNSLog(@"%@: %@", title, response.deviceResponses);
            }];
        }},
    ];

    [self layoutAPIActionButtons];
}

/// 按 category 分组渲染菜单按钮
- (void)layoutAPIActionButtons {
    NSMutableArray<NSString *> *orderedCategories = [NSMutableArray new];
    NSMutableDictionary<NSString *, NSMutableArray *> *grouped = [NSMutableDictionary dictionary];
    for (NSDictionary *action in self.apiActions) {
        NSString *category = action[@"category"];
        if (grouped[category] == nil) {
            grouped[category] = [NSMutableArray array];
            [orderedCategories addObject:category];
        }
        [grouped[category] addObject:action];
    }

    CGFloat yOffset = 10;
    CGFloat buttonHeight = 40;
    CGFloat spacing = 10;
    CGFloat width = self.menuScrollView.bounds.size.width;

    for (NSString *category in orderedCategories) {
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, yOffset, width - 30, 30)];
        categoryLabel.text = category;
        categoryLabel.textColor = [UIColor lightGrayColor];
        categoryLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.menuScrollView addSubview:categoryLabel];
        yOffset += 30;

        for (NSDictionary *action in grouped[category]) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = CGRectMake(20, yOffset, width - 40, buttonHeight);
            [button setTitle:action[@"title"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
            button.layer.cornerRadius = 8;
            button.tag = [self.apiActions indexOfObject:action];
            [button addTarget:self action:@selector(apiButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.menuScrollView addSubview:button];
            yOffset += buttonHeight + spacing;
        }
        yOffset += 15;
    }

    self.menuScrollView.contentSize = CGSizeMake(width, yOffset);
}

- (void)apiButtonTapped:(UIButton *)sender {
    NSDictionary *action = self.apiActions[sender.tag];
    [self hide];
    // 等菜单收起动画结束再执行，避免弹窗与动画叠加
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ((ApiActionHandler)action[@"handler"])(action[@"title"]);
    });
}

#pragma mark - 批量接口调用约定

/**
 * 把同一份参数广播给所有目标实例。
 *
 * 批量接口的 params 结构是 instanceId → 该实例的参数，因此每台实例可以下发不同参数。
 * Demo 里所有实例用同一份参数，故统一在这里展开。
 */
- (NSDictionary<NSString *, NSDictionary *> *)paramsForAllInstances:(NSDictionary *)params {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.instanceIds.count];
    for (NSString *instanceId in self.instanceIds) {
        result[instanceId] = params;
    }
    return result;
}

/// 只关心成功/失败的指令型接口，用这个现成的 completion 即可
- (void (^)(CaiBatchTaskResponse *, NSError *))batchCompletion:(NSString *)action {
    __weak typeof(self) weakSelf = self;
    return ^(CaiBatchTaskResponse *response, NSError *error) {
        [weakSelf reportBatchResult:response error:error action:action];
    };
}

/**
 * 批量接口的结果检查，返回 YES 表示所有实例都成功。
 *
 * 三层结果需要分别判断，漏掉任何一层都会把失败当成功：
 *   1. error       —— 请求本身没成功（网络、参数序列化等）
 *   2. code        —— 请求成功但云端整体拒绝
 *   3. 各实例 code —— 整体 code 为 0 时，个别实例仍可能失败（如 10002 invalid token）
 */
- (BOOL)reportBatchResult:(CaiBatchTaskResponse *)response error:(NSError *)error action:(NSString *)action {
    if (error != nil) {
        ApiTestNSLog(@"%@ 请求失败: %@", action, error);
        [DemoToast showInView:self.hostView message:[action stringByAppendingString:@"失败"]];
        return NO;
    }
    if (response.code != 0) {
        ApiTestNSLog(@"%@ 整体失败: [%ld] %@", action, (long)response.code, response.message);
        [DemoToast showInView:self.hostView message:[action stringByAppendingString:@"失败"]];
        return NO;
    }

    NSMutableArray<NSString *> *failedItems = [NSMutableArray new];
    [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *instanceId, CaiDeviceResponse *item, BOOL *stop) {
        if (item.code != 0) {
            [failedItems addObject:[NSString stringWithFormat:@"%@([%ld]%@)", instanceId, (long)item.code, item.msg]];
        }
    }];
    if (failedItems.count > 0) {
        ApiTestNSLog(@"%@ 部分实例失败: %@", action, [failedItems componentsJoinedByString:@", "]);
        [DemoToast showInView:self.hostView message:[NSString stringWithFormat:@"%@：%lu 台实例失败", action, (unsigned long)failedItems.count]];
        return NO;
    }

    ApiTestNSLog(@"%@ 成功", action);
    [DemoToast showInView:self.hostView message:[action stringByAppendingString:@"成功"]];
    return YES;
}

#pragma mark - 上传文件构造

- (NSArray<CaiUploadFileItem *> *)uploadFileItems {
    NSArray *files = @[@[@"movie", @"mp4"], @[@"picture", @"jpg"], @[@"1", @"apk"]];
    NSMutableArray<CaiUploadFileItem *> *items = [NSMutableArray new];
    for (NSArray *file in files) {
        CaiUploadFileItem *item = [CaiUploadFileItem new];
        item.fileName = [NSString stringWithFormat:@"%@.%@", file[0], file[1]];
        item.filePath = @"/sdcard/media";
        item.fileData = [self dataForAssetNamed:file[0] ofType:file[1]];
        [items addObject:item];
    }
    return items;
}

- (NSArray<CaiUploadMediaFileItem *> *)uploadMediaFileItems {
    NSArray *files = @[@[@"movie", @"mp4"], @[@"picture", @"jpg"]];
    NSMutableArray<CaiUploadMediaFileItem *> *items = [NSMutableArray new];
    for (NSArray *file in files) {
        CaiUploadMediaFileItem *item = [CaiUploadMediaFileItem new];
        item.fileName = [NSString stringWithFormat:@"%@.%@", file[0], file[1]];
        item.fileData = [self dataForAssetNamed:file[0] ofType:file[1]];
        [items addObject:item];
    }
    return items;
}

#pragma mark - 本机传感器数据上报

- (void)enableCoreMotion:(BOOL)enable {
    self.isEnableSensor = enable;
    if (enable) {
        if (self.motionManager.isAccelerometerAvailable) {
            [DemoToast showInView:self.hostView message:@"开启传感器"];
            self.motionManager.accelerometerUpdateInterval = 0.1;
            [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                                      withHandler:^(CMAccelerometerData *data, NSError *error) {
                if (error != nil) {
                    ApiTestNSLog(@"读取加速度计失败: %@", error);
                    return;
                }
                [self setSensorDataWithAcceleration:data.acceleration];
            }];
        } else {
            [DemoToast showInView:self.hostView message:@"传感器不可用"];
        }
    } else {
        [self.motionManager stopAccelerometerUpdates];
        [DemoToast showInView:self.hostView message:@"关闭传感器"];
    }
}

/**
 * 把本机加速度计数据持续上报给云端实例，云端应用读到的传感器值即为本机姿态。
 *
 * 上报频率较高，因此结果只在失败时打日志，不逐次弹提示。
 */
- (void)setSensorDataWithAcceleration:(CMAcceleration)acceleration {
    NSDictionary *params = [self paramsForAllInstances:@{
        @"Type": @"accelerometer",
        @"Values": @[@(acceleration.x), @(acceleration.y), @(acceleration.z)]
    }];
    [self.androidInstance setSensorWithParams:params completion:^(CaiBatchTaskResponse *response, NSError *error) {
        if (error != nil || response.code != 0) {
            ApiTestNSLog(@"上报加速度计失败: %@ / [%ld] %@", error, (long)response.code, response.message);
        }
    }];
}

#pragma mark - 辅助方法

/// 读取工程内置的演示文件（movie.mp4 / picture.jpg / 1.apk），供上传接口使用
- (NSData *)dataForAssetNamed:(NSString *)name ofType:(NSString *)type {
    NSDataAsset *dataAsset = [[NSDataAsset alloc] initWithName:name];
    if (dataAsset.data != nil) {
        return dataAsset.data;
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    return filePath != nil ? [NSData dataWithContentsOfFile:filePath] : nil;
}

@end
