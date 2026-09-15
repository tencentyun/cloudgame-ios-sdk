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
- (void)distributeApp;

- (void)onSetVolume:(CGFloat)volume;
- (void)onSetBitrateLevel:(int)level;
- (void)onEnableLocalAudio:(BOOL)enable;
- (void)onEnableLocalVideo:(BOOL)enable;
- (void)onSwitchCamera:(BOOL)isFrontCamera;
- (void)pauseResumeControl:(BOOL)doPause;

- (void)onCreateDataChannel;
- (void)onDataChannelSend;

- (void)openKeyboard:(BOOL)isOpen;
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

/// 串流页设置面板：把 SDK 各项能力铺成按钮，操作经 delegate 回调给串流页
@interface CAIDemoSettingView : UIView

@property(nonatomic, weak) id<CAIDemoSettingViewDelegate> delegate;

- (void)setAllDebugInfo:(NSDictionary *)allInfo;

@end
