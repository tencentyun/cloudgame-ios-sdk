//
//  VideoSink.h
//  TCRSDK
//
//  Created by xxhape on 2023/9/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TWEBRTC/TWEBRTC.h>

@interface TCRVideoFrame : NSObject

@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int rotation;
/** Timestamp in nanoseconds. */
@property (nonatomic, assign) int64_t timeStampNs;
/**
 视频帧数据
 */
@property (nonatomic, assign) CVPixelBufferRef pixelBuffer;
@end

#pragma mark--- 解码后视频帧接口 ---
@protocol VideoSink <NSObject>
@required
/*
  解码后的视频帧数据回调
 */
- (void)onRenderVideoFrame:(TCRVideoFrame *)frame;
@end
