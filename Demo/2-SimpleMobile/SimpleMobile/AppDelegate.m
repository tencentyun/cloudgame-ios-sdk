//
//  AppDelegate.m
//  SimpleMobile
//
//  Created by LyleYu on 2021/10/19.
//  Copyright © 2021 yujunlei. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:frame];
    self.window.rootViewController = [[ViewController alloc] init];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    return YES;
}

@end
