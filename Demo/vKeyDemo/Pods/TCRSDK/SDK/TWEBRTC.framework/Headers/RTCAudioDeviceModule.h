#import <Foundation/Foundation.h>
#import <TWEBRTC/RTCMacros.h>

NS_ASSUME_NONNULL_BEGIN

RTC_OBJC_EXPORT
@interface RTCAudioDeviceModule : NSObject

- (instancetype)initWithEnableCustomAudioCapture:(BOOL)enableCustomAudioCapture;

/** Send custom audio data */
- (bool)sendCustomAudioData:(NSData *)audioBuffer timestampNs:(uint64_t)timestampNs;

@end

NS_ASSUME_NONNULL_END
