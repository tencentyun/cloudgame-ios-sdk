//
//  TCGVKeyGamepad.h
//  tcgsdk
//
//  Created by LyleYu on 2021/9/17.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCGGameController;

@interface TCGVKeyGamepad : UIView

@property(nonatomic, weak) TCGGameController *weakController;

- (instancetype)initWithController:(TCGGameController *)controller;

/*! 创建一个虚拟按键视图
* @param frame 虚拟按键视图的frame
* @param controller tcgsdk句柄
*/
- (instancetype)initWithFrame:(CGRect)frame controller:(TCGGameController *)controller;

/*! 加载虚拟按键布局，生成按键
* @param cfg 布局文件的内容
* @discussion 布局文件跟安卓、JS SDK通用。
*/
- (void)showKeyGamepad:(NSString *)cfg;

/*! 启用当前的按键布局是否需要主动通知云端
* @return 是否需要主动通知云端启用按键布局。
* @discussion 目前游戏手柄类按键(如XBox的手柄按键)在启用前要主动调用SDK的enableVirtualGamepad接口
*/
- (BOOL)needConnected;

@end
