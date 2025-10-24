
//
//  ProxyConnectionDelegate.h
//  TCRPROXYSDK
//
//  Created by cyy on 2025/09/30.
//

#import <Foundation/Foundation.h>
#import <TCRPROXYSDK/ConnectionState.h>

NS_ASSUME_NONNULL_BEGIN

/// 连接状态回调协议
@protocol ProxyConnectionDelegate <NSObject>

/// 连接状态变化回调
/// @param state 当前连接状态
/// @param message 状态描述信息
- (void)onConnectionStateChanged:(ConnectionState)state message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
