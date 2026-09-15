#import "DemoToast.h"
#import "CAIDemoAccessibilityIds.h"

@implementation DemoToast

+ (void)showInViewController:(UIViewController *)viewController message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        // viewIfLoaded 而非 view：视图未加载说明页面从未显示过，此时提示没有意义，
        // 更不该由一条提示把视图强行创建出来。
        [self presentInView:viewController.viewIfLoaded message:message];
    });
}

+ (void)showInView:(UIView *)view message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentInView:view message:message];
    });
}

/// 主线程专用：调用方负责保证已切到主线程
+ (void)presentInView:(UIView *)view message:(NSString *)message {
    if (view == nil) {
        return;
    }

    UILabel *toastLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    toastLabel.text = message;
    toastLabel.accessibilityIdentifier = CAIIdToast;
    toastLabel.textColor = [UIColor whiteColor];
    toastLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    toastLabel.textAlignment = NSTextAlignmentCenter;
    toastLabel.layer.cornerRadius = 8;
    toastLabel.clipsToBounds = YES;
    toastLabel.alpha = 0;

    [toastLabel sizeToFit];
    CGRect frame = toastLabel.frame;
    frame.size.width += 40;
    frame.size.height += 20;
    frame.origin.x = (view.bounds.size.width - frame.size.width) / 2;
    frame.origin.y = view.bounds.size.height - 100;
    toastLabel.frame = frame;

    [view addSubview:toastLabel];

    [UIView animateWithDuration:0.3 animations:^{
        toastLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:2.0 options:0 animations:^{
            toastLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [toastLabel removeFromSuperview];
        }];
    }];
}

@end
