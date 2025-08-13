//
//  TCGDemoExperienceInputText.m
//  TCGDemo
//
//  Created by LyleYu on 2021/6/23.
//

#import "TCGDemoExperienceInputText.h"
#import "TCGDemoUtils.h"

@interface TCGDemoExperienceInputText () <UITextFieldDelegate> {
    UITextField *_txtInput;
}

@end

@implementation TCGDemoExperienceInputText

- (instancetype)initWithFrame:(CGRect)frame name:(NSString *)name oldValue:(NSString *)oldText {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];

        UILabel *txtName = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 48, 12)];
        txtName.backgroundColor = [UIColor clearColor];
        txtName.font = [UIFont systemFontOfSize:10];
        txtName.textColor = [UIColor whiteColor];
        txtName.textAlignment = NSTextAlignmentLeft;
        txtName.text = name;
        [self addSubview:txtName];

        CALayer *line = [CALayer new];
        line.frame = CGRectMake(60, 7.5, 0.5, 7.5);
        line.backgroundColor = [TCGDemoUtils tcg_colorValue:@"3064B0"].CGColor;
        [self.layer addSublayer:line];

        _txtInput = [[UITextField alloc] initWithFrame:CGRectMake(76, 4.5, 100, 14)];
        _txtInput.backgroundColor = [UIColor clearColor];
        _txtInput.font = [UIFont systemFontOfSize:10];
        _txtInput.textColor = [UIColor whiteColor];
        _txtInput.textAlignment = NSTextAlignmentLeft;
        _txtInput.keyboardType = UIKeyboardTypeASCIICapable;
        _txtInput.returnKeyType = UIReturnKeyDone;
        _txtInput.delegate = self;
        _txtInput.autocorrectionType = UITextAutocorrectionTypeNo;
        NSString *placedString = [NSString stringWithFormat:@"请输入%@", name];
        NSMutableAttributedString *placedAttr = [[NSMutableAttributedString alloc] initWithString:placedString];
        [placedAttr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, placedString.length)];
        [placedAttr addAttribute:NSForegroundColorAttributeName value:[TCGDemoUtils tcg_colorValue:@"CEDBED"]
                           range:NSMakeRange(0, placedString.length)];
        _txtInput.attributedPlaceholder = placedAttr;
        if (oldText.length > 0) {
            _txtInput.text = oldText;
        }
        [self addSubview:_txtInput];
    }
    return self;
}

- (NSString *)text {
    return _txtInput.text;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.inputDelegate respondsToSelector:@selector(onBeginEditing:)]) {
        [self.inputDelegate onBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_txtInput resignFirstResponder];
    return YES;
}

@end
