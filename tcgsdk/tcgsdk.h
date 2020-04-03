//
//  tcgsdk.h
//  tcgsdk
//
//  Created by okhowang(王沛文) on 2020/3/24.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

#import "TcgSdkDelegate.h"
#import "TcgSdkEvent.h"
#import "TcgSdkLogger.h"
#import "TcgSdkParams.h"
//! Project version number for tcgsdk.
FOUNDATION_EXPORT double tcgsdkVersionNumber;

//! Project version string for tcgsdk.
FOUNDATION_EXPORT const unsigned char tcgsdkVersionString[];

// In this header, you should import all the public headers of your framework
// using statements like #import <tcgsdk/PublicHeader.h>

typedef NS_ENUM(NSInteger, TcgSdkCursorMode) {
    TcgSdkCursorModeFixedLocal,    // 本地固定图标渲染鼠标
    TcgSdkCursorModeDynamicLocal,  // 本地动态图标渲染鼠标
    TcgSdkCursorModeRemote,        // 远端渲染鼠标
};

@interface TcgSdk : NSObject

@property(nonatomic) TcgSdkCursorMode cursorMode;
// 默认为false false状态下mouseMove传入的x y被认为是当前view的绝对坐标
// true状态下mouseMove传入的x y被认为是机遇当前位置移动的坐标
@property(nonatomic) bool tabletMouseMode;

// 在画面上展示debug信息
@property bool debugDisplay;

- (instancetype)initWithParams:(TcgSdkParams *)params andDelegate:(id<TcgSdkDelegate>)listener;

- (NSString *)getClientSession;

- (bool)start:(NSString *)serverSession;

- (void)destroy;

// 当view大小变化时调用，更新窗口大小
- (void)updateViewFrame;

/**
 - fps: 帧率，整型，范围[10,60]，单位帧;
 - max_bitrate: 最大码率，整型，范围[1,15]，单位Mbps
 - min_bitrate: 最小码率，整型，范围[1,15], 单位Mbps
 */
- (void)setStreamProfileWithFps:(NSUInteger)fps
                  andMaxBitRate:(NSUInteger)max
                  andMinBitRate:(NSUInteger)min;

// 设置音量（与全局隔离）
- (void)setVolume:(float)volume;

- (void)sendKeyEvent:(NSInteger)key down:(bool)down;

- (void)mouseMoveX:(float)x andY:(float)y;

- (void)sendRawEvent:(TcgSdkEvent *)event;

- (void)sendRawEvents:(NSArray<TcgSdkEvent *> *)events;

- (void)restart;

- (void)setLogger:(id<TcgSdkLogger>)logger;

- (void)setLogLevel:(TcgSdkLogLevel)level;

@end
