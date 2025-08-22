#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCGDemoAudioCapturor : NSObject

/// 单例访问入口
+ (instancetype)shared;

/// 配置音频参数（需在首次调用 start 前设置）
/// @param sampleRate 采样率（如 16000）
/// @param channelCount 声道数（如 1）
/// @param dumpAudio 是否将 PCM 数据写入文件（调试用）
- (void)configureWithSampleRate:(Float64)sampleRate
                   channelCount:(UInt32)channelCount
                      dumpAudio:(BOOL)dumpAudio;

/// 开始捕获（需已配置参数）
- (void)startCapture;

/// 停止捕获
- (void)stopCapture;

/// 音频数据回调 Block
/// @param data 原始 PCM 数据
/// @param timestamp 时间戳（纳秒精度）
@property (nonatomic, copy) void (^audioDataHandler)(NSData *data, uint64_t timestamp);

@end

NS_ASSUME_NONNULL_END
