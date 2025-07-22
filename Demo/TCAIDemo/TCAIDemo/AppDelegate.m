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
    self.window.rootViewController = vc;
}

@end
