#import "ExpServerRequest.h"

// 体验服务器（测试环境），路径前缀 /external 与 Android 端 ExpServerRequest 对齐
static NSString *const kHostBaseUrl = @"https://test-cai-experience-server.crtrcloud.com/external";

static NSString *const kErrorDomain = @"ExpServerRequest";

// 登录成功后由服务端下发的鉴权 Cookie，后续请求需带上
static NSString *sCookie = nil;

@implementation ExpServerRequest

+ (void)postPath:(NSString *)path
          params:(NSDictionary *)params
      completion:(void (^)(NSDictionary *response, NSError *error))completion {
    NSString *url = [kHostBaseUrl stringByAppendingString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // 以下两个请求头是本 Demo 所用体验服务器的鉴权要求，并非 TcrSdk 的要求
    [request addValue:@"ap-shenzhen" forHTTPHeaderField:@"Request-Host"];
    [request addValue:@"https://mouhong.test-cai-experience.crtrcloud.com" forHTTPHeaderField:@"Origin"];
    if (sCookie.length > 0) {
        [request addValue:sCookie forHTTPHeaderField:@"Cookie"];
    }

    NSError *encodeError = nil;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:&encodeError];
    if (request.HTTPBody == nil) {
        completion(nil, encodeError ?: [self errorWithMessage:@"请求参数无法序列化"]);
        return;
    }

    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            completion(nil, error);
            return;
        }
        // 保存服务端下发的 Set-Cookie，供后续请求鉴权使用
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSString *setCookie = ((NSHTTPURLResponse *)response).allHeaderFields[@"Set-Cookie"];
            if (setCookie.length > 0) {
                sCookie = setCookie;
            }
        }

        id json = data != nil ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
        if (![json isKindOfClass:[NSDictionary class]]) {
            // 打印原始响应，便于排查非 JSON 响应（如网关错误页）
            NSLog(@"[ExpServer] %@ 返回非 JSON: %@", path, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            completion(nil, [self errorWithMessage:@"响应格式错误"]);
            return;
        }

        // 云 API 响应统一包一层 Response，业务错误放在 Response.Error 里
        NSDictionary *result = json[@"Response"];
        if (![result isKindOfClass:[NSDictionary class]]) {
            NSLog(@"[ExpServer] %@ 缺少 Response 字段: %@", path, json);
            completion(nil, [self errorWithMessage:@"响应格式错误"]);
            return;
        }
        NSDictionary *serverError = result[@"Error"];
        if (serverError != nil) {
            NSLog(@"[ExpServer] %@ 业务失败: %@", path, serverError);
            completion(nil, [self errorWithMessage:serverError[@"Message"] ?: @"服务端返回错误"]);
            return;
        }
        completion(result, nil);
    }] resume];
}

+ (NSError *)errorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:kErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : message}];
}

@end
