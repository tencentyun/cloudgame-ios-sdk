//
//  TouchScreen.h
//  TCRSDK
//
//  Created by xxhape on 2023/9/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TouchScreen <NSObject>

/**
 * Trigger the touch event of the cloud touch screen.
 *
 * <p>If you have rendered streaming video on the local view and want to obtain the parameters of the touch event
 * that triggers the cloud touch screen from the touch event of the local view, then you may need to perform some
 * coordinate system conversion, and convert the coordinates of the touch point on the local view to a coordinate
 * value on the streaming video. The coordinate system of the streaming video is based on the upper left corner of
 * the streaming video as the origin, the x-axis is rightward, and the y-axis is downward. For example, the
 * streaming video shown in the figure below is centered and rendered on the local view, and the touch point
 * coordinates (a, b) of the local view need to be converted to coordinates (x, y) in the streaming video coordinate
 * system.</p>
 *
 * @param x The coordinate value x of the touch point on the streaming video coordinate system.
 * @param y The coordinate value y of the touch point on the streaming video coordinate system.
 * @param eventType 0 for press, 1 for move, 2 for lift.
 * @param fingerID The pointer identifier associated with a particular pointer data index in this event. The
 *         identifier tells you the actual pointer number associated with the data, accounting for individual
 *         pointers going up and down since the start of the current gesture.
 * @param width The width of the streaming video.
 * @param height The height of the streaming video.
 * @param timestamp The time this event occurred
 */
- (void)touchWithX:(NSNumber *)x
                 y:(NSNumber *)y
         eventType:(int)eventType
          fingerID:(int)fingerID
             width:(int)width
            height:(int)height
         timestamp:(long)timestamp;

@end

NS_ASSUME_NONNULL_END
