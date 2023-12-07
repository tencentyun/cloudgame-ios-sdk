//
//  Keyboard.h
//  TCRSDK
//
//  Created by xxhape on 2023/9/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol Keyboard <NSObject>

/**
 * Trigger a key event of the cloud keyboard.
 *
 * @param keycode The keycode
 * @param down Valid values: `true`: Press; `false`: Release.
 */
- (void)onKeyboard:(NSInteger)keycode down:(BOOL)down;

/**
 * Trigger a key event of the cloud keyboard. Differentiate between the left and right keys of the
 * keyboard.
 *
 * @param keycode The keycode. Please refer to WindowsKeyEvent.h for the definition of key codes.
 * @param down Valid values: `true`: Press; `false`: Release.
 * @param isLeft Used to distinguish between left and right keys of the keyboard: `true`: Left; `false` :
 *         Right.
 */
- (void)onKeyboard:(NSInteger)keycode down:(BOOL)down isLeft:(BOOL)isLeft;

/**
 * Query the capitalization status of the cloud virtual keyboard.
 *
 * @param finishBlk retCode 0 lower，1 upper
 */
- (void)checkKeyboardCapsLock:(void (^)(int retCode))finishBlk;

/**
 * Reset the capitalization status (to lowercase) of the cloud virtual keyboard.
 */
- (void)resetKeyboardCapsLock;

/**
 * Reset the key status of the cloud keyboard.<br>
 * This API is used to release all keys when there are stuck keys on the keyboard.
 */
- (void)resetKeyboard;

@end

NS_ASSUME_NONNULL_END
