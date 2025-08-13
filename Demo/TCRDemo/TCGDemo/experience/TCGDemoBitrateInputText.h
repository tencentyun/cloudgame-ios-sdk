//
//  TCGDemoBitrateInputText.h
//  TCGDemo
//
//  Created by LyleYu on 2021/7/7.
//

#import <UIKit/UIKit.h>
#import "TCGDemoInputDelegate.h"

@interface TCGDemoBitrateInputText : UIView

@property(nonatomic, weak) id<TCGDemoInputDelegate> inputDelegate;

- (instancetype)initWithFrame:(CGRect)frame name:(NSString *)name min:(NSNumber *)min max:(NSNumber *)max;

- (int)minBitrate;

- (int)maxBitrate;

@end
