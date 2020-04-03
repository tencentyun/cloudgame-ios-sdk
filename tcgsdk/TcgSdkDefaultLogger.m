//
//  TcgSdkDefaultLogger.m
//  tcgsdk
//
//  Created by okhowang(王沛文) on 2020/4/2.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TcgSdkDefaultLogger.h"

static NSString *levelToString(TcgSdkLogLevel level) {
    static NSArray *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      dict = @[
          @"None",
          @"Fatal",
          @"Error",
          @"Warning",
          @"Info",
          @"Debug",
          @"Trace",
      ];
    });
    return dict[level];
}

@implementation TcgSdkDefaultLogger

- (void)logWithLevel:(TcgSdkLogLevel)level andStr:(nonnull NSString *)log {
    NSLog(@"[%@]%@", levelToString(level), log);
}

@end
