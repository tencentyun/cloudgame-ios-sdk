#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 实例列表页：展示可用实例，勾选后初始化 SDK 凭证并进入功能页
@interface InstanceListVC : UIViewController

/// @param token       Token 登录模式下由登录页直接带入；账号模式传 nil
/// @param accessInfo  Token 登录模式下由登录页直接带入；账号模式传 nil
/// @param instanceIds Token 登录模式下从 AccessInfo 解析出的实例 ID；账号模式传 nil
- (instancetype)initWithToken:(nullable NSString *)token
                   accessInfo:(nullable NSString *)accessInfo
                  instanceIds:(nullable NSArray<NSString *> *)instanceIds;

@end

NS_ASSUME_NONNULL_END
