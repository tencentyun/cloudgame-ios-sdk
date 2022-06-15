//
//  SecurityUtility.h
//  SimplePCDemo
//
//  Created by xxhape on 21.1.22.
//

#import <Foundation/Foundation.h>

@interface SecurityUtil : NSObject

+ (NSString *) sha256Hash:(NSString *)input;
@end

