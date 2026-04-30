//
//  Proxy.h
//  PROXY
//
//  Created by cyy on 2025/8/28.
//

#import <Foundation/Foundation.h>
#import <TCRPROXYSDK/ProxyConnectionDelegate.h>

NS_ASSUME_NONNULL_BEGIN

/// 代理服务核心入口
@interface Proxy : NSObject

/// 单例获取（默认日志级别4 Info）
+ (instancetype)sharedInstance;

/// 单例获取（可指定日志级别，2-VERBOSE，3-DEBUG，4-INFO，5-WARNING，6-ERROR）
+ (instancetype)sharedInstanceWithLogLevel:(NSInteger)logLevel;

/// 初始化代理服务（必须先于 startProxy 调用）
/// @param relayInfoString 云端下发的代理中继信息
/// @return 初始化是否成功
- (BOOL)initWithRelayInfoString:(NSString *)relayInfoString;

/// 初始化代理服务（宽带参数版，必须先于 startProxy 调用）
/// @param bandwidth 设备带宽（如 @"1MB" 或 @"500KB"），最大 4MB
/// @param relayInfoString 云端下发的代理中继信息
/// @return 初始化是否成功
/// @deprecated 请使用 initWithUploadBandwidth:downloadBandwidth:relayInfoString: 以分别控制上下行带宽
- (BOOL)initWithBandwidth:(nullable NSString *)bandwidth relayInfoString:(NSString *)relayInfoString
    DEPRECATED_MSG_ATTRIBUTE("Use initWithUploadBandwidth:downloadBandwidth:relayInfoString: instead");

/// 初始化代理服务（分别指定上下行带宽，必须先于 startProxy 调用）
/// @param uploadBandwidth   上行带宽限制（即本地手机发往云机），如 @"2MB"、@"512KB"，nil 使用默认值 4MB，最大 4MB
/// @param downloadBandwidth 下行带宽限制（即云机发往本地手机），如 @"4MB"、@"1MB"，nil 使用默认值 4MB，最大 4MB
/// @param relayInfoString   云端下发的代理中继信息
/// @return 初始化是否成功
- (BOOL)initWithUploadBandwidth:(nullable NSString *)uploadBandwidth
               downloadBandwidth:(nullable NSString *)downloadBandwidth
                relayInfoString:(NSString *)relayInfoString;

/// 启动代理服务。须先 init 成功
- (void)startProxy;

/// 停止代理服务
- (void)stopProxy;

/// 设置连接状态变化监听器
/// 通过此接口可以监听代理服务的连接状态变化，包括：
/// - 连接断开
/// - 连接中/重连中  
/// - 连接完成
/// @param delegate 连接状态变化监听器，传nil可清除监听
- (void)setConnectionDelegate:(nullable id<ProxyConnectionDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
