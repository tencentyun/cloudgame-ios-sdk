/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class RTCVideoFrame;

typedef void (^RTCFrozenHandler)(BOOL isFreeze);
RTC_OBJC_EXPORT
@protocol RTCVideoRenderer <NSObject>

/** The size of the frame. */
- (void)setSize:(CGSize)size;

/** The frame to be displayed. */
- (void)renderFrame:(nullable RTCVideoFrame *)frame;

-(void)pause:(BOOL)isPause;

- (void)setRenderRotationOverride:(NSValue *)rotationOverride;

- (void)setViewContentMode:(UIViewContentMode)contentMode;

@optional
-(RTCVideoFrame*)captureFrame;

- (void)setFrozenHandler:(RTCFrozenHandler)handler frozenDelay:(int64_t)frozenDelay;

@end

RTC_OBJC_EXPORT
@protocol RTCVideoViewDelegate <NSObject>

- (void)videoView:(id<RTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size;


@optional
- (void)videoView:(id<RTCVideoRenderer>)videoView isFirstFrame:(BOOL)isfirstFrame;

@end

NS_ASSUME_NONNULL_END
