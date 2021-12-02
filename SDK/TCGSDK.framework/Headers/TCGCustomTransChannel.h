//
//  TCGCustomTransChannel.h
//  tcgsdk
//
//  Created by LyleYu on 2021/3/11.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TCGCustomTransChannelDelegate <NSObject>
/*!
 * 与后台连接成功
 * @param remotePort 云端程序监听的UDP端口号
 */
- (void)onConnSuccessAtRemotePort:(int)remotePort;

/*!
 * 与后台连接失败
 * @param error 连接失败的原因，code：-1云端连接程序失败，10009 连接处理超时，
 * @param remotePort 云端程序监听的UDP端口号
 */
- (void)onConnFailed:(NSError *)error atRemotePort:(int)remotePort;

/*!
 * 云端主动关闭了通道
 * @param remotePort 云端程序监听的UDP端口号
 */
- (void)onClosedAtRemotePort:(int)remotePort;;

/*!
 * 接收来自云端程序的数据
 * @param data 云端发过来的数据
 * @param remotePort 云端程序监听的UDP端口号
 */
- (void)onReceiveData:(NSData *)data fromRemotePort:(int)remotePort;
@end


@interface TCGCustomTransChannel : NSObject

@property(nonatomic, weak) id<TCGCustomTransChannelDelegate> delegate;
@property(nonatomic, copy, readonly) NSString *channelLabel;
@property(nonatomic, assign, readonly) int remoteUdpPort;

/*!
 * 向云端程序发送二进制数据
 * @discussion 一次最多能发送1200bytes的数据
 * @return 发送状态。0发送成功，-1 数据超过长度， -2 当前通道未连接成功
 */
- (int)sendData:(NSData *)data;

/*!
 * 关闭通道
 */
- (void)close;

@end
