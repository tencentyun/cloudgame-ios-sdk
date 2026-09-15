#import <UIKit/UIKit.h>

@protocol CAIDemoTextFieldDelegate <NSObject>

/// keycode 取 ASCII 值，退格固定为 8
- (void)onClickKey:(int)keycode;

@end

/**
 * 隐形输入框：把系统键盘的输入转成键码，交给云端实例。
 *
 * 为什么要子类化而不是直接用 UITextField：
 * 退格键在输入框为空时**不会**触发 textField:shouldChangeCharactersInRange:，
 * 只能通过重写 deleteBackward 捕获。而本控件恒为空（输入不留存本地，只上行键码），
 * 因此退格必须走 deleteBackward，无法只靠 delegate 实现。
 */
@interface CAIDemoTextField : UITextField

@property(nonatomic, weak) id<CAIDemoTextFieldDelegate> keyCodedelegate;

@end
