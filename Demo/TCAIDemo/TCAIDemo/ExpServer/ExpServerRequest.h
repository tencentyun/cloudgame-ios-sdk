#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 体验服务器请求（Demo 脚手架，与 TcrSdk 无关）。
 *
 * 本 Demo 用它登录、查询实例、申请 Token/AccessInfo。实际接入时应替换为
 * 向自己的业务后台发请求：云 API 密钥只能放在后台，由后台下发凭证给客户端。
 */
@interface ExpServerRequest : NSObject

/**
 * POST 一个 JSON 请求，并取出响应里的 Response 字段。
 *
 * @param path       接口路径，如 @"/Login"
 * @param params     JSON 请求体
 * @param completion 成功时 response 为已解包的 Response 内容，失败时 error 非空。
 *                   回调在子线程，操作 UI 需自行切回主线程。
 */
+ (void)postPath:(NSString *)path
          params:(NSDictionary *)params
      completion:(void (^)(NSDictionary *_Nullable response, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
