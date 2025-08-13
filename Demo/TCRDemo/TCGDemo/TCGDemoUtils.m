//
//  TCGDemoUtils.m
//  TCGDemo
//
//  Created by LyleYu on 2021/6/23.
//

#import "TCGDemoUtils.h"

@implementation TCGDemoUtils

+ (UIColor *)tcg_colorValue:(NSString *)colorStr {
    if ([colorStr length] == 6 || [colorStr length] == 8) {
        CGFloat alpha = 1.0;
        CGFloat red, green, blue;
        char subStr[3] = { 0 };
        char *ptr;
        subStr[0] = [colorStr characterAtIndex:0];
        subStr[1] = [colorStr characterAtIndex:1];
        red = strtol(subStr, &ptr, 16) / 255.0f;
        subStr[0] = [colorStr characterAtIndex:2];
        subStr[1] = [colorStr characterAtIndex:3];
        green = strtol(subStr, &ptr, 16) / 255.0f;
        subStr[0] = [colorStr characterAtIndex:4];
        subStr[1] = [colorStr characterAtIndex:5];
        blue = strtol(subStr, &ptr, 16) / 255.0f;
        if ([colorStr length] == 8) {
            subStr[0] = [colorStr characterAtIndex:6];
            subStr[1] = [colorStr characterAtIndex:7];
            alpha = strtol(subStr, &ptr, 16) / 255.0f;
        }
        return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        ;
    }
    return [UIColor clearColor];
}

+ (void)tcg_postUrl:(NSString *)url params:(NSDictionary *)params finishBlk:(httpResponseBlk)finishBlk {
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:url]];
    [request setHTTPMethod:@"POST"];
    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    if (error != nil || body == nil) {
        NSLog(@"JSON serialization error:%@", error);
        if (finishBlk) {
            finishBlk(nil, nil, error);
        }
        return;
    }
    [request setHTTPBody:body];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [[session dataTaskWithRequest:request completionHandler:finishBlk] resume];
}

@end
