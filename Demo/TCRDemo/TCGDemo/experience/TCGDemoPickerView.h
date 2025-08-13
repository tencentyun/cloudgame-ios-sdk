//
//  TCGDemoCheckbox.h
//  TCGDemo
//
//  Created by LyleYu on 2021/7/8.
//

#import <UIKit/UIKit.h>

@interface TCGDemoPickerView : UIView

@property(nonatomic, strong) NSString *seletedValue;

- (instancetype)initWithFrame:(CGRect)frame name:(NSString *)name parent:(UIView *)parentView items:(NSArray<NSDictionary*>*)items;

@end
