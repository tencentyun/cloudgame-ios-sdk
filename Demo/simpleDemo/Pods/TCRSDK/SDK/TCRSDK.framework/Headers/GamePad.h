//
//  GamePad.h
//  TCRSDK
//
//  Created by xxhape on 2023/9/22.
//  Copyright © 2023 Tencent. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, KeyType) {
    LS,
    RS,
    LT,
    RT
};

@protocol Gamepad <NSObject>

/**
 * Trigger the cloud machine to insert the virtual Gamepad.
 */
- (void)connectGamepad;

/**
 * Trigger the cloud machine to pull out the virtual Gamepad.
 */
- (void)disconnectGamepad;

/**
 * Trigger a key event of the cloud Gamepad.
 *
 * @param keycode The keycode. Please refer to WindowsKeyEvent.h for the definition of key codes.
 * @param down true if the button is pressed, false if the button is released.
 */
- (void)onGamepadKey:(NSInteger)keycode down:(BOOL)down;

/**
 * Trigger a stick event of the cloud Gamepad.
 *
 * @param type The stick type. See KeyTypeLS, KeyTypeRS in this file.
 * @param x The X coordinate of the stick
 * @param y The Y coordinate of the stick
 */
- (void)onGamepadStick:(KeyType)type x:(NSInteger)x y:(NSInteger)y;

/**
 * Trigger a trigger event of the cloud Gamepad.
 *
 * @param type The trigger type. See KeyTypeLT, KeyTypeRT in this file.
 * @param value The absolute position of the trigger control. The value is normalized to a range from 0
 *         (released) to 255 (fully pressed).
 * @param down true if the trigger is pressed, false if the trigger is released.
 */
- (void)onGamepadTrigger:(KeyType)type value:(NSInteger)value down:(BOOL)down;

@end

NS_ASSUME_NONNULL_END
