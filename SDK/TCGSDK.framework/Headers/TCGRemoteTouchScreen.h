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
/*
  清除本地存储的touch事件(用于卡键情况)
 */
- (void)cleanTouchEvent;
@end