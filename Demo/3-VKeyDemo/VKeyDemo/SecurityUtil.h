//
//  SecurityUtil.h
//  VKeyDemo
//
//  Created by xxhape on 2022/6/30.
//  Copyright © 2022 yujunlei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityUtil : NSObject

+ (NSString *) sha256Hash:(NSString *)input;
@end

