//
//  TCGDemoSettingView.h
//  TCGDemo
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

@protocol TCGDemoSettingViewDelegate <NSObject>

- (void)pasteText;
- (void)restartGame;
- (void)modifyRES;

- (void)onSetVolume:(CGFloat)volume;
- (void)onSetBitrateLevel:(int)level;
- (void)onEnableLocalAudio:(BOOL)enable;
- (void)onEnableLocalVideo:(BOOL)enable;
- (void)onSwitchCamera:(BOOL)isFrontCamera;
- (void)pauseResumeGame:(BOOL)doPause;

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
- (void)stopGame;
- (void)onRotateView;
- (void)openTouchView:(BOOL)isOpen;
- (void)enableCoreMotion:(BOOL)enable;

- (void)onKeyboard:(int)keycode;
- (void)onStartProxy;
- (void)onStopProxy;

@end

@interface TCGDemoSettingView : UIView

@property(nonatomic, weak) id<TCGDemoSettingViewDelegate> delegate;

- (void)setAllDebugInfo:(NSDictionary *)allInfo;

@end

