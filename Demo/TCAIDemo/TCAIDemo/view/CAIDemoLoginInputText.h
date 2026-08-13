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

// height: 输入框高度；multiline: 是否支持多行输入（用于 AccessInfo 这类长文本）
- (instancetype)initWithFrame:(CGRect)frame name:(NSString *)name oldValue:(NSString*)oldText height:(CGFloat)height multiline:(BOOL)multiline;

- (NSString *)text;

@end

