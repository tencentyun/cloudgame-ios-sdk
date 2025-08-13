//
//  TCGDemoCheckbox.m
//  TCGDemo
//
//  Created by LyleYu on 2021/7/8.
//

#import "TCGDemoPickerView.h"
#import "TCGDemoUtils.h"

@interface TCGDemoPickerView () <UIPickerViewDelegate, UIPickerViewDataSource> {
    UIPickerView *_picker;
    NSArray<NSDictionary *> *_items;
    UILabel *_txtContent;
    UIControl *_clickBgView;
    NSInteger _selectedRow;
}

@property (nonatomic, weak) UIView *weakParentView;

@end

@implementation TCGDemoPickerView

- (instancetype)initWithFrame:(CGRect)frame name:(NSString *)name parent:(UIView *)parentView items:(NSArray<NSDictionary *> *)items {
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

        _txtContent = [[UILabel alloc] initWithFrame:CGRectMake(76, 4.5, 130, 14)];
        _txtContent.backgroundColor = [UIColor clearColor];
        _txtContent.font = [UIFont systemFontOfSize:10];
        _txtContent.textColor = [UIColor whiteColor];
        _txtContent.textAlignment = NSTextAlignmentLeft;
        _txtContent.text = [NSString stringWithFormat:@"选择%@", name];

        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(100 - 10, 2, 10, 10)];
        image.image = [UIImage imageNamed:@"login_triangle"];
        [_txtContent addSubview:image];
        [self addSubview:_txtContent];

        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick)];
        [_txtContent addGestureRecognizer:click];
        _txtContent.userInteractionEnabled = YES;

        _picker = [[UIPickerView alloc] init];
        _picker.backgroundColor = [TCGDemoUtils tcg_colorValue:@"0C2958"];
        _picker.dataSource = self;
        _picker.delegate = self;
        _selectedRow = -1;

        _clickBgView = [[UIControl alloc] initWithFrame:parentView.bounds];
        UITapGestureRecognizer *bgClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick)];
        [_clickBgView addGestureRecognizer:bgClick];

        self.weakParentView = parentView;
    }
    return self;
}

- (void)onClick {
    if (_picker.superview != nil) {
        [_picker removeFromSuperview];
        [_clickBgView removeFromSuperview];
    } else {
        CGRect viewFrame = [self convertRect:_txtContent.frame toView:self.weakParentView];
        CGFloat top = viewFrame.origin.y + viewFrame.size.height;
        CGFloat left = viewFrame.origin.x - _txtContent.frame.origin.x;
        CGFloat maxHeight = MIN(_items.count, 3) * 22.5;
        _picker.frame = CGRectMake(left, top, 225, maxHeight);
        [self.weakParentView addSubview:_clickBgView];
        [self.weakParentView addSubview:_picker];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _items.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 225;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 22.5;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    UILabel *pickerLabel = (UILabel *)view;
    if (!pickerLabel) {
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.backgroundColor = [UIColor clearColor];
        pickerLabel.font = [UIFont systemFontOfSize:10];
        pickerLabel.textColor = [UIColor whiteColor];
        pickerLabel.textAlignment = NSTextAlignmentLeft;
    }
    pickerLabel.text = [[_items objectAtIndex:row] objectForKey:@"title"];
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _txtContent.text = [[_items objectAtIndex:row] objectForKey:@"title"];
    _selectedRow = row;
}

- (NSString *)seletedValue {
    if (_selectedRow == -1) {
        return nil;
    }
    return [[_items objectAtIndex:_selectedRow] objectForKey:@"value"];
}

- (void)setSeletedValue:(NSString *)seletedValue {
    for (NSInteger i = 0; i < _items.count; i++) {
        NSDictionary *item = [_items objectAtIndex:i];
        if ([[item objectForKey:@"value"] isEqualToString:seletedValue]) {
            _selectedRow = i;
            break;
        }
    }
    if (_selectedRow >= 0) {
        [_picker selectRow:_selectedRow inComponent:0 animated:NO];
        _txtContent.text = [[_items objectAtIndex:_selectedRow] objectForKey:@"title"];
    }
}

@end
