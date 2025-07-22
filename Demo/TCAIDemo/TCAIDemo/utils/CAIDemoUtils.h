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

@end
