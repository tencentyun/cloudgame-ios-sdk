//
//  TcgSdkUtils.m
//  tcgsdk
//
//  Created by okhowang(王沛文) on 2020/4/1.
//  Copyright © 2020 Tencent. All rights reserved.
//
#import "TcgSdkUtils.h"
#import <Foundation/Foundation.h>

NSData *toJSON(id obj) {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&error];
    assert(data);
    assert(error == nil);
    return data;
}

NSString *toJSONString(id obj) {
    NSData *data = toJSON(obj);
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

NSString *toString(NSData *data) {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

id toType(id obj, Class class) {
    if ([obj isKindOfClass:class]) return obj;
    return nil;
}
