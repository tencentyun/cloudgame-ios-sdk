//
//  abc.h
//  TCRSDK
//
//  Created by xxhape on 2024/11/28.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SensorType) {
    // 加速度计
    ACCELEROMETER = 0,
    // 陀螺仪
    GYRO = 1
};


@protocol MotionSensor <NSObject>

/**
* Called when there is a change in the sensor data.
*
* This method is triggered whenever the sensor detects a change in its readings.
* The method processes the incoming sensor event and determines the type of sensor
* that generated the event. Currently, it supports accelerometer and gyroscope sensors.
*     
*/
- (void)onSensorData:(SensorType)key x:(double)x y:(double)y z:(double)z;

@end

NS_ASSUME_NONNULL_END
