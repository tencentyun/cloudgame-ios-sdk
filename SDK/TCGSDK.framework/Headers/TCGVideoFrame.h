//
//  TCGVideoFrame.h
//  TCGSDK
//
//  Created by xxhape on 2023/8/4.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCGVideoFrame : NSObject

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

