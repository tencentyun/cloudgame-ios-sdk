//
//  TcgSdkDelegate.h
//  tcgsdk
//
//  Created by okhowang(王沛文) on 2020/3/25.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TcgSdkReport.h"
NS_ASSUME_NONNULL_BEGIN

@class TcgSdk;

@protocol TcgSdkDelegate <NSObject>

- (void)tcg:(TcgSdk *)sdk didConnect:(nullable NSError *)error;

- (void)tcg:(TcgSdk *)sdk didDisconnectWithCode:(NSNumber *)code andMessage:(NSString *)message;

// when init done or init error
- (void)tcg:(TcgSdk *)sdk didInit:(nullable NSError *)error andView:(UIView *)view;

- (void)tcg:(TcgSdk *)sdk didInputStateChange:(bool)needInput;

// when display region change in view
- (void)tcg:(TcgSdk *)sdk didFrameChanged:(CGRect)frame;

@optional
- (void)tcg:(TcgSdk *)sdk didStats:(TcgSdkReport *)report;

@end

NS_ASSUME_NONNULL_END
