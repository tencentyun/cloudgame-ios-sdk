#import <UIKit/UIKit.h>
#import <TCRSDK/TCRSDK.h>

#import "CAICloudPhoneCell.h"

/**
 * 实例功能页（群控入口）。
 *
 * 本页不创建也不依赖会话：实例画面通过 HTTP 截图接口轮询获取，实例操作走批量 HTTP 接口，
 * 因此浏览期间不会建立串流连接。点击「设为主控」后进入串流页，由串流页建立并持有连接。
 *
 * 本页需 push 进导航栈使用：截图轮询的启停绑定在页面可见性上，
 * 进入串流页时自动暂停，返回时自动恢复。
 */
@interface InstanceControlVC: UIViewController
- (instancetype)initWithInstanceIds:(NSArray<NSString *> *)instanceIds;
@end
