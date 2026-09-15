#import <UIKit/UIKit.h>
#import <TCRSDK/TCRSDK.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 云手机实例操作菜单：以浮层形式列出 AndroidInstance 的各项接口。
 *
 * 每一项的 handler 即该接口的完整调用示例：构造参数 → 调用 AndroidInstance → 处理结果。
 * 这里所有接口都是纯 HTTP 调用，只依赖 setAccessToken 传入的凭证，不需要 TcrSession；
 * 需要会话数据通道的接口（设为主控、群控同步等）在串流页 StreamingVC 中演示。
 */
@interface InstanceApiMenuView : UIView

/// @param androidInstance 实例操作入口
/// @param instanceIds     接口下发的目标实例
- (instancetype)initWithAndroidInstance:(AndroidInstance *)androidInstance
                            instanceIds:(NSArray<NSString *> *)instanceIds;

/// 以浮层形式显示在 view 上，点击空白处关闭
- (void)showInView:(UIView *)view;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
