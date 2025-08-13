//
//  TCGDemoRaidoButton.h
//  TCGDemo
//
//  Created by LyleYu on 2021/7/9.
//

#import <UIKit/UIKit.h>

@interface TCGDemoRaidoButton : UIView

@property(nonatomic, strong) NSString *seletedValue;

- (instancetype)initWithFrame:(CGRect)frame name:(NSString *)name items:(NSArray<NSString*>*)items;

@end
