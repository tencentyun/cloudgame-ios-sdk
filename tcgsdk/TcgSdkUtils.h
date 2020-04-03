//
//  TcgSdkUtils.h
//  tcgsdk
//
//  Created by okhowang(王沛文) on 2020/4/1.
//  Copyright © 2020 Tencent. All rights reserved.
//

#ifndef TcgSdkUtils_h
#define TcgSdkUtils_h

#import <UIKit/UIKit.h>
NSData *toJSON(id obj);
NSString *toJSONString(id obj);
NSString *toString(NSData *data);
id toType(id obj, Class class);
#endif /* TcgSdkUtils_h */
