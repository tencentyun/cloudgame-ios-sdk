#import <Foundation/Foundation.h>

RTC_OBJC_EXPORT
@protocol RTCAudioSink <NSObject>

- (void)onAudioData:(NSData*)data bitsPerSample:(int)bitsPerSample sampleRate:(int)sampleRate channels:(int)channels frames:(int)frames;

@end