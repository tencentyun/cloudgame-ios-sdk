//
//  TCGSdkConst.h
//  Pods
//
//  Created by LyleYu on 2020/12/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

extern const NSString *TCGSDKVersion;

typedef NS_ENUM(NSUInteger, TCGLogLevel){
    TCGLogLevelDebug,
    TCGLogLevelInfo,
    TCGLogLevelWarning,
    TCGLogLevelError,
    TCGLogLevelNone,
};

/*! 单次透传二进制数据的最大字节数 */
static int gTransCustomDataMaxLength = 1200;
/*! 最多同时支持创建的透传通道个数 */
static int gTransCustomDataChannelNum = 3;

typedef NS_ENUM(NSInteger, TCGErrorType) {
    TCG_OK                              = 0,

    /*! 系统繁忙,请稍后重试 **/
    INIT_ERROR_SYS_BUSY                 = 1,
    /*! 票据不合法 **/
    INIT_ERROR_TICKET_ILLEGAL           = 2,
    /*! 我们建议您使用超过10Mbps的带宽以完美体验腾讯云云游戏 **/
    INIT_ERROR_INEFFICIENT_BANDWIDTH    = 3,
    /*! 资源不足,请稍后重试 **/
    INIT_ERROR_UNDER_RESOURCE           = 4,
    /*! 票据失效 **/
    INIT_ERROR_TICKET_EXPIRED           = 5,
    /*! SDP错误信息错误 **/
    INIT_ERROR_INVALID_SPD              = 6,
    /*! 游戏拉起失败 **/
    INIT_ERROR_LAUNCH_GAME_ERROR        = 7,
    /*! 下载用户游戏存档失败 **/
    INIT_ERROR_GET_ARCHIVE_FAILED       = 8,

    /*! 设置远端SDP异常 **/
    CONN_ERROR_SET_REMOTE_SDP_FAILED    = 10000,
    /*! 设置本地SDP异常 **/
    CONN_ERROR_SET_LOCAL_SDP_FAILED     = 10001,
    /*! 节点连接异常 **/
    CONN_ERROR_PEER_CONNECTION_FAILED   = 10002,
    /*! 云API调了stopGame **/
    CONN_ERROR_USER_LOGOUT              = 10003,
    /*! 用户已在其他设备登录 **/
    CONN_ERROR_DUPLICATE_CONNECTION     = 10004,
    /*! 云端主动关闭连接 **/
    CONN_ERROR_REMOTE_CLOSE             = 10008,    // 跟安卓靠齐
    /*! 连接云端超时未出画面 **/
    CONN_ERROR_VIDEO_TIMEOUT            = 10009,

    /*! 连接未断开但帧率为0 **/
    CONN_ERROR_NO_VIDEO_FRAME           = 10020,    // 安卓现在没有相应的错误码，占用
    /*! 云端响应超时*/
    CONN_ERROR_REPLY_TIMEOUT            = 10021,    // 安卓现在没有相应的错误码，占用
    /*! 玩家主动操作退出游戏 */
    CONN_CLOSE_NORMAL                   = 19000,
    /*! 玩家主动操作重新连接游戏 */
    CONN_RECONNECT_BYUSER               = 19001,

    ERROR_UNKNOWN                       = 99999
};

typedef NS_ENUM(NSInteger, TCGMouseCursorShowMode) {
    /*! 客户端自行渲染鼠标 **/
    TCGMouseCursorShowMode_Custom = 0,
    /*! 云端下发鼠标图片，由客户端渲染 **/
    TCGMouseCursorShowMode_Local = 1,
    /*! 云端画面内渲染鼠标图片 **/
    TCGMouseCursorShowMode_Remote = 2
};

typedef NS_ENUM(NSInteger, TCGMouseCursorTouchMode) {
    /*! 鼠标跟随手指移动,点击可以单击按键 */
    TCGMouseCursorTouchMode_AbsoluteTouch= 0,
    /*! 手指滑动控制鼠标相对移动
     * 轻触触发鼠标左键
     * 长按触发按点击鼠标左键, 可以拖动
     * 滑动仅触发鼠标移动
    **/
    TCGMouseCursorTouchMode_RelativeTouch = 1,
    /*! 鼠标在相对位置移动，不触发点击事件 */
    TCGMouseCursorTouchMode_RelativeOnly = 2
};

typedef NS_ENUM(NSInteger, TCGTextFieldType) {
    /*! 鼠标左键点击了一个普通的文本框 */
    TCGTextFieldType_Normal = 0,
    /*! 鼠标左键点击了一个支持自动登录的文本框 */
    TCGTextFieldType_AutoLogin = 1,
    /*! 鼠标左键点击了文本框，但当前状态为禁止用户输入(如后台正在模拟自动登录) */
    TCGTextFieldType_Disable = 99,

    TCGTextFieldType_Unknown = -1
};

typedef enum : NSInteger {
    TCGNetwork_NotReachable = 0,
    TCGNetwork_Wifi = 1,
    TCGNetwork_2G = 2,
    TCGNetwork_3G = 3,
    TCGNetwork_4G = 4,
    TCGNetwork_5G = 5,
    TCGNetwork_Unknown = 9,
} TCGNetworkStatus;

typedef void(^TCGMsgHandleBlk)(NSError *error, NSDictionary *msg);
