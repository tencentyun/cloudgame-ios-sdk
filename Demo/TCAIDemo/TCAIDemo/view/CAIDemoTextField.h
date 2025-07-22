//
//  CAIDemoTextField.h
//  CAIDemo
//
//  Created by LyleYu on 2020/12/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CAIDemoTextFieldDelegate <NSObject>

- (void)onClickKey:(int)keycode;

@end

@interface CAIDemoTextField : UITextField

@property(nonatomic, weak) id<CAIDemoTextFieldDelegate> keyCodedelegate;

- (instancetype)initWithFrame:(CGRect)frame;

@end
