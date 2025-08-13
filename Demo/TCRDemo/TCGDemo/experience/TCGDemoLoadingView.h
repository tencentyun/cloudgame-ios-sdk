//
//  TCGDemoLoadingView.h
//  TCGDemo
//
//  Created by LyleYu on 2021/7/14.
//

#import <UIKit/UIKit.h>

@interface TCGDemoLoadingView : UIView
@property (nonatomic, assign) int processValue;

- (instancetype)initWithFrame:(CGRect)frame process:(int)process;

@end
