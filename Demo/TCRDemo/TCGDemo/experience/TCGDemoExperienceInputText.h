//
//  TCGDemoExperienceInputText.h
//  TCGDemo
//
//  Created by LyleYu on 2021/6/23.
//

#import <UIKit/UIKit.h>
#import "TCGDemoInputDelegate.h"

@interface TCGDemoExperienceInputText : UIView

@property(nonatomic, weak) id<TCGDemoInputDelegate> inputDelegate;

- (instancetype)initWithFrame:(CGRect)frame name:(NSString *)name oldValue:(NSString*)oldText;

- (NSString *)text;

@end

