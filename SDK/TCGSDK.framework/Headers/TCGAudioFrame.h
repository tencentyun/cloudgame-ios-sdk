//
//  TCGAudioFrame.h
//  TCGSDK
//
//  Created by xxhape on 2023/8/9.
//

#import <Foundation/Foundation.h>

/**
 通常播放时我们设置的参数为
 _audioDescription.mSampleRate = 48000;
 _audioDescription.mFormatID = kAudioFormatLinearPCM;
 _audioDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
 _audioDescription.mChannelsPerFrame = 2;
 _audioDescription.mFramesPerPacket = 1;
 _audioDescription.mBitsPerChannel = 16;
 _audioDescription.mBytesPerFrame = 4;
 _audioDescription.mBytesPerPacket = _audioDescription.mBytesPerFrame * _audioDescription.mFramesPerPacket;
 */
@interface TCGAudioFrame : NSObject
/**
 音频数据
 */
@property (nonatomic, assign) NSData* data;
/**
 每个音频样本的位数
 */
@property (nonatomic, assign) int bitsPerSample;
/**
 音频的采样率
 */
@property (nonatomic, assign) int sampleRate;
/**
 音频数据中的通道数量
 */
@property (nonatomic, assign) int channels;
/**
 音频数据中的样本帧数
 */
@property (nonatomic, assign) int frames;
@end

