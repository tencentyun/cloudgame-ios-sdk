#import <UIKit/UIKit.h>

/// 轻量提示：在视图底部浮出一行文字，2 秒后自动消失
@interface DemoToast : NSObject

/**
 * 在指定控制器的视图上提示，可在任意线程调用（SDK 回调与网络回调都不保证在主线程）。
 *
 * 控制器的 view 在内部切到主线程后才读取，因此调用方不必自己 dispatch。
 * 在控制器里提示一律用这个方法，不要用 showInView: 传 self.view —— 参数会在调用线程求值，
 * 而 UIViewController.view 属于 UI API，在后台线程读取会触发 Main Thread Checker 告警。
 */
+ (void)showInViewController:(UIViewController *)viewController message:(NSString *)message;

/// 在已持有的视图上提示，可在任意线程调用。持有 UIView 的非控制器对象（如自定义浮层）用这个
+ (void)showInView:(UIView *)view message:(NSString *)message;

@end
