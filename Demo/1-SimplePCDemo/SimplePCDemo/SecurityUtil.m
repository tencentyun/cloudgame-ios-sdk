//
//  SecurityUtility.m
//  SimplePCDemo
//
//  Created by xxhape on 21.1.22.
//

#import "SecurityUtil.h"
#import <CommonCrypto/CommonDigest.h>
@implementation SecurityUtil

+(NSString *) sha256Hash:(NSString *)input{
    const char* str =[input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0;i<CC_SHA256_DIGEST_LENGTH;i++){
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}
@end
