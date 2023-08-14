//
//  TCGMultiPlayer.h
//  TCGSDK
//
//  Created by xxhape on 2023/8/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TCGGamePlayer;

@protocol TCGMultiPlayerDelegate <NSObject>

/*!
* 当非房主申请切换席位时，房主会触发此回调，以此决定是否同意切换席位
* @param userId 申请切换席位/角色的用户ID
* @param role 申请变更成此角色(viewer, player)
* @param seatIndex 申请变更到此席位
*/
- (void)onSeatApplied:(NSString *)userId role:(NSString *)role seatIndex:(int)seatIndex;

/*!
* 当前房间玩家的所有信息变化，都会触发此回调
* @param roomInfo 房间信息
*/
- (void)onRoomInfoChange:(NSDictionary *)roomInfo;

@end

@interface TCGMultiPlayer : NSObject

@property(nonatomic, weak) TCGGamePlayer *weakPlayer;
@property(nonatomic, weak) id<TCGMultiPlayerDelegate> delegate;

- (instancetype)initWithPlayer:(TCGGamePlayer *)weakPlayer delegate:(id<TCGMultiPlayerDelegate>)delegate;

/*!
* (非房主)申请切换席位或者角色权限(观众/玩家)
*  @param userId 用户ID
*  @param role 角色
*  @param seatIndex 席位数
*  @param finishBlk 执行结果回调，retCode: 0 申请成功(只说明房主收到申请，不表示房主同意了申请)，
                                 -1 席位ID无效，
                                 -2 无当前操作的权限，
                                 -3 角色role无效，
                                 -4 无当前userId。
                                 -9 云端响应超时，
                                 -10 参数错误
*/
- (void)applySwitchUserId:(NSString *)userId toRole:(NSString *)role seatIndex:(int)seatIndex blk:(void(^)(int retCode))finishBlk;

/*!
* (房主)切换席位或者角色权限
*  @param userId 用户ID
*  @param role 角色
*  @param seatIndex 席位数
*  @param finishBlk 执行结果回调，retCode: 0 切换成功，
                                 -1 席位ID无效，
                                 -2 无当前操作的权限，
                                 -3 角色role无效，
                                 -4 无当前userId，
                                 -5 切换失败(内部错误)，
                                 -9 云端响应超时，
                                 -10 参数错误
*/
- (void)changeSwitchUserId:(NSString *)userId toRole:(NSString *)role seatIndex:(int)seatIndex blk:(void(^)(int retCode))finishBlk;

- (BOOL)micMute;
- (void)setMicMute:(BOOL)mute;

/*!
* 申请同步房间信息，通过onRoomInfoChange:回调返回结果
*/
- (void)getRoomInfo;

@end
