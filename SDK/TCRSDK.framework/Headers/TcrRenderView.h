//
//  TcrRenderView.h
//  TCRSDK
//
//  Created by xxhape on 2023/9/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TWEBRTC/TWEBRTC.h>

@protocol TcrRenderViewObserver <NSObject>

- (void)onFirstFrameRendered;

@end

// 暂时不启用metal，目前只有OpenGL才能使视图内容铺满videoView
// #if __arm64__
//@interface TCGGameVideoView : RTCMTLVideoView
// #else
@interface TcrRenderView : RTCEAGLVideoView
// #endif

@property (nonatomic, assign) CGFloat scaleValue;
@property (nonatomic, assign) BOOL enablePinch;
@property (nonatomic, assign) UIInterfaceOrientation videoOrientation;
@property (nonatomic, assign) BOOL enableRender;
@property (nonatomic, weak) id<TcrRenderViewObserver> Observer;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)setTcrRenderViewObserver:(id<TcrRenderViewObserver>)Observer;
- (void)resetVideoViewFrame;
- (void)setEnablePinch:(BOOL)enablePinch;
- (void)resetRenderState;
@end
