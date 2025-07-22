//
//  CAIDemoTextField.m
//  CAIDemo
//
//  Created by LyleYu on 2020/12/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "CAIDemoTextField.h"

@interface CAIDemoTextField () <UITextFieldDelegate>

@end

@implementation CAIDemoTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor clearColor];
        self.keyboardType = UIKeyboardTypeASCIICapable;
        self.tintColor = [UIColor clearColor];
        self.returnKeyType = UIReturnKeyDone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.delegate = self;
    }
    return self;
}

- (void)deleteBackward {
    [super deleteBackward];
    NSLog(@"delete");
    if ([self.keyCodedelegate respondsToSelector:@selector(onClickKey:)]) {
        [self.keyCodedelegate onClickKey:8];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"%@", string);

    if ([string length] > 0 && [self.keyCodedelegate respondsToSelector:@selector(onClickKey:)]) {
        int keycode = [string characterAtIndex:0];
        [self.keyCodedelegate onClickKey:keycode];
    }

    return NO;
}

@end
