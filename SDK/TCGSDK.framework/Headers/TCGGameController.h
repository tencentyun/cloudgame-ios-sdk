//
//  TCGGameController.h
//  TCGSDK
//
//  Created by LyleYu on 2020/12/27.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <tcgsdk/TCGGamePlayer.h>

@class TCGVirtualMouseCursor;

typedef void(^tBoolFinishBlk)(BOOL isCapsLock, NSError *error);

@protocol TCGGameControllerDelegate <NSObject>

@optional
/*!
 * 鼠标本地绘制模式下，云端实时下发鼠标游标的图片
 * @param image 游标指针的图片
 * @param imageFrame 游标的位置。视频源的坐标系，本地应用时注意换算
 */
- (void)onCursorImageUpdated:(UIImage *)image frame:(CGRect)imageFrame;

/*!
 * 云端鼠标显示状态变化
 * @param isVisble YES 当前鼠标可见，NO 不可见
 */
- (void)onCursorVisibleChanged:(BOOL)isVisble;

/*!
 * 鼠标左键点中了文本输入框
 * @param type 当前文本框的类型或状态
 */
- (void)onClickedTextField:(TCGTextFieldType)type;

/*!
 * 云端是否禁止客户端的输入
 * @discussion 如云端在尝试自动登陆账号时，会忽略客户端的输入。
 * @param isEnable YES:允许客户端输入, NO:忽略客户端的输入消息
 */
- (void)onRemoteInputStatus:(BOOL)isEnable;

/*!
* 云端执行自动登录任务结束(并不识别账号与密码的正确性)
* @discussion 云端在尝试自动登陆时，会忽略客户端的输入。
* @param status 0:模拟输入动作执行成功，并不代表账号与密码正确。
             -1:模拟输入动作执行失败，只是输入动作执行失败。
*/
-(void)onAutoLoginFinish:(int)status;

@end

/*! TCGGamePlayer的封装类，通过gamePlayer.controller获取实例
 *  为云游的操控提供便捷的接口与回调,
 */
@interface TCGGameController : NSObject

@property(nonatomic, weak) TCGGamePlayer *weakPlayer;
@property(nonatomic, weak) id<TCGGameControllerDelegate> controlDelegate;

/*!
 * 清空云端的按键，清除异常卡键的状态。
 */
- (void)resetRemoteKeycode;

/*!
 * 发送键盘按键消息到云端
 * @param keycode 按键码
 * @param isDown YES 发送按下的消息，NO 发送抬起的消息
 */
- (void)clickKeyboard:(int)keycode isDown:(BOOL)isDown;

/*!
 * 通知云端启用游戏手柄
 * @param enable YES 发送启用的消息，NO 发送禁用的消息
 * @discussion 需要等onVideoShow回调被触发了，与云端的消息传输通道已创建后，调用才能生效
 */
- (void)enableVirtualGamepad:(BOOL)enable;

/*!
 * 发送游戏手柄按键消息到云端
 * @param keycode 按键码
 * @param isDown YES 发送按下的消息，NO 发送抬起的消息
 */
- (void)clickGamepadKey:(int)keycode isDown:(BOOL)isDown;

/*!
 * 转动游戏手柄的(左/右)摇杆
 * @param deltaX  范围[-1, 1]，最左端为-1 最右端为 1
 * @param deltaY  范围[-1, 1]，最下方为-1 最上方为 1
 * @param isLeft   YES:转动左摇杆， NO:转动右摇杆
 */
- (void)turnJoyStickX:(CGFloat)deltaX y:(CGFloat)deltaY isLeft:(BOOL)isLeft;

/*!
 * 设置鼠标渲染的模式
 * @param mode ，推荐使用本地渲染模式(TCGMouseCursorShowMode_Local)
 */
- (void)setCursorShowMode:(TCGMouseCursorShowMode)mode;

/*!
 * 发送鼠标移动后的绝对坐标消息到云端
 * @param x 绝对坐标值(视频源尺寸范围内)
 * @param y 绝对坐标值(视频源尺寸范围内)
 */
- (void)mouseMoveToX:(CGFloat)x y:(CGFloat)y;

/*!
 * 发送鼠标移动的相对变化值到云端
 * @param diffX 坐标变化值
 * @param diffY 坐标变化值
 */
- (void)mouseDeltaMoveX:(CGFloat)diffX y:(CGFloat)diffY;

/*!
 * 发送鼠标的左右按键消息到云端
 * @param isLeft YES 发送左键消息，NO 发送右键消息
 * @param isDown YES 发送按下的消息，NO 发送抬起的消息
 */
- (void)clickMouseIsLeft:(BOOL)isLeft isDown:(BOOL)isDown;

/*!
 * 发送鼠标滚轮滚动的消息到云端
 * @param delta 滚动变化值
 */
- (void)mouseScroll:(CGFloat)delta;

/*!
 * 发送鼠标中键点击的消息到云端
 * @param isDown YES 发送按下的消息，NO 发送抬起的消息
 */
- (void)clickMouseMiddleKey:(BOOL)isDown;

/*!
 * 按键消息的底层接口，（支持发送消息队列，队列存放json格式的字符串）
 * @param touchMessage 按键消息
 */
- (void)sendKeycodeMessage:(NSDictionary *)touchMessage;

/*!
 * 异步查询云端大小写状态
 * @param finishBlk 异常回调，retCode 查询的结果，0 小写，1 大写， -1 查询超时， -2 查询出错
 */
- (void)asyncCheckRemoteCapsLock:(void(^)(int retCode))finishBlk;

/*!
 * 将文本内容复制到当前选中的文本框内
 * @param text 想复制的文本内容
 * @param finishBlk 消息发送的结果：0 云端接收到消息，-1 消息传输失败， -2 消息传输超时
 * @discussion 回调返回0，仅表示云端接收到文本内容，输入成功与否取决于当前文本框是否支持复制操作，接口本身无法感知。
 */
- (void)asyncPasteText:(NSString *)text intoTextFieldWithBlk:(void(^)(int retCode))finishBlk;

/*!
* 云端自动登录(模拟输入账号与密码)
*  @param username 用户名
*  @param passwd 密码
*  @param finishBlk 执行结果回调，retCode: 0 开始自动登录，
                                 -1 当前游戏不支持，
                                 -2 当前窗口不支持，
                                 -3 上一次自动登录未结束，
                                 -4 云端内部错误。
                                 -9 云端响应超时，
                                 -10 参数错误
* @discussion 接口回调返回0表明云端开始模拟输入信息，这个过程耗时较长(但超过10秒会触发超时逻辑)，在此期间客户端的控制消息会被云端忽略掉。
         模拟输入动作执行结束后，通过代理onAutoLoginFinish通知执行情况。
*/
- (void)asyncAutoLogin:(NSString *)username passwd:(NSString *)passwd finishBlk:(void(^)(int retCode))finishBlk;

/*!
* 取消当前自动登录操作
*/
- (void)cancleAutoLogin;

/*!
* (手游) 触发云端的返回动作(触发安卓的物理返回键)
*/
- (void)remoteMobileBackClick;
@end
