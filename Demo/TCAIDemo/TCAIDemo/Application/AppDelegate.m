#import "AppDelegate.h"
#import "LoginVC.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 工程没有 Main.storyboard，window 与 rootViewController 需要自己建。
    // 登录页 -> 实例列表页 -> 功能页 -> 串流页，页面跳转全部交给导航栈。
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:[[LoginVC alloc] init]];
    navVC.navigationBar.hidden = YES;   // 各页面都自带顶部栏与返回按钮

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = navVC;
    [self.window makeKeyAndVisible];

    // 串流过程中不自动锁屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    return YES;
}

@end
