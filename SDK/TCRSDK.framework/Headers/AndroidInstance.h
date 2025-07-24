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
 * @brief 每个设备响应基类
 * @discussion 表示单个设备操作的响应结果
 */
@interface CaiDeviceResponse : NSObject

/**
 * @brief 单个设备操作状态码
 * @discussion 0 表示成功，非0表示失败（
 * Code: 10001, Msg: "invalid param"，
 * Code: 10002, Msg: "invalid token"，
 * Code: 10003, Msg: "invalid operate"）
 */
@property (nonatomic, assign) NSInteger code;

/**
 * @brief 单个设备状态消息
 * @discussion 操作结果的描述信息
 */
@property (nonatomic, copy, nullable) NSString *msg;

@end

/**
 * @brief 批量任务响应基类
 * @discussion 表示批量操作的响应结果
 */
@interface CaiBatchTaskResponse<__covariant DeviceResponseType: CaiDeviceResponse *> : NSObject

/**
 * @brief 整体操作状态码
 * @discussion
 *   - 0: 整体操作成功（可能包含部分设备失败）
 *   - 非0: 整体操作失败
 */
@property (nonatomic, assign) NSInteger code;

/**
 * @brief 整体状态消息
 * @discussion 操作结果的描述信息
 */
@property (nonatomic, copy, nullable) NSString *message;

/**
 * @brief 各设备响应字典
 * @discussion
 *   - key: instanceId (NSString)
 *   - value: CaiDeviceResponse 子类对象
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, DeviceResponseType> *deviceResponses;

@end

#pragma mark - DescribeInstanceProperties内部数据模型

/**
 * @brief 设备信息模型
 * @discussion 包含设备的品牌和型号信息
 */
@interface CaiDeviceInfo : NSObject

/**
 * @brief 设备品牌
 * @discussion 例如 @"Samsung", @"Xiaomi" 等
 */
@property (nonatomic, copy, nullable) NSString *brand;

/**
 * @brief 设备型号
 * @discussion 例如 @"Galaxy S24", @"Redmi Note 10" 等
 */
@property (nonatomic, copy, nullable) NSString *model;

@end

/**
 * @brief GPS 位置信息模型
 * @discussion 表示设备的地理位置
 */
@interface CaiGPSInfo : NSObject

/**
 * @brief 经度值
 * @discussion 范围 -180.0 ~ 180.0
 */
@property (nonatomic, assign) double longitude;

/**
 * @brief 纬度值
 * @discussion 范围 -90.0 ~ 90.0
 */
@property (nonatomic, assign) double latitude;

@end

/**
 * @brief 语言信息模型
 * @discussion 表示设备的语言设置
 */
@interface CaiLanguageInfo : NSObject

/**
 * @brief 语言代码
 * @discussion 例如 @"zh", @"en" 等
 */
@property (nonatomic, copy, nullable) NSString *language;

/**
 * @brief 国家/地区代码
 * @discussion 例如 @"CN", @"US" 等
 */
@property (nonatomic, copy, nullable) NSString *country;

@end

/**
 * @brief 地区信息模型
 * @discussion 表示设备的地区设置
 */
@interface CaiLocaleInfo : NSObject

/**
 * @brief 时区设置
 * @discussion 例如 @"Asia/Shanghai", @"America/Los_Angeles"
 */
@property (nonatomic, copy, nullable) NSString *timezone;

@end

/**
 * @brief 代理信息模型
 * @discussion 表示设备的网络代理配置
 */
@interface CaiProxyInfo : NSObject

/**
 * @brief 是否启用代理
 * @discussion YES/NO 表示启用/禁用
 */
@property (nonatomic, assign) BOOL enabled;

/**
 * @brief 代理协议
 * @discussion 例如 @"http", @"socks5", @"https"
 */
@property (nonatomic, copy, nullable) NSString *protocol;

/**
 * @brief 代理服务器主机地址
 */
@property (nonatomic, copy, nullable) NSString *host;

/**
 * @brief 代理服务器端口
 */
@property (nonatomic, assign) NSInteger port;

/**
 * @brief 代理认证用户名
 */
@property (nonatomic, copy, nullable) NSString *user;

/**
 * @brief 代理认证密码
 */
@property (nonatomic, copy, nullable) NSString *password;

@end

/**
 * @brief SIM 卡信息模型
 * @discussion 表示设备的 SIM 卡状态和识别信息
 */
@interface CaiSIMInfo : NSObject

/**
 * @brief SIM 卡状态
 * @discussion 0=未激活, 1=已激活
 */
@property (nonatomic, assign) NSInteger state;

/**
 * @brief 手机号码
 */
@property (nonatomic, copy, nullable) NSString *phoneNumber;

/**
 * @brief 国际移动用户识别码
 */
@property (nonatomic, copy, nullable) NSString *IMSI;

/**
 * @brief 集成电路卡识别码
 */
@property (nonatomic, copy, nullable) NSString *ICCID;

@end

/**
 * @brief 额外属性模型
 * @discussion 表示设备自定义属性
 */
@interface CaiExtraProperty : NSObject

/**
 * @brief 属性键名
 */
@property (nonatomic, copy, nullable) NSString *key;

/**
 * @brief 属性值
 */
@property (nonatomic, copy, nullable) NSString *value;
@end

/**
 * @brief 属性查询响应项
 * @discussion 单台设备的属性查询结果
 */
@interface CaiInstancePropertiesResponseItem : CaiDeviceResponse

/**
 * @brief 请求ID
 * @discussion 用于追踪请求的唯一标识
 */
@property (nonatomic, copy, nullable) NSString *requestId;

/**
 * @brief 设备信息
 */
@property (nonatomic, strong, nullable) CaiDeviceInfo *deviceInfo;

/**
 * @brief GPS 信息
 */
@property (nonatomic, strong, nullable) CaiGPSInfo *GPSInfo;

/**
 * @brief 语言信息
 */
@property (nonatomic, strong, nullable) CaiLanguageInfo *languageInfo;

/**
 * @brief 地区信息
 */
@property (nonatomic, strong, nullable) CaiLocaleInfo *localeInfo;

/**
 * @brief 代理信息
 */
@property (nonatomic, strong, nullable) CaiProxyInfo *proxyInfo;

/**
 * @brief SIM 卡信息
 */
@property (nonatomic, strong, nullable) CaiSIMInfo *SIMInfo;
@end

#pragma mark - App数据模型

/**
 * @brief 应用信息模型
 * @discussion 表示设备的应用程序信息
 */
@interface CaiApp : NSObject

/**
 * @brief 首次安装时间
 * @discussion Unix 时间戳 (毫秒)
 */
@property (nonatomic, assign) long long firstInstallTimeMs;

/**
 * @brief 应用显示名称
 * @discussion 用户可见的应用名称
 */
@property (nonatomic, copy, nullable) NSString *label;

/**
 * @brief 最后更新时间
 * @discussion Unix 时间戳 (毫秒)
 */
@property (nonatomic, assign) long long lastUpdateTimeMs;

/**
 * @brief 应用包名
 * @discussion 唯一标识应用的包名
 */
@property (nonatomic, copy, nullable) NSString *packageName;

/**
 * @brief 应用版本名称
 * @discussion 例如 @"1.0.0", @"2.3.4"
 */
@property (nonatomic, copy, nullable) NSString *versionName;

@end

/**
 * @brief 用户应用查询响应项
 * @discussion 单台设备的第三方应用查询结果
 */
@interface CaiListUserAppsResponseItem : CaiDeviceResponse

///**
// * @brief 请求ID
// * @discussion 用于追踪请求的唯一标识
// */
//@property (nonatomic, copy) NSString *requestId;

/**
 * @brief 应用列表
 * @discussion 设备上安装的第三方应用程序列表
 */
@property (nonatomic, strong, nullable) NSArray<CaiApp *> *appList;

@end

/**
 * @brief 所有应用查询响应项
 * @discussion 单台设备的所有应用程序查询结果
 */
@interface CaiListAllAppsResponseItem : CaiDeviceResponse

/**
 * @brief 请求ID
 * @discussion 用于追踪请求的唯一标识
 */
@property (nonatomic, copy, nullable) NSString *requestId;

/**
 * @brief 所有应用列表
 * @discussion 包括系统应用和第三方应用
 */
@property (nonatomic, strong, nullable) NSArray<CaiApp *> *appList;

@end

#pragma mark - DescribeKeepFrontAppStatus数据模型
/**
 * @brief 前台保持响应项
 */
@interface CaiDescribeKeepFrontAppStatusResponseItem : CaiDeviceResponse

/**
 * @brief 应用包名
 */
@property (nonatomic, strong, nullable) NSString *packageName;

/**
 * @brief 应用前台保持
 */
@property (nonatomic, assign) BOOL enable;

/**
 * @brief 重启间隔时长
 */
@property (nonatomic, assign) int restartIntervalSeconds;

@end

#pragma mark - DescribeCameraMediaPlayStatus数据模型
/**
 * @brief 摄像头媒体状态响应项
 * @discussion 单台设备的摄像头媒体播放状态
 */
@interface CaiDescribeCameraMediaPlayStatusResponseItem : CaiDeviceResponse

/**
 * @brief 媒体文件路径
 */
@property (nonatomic, copy, nullable) NSString *filePath;

/**
 * @brief 循环次数
 * @discussion 负数表示无限循环
 */
@property (nonatomic, assign) NSInteger loops;

@end

#pragma mark - DescribeKeepAliveList数据模型
/**
 * @brief 保活列表响应项
 * @discussion 单台设备的后台保活应用列表
 */
@interface CaiDescribeKeepAliveListResponseItem : CaiDeviceResponse

/**
 * @brief 保活应用列表
 * @discussion 应用包名的数组
 */
@property (nonatomic, strong, nullable) NSArray<NSString *> *appList;

@end

#pragma mark - MediaSearch数据模型
/**
 * @brief 媒体文件信息模型
 * @discussion 表示媒体文件的基本信息
 */
@interface CaiMediaItem : NSObject

/**
 * @brief 文件名
 * @discussion 包含扩展名，例如 @"video.mp4"
 */
@property (nonatomic, copy, nullable) NSString *fileName;

/**
 * @brief 完整文件路径
 * @discussion 例如 @"/sdcard/Movies/video.mp4"
 */
@property (nonatomic, copy, nullable) NSString *filePath;

/**
 * @brief 文件大小
 * @discussion 以字节为单位的文件大小
 */
@property (nonatomic, assign) long long fileBytes;

/**
 * @brief 文件修改时间
 * @discussion Unix 时间戳 (毫秒)
 */
@property (nonatomic, assign) long long fileModifiedTime;

@end

/**
 * @brief 媒体搜索响应项
 * @discussion 单台设备的媒体搜索结果
 */
@interface CaiMediaSearchResponseItem : CaiDeviceResponse

/**
 * @brief 媒体文件列表
 */
@property (nonatomic, strong, nullable) NSArray<CaiMediaItem *> *mediaList;

@end

/**
 * @brief 批量媒体搜索响应
 * @discussion 多台设备的媒体搜索结果
 */
@interface CaiMediaSearchResponse : CaiBatchTaskResponse<CaiMediaSearchResponseItem *>
@end

#pragma mark - DescribeAppInstallBlackList数据模型
/**
 * @brief 应用黑名单响应项
 * @discussion 单台设备的应用安装黑名单
 */
@interface CaiDescribeAppInstallBlackListResponseItem : CaiDeviceResponse

/**
 * @brief 黑名单应用列表
 * @discussion 禁止安装的应用包名数组
 */
@property (nonatomic, strong, nullable) NSArray<NSString *> *appList;

@end

#pragma mark - GetNavVisibleStatus数据模型
/**
 * @brief 获取单台设备当前系统导航栏显示状态响应
 */
@interface CaiGetNavVisibleStatusResponseItem : CaiDeviceResponse

/**
 * @brief 导航栏是否显示
 */
@property (nonatomic, assign) BOOL visible;

@end

#pragma mark - getSystemMusicVolume数据模型
/**
 * @brief 获取单台设备当前系统媒体音量大小
 */
@interface CaiGetSystemMusicVolumeResponseItem : CaiDeviceResponse

/**
 * @brief 当前系统媒体音量大小（0-100）
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
 * @brief 批量属性查询响应
 * @discussion 多台设备的属性查询结果
 */
@interface CaiDescribeInstancePropertiesResponse : CaiBatchTaskResponse<CaiInstancePropertiesResponseItem *>
@end

/**
 * @brief 批量用户应用查询响应
 * @discussion 多台设备的第三方应用查询结果
 */
@interface CaiListUserAppsResponse :  CaiBatchTaskResponse<CaiListUserAppsResponseItem *>
@end

/**
 * @brief 批量摄像头媒体状态响应
 * @discussion 多台设备的摄像头媒体播放状态
 */
@interface CaiDescribeCameraMediaPlayStatusResponse : CaiBatchTaskResponse<CaiDescribeCameraMediaPlayStatusResponseItem *>
@end

/**
 * @brief 批量前台保持响应
 */
@interface CaiDescribeKeepFrontAppStatusResponse : CaiBatchTaskResponse<CaiDescribeKeepFrontAppStatusResponseItem *>
@end

/**
 * @brief 批量保活列表响应
 * @discussion 多台设备的后台保活应用列表
 */
@interface CaiDescribeKeepAliveListResponse : CaiBatchTaskResponse<CaiDescribeKeepAliveListResponseItem *>
@end

/**
 * @brief 批量所有应用查询响应
 * @discussion 多台设备的所有应用程序查询结果
 */
@interface CaiListAllAppsResponse : CaiBatchTaskResponse<CaiListAllAppsResponseItem *>
@end

/**
 * @brief 批量应用黑名单响应
 * @discussion 多台设备的应用安装黑名单
 */
@interface CaiDescribeAppInstallBlackListResponse : CaiBatchTaskResponse<CaiDescribeAppInstallBlackListResponseItem *>
@end

/**
 * @brief 获取当前系统导航栏显示状态响应
 * @discussion 多台设备的系统导航栏显示状态响应
 */
@interface CaiGetNavVisibleStatusResponse : CaiBatchTaskResponse<CaiGetNavVisibleStatusResponseItem *>
@end

/**
 * @brief 获取多台设备的当前系统媒体音量大小
 * @discussion 多台设备的当前系统媒体音量大小
 */
@interface CaiGetSystemMusicVolumeResponse : CaiBatchTaskResponse<CaiGetSystemMusicVolumeResponseItem *>
@end

/**
 * @brief 文件上传响应
 */
@interface CaiUploadResponse : NSObject
/**
 * @brief 响应码
 */
@property (nonatomic, assign) NSInteger code;
/**
 * @brief 响应消息
 */
@property (nonatomic, copy, nullable) NSString *msg;
/**
 * @brief 文件状态
 */
@property (nonatomic, strong, nullable) NSArray<NSDictionary *> *fileStatus;
@end

/**
 * @brief 媒体上传响应
 */
@interface CaiUploadMediaFilesResponse : NSObject
/**
 * @brief 响应码
 */
@property (nonatomic, assign) NSInteger code;
/**
 * @brief 响应消息
 */
@property (nonatomic, copy, nullable) NSString *msg;
@end


#pragma mark - 回调类型定义

/**
 * @brief 批量任务基础回调类型
 * @param response 批量任务响应模型
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiBatchTaskCompletion)(CaiBatchTaskResponse *_Nonnull response, NSError * _Nullable error);

/**
 * @brief 上传文件回调类型
 * @param response 上传文件响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiUploadFilesCompletion)(CaiUploadResponse *_Nonnull response, NSError *_Nullable error);

/**
 * @brief 上传媒体文件回调类型
 * @param response 上传文件响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiUploadMediaFilesCompletion)(CaiUploadMediaFilesResponse *_Nonnull response, NSError *_Nullable error);

/**
 * @brief 属性查询回调类型
 * @param response 属性查询响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiDescribeInstancePropertiesCompletion)(CaiDescribeInstancePropertiesResponse *_Nonnull response, NSError *_Nullable error);

/**
 * @brief 用户应用查询回调类型
 * @param response 用户应用查询响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiListUserAppsCompletion)(CaiListUserAppsResponse *_Nonnull response, NSError *_Nullable error);

/**
 * @brief 摄像头媒体状态回调类型
 * @param response 摄像头媒体状态响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiDescribeCameraMediaPlayStatusCompletion)(CaiDescribeCameraMediaPlayStatusResponse *_Nonnull response, NSError *_Nullable error);

/**
 * @brief 应用前台状态回调类型
 * @param response 应用前台状态响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiDescribeKeepFrontAppStatusCompletion)(CaiDescribeKeepFrontAppStatusResponse *_Nonnull response, NSError *_Nullable error);

/**
 * @brief 保活列表查询回调类型
 * @param response 保活列表响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiDescribeKeepAliveListCompletion)(CaiDescribeKeepAliveListResponse *_Nonnull response, NSError *_Nullable error);

/**
 * @brief 媒体搜索回调类型
 * @param response 媒体搜索响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiMediaSearchCompletion)(CaiMediaSearchResponse *_Nonnull response, NSError *_Nullable error);

/**
 * @brief 所有应用查询回调类型
 * @param response 所有应用查询响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiListAllAppsCompletion)(CaiListAllAppsResponse *_Nonnull response, NSError *_Nullable error);

/**
 * @brief 应用黑名单查询回调类型
 * @param response 应用黑名单响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiDescribeAppInstallBlackListCompletion)(CaiDescribeAppInstallBlackListResponse *_Nonnull response, NSError *_Nullable error);

/**
 * @brief 获取当前系统导航栏显示状态回调类型
 * @param response 获取当前系统导航栏显示状态响应
 * @param error 错误对象（系统级错误）
 */
typedef void (^CaiGetNavVisibleStatusCompletion)(CaiGetNavVisibleStatusResponse *_Nonnull response, NSError *_Nullable error);

/**
 * @brief 获取当前系统媒体音量大小回调类型
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
 * @brief 批量设置设备GPS位置信息
 * @discussion 为多台设备设置模拟GPS位置信息，支持同时更新多个设备的定位数据
 *
 * @par 参数结构说明:
 * @param params 位置信息参数字典
 *               - key: instanceId (NSString)
 *               - value: 位置参数 (NSDictionary)，结构为:
 *                 @{
 *                    @"Longitude": @(经度值),  // 经度 (double)
 *                    @"Latitude": @(纬度值)    // 纬度 (double)
 *                 }
 * @param completion 批量操作回调
 *
 * @par 使用示例:
 * @code
 * NSDictionary *locations = @{
 *     @"cai-device-001": @{@"Longitude": @113.32412, @"Latitude": @23.124124},
 *     @"cai-device-002": @{@"Longitude": @114.32412, @"Latitude": @24.124124}
 * };
 *
 * [androidInstance setLocationWithParams:locations completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 位置信息设置成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 位置信息设置失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)setLocationWithParams:(NSDictionary<NSString *, NSDictionary *> *_Nonnull)params
                   completion:(nullable CaiBatchTaskCompletion)completion;

/**
 * @brief 批量设置设备分辨率
 * @discussion 动态调整设备屏幕分辨率，支持同时修改多个设备的显示设置
 *
 * @par 参数结构说明:
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
 * @code
 * NSDictionary *resolutions = @{
 *     @"cai-device-001": @{@"Width": @720, @"Height": @1280, @"DPI": @240},
 *     @"cai-device-002": @{@"Width": @1080, @"Height": @1920}
 * };
 *
 * [androidInstance setResolutionWithParams:resolutions completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 分辨率设置成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 分辨率设置失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)setResolutionWithParams:(NSDictionary<NSString *, NSDictionary *> *_Nonnull)params
                     completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量粘贴文本到设备
 * @discussion 模拟在多个设备输入框执行粘贴操作
 *
 * @par 参数结构说明:
 * @param params 粘贴文本参数字典
 *               - key: instanceId (NSString)
 *               - value: 粘贴参数 (NSDictionary)，结构为:
 *                 @{
 *                    @"Text": @"粘贴文本"  // 要粘贴的文本内容
 *                 }
 * @param completion 批量操作回调
 *
 * @par 使用示例:
 * @code
 * NSDictionary *texts = @{
 *     @"cai-device-001": @{@"Text": @"Hello World"},
 *     @"cai-device-002": @{@"Text": @"粘贴测试文本"}
 * };
 *
 * [androidInstance pasteWithParams:texts completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 粘贴成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 粘贴失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)pasteWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
             completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量发送文本到设备剪切板
 * @discussion 将文本复制到多个设备的系统剪切板
 *
 * @par 参数结构说明:
 * @param params 剪切板文本参数字典
 *               - key: instanceId (NSString)
 *               - value: 文本参数 (NSDictionary)，结构为:
 *                 @{
 *                    @"Text": @"剪切板内容"  // 要复制到剪切板的文本
 *                 }
 * @param completion 批量操作回调
 *
 * @par 使用示例:
 * @code
 * NSDictionary *clipboardTexts = @{
 *     @"cai-device-001": @{@"Text": @"剪切板测试内容"},
 *     @"cai-device-002": @{@"Text": @"这是第二台设备的文本"}
 * };
 *
 * [androidInstance sendClipboardWithParams:clipboardTexts completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 剪切板设置成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 剪切板设置失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)sendClipboardWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                     completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量执行摇一摇操作
 * @discussion 在多个设备上模拟摇一摇手势（加速度传感器事件）
 *
 * @par 参数结构说明:
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{} (保留未来扩展)
 * @param completion 批量操作回调
 *
 * @par 使用示例:
 * @code
 * NSDictionary *devices = @{
 *     @"cai-device-001": @{},
 *     @"cai-device-002": @{}
 * };
 *
 * [androidInstance shakeWithParams:devices completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 摇一摇成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 摇一摇失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)shakeWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
             completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量执行吹一吹操作
 * @discussion 在多个设备上模拟吹一吹
 *
 * @par 参数结构说明:
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{} (保留未来扩展)
 * @param completion 批量操作回调
 *
 * @par 使用示例:
 * @code
 * NSDictionary *devices = @{
 *     @"cai-device-001": @{},
 *     @"cai-device-002": @{}
 * };
 *
 * [androidInstance blowWithParams:devices completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 吹一吹成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 吹一吹失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)blowWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
             completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量设置设备传感器信息
 * @discussion 为多台设备设置加速度计或陀螺仪传感器数据，用于模拟设备的运动状态。
 *
 * @par 参数结构说明:
 * @param params 操作参数字典
 *               - key: instanceId (NSString)
 *               - value: 传感器参数 (NSDictionary)，结构为:
 *                 @{
 *                    @"Type": sensorType,       // 传感器类型字符串 (必需)
 *                    @"Values": valuesArray      // 传感器数值数组 (必需)
 *                 }
 * @param completion 批量操作回调
 *
 * @par 传感器参数详解:
 * - <b>Type (NSString)</b>：
 *   支持的传感器类型：
 *     - @"accelerometer"：加速度计 (单位: m/s²)
 *     - @"gyroscope"：陀螺仪 (单位: rad/s)
 *
 * - <b>Values (NSArray<NSNumber *>)</b>：
 *   3维数值数组，依次表示 x/y/z 轴的值，格式为:
 *     @[ @(xValue), @(yValue), @(zValue) ]
 *
 * @par 使用示例:
 * @code
 * // 示例1: 为两个设备设置加速度计数据
 * NSDictionary *sensorData = @{
 *     @"cai-xxx1": @{
 *         @"Type": @"accelerometer",
 *         @"Values": @[ @1.5, @0.2, @9.8 ] // x=1.5, y=0.2, z=9.8 (重力加速度)
 *     },
 *     @"cai-xxx2": @{
 *         @"Type": @"gyroscope",
 *         @"Values": @[ @0.5, @0.0, @1.2 ] // x=0.5, y=0.0, z=1.2 rad/s
 *     }
 * };
 *
 * [androidInstance setSensorWithParams:sensorData completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 传感器设置成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 传感器设置失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)setSensorWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                 completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量发送App binder消息
 * @discussion 向多台设备上的指定应用发送自定义消息
 *
 * @par 参数结构说明:
 * @param params 消息参数字典
 *               - key: instanceId (NSString)
 *               - value: 消息参数 (NSDictionary)，结构为:
 *                 @{
 *                    @"PackageName": @"应用包名",  // 接收消息的应用包名
 *                    @"Msg": @"消息内容"         // 要发送的自定义消息
 *                 }
 * @param completion 批量操作回调
 *
 * @par 使用示例:
 * @code
 * NSDictionary *messages = @{
 *     @"cai-device-001": @{@"PackageName": @"com.example.app", @"Msg": @"命令更新"},
 *     @"cai-device-002": @{@"PackageName": @"com.demo.app", @"Msg": @"数据同步"}
 * };
 *
 * [androidInstance sendTransMessageWithParams:messages completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 消息发送成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 消息发送失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)sendTransMessageWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                       completion:(CaiBatchTaskCompletion _Nullable)completion;

#pragma mark 云手机操作接口 > 批量设备操作（异步接口） > 设备属性与应用管理

/**
 * @brief 批量查询实例属性
 * @discussion 查询多台设备的基础属性和配置信息，如设备品牌、型号、代理设置等
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 批量操作回调
 *
 *
 * @par 响应数据结构:
 * @code
 * {
 *   "DeviceInfo": { "Brand": "Samsung", "Model": "Galaxy S24" },
 *   "ProxyInfo": { "Enabled": true, "Protocol": "socks5", ... },
 *   "GPSInfo": { "Longitude": 121.4737, "Latitude": 31.2304 },
 *   // 其他属性...
 * }
 * @endcode
 *
 * @par 使用示例:
 * @code
 * NSDictionary *devices = @{@"cai-device-001": @{}, @"cai-device-002": @{}};
 * [androidInstance describeInstancePropertiesWithParams:devices completion:^(CaiDescribeInstancePropertiesResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         CaiInstancePropertiesResponseItem *item = (CaiInstancePropertiesResponseItem *)deviceResp;
 *
 *         if (item.code == 0) {
 *             NSLog(@"设备 %@ 属性查询成功", deviceId);
 *             NSLog(@"  品牌: %@", item.deviceInfo.brand);
 *             NSLog(@"  型号: %@", item.deviceInfo.model);
 *             NSLog(@"  位置: 经度 %f, 纬度 %f", item.GPSInfo.longitude, item.GPSInfo.latitude);
 *         } else {
 *             NSLog(@"设备 %@ 查询失败: [%ld] %@", deviceId, (long)item.code, item.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)describeInstancePropertiesWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                                 completion:(nullable CaiDescribeInstancePropertiesCompletion)completion;

/**
 * @brief 查询已安装第三方应用
 * @discussion 获取设备上安装的所有第三方应用程序列表
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调
 *
 * @par 响应数据结构:
 * @code
 * {
 *   "Apps": [
 *     { "PackageName": "com.wechat", "AppName": "微信", "Version": "8.0.1" },
 *     { "PackageName": "com.alipay", "AppName": "支付宝", "Version": "10.2.0" }
 *   ]
 * }
 * @endcode
 *
 * @par 使用示例:
 * @code
 * NSDictionary *devices = @{@"cai-device-001": @{}, @"cai-device-002": @{}};
 * [androidInstance listUserAppsWithParams:devices completion:^(CaiListUserAppsResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         CaiListUserAppsResponseItem *item = (CaiListUserAppsResponseItem *)deviceResp;
 *
 *         if (item.code == 0) {
 *             NSLog(@"设备 %@ 安装的第三方应用:", deviceId);
 *             for (CaiApp *app in item.appList) {
 *                 NSLog(@"  %@ (%@) 版本: %@", app.label, app.packageName, app.versionName);
 *             }
 *         } else {
 *             NSLog(@"设备 %@ 应用查询失败: [%ld] %@", deviceId, (long)item.code, item.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)listUserAppsWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                   completion:(CaiListUserAppsCompletion _Nullable)completion;


- (void)modifyInstancePropertiesWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                               completion:(CaiBatchTaskCompletion _Nullable)completion;

#pragma mark 云手机操作接口 > 批量设备操作（异步接口） > 应用管理操作

/**
 * @brief 批量卸载应用
 * @discussion 从多台设备卸载指定的应用程序
 *
 * @param params 卸载参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"PackageName": @"应用包名"}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *uninstallParams = @{
 *   @"cai-device-001": @{@"PackageName": @"com.unwanted.app"},
 *   @"cai-device-002": @{@"PackageName": @"com.unwanted.app"}
 * };
 * [androidInstance unInstallByPackageNameWithParams:uninstallParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 卸载应用成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 卸载应用失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)unInstallByPackageNameWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                             completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量启动应用
 * @discussion 在多个设备上启动指定的应用程序和Activity
 *
 * @param params 启动参数字典
 *               - key: instanceId (NSString)
 *               - value: @{
 *                   @"PackageName": @"应用包名",
 *                   @"ActivityName": @"Activity"
 *                 }
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *launchParams = @{
 *   @"cai-device-001": @{
 *     @"PackageName": @"com.launch.app",
 *     @"ActivityName": @"MainActivity"
 *   }
 * };
 * [androidInstance startAppWithParams:launchParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 启动应用成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 启动应用失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)startAppWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量停止应用
 * @discussion 停止在多个设备上运行的指定应用程序
 *
 * @param params 停止参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"PackageName": @"应用包名"}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *stopParams = @{
 *   @"cai-device-001": @{@"PackageName": @"com.running.app"}
 * };
 * [androidInstance stopAppWithParams:stopParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 停止应用成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 停止应用失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)stopAppWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
               completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量清除应用数据
 * @discussion 清除指定应用程序在设备上的应用数据
 *
 * @param params 清除参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"PackageName": @"应用包名"}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *clearParams = @{
 *   @"cai-device-001": @{@"PackageName": @"com.cache.heavy"}
 * };
 * [androidInstance clearAppDataWithParams:clearParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 清除应用数据成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 清除应用数据失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)clearAppDataWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                    completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量启用应用
 * @discussion 启用设备上被禁用的应用程序
 *
 * @param params 启用参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"PackageName": @"应用包名"}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *enableParams = @{
 *   @"cai-device-001": @{@"PackageName": @"com.disabled.app"}
 * };
 * [androidInstance enableAppWithParams:enableParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 启动应用成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 启动应用失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)enableAppWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                 completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量禁用应用
 * @discussion 禁用设备上的指定应用程序(相当于"冻结"应用)
 *
 * @param params 禁用参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"PackageName": @"应用包名"}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *disableParams = @{
 *   @"cai-device-001": @{@"PackageName": @"com.disabled.app"}
 * };
 * [androidInstance disableAppWithParams:disableParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 禁用应用成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 禁用应用失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)disableAppWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                  completion:(CaiBatchTaskCompletion _Nullable)completion;

#pragma mark 云手机操作接口 > 批量设备操作（异步接口） > 摄像头控制

/**
 * @brief 批量在摄像头播放媒体文件
 * @discussion 在设备摄像头模拟视频流输入
 *
 * @param params 播放参数字典
 *               - key: instanceId (NSString)
 *               - value: @{
 *                   @"FilePath": @"视频文件路径",
 *                   @"Loops": @(循环次数) // 负数表示无限循环
 *                 }
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *playParams = @{
 *   @"cai-device-001": @{
 *     @"FilePath": @"/sdcard/video.mp4",
 *     @"Loops": @3
 *   }
 * };
 * [androidInstance startCameraMediaPlayWithParams:playParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 播放媒体文件成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 播放媒体文件失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)startCameraMediaPlayWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                           completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量停止摄像头媒体播放
 * @discussion 停止在设备摄像头上的媒体文件播放
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *stopParams = @{
 *   @"cai-device-001": @{}
 * };
 * [androidInstance stopCameraMediaPlayWithParams:stopParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 停止摄像头媒体播放成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 停止摄像头媒体播放失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)stopCameraMediaPlayWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                          completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量查询摄像头播放状态
 * @discussion 获取当前在设备摄像头上的媒体播放状态
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调
 *
 * @par 响应数据结构:
 * @code
 * NSDictionary *params = @{
 *   @"cai-device-001": @{}
 * };
 * [androidInstance describeCameraMediaPlayStatusWithParams:params completion:^(CaiDescribeCameraMediaPlayStatusResponse *response, NSError *error) {
 *     // 处理系统错误
 *     if (error) {
 *         NSLog(@"摄像头状态查询失败，系统错误: %@", error.localizedDescription);
 *         return;
 *     }
 *
 *     // 检查整体操作结果
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败 [%ld]: %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     // 处理每个设备的响应
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         // 转换为具体类型
 *         CaiDescribeCameraMediaPlayStatusResponseItem *item = (CaiDescribeCameraMediaPlayStatusResponseItem *)deviceResp;
 *
 *         if (item.code == 0) {
 *             NSLog(@"设备 [%@] 摄像头状态:", deviceId);
 *
 *             if (item.filePath) {
 *                 if (item.loops < 0) {
 *                     NSLog(@"  正在循环播放: %@", item.filePath.lastPathComponent);
 *                 } else if (item.loops == 0) {
 *                     NSLog(@"  播放已停止");
 *                 } else {
 *                     NSLog(@"  正在播放 [%ld轮]: %@", (long)item.loops, item.filePath.lastPathComponent);
 *                 }
 *             } else {
 *                 NSLog(@"  当前无媒体播放");
 *             }
 *         } else {
 *             // 设备级错误处理
 *             NSLog(@"设备 [%@] 查询失败 [%ld]: %@", deviceId, (long)item.code, item.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)describeCameraMediaPlayStatusWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                                    completion:(CaiDescribeCameraMediaPlayStatusCompletion _Nullable)completion;

/**
 * @brief 批量在摄像头显示图片
 * @discussion 在设备摄像头模拟输入静态图片
 *
 * @param params 图片参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"FilePath": @"图片文件路径"}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *imageParams = @{
 *   @"cai-device-001": @{@"FilePath": @"/sdcard/image.jpg"}
 * };
 * [androidInstance displayCameraImageWithParams:imageParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 显示图片成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 显示图片失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)displayCameraImageWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                          completion:(CaiBatchTaskCompletion _Nullable)completion;

#pragma mark 云手机操作接口 > 批量设备操作（异步接口） > 应用保活管理

/**
 * @brief 修改前台应用保活状态
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
 *
 * @par 使用示例:
 * @code
 * NSDictionary *settings = @{
 *   @"cai-device-001": @{
 *     @"PackageName": @"com.example.app",
 *     @"Enable": @YES,
 *     @"RestartInterValSeconds": @5
 *   }
 * };
 * [androidInstance modifyKeepFrontAppStatusWithParams:settings completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 修改后台保活状态成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 修改后台保活状态失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)modifyKeepFrontAppStatusWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                               completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 查询前台应用保活状态
 * @discussion 获取设备上已配置的前台应用保活设置
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调
 *
 * @par 响应数据结构:
 * @code
 * NSDictionary *settings = @{
 *   @"cai-device-001": @{
 *     @"PackageName": @"com.example.app",
 *     @"Enable": @YES,
 *     @"RestartInterValSeconds": @5
 *   }
 * };
 * [androidInstance modifyKeepFrontAppStatusWithParams:settings completion:^(CaiDescribeKeepFrontAppStatusResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 查询前台保活状态成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 查询前台保活状态失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)describeKeepFrontAppStatusWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                                 completion:(CaiDescribeKeepFrontAppStatusCompletion _Nullable)completion;


#pragma mark 云手机操作接口 > 批量设备操作（异步接口） > 后台保活管理

/**
 * @brief 批量添加后台保活应用
 * @discussion 将应用添加到设备后台保活列表，减少被系统杀死的概率
 *
 * @param params 保活参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"AppList": @[@"应用包名1", @"应用包名2"]}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *addParams = @{
 *   @"cai-device-001": @{@"AppList": @[@"com.wechat", @"com.alipay"]}
 * };
 * [androidInstance addKeepAliveListWithParams:addParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 添加后台保活应用成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 添加后台保活应用失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)addKeepAliveListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                       completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量移除后台保活应用
 * @discussion 从设备后台保活列表中移除指定应用
 *
 * @param params 移除参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"AppList": @[@"应用包名1", @"应用包名2"]}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @code
 * NSDictionary *removeParams = @{
 *   @"cai-device-001": @{@"AppList": @[@"com.wechat", @"com.alipay"]}
 * };
 * [androidInstance removeKeepAliveListWithParams:removeParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 移除后台保活应用成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 移除后台保活应用失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)removeKeepAliveListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                          completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量设置后台保活列表
 * @discussion 完全覆盖设备后台保活列表(替换现有列表)
 *
 * @param params 保活参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"AppList": @[@"应用包名1", @"应用包名2"]}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *setParams = @{
 *   @"cai-device-001": @{@"AppList": @[@"com.wechat", @"com.alipay"]}
 * };
 * [androidInstance setKeepAliveListWithParams:setParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 设置后台保活列表成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 设置后台保活列表失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)setKeepAliveListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                       completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量查询后台保活列表
 * @discussion 获取设备当前的后台保活应用列表
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调
 *
 * @par 响应数据结构:
 * @code
 * NSDictionary *params = @{
 *   @"cai-device-001": @{}
 * };
 * [androidInstance describeKeepAliveListWithParams:params completion:^(CaiDescribeKeepAliveListResponse *response, NSError *error) {
 *     // 处理系统级错误（如网络错误）
 *     if (error) {
 *         NSLog(@"查询失败，系统错误: %@", error.localizedDescription);
 *         return;
 *     }
 *
 *     // 检查整体操作状态码
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     // 遍历每个设备的响应
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         // 注意：这里需要将deviceResp转换为具体的子类CaiDescribeKeepAliveListResponseItem
 *         CaiDescribeKeepAliveListResponseItem *item = (CaiDescribeKeepAliveListResponseItem *)deviceResp;
 *
 *         // 检查设备级操作状态码
 *         if (item.code == 0) {
 *             // 查询成功，打印保活应用列表
 *             NSLog(@"设备 %@ 的后台保活应用列表:", deviceId);
 *             for (NSString *packageName in item.appList) {
 *                 NSLog(@"  - %@", packageName);
 *             }
 *         } else {
 *             // 设备级操作失败
 *             NSLog(@"设备 %@ 查询失败: [%ld] %@", deviceId, (long)item.code, item.msg);
 *         }
 *     }];
 *
 *     // 额外：统计有保活应用的设备
 *     NSArray *devicesWithKeepAlive = [response.deviceResponses.allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *deviceId, NSDictionary *bindings) {
 *         CaiDescribeKeepAliveListResponseItem *item = (CaiDescribeKeepAliveListResponseItem *)response.deviceResponses[deviceId];
 *         return (item.code == 0 && item.appList.count > 0);
 *     }]];
 *     NSLog(@"有后台保活应用的设备: %@", [devicesWithKeepAlive componentsJoinedByString:@", "]);
 * }];
 * @endcode
 */
- (void)describeKeepAliveListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                            completion:(CaiDescribeKeepAliveListCompletion _Nullable)completion;

/**
 * @brief 批量清空后台保活列表
 * @discussion 清空设备上所有后台保活应用
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *clearParams = @{@"cai-device-001": @{}};
 * [androidInstance clearKeepAliveListWithParams:clearParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 清空后台保活列表成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 清空后台保活列表失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)clearKeepAliveListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                          completion:(CaiBatchTaskCompletion _Nullable)completion;

#pragma mark 云手机操作接口 > 批量设备操作（异步接口） > 设备控制

/**
 * @brief 批量设置设备静音
 * @discussion 将多台设备的媒体音量设为静音
 *
 * @param params 静音参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"Mute": @(YES/NO)} // YES:静音, NO:取消静音
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *muteParams = @{
 *   @"cai-device-001": @{@"Mute": @YES},
 *   @"cai-device-002": @{@"Mute": @YES}
 * };
 * [androidInstance muteWithParams:muteParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 设置设备静音成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 设置设备静音失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)muteWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
            completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量搜索媒体库文件
 * @discussion 在多台设备上搜索媒体库文件
 *
 * @param params 搜索参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"Keyword": @"搜索关键词"}
 * @param completion 完成回调
 *
 * @par 使用示例:
 * @code
 * NSDictionary *params = @{
 *   @"cai-device-001": @{},
 *   @"cai-device-002": @{}
 * };
 * [androidInstance mediaSearchWithParams:params completion:^(CaiMediaSearchResponse *response, NSError *error) {
 *     // 处理系统级错误（如网络错误）
 *     if (error) {
 *         NSLog(@"媒体搜索失败，系统错误: %@", error.localizedDescription);
 *         return;
 *     }
 *
 *     // 检查整体操作状态码
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     // 遍历每个设备的响应
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         // 转换为具体类型
 *         CaiMediaSearchResponseItem *item = (CaiMediaSearchResponseItem *)deviceResp;
 *
 *         // 检查设备级操作状态码
 *         if (item.code == 0) {
 *             // 搜索成功，打印搜索结果
 *             NSLog(@"设备 %@ 的媒体搜索结果 (%ld个文件):", deviceId, (long)item.mediaList.count);
 *
 *             if (item.mediaList.count > 0) {
 *                 for (CaiMediaItem *media in item.mediaList) {
 *                     NSLog(@"  - %@", media.fileName);
 *                     NSLog(@"    路径: %@", media.filePath);
 *                     NSLog(@"    大小: %.2f MB", (double)media.fileBytes / (1024 * 1024));
 *
 *                     // 格式化日期
 *                     NSDate *date = [NSDate dateWithTimeIntervalSince1970:media.fileModifiedTime / 1000];
 *                     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
 *                     formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
 *                     NSLog(@"    修改时间: %@", [formatter stringFromDate:date]);
 *                 }
 *             } else {
 *                 NSLog(@"  未找到匹配的媒体文件");
 *             }
 *         } else {
 *             // 设备级操作失败
 *             NSLog(@"设备 %@ 搜索失败: [%ld] %@", deviceId, (long)item.code, item.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)mediaSearchWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                   completion:(CaiMediaSearchCompletion _Nullable)completion;

/**
 * @brief 批量重启设备
 * @discussion 重启多台设备
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *rebootParams = @{@"cai-device-001": @{}};
 * [androidInstance rebootWithParams:rebootParams completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 重启设备成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 重启设备失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)rebootWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
              completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量查询所有应用列表
 * @discussion 获取设备上安装的所有应用列表
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调
 *
 * @par 使用示例:
 * @code
 * NSDictionary *params = @{@"cai-device-001": @{}};
 * [androidInstance listAllAppsWithParams:params completion:^(CaiListAllAppsResponse *response, NSError *error) {
 *     // 处理系统级错误（如网络错误）
 *     if (error) {
 *         NSLog(@"查询失败，系统错误: %@", error.localizedDescription);
 *         return;
 *     }
 *
 *     // 检查整体操作状态码
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     // 遍历每个设备的响应
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         // 转换为具体类型
 *         CaiListAllAppsResponseItem *item = (CaiListAllAppsResponseItem *)deviceResp;
 *
 *         // 检查设备级操作状态码
 *         if (item.code == 0) {
 *             // 查询成功，打印应用列表
 *             NSLog(@"设备 %@ 安装的所有应用 (%ld个):", deviceId, (long)item.appList.count);
 *
 *             // 分类统计
 *             NSInteger systemApps = 0;
 *             NSInteger userApps = 0;
 *
 *             for (CaiApp *app in item.appList) {
 *                 // 判断是否为系统应用（根据包名或安装位置）
 *                 BOOL isSystemApp = [app.packageName hasPrefix:@"com.android"] ||
 *                                    [app.packageName hasPrefix:@"com.google"];
 *
 *                 if (isSystemApp) {
 *                     systemApps++;
 *                 } else {
 *                     userApps++;
 *                 }
 *
 *                 // 打印应用详情
 *                 NSLog(@"  - %@ (%@)", app.label, app.packageName);
 *                 NSLog(@"    版本: %@", app.versionName);
 *                 NSLog(@"    安装时间: %@", [self formattedDateFromTimestamp:app.firstInstallTimeMs]);
 *
 *                 // 标记系统应用
 *                 if (isSystemApp) {
 *                     NSLog(@"    [系统应用]");
 *                 }
 *             }
 *
 *             NSLog(@"  系统应用: %ld个, 用户应用: %ld个", (long)systemApps, (long)userApps);
 *         } else {
 *             // 设备级操作失败
 *             NSLog(@"设备 %@ 查询失败: [%ld] %@", deviceId, (long)item.code, item.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)listAllAppsWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                   completion:(CaiListAllAppsCompletion _Nullable)completion;

/**
 * @brief 批量关闭应用到后台
 * @discussion 将前台应用切换到后台运行
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *params = @{@"cai-device-001": @{}};
 * [androidInstance moveAppBackgroundWithParams:params completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 关闭应用到后台成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 关闭应用到后台失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)moveAppBackgroundWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                         completion:(CaiBatchTaskCompletion _Nullable)completion;

#pragma mark 云手机操作接口 > 批量设备操作（异步接口） > 应用黑名单管理

/**
 * @brief 批量新增应用安装黑名单
 * @discussion 批量新增应用安装黑名单，新增时如果应用已安装，会进行卸载。
 *
 * @param params 黑名单参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"AppList": @[@"应用包名1", @"应用包名2"]}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *addBlacklist = @{
 *   @"cai-device-001": @{@"AppList": @[@"com.wechat", @"com.alipay"]}
 * };
 * [androidInstance addAppInstallBlackListWithParams:addBlacklist completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 新增应用安装黑名单成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 新增应用安装黑名单失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 *
 * @note 如果黑名单应用已安装，会被自动卸载
 */
- (void)addAppInstallBlackListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                             completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量移除应用安装黑名单
 * @discussion 从黑名单中移除应用，允许安装
 *
 * @param params 黑名单参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"AppList": @[@"应用包名1", @"应用包名2"]}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *removeBlacklist = @{
 *   @"cai-device-001": @{@"AppList": @[@"com.wechat", @"com.alipay"]}
 * };
 * [androidInstance removeAppInstallBlackListWithParams:removeBlacklist completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 移除应用安装黑名单成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 移除应用安装黑名单失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)removeAppInstallBlackListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                                completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量覆盖应用安装黑名单
 * @discussion 完全替换设备上的应用安装黑名单
 *
 * @param params 黑名单参数字典
 *               - key: instanceId (NSString)
 *               - value: @{@"AppList": @[@"应用包名1", @"应用包名2"]}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *setBlacklist = @{
 *   @"cai-device-001": @{@"AppList": @[@"com.wechat", @"com.alipay"]}
 * };
 * [androidInstance setAppInstallBlackListWithParams:setBlacklist completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 覆盖应用安装黑名单成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 覆盖应用安装黑名单失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)setAppInstallBlackListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                             completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量查询应用安装黑名单
 * @discussion 获取设备当前的应用安装黑名单
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调
 *
 * @par 使用示例:
 * @code
 * NSDictionary *getBlacklist = @{
 *   @"cai-device-001": @{},
 *   @"cai-device-002": @{},
 * };
 * [androidInstance describeAppInstallBlackListWithParams:getBlacklist completion:^(CaiDescribeAppInstallBlackListResponse *response, NSError *error) {
 *     // 处理系统级错误（如网络错误）
 *     if (error) {
 *         NSLog(@"查询失败，系统错误: %@", error.localizedDescription);
 *         return;
 *     }
 *
 *     // 检查整体操作状态码
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     // 遍历每个设备的响应
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         // 转换为具体类型
 *         CaiDescribeAppInstallBlackListResponseItem *item = (CaiDescribeAppInstallBlackListResponseItem *)deviceResp;
 *
 *         // 检查设备级操作状态码
 *         if (item.code == 0) {
 *             // 查询成功，打印黑名单列表
 *             NSLog(@"设备 %@ 的应用安装黑名单 (%ld个):", deviceId, (long)item.appList.count);
 *
 *             if (item.appList.count > 0) {
 *                 for (NSString *packageName in item.appList) {
 *                     NSLog(@"  - %@", packageName);
 *                 }
 *             } else {
 *                 NSLog(@"  黑名单为空");
 *             }
 *         } else {
 *             // 设备级操作失败
 *             NSLog(@"设备 %@ 查询失败: [%ld] %@", deviceId, (long)item.code, item.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)describeAppInstallBlackListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                                  completion:(CaiDescribeAppInstallBlackListCompletion _Nullable)completion;

/**
 * @brief 批量清空应用安装黑名单
 * @discussion 清空设备上的应用安装黑名单
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString)
 *               - value: 空字典 @{}
 * @param completion 完成回调 (CaiBatchTaskCompletion)
 *
 * @par 使用示例:
 * @code
 * NSDictionary *clearBlacklist = @{
 *   @"cai-device-001": @{},
 *   @"cai-device-002": @{},
 * };
 * [androidInstance clearAppInstallBlackListWithParams:clearBlacklist completion:^(CaiBatchTaskResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"系统错误: %@", error);
 *         return;
 *     }
 *
 *     if (response.code != 0) {
 *         NSLog(@"整体操作失败: [%ld] %@", (long)response.code, response.message);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiDeviceResponse *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 清空应用安装黑名单成功", deviceId);
 *         } else {
 *             NSLog(@"设备 %@ 清空应用安装黑名单失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)clearAppInstallBlackListWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                               completion:(CaiBatchTaskCompletion _Nullable)completion;

/**
 * @brief 批量获取导航栏可见状态
 * @discussion 查询设备导航栏（状态栏）的当前可见状态。导航栏通常包含时间、电池状态和通知图标等系统信息。
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString) 设备实例ID
 *               - value: 空字典 @{} 表示不需要额外参数
 * @param completion 完成回调，返回导航栏状态结果
 *                  - response: CaiGetNavVisibleStatusResponse 对象，包含导航栏状态信息
 *                  - error: 网络或系统错误对象
 *
 * @par 使用示例:
 * @code
 * NSDictionary *devices = @{@"device-001": @{}};
 * [androidInstance getNavVisibleStatusWithParams:devices completion:^(CaiGetNavVisibleStatusResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"查询失败: %@", error.localizedDescription);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiGetNavVisibleStatusResponseItem *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 导航栏可见: %d", deviceResp.visible);
 *         } else {
 *             NSLog(@"设备 %@ 获取导航栏可见状态失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)getNavVisibleStatusWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                               completion:(CaiGetNavVisibleStatusCompletion _Nullable)completion;

/**
 * @brief 获取系统媒体音量
 * @discussion 查询设备当前的媒体音量设置。媒体音量控制音乐、视频、游戏和其他媒体内容的播放音量。
 *
 * @param params 设备参数字典
 *               - key: instanceId (NSString) 设备实例ID
 *               - value: 空字典 @{} 表示不需要额外参数
 * @param completion 完成回调，返回音量信息
 *                  - response: CaiGetSystemMusicVolumeResponse 对象，包含音量信息
 *                  - error: 网络或系统错误对象
 *
 * @par 使用示例:
 * @code
 * NSDictionary *devices = @{@"device-001": @{}};
 * [androidInstance getSystemMusicVolumeWithParams:devices completion:^(CaiGetSystemMusicVolumeResponse *response, NSError *error) {
 *     if (error) {
 *         NSLog(@"查询失败: %@", error.localizedDescription);
 *         return;
 *     }
 *
 *     [response.deviceResponses enumerateKeysAndObjectsUsingBlock:^(NSString *deviceId, CaiGetSystemMusicVolumeResponseItem *deviceResp, BOOL *stop) {
 *         if (deviceResp.code == 0) {
 *             NSLog(@"设备 %@ 媒体音量: %d", deviceResp.volume);
 *         } else {
 *             NSLog(@"设备 %@ 获取系统媒体音量失败: [%ld] %@", deviceId, (long)deviceResp.code, deviceResp.msg);
 *         }
 *     }];
 * }];
 * @endcode
 */
- (void)getSystemMusicVolumeWithParams:(NSDictionary<NSString *, NSDictionary *> * _Nonnull)params
                               completion:(CaiGetSystemMusicVolumeCompletion _Nullable)completion;
@end

