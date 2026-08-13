//
//  CAIDemoInstanceListVC.h
//  TCAIDemo
//
//  实例列表页：登录成功后展示实例列表，勾选实例后再创建 TcrSession 进入实例操作页。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CAIDemoInstanceListVC : UIViewController

/// @param hostBaseUrl 体验服务器地址前缀，账号模式下用于查询实例列表、申请访问凭证
/// @param token       Token 登录模式下由登录页直接带入；账号模式传 nil
/// @param accessInfo  Token 登录模式下由登录页直接带入；账号模式传 nil
/// @param instanceIds Token 登录模式下从 AccessInfo 解析出的实例 ID；账号模式传 nil
- (instancetype)initWithHostBaseUrl:(NSString *)hostBaseUrl
                              token:(nullable NSString *)token
                         accessInfo:(nullable NSString *)accessInfo
                        instanceIds:(nullable NSArray<NSString *> *)instanceIds;

@end

NS_ASSUME_NONNULL_END
