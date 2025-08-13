//
//  TCGDemoBitrateInputText.m
//  TCGDemo
//
//  Created by LyleYu on 2021/7/7.
//

#import "TCGDemoBitrateInputText.h"
#import "TCGDemoUtils.h"

@interface TCGDemoBitrateInputText () <UITextFieldDelegate> {
    int _minBitrate;
    int _maxBitrate;
    UITextField *_minInput;
    UITextField *_maxInput;
}

@end

@implementation TCGDemoBitrateInputText

- (instancetype)initWithFrame:(CGRect)frame name:(NSString *)name min:(NSNumber *)min max:(NSNumber *)max {
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

        _minInput = [[UITextField alloc] initWithFrame:CGRectMake(76, 4.5, 45, 14)];
        _minInput.backgroundColor = [UIColor clearColor];
        _minInput.font = [UIFont systemFontOfSize:10];
        _minInput.textColor = [UIColor whiteColor];
        _minInput.textAlignment = NSTextAlignmentCenter;
        _minInput.keyboardType = UIKeyboardTypeASCIICapable;
        _minInput.returnKeyType = UIReturnKeyDone;
        _minInput.autocorrectionType = UITextAutocorrectionTypeNo;
        _minInput.delegate = self;
        NSString *placedString = @"最小(1M)";
        NSMutableAttributedString *placedAttr = [[NSMutableAttributedString alloc] initWithString:placedString];
        [placedAttr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, placedString.length)];
        [placedAttr addAttribute:NSForegroundColorAttributeName value:[TCGDemoUtils tcg_colorValue:@"CEDBED"]
                           range:NSMakeRange(0, placedString.length)];
        _minInput.attributedPlaceholder = placedAttr;
        if (min != nil) {
            _minInput.text = [NSString stringWithFormat:@"%@", min];
            _minBitrate = [min intValue];
        }
        [self addSubview:_minInput];

        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(123.5, frame.size.height / 2 - 0.5, 9, 1)];
        separator.backgroundColor = [UIColor whiteColor];
        [self addSubview:separator];

        _maxInput = [[UITextField alloc] initWithFrame:CGRectMake(139, 4.5, 45, 14)];
        _maxInput.backgroundColor = [UIColor clearColor];
        _maxInput.font = [UIFont systemFontOfSize:10];
        _maxInput.textColor = [UIColor whiteColor];
        _maxInput.textAlignment = NSTextAlignmentCenter;
        _maxInput.keyboardType = UIKeyboardTypeASCIICapable;
        _maxInput.autocorrectionType = UITextAutocorrectionTypeNo;
        _maxInput.returnKeyType = UIReturnKeyDone;
        _maxInput.delegate = self;
        NSString *placedString2 = @"最大(10M)";
        NSMutableAttributedString *placedAttr2 = [[NSMutableAttributedString alloc] initWithString:placedString2];
        [placedAttr2 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, placedString2.length)];
        [placedAttr2 addAttribute:NSForegroundColorAttributeName value:[TCGDemoUtils tcg_colorValue:@"CEDBED"]
                            range:NSMakeRange(0, placedString2.length)];
        _maxInput.attributedPlaceholder = placedAttr2;
        if (max != nil) {
            _maxInput.text = [NSString stringWithFormat:@"%@", max];
            _maxBitrate = [max intValue];
        }
        _minBitrate = 0;
        _maxBitrate = 11;
        [self addSubview:_maxInput];
    }
    return self;
}

- (int)minBitrate {
    return _minBitrate;
}

- (int)maxBitrate {
    return _maxBitrate == 11 ? 0 : _maxBitrate;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *finalStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([finalStr length] > 0) {
        NSString *regex = @"[0-9]*";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![pred evaluateWithObject:string]) {
            return NO;
        }
    } else {
        textField.text = nil;
        return NO;
    }

    float value = [finalStr floatValue];
    if (value < 0 || value > 10) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.inputDelegate respondsToSelector:@selector(onBeginEditing:)]) {
        [self.inputDelegate onBeginEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    int value = [textField.text intValue];
    if (textField == _minInput) {
        _minBitrate = value;
    } else {
        _maxBitrate = value;
    }
    if (_minBitrate > _maxBitrate) {
        _minBitrate = _maxBitrate = value;
        _maxInput.text = [NSString stringWithFormat:@"%d", value];
        _minInput.text = [NSString stringWithFormat:@"%d", value];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}

@end
