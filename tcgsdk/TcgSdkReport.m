//
// Created by okhowang(王沛文) on 2020/4/3.
//

#import "TcgSdkReport.h"
#import "TcgSdkReport+Private.h"
#import "TcgSdkUtils.h"

@implementation TcgSdkReport

- (void)retrieveFromRTCStatsReports:(NSArray<RTCLegacyStatsReport *> *)reports {
    _reports = reports;
    for (RTCLegacyStatsReport *report in reports) {
        if ([report.type isEqualToString:@"ssrc"]) {
            NSString *mediaType = toType(report.values[@"mediaType"], [NSString class]);
            if ([mediaType isEqualToString:@"video"]) {
                _fps = [(NSString *)toType(report.values[@"googFrameRateOutput"], [NSString class])
                    floatValue];
                _videoLost = [(NSString *)toType(report.values[@"packetsLost"], [NSString class])
                    integerValue];
                _videoNack = [(NSString *)toType(report.values[@"googNacksSent"], [NSString class])
                    integerValue];
                _videoDelay = [(NSString *)toType(report.values[@"googCurrentDelayMs"],
                                                  [NSString class]) integerValue];
                _videoJitterBuffer = [(NSString *)toType(report.values[@"googJitterBufferMs"],
                                                         [NSString class]) integerValue];
            } else if ([mediaType isEqualToString:@"audio"]) {
                _audioLost = [(NSString *)toType(report.values[@"packetsLost"], [NSString class])
                    integerValue];
                _audioDelay = [(NSString *)toType(report.values[@"googCurrentDelayMs"],
                                                  [NSString class]) integerValue];
                _audioJitterBuffer = [(NSString *)toType(report.values[@"googJitterBufferMs"],
                                                         [NSString class]) integerValue];
            }
        } else if ([report.type isEqualToString:@"VideoBwe"]) {
        }
    }
}

- (void)retrieveFromDictionary:(NSDictionary *)dict {
    NSNumber *cpuUsage = toType(dict[@"cpu_usage"], [NSNumber class]);
    if (cpuUsage != nil) _cpuUsage = [cpuUsage floatValue];

    NSString *gpuUsage = toType(dict[@"gpu_usage"], [NSString class]);
    if (gpuUsage != nil) _gpuUsage = gpuUsage;

    NSNumber *screenHeight = toType(dict[@"screen_height"], [NSNumber class]);
    if (screenHeight != nil) _screenHeight = [screenHeight unsignedIntegerValue];

    NSNumber *screenWidth = toType(dict[@"screen_width"], [NSNumber class]);
    if (screenWidth != nil) _screenWidth = [screenWidth unsignedIntegerValue];
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString new];
    [string appendFormat:@"%20@ %zux%zu\n", @"Resolution", _screenWidth, _screenHeight];
    [string appendFormat:@"%20@ %f\n", @"CpuUsage", _cpuUsage];
    [string appendFormat:@"%20@ %@\n", @"GpuUsage", _gpuUsage];
    [string appendFormat:@"%20@ %@\n", @"ServerIP", _serverIP];
    [string appendFormat:@"%20@ %@\n", @"Region", _region];
    [string appendFormat:@"%20@ %zu\n", @"VideoDelay", _videoDelay];
    [string appendFormat:@"%20@ %zu\n", @"VideoLost", _videoLost];
    [string appendFormat:@"%20@ %zu\n", @"VideoJitterBuffer", _videoJitterBuffer];
    [string appendFormat:@"%20@ %zu\n", @"VideoNack", _videoNack];
    [string appendFormat:@"%20@ %f\n", @"FPS", _fps];
    [string appendFormat:@"%20@ %zu\n", @"AudioDelay", _audioDelay];
    [string appendFormat:@"%20@ %zu\n", @"AudioLost", _audioLost];
    [string appendFormat:@"%20@ %zu\n", @"AudioJitterBuffer", _audioJitterBuffer];
    return string;
}
@end
