/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <TWEBRTC/RTCMacros.h>
#import <TWEBRTC/RTCMediaStreamTrack.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RTCAudioSink;
@class RTCAudioSource;

RTC_OBJC_EXPORT
@interface RTC_OBJC_TYPE (RTCAudioTrack) : RTC_OBJC_TYPE(RTCMediaStreamTrack)

- (instancetype)init NS_UNAVAILABLE;
/** Register a audioSink*/
- (void)addSink:(id<RTCAudioSink>)sink;

/** Deregister a audioSink. */
- (void)removeSink:(id<RTCAudioSink>)sink;
/** The audio source for this audio track. */
@property(nonatomic, readonly) RTC_OBJC_TYPE(RTCAudioSource) * source;

@end

NS_ASSUME_NONNULL_END
