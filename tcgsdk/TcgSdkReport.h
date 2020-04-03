//
// Created by okhowang(王沛文) on 2020/4/3.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

@interface TcgSdkReport : NSObject

@property NSString *serverIP;
@property NSString *region;

@property float cpuUsage;
@property NSString *gpuUsage;
@property NSUInteger screenHeight;
@property NSUInteger screenWidth;

@property NSUInteger videoDelay;
@property NSUInteger videoLost;
@property NSUInteger videoJitterBuffer;
@property NSUInteger videoNack;
@property float fps;
@property NSUInteger audioDelay;
@property NSUInteger audioLost;
@property NSUInteger audioJitterBuffer;

@property(readonly) NSArray<RTCLegacyStatsReport *> *reports;

- (void)retrieveFromDictionary:(NSDictionary *)dict;
- (NSString *)description;
@end
