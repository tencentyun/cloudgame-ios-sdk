//
//  TCGVideoFrame.h
//  TCGSDK
//
//  Created by xxhape on 2023/8/4.
//

#import <Foundation/Foundation.h>

@interface TCGVideoFrame : NSObject

@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
/**
 视频帧数据
 */
@property (nonatomic, assign) CVPixelBufferRef pixelBuffer;
@end

