#import <UIKit/UIKit.h>
#import <TCRSDK/TCRSDK.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 串流页：串流会话的创建者与唯一持有者。
 *
 * 会话在本页进入时创建、出栈时销毁。上级页面只负责传入实例 ID，不接触 TcrSession，
 * 这样用户在功能页浏览时不会建立串流连接。
 *
 * 本页需 push 进导航栈使用：会话销毁绑定在出栈这一时机上，
 * 用返回按钮、「结束控制」还是异常关闭退出都会走到同一条清理路径。
 */
@interface StreamingVC : UIViewController

/// @param masterId 主控实例 ID
/// @param slaveIds 被控实例 ID；为空则只连接主控实例，非空时建立群控连接并同步操作
- (instancetype)initWithMasterId:(NSString *)masterId
                        slaveIds:(nullable NSArray<NSString *> *)slaveIds;

@end

NS_ASSUME_NONNULL_END
