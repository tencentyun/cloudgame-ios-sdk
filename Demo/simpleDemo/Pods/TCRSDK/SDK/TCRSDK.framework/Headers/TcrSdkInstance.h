//
//  TcrSdkInstance.h
//  tcrsdk
//
//  Created by xxhape on 2023/10/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <tcrsdk/TCRSdkConst.h>
NS_ASSUME_NONNULL_BEGIN

#pragma mark --- 日志接口 ---
@protocol TCRLogDelegate <NSObject>
@required
/*!
 日志打印回调接口
 @param logLevel 日志打印级别
 @param log log
 */
- (void)logWithLevel:(TCRLogLevel)logLevel log:(NSString *_Nullable)log;
@end

@interface TcrSdkInstance : NSObject

+ (void)setLogger:(id<TCRLogDelegate>_Nonnull)logger withMinLevel:(TCRLogLevel)minLevel;

@end
NS_ASSUME_NONNULL_END
