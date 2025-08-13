//
//  TCGDemoTextField.h
//  TCGDemo
//
//  Created by LyleYu on 2020/12/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TCGDemoTextFieldDelegate <NSObject>

- (void)onClickKey:(int)keycode;

@end

@interface TCGDemoTextField : UITextField

@property(nonatomic, weak) id<TCGDemoTextFieldDelegate> keyCodedelegate;

- (instancetype)initWithFrame:(CGRect)frame;

@end
