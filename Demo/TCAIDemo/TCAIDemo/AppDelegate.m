//
//  AppDelegate.m
//  CAIDemo
//
//  Created by LyleYu on 2020/12/17.
//

#import "AppDelegate.h"
#import <TCRSDK/TCRSDK.h>

#import "CAIDemoLoginVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [self normalTest];

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAll;
}

- (void)normalTest {
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:frame];
    CAIDemoLoginVC *vc = [[CAIDemoLoginVC alloc] init];
    // 登录页 -> 实例列表页 -> 实例操作页，使用导航栈管理跳转
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.navigationBar.hidden = YES;
    self.window.rootViewController = navVC;
    [self.window makeKeyAndVisible];
}

@end
