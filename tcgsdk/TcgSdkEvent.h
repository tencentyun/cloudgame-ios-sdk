//
//  TcgSdkEvent.h
//  tcgsdk
//
//  Created by okhowang(王沛文) on 2020/3/31.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TcgSdkEventType) {
    TcgSdkEventTypeMouseDeltaMove,
    TcgSdkEventTypeMouseMove,
    TcgSdkEventTypeMouseLeft,
    TcgSdkEventTypeMouseRight,
    TcgSdkEventTypeMouseScroll,
    TcgSdkEventTypeKeyboard,
    TcgSdkEventTypeGamePadConnect,
    TcgSdkEventTypeGamePadDisconnect,
    TcgSdkEventTypeGamePadKey,
    TcgSdkEventTypeAxisLeft,
    TcgSdkEventTypeAxisRight,
    TcgSdkEventTypeGamePadLt,
    TcgSdkEventTypeGamePadRt,
};

@interface TcgSdkEvent : NSObject
@property TcgSdkEventType type;
@property NSNumber *key;
@property bool down;
@property NSNumber *x;
@property NSNumber *y;
@property NSNumber *delta;
// use for GamePadConnect/GamePadDisconnect
- (instancetype)initEvnet:(TcgSdkEventType)type;
// use for MouseLeft/MouseRight
- (instancetype)initMouseEvent:(TcgSdkEventType)type andDown:(bool)down;
// use for MouseScroll
- (instancetype)initScollEvent:(TcgSdkEventType)type andDelta:(int)delta;
// use for MouseMove/AxisLeft/AxisRight/MouseDeltaMove
- (instancetype)initLocationEvent:(TcgSdkEventType)type andX:(int)x andY:(int)y;
// use for GamePadKey/Keyboard
- (instancetype)initKeyEvent:(TcgSdkEventType)type andKey:(NSInteger)key andDown:(bool)down;
// use for Lt/Rt
- (instancetype)initTriggerEvent:(TcgSdkEventType)type andX:(int)x andDown:(bool)down;

- (NSDictionary *)data;
@end

NS_ASSUME_NONNULL_END
