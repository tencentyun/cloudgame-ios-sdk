//
//  Mouse.h
//  TCRSDK
//
//  Created by xxhape on 2023/9/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TCRSDK/TCRSdkConst.h>

NS_ASSUME_NONNULL_BEGIN

@protocol Mouse <NSObject>
/**
 * Trigger a click event of the cloud mouse.
 *
 * @param key The mouse button. Valid values: `left`: The left button; `middle`: The scroll wheel; `right`:
 *         The right button; `forward`: The forward side button; `backward`: The back side button.
 * @param down Valid values: `true`: Press; `false`: Release.
 */
- (void)onMouseKey:(TCRMouseKeyType)key isDown:(BOOL)down;

/**
 * Rotate the scroll wheel of the cloud mouse.
 *
 * @param delta Valid values: -1.0~1.0
 */
- (void)onMouseScroll:(float)delta;

/**
 * According to the offset pixel amount [localDeltaX, localDeltaY] of the local mouse movement,
 * calculate the relative movement pixel amount [DeltaX, DeltaY] of the remote movement. <br>
 *
 * @param deltaX The offset on the horizontal axis by which the cursor needs to move in remote device
 * @param deltaY The offset on the vertical axis by which the cursor needs to move in remote device
 */
- (void)onMouseDeltaMove:(int)deltaX deltaY:(int)deltaY;
/**
 * After you get the coordinates of the local View, you need to convert the coordinates to the coordinates of the
 * remote end before calling this method.Before calculation, you need to get the width and height of the gameView
 * [localViewWidth, localViewHeight] and the position of the click position in the game screen [localX, localY].
 * Then calculate the coordinates through the following sample code to get [remoteX,remoteY].<br>
 * Finally, call the interface to send the mouse movement event.<br>
 *
 * @param x The X coordinate on the remote device
 * @param y The Y coordinate on the remote device
 */
- (void)onMouseMoveTo:(int)x y:(int)y;
@end

NS_ASSUME_NONNULL_END
