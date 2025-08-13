//
//  TCGDemoUtils.h
//  TCGDemo
//
//  Created by LyleYu on 2021/6/23.
//

#import <UIKit/UIKit.h>

typedef void (^httpResponseBlk)(NSData * data, NSURLResponse * response, NSError * error);

@interface TCGDemoUtils : NSObject

+ (UIColor *)tcg_colorValue:(NSString *)colorStr;

+ (void)tcg_postUrl:(NSString *)url params:(NSDictionary *)params finishBlk:(httpResponseBlk)finishBlk;

@end
