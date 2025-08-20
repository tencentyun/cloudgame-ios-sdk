//
//  TCGDemoGamePlayVC.h
//  tcgsdk-demo
//
//  Created by LyleYu on 2020/12/11.
//  Copyright © 2021 Tencent. All rights reserved.
//

#ifndef TCGDemoVC_h
#define TCGDemoVC_h

#import <UIKit/UIKit.h>
#import <TCRSDK/TCRSDK.h>

typedef void(^tGameStopBlk)(void);

@interface TCGDemoGamePlayVC : UIViewController
@property(nonatomic, copy) tGameStopBlk gameStopBlk;

- (instancetype)initWithPlay:(TcrSession *)play remoteSession:(NSString *)remoteSession;
- (instancetype)initWithPlay:(TcrSession *)play remoteSession:(NSString *)remoteSession loadingView:(UIView *)loadingView;
- (instancetype)initWithPlay:(TcrSession *)play remoteSession:(NSString *)remoteSession loadingView:(UIView *)loadingView captureWidth:(int)captureWidth captureHeight:(int)captureHeight captureFps:(int)captureFps;
- (instancetype)initWithPlay:(TcrSession *)play experienceCode:(NSDictionary *)params;

@end

#endif /* TCGDemoVC_h */
