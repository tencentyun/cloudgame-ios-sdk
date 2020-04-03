//
//  TcgSdkEvent.m
//  tcgsdk
//
//  Created by okhowang(王沛文) on 2020/3/31.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TcgSdkEvent.h"
#import "macros.h"

@implementation TcgSdkEvent

- (instancetype)initScollEvent:(TcgSdkEventType)type andDelta:(int)delta {
    self = [super init];
    if (self != nil) {
        self.type = type;
        self.delta = @(delta);
    }
    return self;
}

- (instancetype)initMouseEvent:(TcgSdkEventType)type andDown:(bool)down {
    self = [super init];
    if (self != nil) {
        self.type = type;
        self.down = down;
    }
    return self;
}

- (instancetype)initEvnet:(TcgSdkEventType)type {
    self = [super init];
    if (self != nil) {
        self.type = type;
    }
    return self;
}

- (instancetype)initLocationEvent:(TcgSdkEventType)type andX:(int)x andY:(int)y {
    self = [super init];
    if (self != nil) {
        self.type = type;
        self.x = @(x);
        self.y = @(y);
    }
    return self;
}

- (instancetype)initKeyEvent:(TcgSdkEventType)type andKey:(NSInteger)key andDown:(bool)down {
    self = [super init];
    if (self != nil) {
        self.type = type;
        self.key = @(key);
        self.down = down;
    }
    return self;
}

- (instancetype)initTriggerEvent:(TcgSdkEventType)type andX:(int)x andDown:(bool)down {
    self = [super init];
    if (self != nil) {
        self.type = type;
        self.x = @(x);
        self.down = down;
    }
    return self;
}

- (NSDictionary *)data {
    switch (_type) {
        case TcgSdkEventTypeMouseDeltaMove:
            return @{@"type" : @"mousedeltamove", @"x" : self.x, @"y" : self.y};
        case TcgSdkEventTypeMouseMove:
            return @{@"type" : @"mousemove", @"x" : self.x, @"y" : self.y};
        case TcgSdkEventTypeMouseLeft:
            return @{@"type" : @"mouseleft", @"down" : NSBOOL(self.down)};
        case TcgSdkEventTypeMouseRight:
            return @{@"type" : @"mouseright", @"down" : NSBOOL(self.down)};
        case TcgSdkEventTypeMouseScroll:
            return @{@"type" : @"mousescroll", @"delta" : self.delta};
        case TcgSdkEventTypeKeyboard:
            return @{@"type" : @"keyboard", @"key" : self.key, @"down" : NSBOOL(self.down)};
        case TcgSdkEventTypeGamePadConnect:
            return @{@"type" : @"gamepadconnect"};
        case TcgSdkEventTypeGamePadDisconnect:
            return @{@"type" : @"gamepaddisconnect"};
        case TcgSdkEventTypeGamePadKey:
            return @{@"type" : @"gamepadkey", @"key" : self.key, @"down" : NSBOOL(self.down)};
        case TcgSdkEventTypeAxisLeft:
            return @{@"type" : @"axisleft", @"x" : self.x, @"y" : self.y};
        case TcgSdkEventTypeAxisRight:
            return @{@"type" : @"axisright", @"x" : self.x, @"y" : self.y};
        case TcgSdkEventTypeGamePadLt:
            return @{@"type" : @"lt", @"x" : self.x, @"down" : NSBOOL(self.down)};
        case TcgSdkEventTypeGamePadRt:
            return @{@"type" : @"rt", @"x" : self.x, @"delta" : NSBOOL(self.down)};
    }
}
@end
