//
//  TCRSdkConst.h
//  TCRSDK
//
//  Created by xxhape on 2023/9/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

extern const NSString *TCRSDKVersion;

typedef NS_ENUM(NSUInteger, TCRLogLevel) {
    TCRLogLevelDebug,
    TCRLogLevelInfo,
    TCRLogLevelWarning,
    TCRLogLevelError,
    TCRLogLevelNone,
};

/*! 单次透传二进制数据的最大字节数 */
static int gTransCustomDataMaxLength = 1200;
/*! 最多同时支持创建的透传通道个数 */
static int gTransCustomDataChannelNum = 3;

typedef NS_ENUM(NSInteger, TcrCode) {
    /*! This indicates that the result is success.  **/
    Success = 0,
    /*! This indicates that the request is timed out. **/
    ErrTimeout = 100010,
    /*! This indicates that the request parameter is invalid.  **/
    ErrInvalidParams = 100011,
    /*! This indicates that some unknown error has happened. **/
    ErrUnknown = 100012,
    /*! This indicates that some internal error has happened. **/
    ErrInternalError = 100013,
    /*! This indicates that the context state is illegal.  **/
    ErrStateIllegal = 100014,
    /*! The starting error code of the multi-player module. **/
    ErrMultiPlayerBaseCode = 101000,
    /*! An invalid seat **/
    MultiPlayerInvalidSeatIndex = ErrMultiPlayerBaseCode + 1,
    /*! The viewer couldn't switch the seat. **/
    MultiPlayerNoAuthorized = ErrMultiPlayerBaseCode + 2,
    /*! The role dosen’t exist.  **/
    MultiPlayerNoSuchRole = ErrMultiPlayerBaseCode + 3,
    /*! The `user_id` doesn’t exist. **/
    MultiPlayerNoSuchUser = ErrMultiPlayerBaseCode + 4,
    /*! Seat assignment failed. **/
    MultiPlayerAssignSeatFailed = ErrMultiPlayerBaseCode + 5,
    /*! The host didn't need to change the seat. **/
    MultiPlayerIgnoredHostSubmit = ErrMultiPlayerBaseCode + 6,
    /*! The starting error code of the data channel module. **/
    ErrDataChannelBaseCode = 102000,
    /*! This indicates that the data channel is created failed. **/
    ErrCreateFailure = ErrDataChannelBaseCode + 1,
    /*! This indicates that the data channel has been closed. **/
    ErrClosed = ErrDataChannelBaseCode + 2,
    /*! The code returned when the state of TcrSession changes to STATE_CLOSED**/
    SessionStopBaseCode = 104000,
    /*! This value indicates that an unknown error occurred in the cloud **/
    SessionStopServerUnknown = SessionStopBaseCode + 1,
    /*! This value indicates that the server issues an exit command: Repeat userID connection. **/
    SessionStopServerDuplicateConnect = SessionStopBaseCode + 2,
    /*! This value indicates that the server issues exit instructions: Cloud API call exit **/
    SessionStopServerStopGame = SessionStopBaseCode + 3,
    /*! This value indicates that the server issues an exit command: the cloud actively exits **/
    SessionStopServerExit = SessionStopBaseCode + 4,
    /*! This value indicates that the App call TcrSession.release() to actively exit **/
    SessionStopStopManually = SessionStopBaseCode + 5,
    /*! This value indicates that reconnection failure leads to exit **/
    SessionStopReconnectFailed = SessionStopBaseCode + 6,
    /*! This value indicate that failed to connect to cloud  **/
    SessionStopConnectFailed = SessionStopBaseCode + 7
};

typedef NS_ENUM(NSInteger, MicStatus) {
    /** If the mic is muted by the room owner, the user cannot unmute it. */
    MIC_STATUS_DISABLE = 0,
    /** If the mic is muted by the user, the user can unmute it. */
    MIC_STATUS_OFF = 1,
    /** The user unmutes the mic.*/
    MIC_STATUS_ON = 2
};

typedef NS_ENUM(NSUInteger, TcrEvent) {
    /**
     * This event indicates that the session has been initialized.<br>
     *
     * The associated event data is NSString (client Session);
     */
    STATE_INITED,
    /**
     * This event indicates that the session is connected.<br>
     *
     * This event has no associated data.
     */
    STATE_CONNECTED,
    /**
     * This event indicates that the session is reconnecting. You can do some interaction to prompt your user.<br>
     *
     * This event has no associated data.
     */
    STATE_RECONNECTING,
    /**
     * This event indicates that the session is closed, and thus it can not be used any more.<br>
     *
     * The associated event data is of type Integer.For the value range, refer to TcrCode#SessionStopBaseCode
     */
    STATE_CLOSED,
    /**
     * This event indicates that the performance data is updated. <br>
     *
     * The associated event data is of type NSDictionary
     */
    CLIENT_STATS,
    /**
     * This event indicates that the status of the game process on the server has been changed.<br>
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *     user_id: String      // The user ID
     *     game_id: String      // The game ID
     *     app_id: number
     *     request_id: string
     *     status: number       // The game start error code. Valid values:
     *                          // `0`: Started the game successfully;
     *                          // `1`: Failed to start the game;
     * }
     * }
     */
    GAME_START_COMPLETE,
    /**
     * This event indicates that the status of the game process on the server has been stopped.<br>
     *
     * The associated event data is of type NSDictionary in json format:
     *  {@code
     * {
     *     user_id: String      // The user ID
     *     game_name: String      // The game name
     *     timestamp: number      // stop time stamp
     *     message: String       // stop message
     * }
     * }
     */
    GAME_PROCESS_STOPPED,
    /**
     * This event indicates the status of the archive loading in the server.<br>
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *     user_id: String      // The user ID
     *     game_id: String      // The game ID
     *     name: String         // The eventual filename of the archive
     *     url: String          // The archive download address
     *     status: number       // The error code of the archive loading status.
     *                          // Valid values:
     *                          // `0`: loaded the archive successfully;
     *                          // `1`: Failed to download the archive;
     *                          // `2`: Failed to verify the archive;
     *                          // `3`: Failed to extract the archive;
     *                          // `4`: Other error;
     *                          // `5`: The archive was being downloaded.
     *     save_type: String    // "`Auto` or `Normal`",
     *     category_id: String  // The archive category ID
     *     archive_size: number // The archive size
     *     loaded_size: number  // The size of the downloaded archive
     * }
     * }
     */
    ARCHIVE_LOAD_STATUS,
    /**
     * This event indicates the status of the archive saving in the server.<br>
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *     user_id: String      // The user ID
     *     game_id: String      // The game ID
     *     name: String         // The eventual filename of the archive
     *     md5: String          // The MD5 value of the archive
     *    status: number        // The error code of the archive saving status.
     *                          // Valid values:
     *                          // `0`: saved the archive successfully;
     *                          // `1`: Failed to save the archive;
     *                          // `2`: Failed to compress the archive;
     *                          // `3`: Other error;
     *                          // `4`: The archive was being uploaded;
     *                          // `5`: The archive could not be found;
     *                          // `6`: The archive operations were too frequent.
     *   save_type: String      // "`Auto` or `Normal`",
     *   category_id: String    // The archive category ID
     *   archive_size: number   // The archive size
     *   saved_size: number     // The size of the saved archive
     * }
     * }
     */
    ARCHIVE_SAVE_STATUS,
    /**
     * This event indicates that the input status of the server has changed. <br>
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *   status: String  // If the status distributed by the cloud is `disabled`, input is disabled.
     * }
     * }
     */
    INPUT_STATUS_CHANGED,
    REMOTE_DESKTOP_INFO,
    /**
     * This event indicates that the configuration of the cloud phone screen configuration has been changed.<br>
     *
     * The associated event data is of type interger(enum of UIInterfaceOrientation)
     */
    SCREEN_CONFIG_CHANGE,
    /**
     * This event indicates that the cloud Mobile screen information is updated.<br>
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *   width: number
     *   height: number
     * }
     * }
     */
    VIDEO_STREAM_CONFIG_CHANGED,
    /**
     * This event indicates that the remote cursor image information is updated. <br>
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *   image: UIImage
     *   imageFrame: NSArray
     * }
     * }
     */
    CURSOR_IMAGE_INFO,
    /**
     * This event indicates that the frame rate remains low for 10 consecutive seconds.<br>
     *
     * This event has no associated data.
     */
    CLIENT_LOW_FPS,
    /**
     * This event indicates that the showing status of cloud cursor is changed. <br>
     *
     * The associated event data is of type BOOL
     */
    CURSOR_STATE_CHANGE,
    /**
     * This event indicates that the multi user seat info is updated. <br>
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *   players: NSDictionary
     *   viewers: NSDictionarys
     *   max_players: number
     *   player_left: number
     * }
     * }
     * sample:
     *"players":[{"name":"user1","seat_index":0,"mic_status":1},{"name":"user2","seat_index":1,"mic_status":1}],"viewers":[{"name":"user3","seat_index":0,"mic_status":0},{"name":"user4","seat_index":0,"mic_status":0}],
     *"max_players": Number, "player_left":Number}
     */
    MULTI_USER_SEAT_INFO,
    /**
     * This event indicates that some user request to change seat. Note that only the host will receive this
     * event.<br>
     *
     * The associated event data is of typeNSDictionary in json format:
     * {@code
     * {
     *   user_id: String
     *   to_role: String  // valid values: player/viewer
     *   seat_index: Interger
     * }
     * }
     */
    MULTI_USER_ROLE_APPLY,
    /**
     * This event indicates that the status of the remote input box has changed. <br>
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *    field_type: String    // the type input box
     *                          // Valid values:
     *                          // `normal_input`: This type represents the input box of a regular window gaining
     *                          //                 focus.
     *                          //
     *                          // `autologin_input`: This value has been deprecated.
     *                          //
     *                          // `unfocused`: This type represents the focus being moved out of the window.
     *
     *   text: String           // The text content in the remote input box.<br>
     *                          // This field is only supported when the cloud application is an Android application
     * }
     * }
     */
    INPUT_STATE_CHANGE,
    START_AUTO_LOGIN
};


typedef NS_ENUM(NSInteger, TCRMouseCursorTouchMode) {
    /*! 鼠标跟随手指移动,点击可以单击按键 */
    TCRMouseCursorTouchMode_AbsoluteTouch = 0,
    /*! 手指滑动控制鼠标相对移动
     * 轻触触发鼠标左键
     * 长按触发按点击鼠标左键, 可以拖动
     * 滑动仅触发鼠标移动
     **/
    TCRMouseCursorTouchMode_RelativeTouch = 1,
    /*! 鼠标在相对位置移动，不触发点击事件 */
    TCRMouseCursorTouchMode_RelativeOnly = 2
};

typedef NS_ENUM(NSInteger, TCRMouseKeyType) {
    LEFT = 0,
    RIGHT = 1,
    MIDDLE = 2,
    FORWARD = 3,
    BACKWARD = 4,
};

typedef enum : NSInteger {
    TCRNetwork_NotReachable = 0,
    TCRNetwork_Wifi = 1,
    TCRNetwork_2G = 2,
    TCRNetwork_3G = 3,
    TCRNetwork_4G = 4,
    TCRNetwork_5G = 5,
    TCRNetwork_Unknown = 9,
} TCRNetworkStatus;

typedef void (^TCRMsgHandleBlk)(NSError *error, NSDictionary *msg);
