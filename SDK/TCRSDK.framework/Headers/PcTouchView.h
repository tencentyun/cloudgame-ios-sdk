//
//  PcTouchView.h
//  TCRSDK
//
//  Created by xxhape on 2023/9/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <tcrsdk/TCRSdkConst.h>
@class TcrSession;

// Mouse type, only supports single-finger sliding operation
@interface PcTouchView : UIView
- (instancetype)initWithFrame:(CGRect)frame
                      session:(TcrSession *)session;

/*!
 * Set the mouse control mode
 * @param mode For details, see the definition of TCRMouseCursorTouchMode
 */
- (void)setCursorTouchMode:(TCRMouseCursorTouchMode)mode;

/*!
 * Set whether the mouse is visible
 * @param isShow YES to display, NO to hide
 */
- (void)setCursorIsShow:(BOOL)isShow;

/*!
 * Set the sensitivity when moving the mouse, valid in relative movement mode
 * @param sensitive The default 1.0 is the same as the manual sliding range
 */
- (void)setCursorSensitive:(CGFloat)sensitive;

/*!
 * Set the default mouse icon, valid in local rendering mode
 * @param image cursor pointer icon
 * @param remoteFrame The size and position of the cursor view, in the video source coordinate system
 */
- (void)setCursorImage:(UIImage *)image andRemoteFrame:(CGRect)remoteFrame;

/*!
 * Set the click type that triggers the mouse when clicking. The default triggers left click.
 * @param isLeft YES, triggers the left mouse button; NO, triggers the right mouse button
 */
- (void)setClickTypeIsLeft:(BOOL)isLeft;

/*!
 * Move the mouse pointer through the interface (valid in local rendering mode)
 * @param diffX On the X-axis of the current mouse view, the mouse pointer moves diffX points.
 * @param diffY On the Y axis of the current mouse view, the mouse pointer moves diffY points.
*/
- (void)moveCursorWithDiffX:(CGFloat)diffX diffY:(CGFloat)diffY;

@end

