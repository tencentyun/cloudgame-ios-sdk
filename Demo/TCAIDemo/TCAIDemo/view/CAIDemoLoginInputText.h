//
//  CAIDemoExperienceInputText.h
//  CAIDemo
//
//  Created by LyleYu on 2021/6/23.
//

#import <UIKit/UIKit.h>

@protocol CAIDemoInputDelegate <NSObject>

- (void)onBeginEditing:(UIView *)view;

@end

@interface CAIDemoLoginInputText : UIView

@property(nonatomic, weak) id<CAIDemoInputDelegate> inputDelegate;

- (instancetype)initWithFrame:(CGRect)frame name:(NSString *)name oldValue:(NSString*)oldText;

- (NSString *)text;

@end

