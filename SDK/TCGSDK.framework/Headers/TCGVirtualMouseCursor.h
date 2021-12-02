//
//  TCGVirtualMouseCursor.h
//  tcgsdk
//
//  Created by LyleYu on 2020/12/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TCGGameController;

// 鼠标类，只支持单指滑动操作
@interface TCGVirtualMouseCursor : UIView
- (instancetype)initWithFrame:(CGRect)frame
                   controller:(TCGGameController *)controller;

/*!
 * 设置视频源尺寸大小，用于换算坐标值(版本1.1.1 废弃)
 * @param videoSize 云端视频编码输出的尺寸
 */
- (void)setVideoSize:(CGSize)videoSize DEPRECATED_MSG_ATTRIBUTE();

/*!
 * 设置鼠标的操控模式
 * @param mode 详情见TCGMouseCursorTouchMode的定义
 */
- (void)setCursorTouchMode:(TCGMouseCursorTouchMode)mode;

/*!
 * 设置鼠标是否可见
 * @param isShow YES 显示，NO 隐藏
 */
- (void)setCursorIsShow:(BOOL)isShow;

/*!
 * 设置鼠标移动时的灵敏度，在相对移动模式下有效
 * @param sensitive 默认1.0与手动滑动的幅度相同
 */
- (void)setCursorSensitive:(CGFloat)sensitive;

/*!
 * 设置鼠标的默认图标，在本地渲染模式 下有效
 * @param image 游标指针图标
 * @param remoteFrame 游标view的大小位置，视频源坐标系中
 */
- (void)setCursorImage:(UIImage *)image andRemoteFrame:(CGRect)remoteFrame;

/*!
 * 设置点击时触发鼠标的点击类型，默认触发左键点击
 * @param isLeft YES，触发鼠标左键；NO，触发鼠标右键
 */
- (void)setClickTypeIsLeft:(BOOL)isLeft;

/*!
* 以接口的方式移动鼠标指针(本地渲染模式下有效)
* @param diffX 在当前鼠标视图的X轴上，鼠标指针移动diffX个point.
* @param diffY 在当前鼠标视图的Y轴上，鼠标指针移动diffY个point.
*/
- (void)moveCursorWithDiffX:(CGFloat)diffX diffY:(CGFloat)diffY;

@end
