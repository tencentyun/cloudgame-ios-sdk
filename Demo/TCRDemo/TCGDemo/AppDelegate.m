//
//  AppDelegate.m
//  TCGDemo
//
//  Created by LyleYu on 2020/12/17.
//

#import "AppDelegate.h"
#import <TCRSDK/TCRSDK.h>

#define Experience
#ifdef Experience
#import "TCGDemoExperienceVC.h"
#else
#import "TCGDemoGameListVC.h"
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [self normalGameTest];

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAll;
}

- (void)normalGameTest {
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:frame];
#ifdef Experience
    TCGDemoExperienceVC *vc = [[TCGDemoExperienceVC alloc] init];
#else
    TCGDemoGameListVC *vc = [[TCGDemoGameListVC alloc] init];
#endif
    self.window.rootViewController = vc;
}

@end
