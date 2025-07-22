//
//  CAIDemoSettingView.h
//  CAIDemo
//
//  Created by LyleYu on 2020/12/30.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TCRSDK/Keyboard.h>

typedef NS_ENUM(NSInteger, TcrKeyboardCode) {
  KEY_BACK           = 158,   // 返回键
  KEY_MENU           = 139,   // 菜单键
  KEY_HOME           = 172,   // Home 键
  KEYCODE_VOLUME_UP  = 58,    // 音量加
  KEYCODE_VOLUME_DOWN= 59,    // 音量减
};

@protocol CAIDemoSettingViewDelegate <NSObject>

- (void)pasteText;
- (void)restartCloudApp;
- (void)modifyRES;

- (void)onSetVolume:(CGFloat)volume;
- (void)onSetBitrateLevel:(int)level;
- (void)onEnableLocalAudio:(BOOL)enable;
- (void)onEnableLocalVideo:(BOOL)enable;
- (void)onSwitchCamera:(BOOL)isFrontCamera;
- (void)pauseResumeControl:(BOOL)doPause;

- (void)onCreateDataChannel;
- (void)onDataChannelSend;

- (void)openKeyboard:(BOOL)isOpen;
- (void)openGamepad:(BOOL)isOpen;
- (void)editGamepad;
- (void)onSetCursorTouchMode:(int)mode;
- (void)onSetCursorSensitive:(CGFloat)sensitive;
- (void)onSetCursorClickType:(BOOL)isLeft;
- (void)clearAllKeys;
- (void)checkCapsLock;
- (void)stopControl;
- (void)onRotateView;
- (void)openTouchView:(BOOL)isOpen;
- (void)enableCoreMotion:(BOOL)enable;

- (void)onKeyboard:(int)keycode;

@end

@interface CAIDemoSettingView : UIView

@property(nonatomic, weak) id<CAIDemoSettingViewDelegate> delegate;

- (void)setAllDebugInfo:(NSDictionary *)allInfo;

@end

