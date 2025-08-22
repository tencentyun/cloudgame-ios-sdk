//
//  AndroidInstance.h
//  CaiSDK
//
//  Created by Junfeng Gao on 2025/7/1.
//  Copyright © 2025 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <tcrsdk/TcrSession.h>

#pragma mark - 批量任务响应基类

/**
 * 每个设备响应基类
 * @discussion 表示单个设备操作的响应结果
 */
@interface CaiDeviceResponse : NSObject

/**
 * 单个设备操作状态码
 * @discussion 0 表示成功，非0表示失败（
 * Code: 10001, Msg: "invalid param"，
 * Code: 10002, Msg: "invalid token"，
 * Code: 10003, Msg: "invalid operate"）
 */
@property (nonatomic, assign) NSInteger code;

/**
 * 单个设备状态消息
 * @discussion 操作结果的描述信息
 */
@property (nonatomic, copy, nullable) NSString *msg;

@end

/**
 * 批量任务响应基类
 * @discussion 表示批量操作的响应结果
 */
@interface CaiBatchTaskResponse<__covariant DeviceResponseType: CaiDeviceResponse *> : NSObject

/**
 * 整体操作状态码
 * @discussion
 *   - 0: 整体操作成功（可能包含部分设备失败）
 *   - 非0: 整体操作失败
 */
@property (nonatomic, assign) NSInteger code;

/**
 * 整体状态消息
 * @discussion 操作结果的描述信息
 */
@property (nonatomic, copy, nullable) NSString *message;

/**
 * 各设备响应字典
 * @discussion
 *   - key: instanceId (NSString)
 *   - value: CaiDeviceResponse 子类对象
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, DeviceResponseType> *deviceResponses;

@end

#pragma mark - DescribeInstanceProperties内部数据模型

/**
 * 设备信息模型
 * @discussion 包含设备的品牌和型号信息
 */
@interface CaiDeviceInfo : NSObject

/**
 * 设备品牌
 * @discussion 例如 @"Samsung", @"Xiaomi" 等
 */
@property (nonatomic, copy, nullable) NSString *brand;

/**
 * 设备型号
 * @discussion 例如 @"Galaxy S24", @"Redmi Note 10" 等
 */
@property (nonatomic, copy, nullable) NSString *model;

@end

/**
 * GPS 位置信息模型
 * @discussion 表示设备的地理位置
 */
@interface CaiGPSInfo : NSObject

/**
 * 经度值
 * @discussion 范围 -180.0 ~ 180.0
 */
@property (nonatomic, assign) double longitude;

/**
 * 纬度值
 * @discussion 范围 -90.0 ~ 90.0
 */
@property (nonatomic, assign) double latitude;

@end

/**
 * 语言信息模型
 * @discussion 表示设备的语言设置
 */
@interface CaiLanguageInfo : NSObject

/**
 * 语言代码
 * @discussion 例如 @"zh", @"en" 等
 */
@property (nonatomic, copy, nullable) NSString *language;

/**
 * 国家/地区代码
 * @discussion 例如 @"CN", @"US" 等
 */
@property (nonatomic, copy, nullable) NSString *country;

@end

/**
 * 地区信息模型
 * @discussion 表示设备的地区设置
 */
@interface CaiLocaleInfo : NSObject

/**
 * 时区设置
 * @discussion 例如 @"Asia/Shanghai", @"America/Los_Angeles"
 */
@property (nonatomic, copy, nullable) NSString *timezone;

@end

/**
 * 代理信息模型
 * @discussion 表示设备的网络代理配置
 */
@interface CaiProxyInfo : NSObject

/**
 * 是否启用代理
 * @discussion YES/NO 表示启用/禁用
 */
@property (nonatomic, assign) BOOL enabled;

/**
 * 代理协议
 * @discussion 例如 @"http", @"socks5", @"https"
 */
@property (nonatomic, copy, nullable) NSString *protocol;

/**
 * 代理服务器主机地址
 */
@property (nonatomic, copy, nullable) NSString *host;

/**
 * 代理服务器端口
 */
@property (nonatomic, assign) NSInteger port;

/**
 * 代理认证用户名
 */
@property (nonatomic, copy, nullable) NSString *user;

/**
 * 代理认证密码
 */
@property (nonatomic, copy, nullable) NSString *password;

@end

/**
 * SIM 卡信息模型
 * @discussion 表示设备的 SIM 卡状态和识别信息
 */
@interface CaiSIMInfo : NSObject

/**
 * SIM 卡状态
 * @discussion 0=未激活, 1=已激活
 */
@property (nonatomic, assign) NSInteger state;

/**
 * 手机号码
 */
@property (nonatomic, copy, nullable) NSString *phoneNumber;

/**
 * 国际移动用户识别码
 */
@property (nonatomic, copy, nullable) NSString *IMSI;

/**
 * 集成电路卡识别码
 */
@property (nonatomic, copy, nullable) NSString *ICCID;

@end

/**
 * 额外属性模型
 * @discussion 表示设备自定义属性
 */
@interface CaiExtraProperty : NSObject

/**
 * 属性键名
 */
@property (nonatomic, copy, nullable) NSString *key;

/**
 * 属性值
 */
@property (nonatomic, copy, nullable) NSString *value;
@end

/**
 * 属性查询响应项
 * @discussion 单台设备的属性查询结果
 */
@interface CaiInstancePropertiesResponseItem : CaiDeviceResponse

/**
 * 请求ID
 * @discussion 用于追踪请求的唯一标识
 */
@property (nonatomic, copy, nullable) NSString *requestId;

/**
 * 设备信息
 */
@property (nonatomic, strong, nullable) CaiDeviceInfo *deviceInfo;

/**
 * GPS 信息
 */
@property (nonatomic, strong, nullable) CaiGPSInfo *GPSInfo;

/**
 * 语言信息
 */
@property (nonatomic, strong, nullable) CaiLanguageInfo *languageInfo;

/**
 * 地区信息
 */
@property (nonatomic, strong, nullable) CaiLocaleInfo *localeInfo;

/**
 * 代理信息
 */
@property (nonatomic, strong, nullable) CaiProxyInfo *proxyInfo;

/**
 * SIM 卡信息
 */
@property (nonatomic, strong, nullable) CaiSIMInfo *SIMInfo;
@end

#pragma mark - App数据模型

/**
 * 应用信息模型
 * @discussion 表示设备的应用程序信息
 */
@interface CaiApp : NSObject

/**
 * 首次安装时间
 * @discussion Unix 时间戳 (毫秒)
 */
@property (nonatomic, assign) long long firstInstallTimeMs;

/**
 * 应用显示名称
 * @discussion 用户可见的应用名称
 */
@property (nonatomic, copy, nullable) NSString *label;

/**
 * 最后更新时间
 * @discussion Unix 时间戳 (毫秒)
 */
@property (nonatomic, assign) long long lastUpdateTimeMs;

/**
 * 应用包名
 * @discussion 唯一标识应用的包名
 */
@property (nonatomic, copy, nullable) NSString *packageName;

/**
 * 应用版本名称
 * @discussion 例如 @"1.0.0", @"2.3.4"
 */
@property (nonatomic, copy, nullable) NSString *versionName;

@end

/**
 * 用户应用查询响应项
 * @discussion 单台设备的第三方应用查询结果
 */
@interface CaiListUserAppsResponseItem : CaiDeviceResponse

///**
// * 请求ID
// * @discussion 用于追踪请求的唯一标识
// */
//@property (nonatomic, copy) NSString *requestId;

/**
 * 应用列表
 * @discussion 设备上安装的第三方应用程序列表
 */
@property (nonatomic, strong, nullable) NSArray<CaiApp *> *appList;

@end

/**
 * 所有应用查询响应项
 * @discussion 单台设备的所有应用程序查询结果
 */
@interface CaiListAllAppsResponseItem : CaiDeviceResponse

/**
 * 请求ID
 * @discussion 用于追踪请求的唯一标识
 */
@property (nonatomic, copy, nullable) NSString *requestId;

/**
 * 所有应用列表
 * @discussion 包括系统应用和第三方应用
 */
@property (nonatomic, strong, nullable) NSArray<CaiApp *> *appList;

@end

#pragma mark - DescribeKeepFrontAppStatus数据模型
/**
 * 前台保持响应项
 */
@interface CaiDescribeKeepFrontAppStatusResponseItem : CaiDeviceResponse

/**
 * 应用包名
 */
@property (nonatomic, strong, nullable) NSString *packageName;

/**
 * 应用前台保持
 */
@property (nonatomic, assign) BOOL enable;

/**
 * 重启间隔时长
 */
@property (nonatomic, assign) int restartIntervalSeconds;

@end

#pragma mark - DescribeCameraMediaPlayStatus数据模型
/**
 * 摄像头媒体状态响应项
 * @discussion 单台设备的摄像头媒体播放状态
 */
@interface CaiDescribeCameraMediaPlayStatusResponseItem : CaiDeviceResponse

/**
 * 媒体文件路径
 */
@property (nonatomic, copy, nullable) NSString *filePath;

/**
 * 循环次数
 * @discussion 负数表示无限循环
 */
@property (nonatomic, assign) NSInteger loops;

@end

#pragma mark - DescribeKeepAliveList数据模型
/**
 * 保活列表响应项
 * @discussion 单台设备的后台保活应用列表
 */
@interface CaiDescribeKeepAliveListResponseItem : CaiDeviceResponse

/**
 * 保活应用列表
 * @discussion 应用包名的数组
 */
@property (nonatomic, strong, nullable) NSArray<NSString *> *appList;

@end

#pragma mark - MediaSearch数据模型
/**
 * 媒体文件信息模型
 * @discussion 表示媒体文件的基本信息
 */
@interface CaiMediaItem : NSObject

/**
 * 文件名
 * @discussion 包含扩展名，例如 @"video.mp4"
 */
@property (nonatomic, copy, nullable) NSString *fileName;

/**
 * 完整文件路径
 * @discussion 例如 @"/sdcard/Movies/video.mp4"
 */
@property (nonatomic, copy, nullable) NSString *filePath;

/**
 * 文件大小
 * @discussion 以字节为单位的文件大小
 */
@property (nonatomic, assign) long long fileBytes;

/**
 * 文件修改时间
 * @discussion Unix 时间戳 (毫秒)
 */
@property (nonatomic, assign) long long fileModifiedTime;

@end

/**
 * 媒体搜索响应项
 * @discussion 单台设备的媒体搜索结果
 */
@interface CaiMediaSearchResponseItem : CaiDeviceResponse

/**
 * 媒体文件列表
 */
@property (nonatomic, strong, nullable) NSArray<CaiMediaItem *> *mediaList;

@end

/**
 * 批量媒体搜索响应
 * @discussion 多台设备的媒体搜索结果
 */
@interface CaiMediaSearchResponse : CaiBatchTaskResponse<CaiMediaSearchResponseItem *>
@end

#pragma mark - DescribeAppInstallBlackList数据模型
/**
 * 应用黑名单响应项
 * @discussion 单台设备的应用安装黑名单
 */
@interface CaiDescribeAppInstallBlackListResponseItem : CaiDeviceResponse

/**
 * 黑名单应用列表
 * @discussion 禁止安装的应用包名数组
 */
@property (nonatomic, strong, nullable) NSArray<NSString *> *appList;

@end

#pragma mark - GetNavVisibleStatus数据模型
/**
 * 获取单台设备当前系统导航栏显示状态响应
 */
@interface CaiGetNavVisibleStatusResponseItem : CaiDeviceResponse

/**
 * 导航栏是否显示
 */
@property (nonatomic, assign) BOOL visible;

@end

#pragma mark - getSystemMusicVolume数据模型
/**
 * 获取单台设备当前系统媒体音量大小
 */
@interface CaiGetSystemMusicVolumeResponseItem : CaiDeviceResponse

/**
 * 当前系统媒体音量大小（0-100）
 */
@property (nonatomic, assign) NSInteger volume;

@end

#pragma mark - 文件上传数据模型

@interface CaiUploadFileItem : NSObject
@property (nonatomic, strong, nullable) NSData *fileData;
@property (nonatomic, copy, nullable) NSString *fileName;
@property (nonatomic, copy, nullable) NSString *filePath; // 可选路径
@end

@interface CaiUploadMediaFileItem : NSObject
@property (nonatomic, strong, nullable) NSData *fileData;
@property (nonatomic, copy, nullable) NSString *fileName;
@end

#pragma mark - 响应模型实现



/**
 * 批量属性查询响应
 * @discussion 多台设备的属性查询结果
 */
@interface CaiDescribeInstancePropertiesResponse : CaiBatchTaskResponse<CaiInstancePropertiesResponseItem *>
@end

/**
 * 批量用户应用查询响应
 * @discussion 多台设备的第三方应用查询结果
 */
@interface CaiListUserAppsResponse :  CaiBatchTaskResponse<CaiListUserAppsResponseItem *>
@end

/**
 * 批量摄像头媒体状态响应
 * @discussion 多台设备的摄像头媒体播放状态
 */
@interface CaiDescribeCameraMediaPlayStatusResponse : CaiBatchTaskResponse<CaiDescribeCameraMediaPlayStatusResponseItem *>
@end

/**
 * 批量前台保持响应
 */
@interface CaiDescribeKeepFrontAppStatusResponse : CaiBatchTaskResponse<CaiDescribeKeepFrontAppStatusResponseItem *>
@end

/**
 * 批量保活列表响应
 * @discussion 多台设备的后台保活应用列表
 */
@interface CaiDescribeKeepAliveListResponse : CaiBatchTaskResponse<CaiDescribeKeepAliveListResponseItem *>
@end

/**
 * 批量所有应用查询响应
 * @discussion 多台设备的所有应用程序查询结果
 */
@interface CaiListAllAppsResponse : CaiBatchTaskResponse<CaiListAllAppsResponseItem *>
@end

/**
 * 批量应用黑名单响应
 * @discussion 多台设备的应用安装黑名单
 */
@interface CaiDescribeAppInstallBlackListResponse : CaiBatchTaskResponse<CaiDescribeAppInstallBlackListResponseItem *>
@end

/**
 * 获取当前系统导航栏显示状态响应
 * @discussion 多台设备的系统导航栏显示状态响应
 */
@interface CaiGetNavVisibleStatusResponse : CaiBatchTaskResponse<CaiGetNavVisibleStatusResponseItem *>
@end

/**
 * 获取多台设备的当前系统媒体音量大小
 * @discussion 多台设备的当前系统媒体音量大小
 */
@interface CaiGetSystemMusicVolumeResponse : CaiBatchTaskResponse<CaiGetSystemMusicVolumeResponseItem *>
@end

/**
 * 文件上传响应
 */
@interface CaiUploadResponse : NSObject
/**
 * 响应码
 */
@property (nonatomic, assign) NSInteger code;
/**
 * 响应消息
 */
@property (nonatomic, copy, nullable) NSString *msg;
/**
 * 文件状态
 */
@property (nonatomic, strong, nullable) NSArray<NSDictionary *> *fileStatus;
@end

/**
 * 媒体上传响应
 */
@interface CaiUploadMediaFilesResponse : NSObject
/**
 * 响应码
 */
@property (nonatomic, assign) NSInteger code;
/**
 * 响应消息
 */
@property (nonatomic, copy, nullable) NSString *msg;
@end


#pragma mark - 回调类型定义

/**
 * 批量任务基础回调类型
 * @param response 批量任务响应模型
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiBatchTaskCompletion)(CaiBatchTaskResponse *_Nonnull response, NSError * _Nullable error);

/**
 * 上传文件回调类型
 * @param response 上传文件响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiUploadFilesCompletion)(CaiUploadResponse *_Nonnull response, NSError *_Nullable error);

/**
 * 上传媒体文件回调类型
 * @param response 上传文件响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiUploadMediaFilesCompletion)(CaiUploadMediaFilesResponse *_Nonnull response, NSError *_Nullable error);

/**
 * 属性查询回调类型
 * @param response 属性查询响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiDescribeInstancePropertiesCompletion)(CaiDescribeInstancePropertiesResponse *_Nonnull response, NSError *_Nullable error);

/**
 * 用户应用查询回调类型
 * @param response 用户应用查询响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiListUserAppsCompletion)(CaiListUserAppsResponse *_Nonnull response, NSError *_Nullable error);

/**
 * 摄像头媒体状态回调类型
 * @param response 摄像头媒体状态响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiDescribeCameraMediaPlayStatusCompletion)(CaiDescribeCameraMediaPlayStatusResponse *_Nonnull response, NSError *_Nullable error);

/**
 * 应用前台状态回调类型
 * @param response 应用前台状态响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiDescribeKeepFrontAppStatusCompletion)(CaiDescribeKeepFrontAppStatusResponse *_Nonnull response, NSError *_Nullable error);

/**
 * 保活列表查询回调类型
 * @param response 保活列表响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiDescribeKeepAliveListCompletion)(CaiDescribeKeepAliveListResponse *_Nonnull response, NSError *_Nullable error);

/**
 * 媒体搜索回调类型
 * @param response 媒体搜索响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiMediaSearchCompletion)(CaiMediaSearchResponse *_Nonnull response, NSError *_Nullable error);

/**
 * 所有应用查询回调类型
 * @param response 所有应用查询响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiListAllAppsCompletion)(CaiListAllAppsResponse *_Nonnull response, NSError *_Nullable error);

/**
 * 应用黑名单查询回调类型
 * @param response 应用黑名单响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiDescribeAppInstallBlackListCompletion)(CaiDescribeAppInstallBlackListResponse *_Nonnull response, NSError *_Nullable error);

/**
 * 获取当前系统导航栏显示状态回调类型
 * @param response 获取当前系统导航栏显示状态响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiGetNavVisibleStatusCompletion)(CaiGetNavVisibleStatusResponse *_Nonnull response, NSError *_Nullable error);

/**
 * 获取当前系统媒体音量大小回调类型
 * @param response 获取当前系统媒体音量大小响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiGetSystemMusicVolumeCompletion)(CaiGetSystemMusicVolumeResponse *_Nonnull response, NSError *_Nullable error);


#pragma mark - AndroidInstance 接口类

/**
 * CaiSDK - AndroidInstance 子模块
 *
 * 需要正常初始化CaiSDK后，再调用AndroidInstance相关接口
 *
 * AndroidInstance是CaiSDK的子模块，用于操作云Android设备，包括几类操作能力：
 * 1. 连接单个实例看到云手机画面，以及云手机各种操作
 * 2. 通过截图预览多个云手机的画面
 * 3. 其他各类功能操作
 */
@interface AndroidInstance : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)createInstance NS_UNAVAILABLE;


#pragma mark - 云手机群控接口

/**
 * 设置主控设备
 * @param instanceId 主控设备的instanceId
 */
- (void)setMasterWithInstanceId:(NSString * _Nonnull)instanceId;

/**
 * 请求被控串流
 * @param instanceId 请求串流的instanceId
 * @param status 串流状态（"open"开启/"close"关闭）
 * @param level 串流质量等级（"low"/"normal"/"high"）
 */
- (void)requestStreamWithInstanceId:(NSString * _Nonnull)instanceId
                            status:(NSString *_Nonnull)status
                             level:(NSString *_Nonnull)level;

/**
 * 设置同步实例列表，每次设置都会覆盖上次设置的列表。如果需要停止同步，传入nil或空列表。
 *
 * @param list 需要同步的instanceId列表
 */
- (void)setSyncList:(NSArray<NSString *> *_Nullable)list;

/**
 * 中途加入群控
 * @param instanceIds 需要加入的实例列表
 * @param clientSessions clientSession（可选）
 */
- (void)joinGroupControlWithInstanceIds:(NSArray<NSString *> *_Nonnull)instanceIds
                         clientSessions:(nullable NSArray<NSString *> *)clientSessions;

/**
 * 设置截图事件
 * @param interval 截图事件的间隔（毫秒）
 * @param quality 截图质量（0-100，可选）
 * @param screenshotWidth 截图宽度
 * @param screenshotHeight 截图高度
 */
- (void)setImageEventWithInterval:(NSInteger)interval
                          quality:(nullable NSNumber *)quality screenshotWidth:(int)screenshotWidth screenshotHeight:(int)screenshotHeight;

/**
 * 停止截图事件
 */
- (void)stopImageEvent;

#pragma mark - 云手机消息传输发送

/**
 * 发送App binder消息（单连接适用）
 * @param packageName 应用包名
 * @param message 消息内容
 */
- (void)transMessageWithPackageName:(NSString *_Nonnull)packageName
                           message:(NSString *_Nonnull)message;


#pragma mark - 云手机操作接口
#pragma mark 云手机操作接口 > 单设备操作
/**
 * 获取实例截图信息，quality默认20，分辨率720x1280
 *
 * @param instanceId 实例Id
 * @return 截图URL
 */
- ( NSString * _Nullable )getInstanceImageWithInstanceId:(NSString *_Nonnull)instanceId;

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
                                        quality:(int)quality screenshotWidth:(int)screenshotWidth screenshotHeight:(int)screenshotHeight;

/**
 * 向云端实例上传文件
 *
 * @param instanceId  实例 Id
 * @param files 上传的文件
 * @param completion 任务完成的回调
 */
- (void)uploadWithInstanceId:(NSString *_Nonnull)instanceId files:(NSArray<CaiUploadFileItem *> *_Nonnull)files completion: (nullable CaiUploadFilesCompletion)completion;

/**
 * 向云端实例上传文件
 *
 * @param instanceId  实例 Id
 * @param files 上传的文件
 * @param completion 任务完成的回调
 */
- (void)uploadMediaWithInstanceId:(NSString *_Nonnull)instanceId files:(NSArray<CaiUploadMediaFileItem *> *_Nonnull)files completion: (nullable CaiUploadMediaFilesCompletion)completion;

/**
 * 获取实例下载地址
 *
 * @param instanceId  实例 Id
 * @param path 下载路径
 *
 * @returns response address - 下载地址
 */
- (NSString *_Nonnull)getInstanceDownloadAddressWithInstanceId:(NSString *_Nonnull)instanceId path:(NSString *_Nonnull)path;

/**
 * 获取logcat日志下载地址
 *
 * @param instanceId  实例 Id
 * @param recentDay 最近几天的日志
 *
 * @returns response address - 下载地址
 */
- (NSString *_Nonnull)getInstanceDownloadLogcatAddressWithInstanceId:(NSString *_Nonnull)instanceId recentDay:(int)recentDay;


#pragma mark 云手机操作接口 > 批量设备操作（异步接口）
/**
 * 批量设置设备GPS位置信息
 * @discussion 为多台设备设置模拟GPS位置信息，支持同时更新多个设备的定位数据
 *
 * 参数结构说明:
 * @param params 位置信息参数字典
 *               - key: instanceId (NSString)
 *               - value: 位置参数 (NSDictionary)，结构为:
 *                 @{
 *                    @"Longitude": @(经度值),  // 经度 (double)
 *                    @"Latitude": @(纬度值)    // 纬度 (double)
 *                 }
 * @param completion 批量操作回调
 */
- (void)setLocationWithParams:(NSDictionary<NSString *, NSDictionary *> *_Nonnull)params
                   completion:(nullable CaiBatchTaskCompletion)completion;

/**
 * 批量设置设备分辨率
 * @discussion 动态调整设备屏幕分辨率，支持同时修改多个设备的显示设置
 *
 * 参数结构说明:
 * @param params 分辨率参数字典
 *               - key: instanceId (NSString)
 *               - value: 分辨率参数 (NSDictionary)，结构为:
 *                 @{
 *                    @"Width": @(宽度值),   // 宽度像素 (NSInteger)
 *                    @"Height": @(高度值),  // 高度像素 (NSInteger)
 *                    @"DPI": @(DPI值)      // 像素密度 (NSInteger，可选)
 *                 }
 * @param completion 批量操作回调
 *
 */
- (void)setResolutionWithParams:(NSDictionary<NSString *, NSDictionary *> *_Nonnull)params
                     completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量粘贴文本到设备
 * @discussion 模拟在多个设备输入框执行粘贴操作
 *
 * 参数结构说明:
 * @param params 粘贴文本参数字典
 *               - key: instanceId (NSString)
 *               - value: 粘贴参数 (NSDictionary)，结构为:
 *                 @{
 *                    @"Text": @"粘贴文本"  // 要粘贴的文本内容
 *                 }
 * @param completion 批量操作回调
 *
 */
- (void)pasteWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
             completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量发送文本到设备剪切板
 * @discussion 将文本复制到多个设备的系统剪切板
 *
 * 参数结构说明:
 * @param params 剪切板文本参数字典
 *               - key: instanceId (NSString)
 *               - value: 文本参数 (NSDictionary)，结构为:
 *                 @{
 *                    @"Text": @"剪切板内容"  // 要复制到剪切板的文本
 *                 }
 * @param completion 批量操作回调
 *
 */
- (void)sendClipboardWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                     completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量执行摇一摇操作
 * @discussion 在多个设备上模拟摇一摇手势（加速度传感器事件）
 *
 * 参数结构说明:
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{} (保留未来扩展)
 * @param completion 批量操作回调
 *
 */
- (void)shakeWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
             completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量执行吹一吹操作
 * @discussion 在多个设备上模拟吹一吹
 *
 * 参数结构说明:
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{} (保留未来扩展)
 * @param completion 批量操作回调
 *
 */
- (void)blowWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
             completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量设置设备传感器信息
 * @discussion 为多台设备设置加速度计或陀螺仪传感器数据，用于模拟设备的运动状态。
 *
 * 参数结构说明:
 * @param params 操作参数字典
 *               - key: instanceId (NSString)
 *               - value: 传感器参数 (NSDictionary)，结构为:
 *                 @{
 *                    @"Type": sensorType,       // 传感器类型字符串 (必需)
 *                    @"Values": valuesArray      // 传感器数值数组 (必需)
 *                 }
 * @param completion 批量操作回调
 *
 * 传感器参数详解:
 * - <b>Type (NSString)</b>：
 *   支持的传感器类型：
 *     - @"accelerometer"：加速度计 (单位: m/s²)
 *     - @"gyroscope"：陀螺仪 (单位: rad/s)
 *
 * - <b>Values (NSArray<NSNumber *>)</b>：
 *   3维数值数组，依次表示 x/y/z 轴的值，格式为:
 *     @[ @(xValue), @(yValue), @(zValue) ]
 */
- (void)setSensorWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                 completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量发送App binder消息
 * @discussion 向多台设备上的指定应用发送自定义消息
 *
 * 参数结构说明:
 * @param params 消息参数字典
 *               - key: instanceId (NSString)
 *               - value: 消息参数 (NSDictionary)，结构为:
 *                 @{
 *                    @"PackageName": @"应用包名",  // 接收消息的应用包名
 *                    @"Msg": @"消息内容"         // 要发送的自定义消息
 *                 }
 * @param completion 批量操作回调
 */
- (void)sendTransMessageWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                       completion:(CaiBatchTaskCompletion _Nullable)completion;

#pragma mark 云手机操作接口 > 批量设备操作（异步接口） > 设备属性与应用管理

/**
 * 批量查询实例属性
 * @discussion 查询多台设备的基础属性和配置信息，如设备品牌、型号、代理设置等
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 批量操作回调
 *
 *
 * 响应数据结构:
 * @code
 * {
 *   "DeviceInfo": { "Brand": "Samsung", "Model": "Galaxy S24" },
 *   "ProxyInfo": { "Enabled": true, "Protocol": "socks5", ... },
 *   "GPSInfo": { "Longitude": 121.4737, "Latitude": 31.2304 },
 *   // 其他属性...
 * }
 * @endcode
 */
- (void)describeInstancePropertiesWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                                 completion:(nullable CaiDescribeInstancePropertiesCompletion)completion;

/**
 * 查询已安装第三方应用
 * @discussion 获取设备上安装的所有第三方应用程序列表
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调
 */
- (void)listUserAppsWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                   completion:(CaiListUserAppsCompletion _Nullable)completion;


- (void)modifyInstancePropertiesWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                               completion:(CaiBatchTaskCompletion _Nullable)completion;

#pragma mark 云手机操作接口 > 批量设备操作（异步接口） > 应用管理操作

/**
 * 批量卸载应用
 * @discussion 从多台设备卸载指定的应用程序
 *
 * @param params 卸载参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"PackageName": @"应用包名"}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 */
- (void)unInstallByPackageNameWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                             completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量启动应用
 * @discussion 在多个设备上启动指定的应用程序和Activity
 *
 * @param params 启动参数字典
 *               - key: instanceId (NSString)
 *               - value: @{
 *                   @"PackageName": @"应用包名",
 *                   @"ActivityName": @"Activity"
 *                 }
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)startAppWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量停止应用
 * @discussion 停止在多个设备上运行的指定应用程序
 *
 * @param params 停止参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"PackageName": @"应用包名"}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)stopAppWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
               completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量清除应用数据
 * @discussion 清除指定应用程序在设备上的应用数据
 *
 * @param params 清除参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"PackageName": @"应用包名"}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)clearAppDataWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                    completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量启用应用
 * @discussion 启用设备上被禁用的应用程序
 *
 * @param params 启用参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"PackageName": @"应用包名"}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)enableAppWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                 completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量禁用应用
 * @discussion 禁用设备上的指定应用程序(相当于"冻结"应用)
 *
 * @param params 禁用参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"PackageName": @"应用包名"}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)disableAppWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                  completion:(CaiBatchTaskCompletion _Nullable)completion;

#pragma mark 云手机操作接口 > 批量设备操作（异步接口） > 摄像头控制

/**
 * 批量在摄像头播放媒体文件
 * @discussion 在设备摄像头模拟视频流输入
 *
 * @param params 播放参数字典
 *               - key: instanceId (NSString)
 *               - value: @{
 *                   @"FilePath": @"视频文件路径",
 *                   @"Loops": @(循环次数) // 负数表示无限循环
 *                 }
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)startCameraMediaPlayWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                           completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量停止摄像头媒体播放
 * @discussion 停止在设备摄像头上的媒体文件播放
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 */
- (void)stopCameraMediaPlayWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                          completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量查询摄像头播放状态
 * @discussion 获取当前在设备摄像头上的媒体播放状态
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调
 */
- (void)describeCameraMediaPlayStatusWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                                    completion:(CaiDescribeCameraMediaPlayStatusCompletion _Nullable)completion;

/**
 * 批量在摄像头显示图片
 * @discussion 在设备摄像头模拟输入静态图片
 *
 * @param params 图片参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"FilePath": @"图片文件路径"}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)displayCameraImageWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                          completion:(CaiBatchTaskCompletion _Nullable)completion;

#pragma mark 云手机操作接口 > 批量设备操作（异步接口） > 应用保活管理

/**
 * 修改前台应用保活状态
 * @discussion 配置指定应用在设备前台崩溃或被关闭时的自动重启策略
 *
 * @param params 保活参数字典
 *               - key: instanceId (NSString)
 *               - value: 保活参数 @{
 *                   @"PackageName": @"应用包名",
 *                   @"Enable": @(YES/NO), // 是否启用保活
 *                   @"RestartInterValSeconds": @(秒数) // 重新拉起最长间隔
 *                 }
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)modifyKeepFrontAppStatusWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                               completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 查询前台应用保活状态
 * @discussion 获取设备上已配置的前台应用保活设置
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调
 */
- (void)describeKeepFrontAppStatusWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                                 completion:(CaiDescribeKeepFrontAppStatusCompletion _Nullable)completion;


#pragma mark 云手机操作接口 > 批量设备操作（异步接口） > 后台保活管理

/**
 * 批量添加后台保活应用
 * @discussion 将应用添加到设备后台保活列表，减少被系统杀死的概率
 *
 * @param params 保活参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"AppList": @[@"应用包名1", @"应用包名2"]}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)addKeepAliveListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                       completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量移除后台保活应用
 * @discussion 从设备后台保活列表中移除指定应用
 *
 * @param params 移除参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"AppList": @[@"应用包名1", @"应用包名2"]}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)removeKeepAliveListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                          completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量设置后台保活列表
 * @discussion 完全覆盖设备后台保活列表(替换现有列表)
 *
 * @param params 保活参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"AppList": @[@"应用包名1", @"应用包名2"]}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)setKeepAliveListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                       completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量查询后台保活列表
 * @discussion 获取设备当前的后台保活应用列表
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调
 */
- (void)describeKeepAliveListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                            completion:(CaiDescribeKeepAliveListCompletion _Nullable)completion;

/**
 * 批量清空后台保活列表
 * @discussion 清空设备上所有后台保活应用
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)clearKeepAliveListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                          completion:(CaiBatchTaskCompletion _Nullable)completion;

#pragma mark 云手机操作接口 > 批量设备操作（异步接口） > 设备控制

/**
 * 批量设置设备静音
 * @discussion 将多台设备的媒体音量设为静音
 *
 * @param params 静音参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"Mute": @(YES/NO)} // YES:静音, NO:取消静音
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)muteWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
            completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量搜索媒体库文件
 * @discussion 在多台设备上搜索媒体库文件
 *
 * @param params 搜索参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"Keyword": @"搜索关键词"}
 * @param completion 完成回调
 */
- (void)mediaSearchWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                   completion:(CaiMediaSearchCompletion _Nullable)completion;

/**
 * 批量重启设备
 * @discussion 重启多台设备
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)rebootWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
              completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量查询所有应用列表
 * @discussion 获取设备上安装的所有应用列表
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调
 */
- (void)listAllAppsWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                   completion:(CaiListAllAppsCompletion _Nullable)completion;

/**
 * 批量关闭应用到后台
 * @discussion 将前台应用切换到后台运行
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)moveAppBackgroundWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                         completion:(CaiBatchTaskCompletion _Nullable)completion;

#pragma mark 云手机操作接口 > 批量设备操作（异步接口） > 应用黑名单管理

/**
 * 批量新增应用安装黑名单
 * @discussion 批量新增应用安装黑名单，新增时如果应用已安装，会进行卸载。
 *
 * @param params 黑名单参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"AppList": @[@"应用包名1", @"应用包名2"]}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @note 如果黑名单应用已安装，会被自动卸载
 */
- (void)addAppInstallBlackListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                             completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量移除应用安装黑名单
 * @discussion 从黑名单中移除应用，允许安装
 *
 * @param params 黑名单参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"AppList": @[@"应用包名1", @"应用包名2"]}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)removeAppInstallBlackListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                                completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量覆盖应用安装黑名单
 * @discussion 完全替换设备上的应用安装黑名单
 *
 * @param params 黑名单参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"AppList": @[@"应用包名1", @"应用包名2"]}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)setAppInstallBlackListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                             completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量查询应用安装黑名单
 * @discussion 获取设备当前的应用安装黑名单
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调
 */
- (void)describeAppInstallBlackListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                                  completion:(CaiDescribeAppInstallBlackListCompletion _Nullable)completion;

/**
 * 批量清空应用安装黑名单
 * @discussion 清空设备上的应用安装黑名单
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 */
- (void)clearAppInstallBlackListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                               completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * 批量获取导航栏可见状态
 * @discussion 查询设备导航栏（状态栏）的当前可见状态。导航栏通常包含时间、电池状态和通知图标等系统信息。
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString) 设备实例ID
 *               - value: 空字典 @{} 表示不需要额外参数
 * @param completion 完成回调，返回导航栏状态结果
 *                  - response: CaiGetNavVisibleStatusResponse 对象，包含导航栏状态信息
 *                  - error: 网络或系统错误对象
 */
- (void)getNavVisibleStatusWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                               completion:(CaiGetNavVisibleStatusCompletion _Nullable)completion;

/**
 * 获取系统媒体音量
 * @discussion 查询设备当前的媒体音量设置。媒体音量控制音乐、视频、游戏和其他媒体内容的播放音量。
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString) 设备实例ID
 *               - value: 空字典 @{} 表示不需要额外参数
 * @param completion 完成回调，返回音量信息
 *                  - response: CaiGetSystemMusicVolumeResponse 对象，包含音量信息
 *                  - error: 网络或系统错误对象
 */
- (void)getSystemMusicVolumeWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                               completion:(CaiGetSystemMusicVolumeCompletion _Nullable)completion;
@end

