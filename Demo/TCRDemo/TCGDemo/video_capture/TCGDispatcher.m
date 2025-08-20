/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "TCGDispatcher+Private.h"

static dispatch_queue_t kAudioSessionQueue = nil;
static dispatch_queue_t kCaptureSessionQueue = nil;
static dispatch_queue_t kNetworkMonitorQueue = nil;

@implementation TCGDispatcher

+ (void)initialize {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    kAudioSessionQueue = dispatch_queue_create(
        "org.webTCG.TCGDispatcherAudioSession",
        DISPATCH_QUEUE_SERIAL);
    kCaptureSessionQueue = dispatch_queue_create(
        "org.webTCG.TCGDispatcherCaptureSession",
        DISPATCH_QUEUE_SERIAL);
    kNetworkMonitorQueue =
        dispatch_queue_create("org.webTCG.TCGDispatcherNetworkMonitor", DISPATCH_QUEUE_SERIAL);
  });
}

+ (void)dispatchAsyncOnType:(TCGDispatcherQueueType)dispatchType
                      block:(dispatch_block_t)block {
  dispatch_queue_t queue = [self dispatchQueueForType:dispatchType];
  dispatch_async(queue, block);
}

+ (BOOL)isOnQueueForType:(TCGDispatcherQueueType)dispatchType {
  dispatch_queue_t targetQueue = [self dispatchQueueForType:dispatchType];
  const char* targetLabel = dispatch_queue_get_label(targetQueue);
  const char* currentLabel = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);

  NSAssert(strlen(targetLabel) > 0, @"Label is required for the target queue.");
  NSAssert(strlen(currentLabel) > 0, @"Label is required for the current queue.");

  return strcmp(targetLabel, currentLabel) == 0;
}

#pragma mark - Private

+ (dispatch_queue_t)dispatchQueueForType:(TCGDispatcherQueueType)dispatchType {
  switch (dispatchType) {
    case TCGDispatcherTypeMain:
      return dispatch_get_main_queue();
    case TCGDispatcherTypeCaptureSession:
      return kCaptureSessionQueue;
    case TCGDispatcherTypeAudioSession:
      return kAudioSessionQueue;
    case TCGDispatcherTypeNetworkMonitor:
      return kNetworkMonitorQueue;
  }
}

@end
