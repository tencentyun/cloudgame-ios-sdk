//
//  CAIDemoAudioCapturor.h
//  自定义音频采集
//
//  Created by 高峻峰 on 2023/10/10.
//

#ifndef CAIDemoAudioCapturor_h
#define CAIDemoAudioCapturor_h

#import <AVFoundation/AVFoundation.h>
#import <TCRSDK/TCRSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface CAIDemoAudioCapturor : NSObject

@property (nonatomic, assign, readonly) BOOL isRunning;

+ (void)configureAudioCapturor:(NSInteger)sampleRate channelCount:(NSInteger)channelCount dumpAudio:(BOOL)isDump;
// 未配置时返回 nil，对其调用 start/stop 为空操作
+ (instancetype _Nullable)getInstance;
- (void)startAudioCapture:(TcrSession *)tcrSession;
- (void)stopAudioCapture;

- (void)freeAudioUnit;
- (AudioStreamBasicDescription)getAudioDataFormat;

@end

NS_ASSUME_NONNULL_END

#endif /* CAIDemoAudioCapturor_h */
