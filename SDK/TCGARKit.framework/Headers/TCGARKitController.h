//
//  TCGARKitController.h
//  tcgsdk
//
//  Created by LyleYu on 2021/8/5.
//

#import <UIKit/UIKit.h>

#define kTCGARKitARFaceEnable 0x01

@class TCGGamePlayer;
@protocol TCGARFaceTrackerDelegate <NSObject>

// 人脸检测状态发生变化
- (void)onFaceDetecteChanged:(BOOL)isDetected;
- (void)onFaceBlendShapes:(NSData *)shapesData;

@end

@interface TCGARKitController : NSObject

- (instancetype)initWithPlayer:(TCGGamePlayer *)weakPlayer;

+ (int64_t)getARKitAbility;

//- (void)setFaceTracerDelegate:(id<TCGARFaceTrackerDelegate>)delegate;

- (UIView *)preview;

- (void)startFaceTracking;
- (void)stopFaceTracking;

@end
