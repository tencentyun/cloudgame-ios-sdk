//
//  TCGDemoRaidoButton.m
//  TCGDemo
//
//  Created by LyleYu on 2021/7/9.
//

#import "TCGDemoRaidoButton.h"
#import "TCGDemoUtils.h"

@interface TCGDemoRaidoSubBtn : UIView {
    UILabel *_titleView;
    UIImageView *_imageView;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title image:(UIImage *)image;
- (NSString *)title;
@end

@implementation TCGDemoRaidoSubBtn

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title image:(UIImage *)image {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 6, 10, 10)];
        [_imageView setImage:image];
        [self addSubview:_imageView];

        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(12, 5, 33, 12)];
        _titleView.font = [UIFont systemFontOfSize:10];
        _titleView.textColor = [UIColor whiteColor];
        _titleView.text = title;

        self.userInteractionEnabled = YES;
        [self addSubview:_titleView];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    [_imageView setImage:image];
}

- (NSString *)title {
    return _titleView.text;
}

@end

@interface TCGDemoRaidoButton () {
    NSArray<NSString *> *_items;
    NSMutableArray<TCGDemoRaidoSubBtn *> *_buttons;
}

@end

@implementation TCGDemoRaidoButton

- (instancetype)initWithFrame:(CGRect)frame name:(NSString *)name items:(NSArray<NSString *> *)items {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        _items = [items copy];

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

        _buttons = [NSMutableArray new];
        [self initSubviews];
    }

    return self;
}

- (void)initSubviews {
    CGFloat left = 76;
    for (NSString *item in _items) {
        TCGDemoRaidoSubBtn *btn = [[TCGDemoRaidoSubBtn alloc] initWithFrame:CGRectMake(left, 0, 45, self.frame.size.height) title:item
                                                                      image:[UIImage imageNamed:@"login_radio_unselected"]];
        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick:)];
        [btn addGestureRecognizer:click];
        left += 45 + 5;

        [self addSubview:btn];
        [_buttons addObject:btn];
    }
}

- (void)onClick:(UITapGestureRecognizer *)gest {
    TCGDemoRaidoSubBtn *btn = (TCGDemoRaidoSubBtn *)gest.view;
    [self setSeletedValue:btn.title];
}

- (void)setSeletedValue:(NSString *)seletedValue {
    if (_seletedValue != nil && [seletedValue isEqualToString:_seletedValue]) {
        return;
    }
    _seletedValue = seletedValue;
    for (TCGDemoRaidoSubBtn *button in _buttons) {
        if ([seletedValue isEqualToString:button.title]) {
            [button setImage:[UIImage imageNamed:@"login_radio_selected"]];
        } else {
            [button setImage:[UIImage imageNamed:@"login_radio_unselected"]];
        }
    }
}

@end
