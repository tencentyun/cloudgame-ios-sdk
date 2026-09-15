#import "CAIDemoTextField.h"

@interface CAIDemoTextField () <UITextFieldDelegate>

@end

@implementation CAIDemoTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 全透明：只用来接收系统键盘事件，不参与画面显示
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor clearColor];
        self.tintColor = [UIColor clearColor];
        self.keyboardType = UIKeyboardTypeASCIICapable;
        self.returnKeyType = UIReturnKeyDone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.delegate = self;
    }
    return self;
}

// 输入框恒为空，退格不会走 shouldChangeCharactersInRange，只能在这里捕获
- (void)deleteBackward {
    [super deleteBackward];
    if ([self.keyCodedelegate respondsToSelector:@selector(onClickKey:)]) {
        [self.keyCodedelegate onClickKey:8];
    }
}

// 返回 NO：字符只转发为键码上行，不在本地输入框留存
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string length] > 0 && [self.keyCodedelegate respondsToSelector:@selector(onClickKey:)]) {
        [self.keyCodedelegate onClickKey:[string characterAtIndex:0]];
    }
    return NO;
}

@end
