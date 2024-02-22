//
//  TcrEnvTest.h
//  TCRSDK
//
//  Created by xxhape on 2024/2/22.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^demoHttpResponseBlk)(NSData * data, NSURLResponse * response, NSError * error);

@interface TcrEnvTest : NSObject

/*!
 demo请求体验接口
 
 @param cmd  有效值:@"Start"/@"Stop"
 @param params demo中包含的请求参数
 @param demoHttpResponseBlk http返回结果
 */
+ (void)createAndStopSession:(NSString *)cmd params:(NSDictionary *)params finishBlk:(demoHttpResponseBlk)finishBlk;

@end
