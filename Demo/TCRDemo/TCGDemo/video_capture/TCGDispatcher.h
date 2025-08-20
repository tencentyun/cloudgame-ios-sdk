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

typedef NS_ENUM(NSInteger, TCGDispatcherQueueType) {
  // Main dispatcher queue.
  TCGDispatcherTypeMain,
  // Used for starting/stopping AVCaptureSession, and assigning
  // capture session to AVCaptureVideoPreviewLayer.
  TCGDispatcherTypeCaptureSession,
  // Used for operations on AVAudioSession.
  TCGDispatcherTypeAudioSession,
  // Used for operations on NWPathMonitor.
  TCGDispatcherTypeNetworkMonitor,
};

/** Dispatcher that asynchronously dispatches blocks to a specific
 *  shared dispatch queue.
 */
@interface TCGDispatcher : NSObject

- (instancetype)init NS_UNAVAILABLE;

/** Dispatch the block asynchronously on the queue for dispatchType.
 *  @param dispatchType The queue type to dispatch on.
 *  @param block The block to dispatch asynchronously.
 */
+ (void)dispatchAsyncOnType:(TCGDispatcherQueueType)dispatchType block:(dispatch_block_t)block;

/** Returns YES if run on queue for the dispatchType otherwise NO.
 *  Useful for asserting that a method is run on a correct queue.
 */
+ (BOOL)isOnQueueForType:(TCGDispatcherQueueType)dispatchType;

@end
