
//
//  ConnectionState.h
//  TCRPROXYSDK
//
//  Created by cyy on 2025/09/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 连接状态枚举定义
typedef NS_ENUM(NSInteger, ConnectionState) {
    /// 连接断开
    Disconnected = 0,
    /// 连接中/重连中
    Connecting = 1,
    /// 连接完成
    Connected = 2
};

/// 连接状态工具类
@interface ConnectionStateHelper : NSObject

/// 从状态值获取连接状态枚举
/// @param state 状态值
/// @return 连接状态枚举
+ (ConnectionState)connectionStateFromValue:(NSInteger)state;

/// 获取连接状态描述
/// @param state 连接状态
/// @return 状态描述字符串
+ (NSString *)descriptionForConnectionState:(ConnectionState)state;

@end

NS_ASSUME_NONNULL_END
