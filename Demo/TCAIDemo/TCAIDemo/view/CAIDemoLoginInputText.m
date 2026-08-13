//
//  CAIDemoExperienceInputText.m
//  CAIDemo
//
//  Created by LyleYu on 2021/6/23.
//

#import "CAIDemoLoginInputText.h"
#import "CAIDemoUtils.h"

@interface CAIDemoLoginInputText () <UITextFieldDelegate, UITextViewDelegate> {
    UITextField *_txtInput;
    UITextView *_txtView;   // 多行输入（AccessInfo 长文本）
    UILabel *_placeholder;
    NSString *_placeholderText;
}

@end

@implementation CAIDemoLoginInputText

- (instancetype)initWithFrame:(CGRect)frame name:(NSString *)name oldValue:(NSString *)oldText {
    return [self initWithFrame:frame name:name oldValue:oldText height:frame.size.height multiline:NO];
}

- (instancetype)initWithFrame:(CGRect)frame name:(NSString *)name oldValue:(NSString *)oldText height:(CGFloat)height multiline:(BOOL)multiline {
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
        line.backgroundColor = [CAIDemoUtils CAI_colorValue:@"3064B0"].CGColor;
        [self.layer addSublayer:line];

        CGFloat textHeight = (height > 0 ? height : frame.size.height);
        NSString *placedString = [NSString stringWithFormat:@"请输入%@", name];

        if (multiline) {
            // 多行输入框：使用 UITextView，支持滚动与长文本
            _txtView = [[UITextView alloc] initWithFrame:CGRectMake(76, 2, frame.size.width - 86, textHeight)];
            _txtView.backgroundColor = [UIColor clearColor];
            _txtView.font = [UIFont systemFontOfSize:10];
            _txtView.textColor = [UIColor whiteColor];
            _txtView.textAlignment = NSTextAlignmentLeft;
            _txtView.keyboardType = UIKeyboardTypeASCIICapable;
            _txtView.returnKeyType = UIReturnKeyDone;
            _txtView.autocorrectionType = UITextAutocorrectionTypeNo;
            _txtView.delegate = self;
            if (oldText.length > 0) {
                _txtView.text = oldText;
            } else {
                _placeholderText = placedString;
                [self showPlaceholder:_placeholderText];
            }
            [self addSubview:_txtView];
        } else {
            _txtInput = [[UITextField alloc] initWithFrame:CGRectMake(76, 4.5, frame.size.width - 86, textHeight)];
            _txtInput.backgroundColor = [UIColor clearColor];
            _txtInput.font = [UIFont systemFontOfSize:10];
            _txtInput.textColor = [UIColor whiteColor];
            _txtInput.textAlignment = NSTextAlignmentLeft;
            _txtInput.keyboardType = UIKeyboardTypeASCIICapable;
            _txtInput.returnKeyType = UIReturnKeyDone;
            _txtInput.delegate = self;
            _txtInput.autocorrectionType = UITextAutocorrectionTypeNo;
            // 密码框（name == @"密码"）启用密文显示，避免明文暴露
            if ([name isEqualToString:@"密码"]) {
                _txtInput.secureTextEntry = YES;
            }
            NSMutableAttributedString *placedAttr = [[NSMutableAttributedString alloc] initWithString:placedString];
            [placedAttr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, placedString.length)];
            [placedAttr addAttribute:NSForegroundColorAttributeName value:[CAIDemoUtils CAI_colorValue:@"CEDBED"]
                               range:NSMakeRange(0, placedString.length)];
            _txtInput.attributedPlaceholder = placedAttr;
            if (oldText.length > 0) {
                _txtInput.text = oldText;
            }
            [self addSubview:_txtInput];
        }
    }
    return self;
}

- (void)showPlaceholder:(NSString *)text {
    _placeholder = [[UILabel alloc] initWithFrame:CGRectMake(2, 1, _txtView.bounds.size.width - 4, 12)];
    _placeholder.font = [UIFont systemFontOfSize:10];
    _placeholder.textColor = [CAIDemoUtils CAI_colorValue:@"CEDBED"];
    _placeholder.text = text;
    [_txtView addSubview:_placeholder];
}

- (NSString *)text {
    if (_txtInput != nil) {
        return _txtInput.text;
    }
    if (_txtView != nil) {
        return _txtView.text;
    }
    return @"";
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

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (_placeholder != nil) {
        [_placeholder removeFromSuperview];
        _placeholder = nil;
    }
    if ([self.inputDelegate respondsToSelector:@selector(onBeginEditing:)]) {
        [self.inputDelegate onBeginEditing:textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0 && _placeholder == nil) {
        [self showPlaceholder:_placeholderText];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
