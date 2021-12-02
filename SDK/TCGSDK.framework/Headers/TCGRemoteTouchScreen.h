//
//  TCGRemoteTouchScreen.h
//  tcgsdk
//
//  Created by LyleYu on 2021/3/4.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TCGGameController;

@interface TCGRemoteTouchScreen : UIView

- (instancetype)initWithFrame:(CGRect)frame controller:(TCGGameController *)controller;

@end
