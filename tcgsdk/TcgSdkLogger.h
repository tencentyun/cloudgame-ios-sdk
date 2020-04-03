//
//  TcgSdkLogger.h
//  tcgsdk
//
//  Created by okhowang(王沛文) on 2020/4/2.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TcgSdkLogLevel) {
    TcgSdkLogLevelNone = 0,
    TcgSdkLogLevelFatal,
    TcgSdkLogLevelError,
    TcgSdkLogLevelWarning,
    TcgSdkLogLevelInfo,
    TcgSdkLogLevelDebug,
    TcgSdkLogLevelTrace,
};
@protocol TcgSdkLogger <NSObject>
- (void)logWithLevel:(TcgSdkLogLevel)level andStr:(NSString *)log;
@end

NS_ASSUME_NONNULL_END
