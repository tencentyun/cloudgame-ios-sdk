#import <AVFoundation/AVFoundation.h>
#import <TCRSDK/TCRSDK.h>

NS_ASSUME_NONNULL_BEGIN

/// 自定义音频采集示例：用 AudioUnit 采集麦克风 PCM，经 sendCustomAudioData:captureTimeNs: 上行
@interface CAIAudioCapturer : NSObject

@property (nonatomic, assign, readonly) BOOL isRunning;

+ (void)configureWithSampleRate:(NSInteger)sampleRate channelCount:(NSInteger)channelCount dumpAudio:(BOOL)isDump;
// 未配置时返回 nil，对其调用 start/stop 为空操作
+ (instancetype _Nullable)sharedCapturer;
- (void)startAudioCapture:(TcrSession *)tcrSession;
- (void)stopAudioCapture;
- (void)freeAudioUnit;

@end

NS_ASSUME_NONNULL_END
