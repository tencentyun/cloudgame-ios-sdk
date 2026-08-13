//
//  CAIDemoUtils.h
//  CAIDemo
//
//  Created by LyleYu on 2021/6/23.
//

#import <UIKit/UIKit.h>

typedef void (^httpResponseBlk)(NSData * data, NSURLResponse * response, NSError * error);

@interface CAIDemoUtils : NSObject

+ (UIColor *)CAI_colorValue:(NSString *)colorStr;

+ (void)CAI_postUrl:(NSString *)url params:(NSDictionary *)params finishBlk:(httpResponseBlk)finishBlk;

/// 打印当前音频状态（存活 AudioUnit 的子类型 + AVAudioSession category/mode），用于审计 SDK 对音频的影响。
/// @param tag 日志标记，用于区分打印时机，如 @"开麦克风-前"
+ (void)CAI_dumpAudioStateWithTag:(NSString *)tag;

@end
