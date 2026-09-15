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
    /*! This value indicate that failed to connect to cloud.<br>
     * It is a general connection failure code kept for compatibility. The SDK now reports more specific
     * failure codes instead: SessionStopConnectFailedServerRejected, SessionStopLocalSdpSetFailed,
     * SessionStopRemoteSdpSetFailed, SessionStopLocalSdpCreateFailed, SessionStopClientSessionInvalid,
     * SessionStopConnectFailedDisconnected,
     * SessionStopConnectFailedNetwork, SessionStopConnectFailedResponseInvalid,
     * SessionStopServerSessionParseFailed, SessionStopConnectFailedInvalidState and
     * SessionStopConnectFailedAccessInfoMissing.
     * You are recommended to handle these specific codes, and treat this code as an unknown connection
     * failure fallback.
     **/
    SessionStopConnectFailed = SessionStopBaseCode + 7,
    /*! This value indicate that the ServerSession is missing or invalid in the cloud response **/
    SessionStopServerSessionInvalid = SessionStopBaseCode + 8,
    /*! This value indicates that the cloud rejected the connection request: the connect/play API returned a
     * non-zero business code (e.g. the instance is in an abnormal state or the number of concurrent
     * connections exceeds the limit). Refer to the SDK logs for the business code and message returned by
     * the cloud.
     **/
    SessionStopConnectFailedServerRejected = SessionStopBaseCode + 9,
    /*! This value indicates that the underlying WebRTC connection was disconnected before the first
     * connection was established, usually caused by network issues.
     **/
    SessionStopConnectFailedDisconnected = SessionStopBaseCode + 11,
    /*! This value indicates that the connection request to the cloud failed at the network layer: the
     * connect/play API request failed or timed out and no response was received. Usually caused by network
     * issues, retry is recommended.
     **/
    SessionStopConnectFailedNetwork = SessionStopBaseCode + 12,
    /*! This value indicates that the cloud responded to the connection request but the response could not
     * be parsed (invalid JSON or unexpected structure). Refer to the SDK logs for details.
     **/
    SessionStopConnectFailedResponseInvalid = SessionStopBaseCode + 13,
    /*! This value indicates that the ServerSession returned by the cloud could not be parsed or is missing
     * required fields (e.g. sdp). Refer to the SDK logs for details.
     **/
    SessionStopServerSessionParseFailed = SessionStopBaseCode + 14,
    /*! This value indicates that the session was not in a startable state when the connection was
     * requested, e.g. start was called before the STATE_INITED event or called more than once.
     * Check the calling sequence in the App.
     **/
    SessionStopConnectFailedInvalidState = SessionStopBaseCode + 15,
    /*! This value indicates that the AccessInfo/Token passed to TcrSdk does not contain the access
     * information of the requested cloud phone instance. Check the AccessInfo obtained from the cloud
     * API and the instance ids passed to the connect API.
     **/
    SessionStopConnectFailedAccessInfoMissing = SessionStopBaseCode + 16,
    /*! This value indicates that applying the locally produced SDP to the local WebRTC endpoint failed.
     * The SDP is the one WebRTC itself has just produced, so the cause is the state of the local WebRTC
     * endpoint rather than the SDP content. Refer to the SDK logs for the failing step and the underlying
     * WebRTC error.<br>
     * This may happen while connecting, while reconnecting, or during renegotiation of an established
     * session. Which one it was is told by the preceding STATE_CONNECTED / STATE_RECONNECTING events, so
     * this code always reports the cause rather than the phase.
     **/
    SessionStopLocalSdpSetFailed = SessionStopBaseCode + 18,
    /*! This value indicates that applying the SDP returned by the cloud to the local WebRTC endpoint
     * failed, e.g. it declares a codec profile or level that the device cannot accept. The local SDP had
     * been produced and applied successfully, so the cause is in the SDP delivered by the cloud. Refer to
     * the SDK logs for the received SDP and the underlying WebRTC error.<br>
     * This may happen while connecting, while reconnecting, or during renegotiation of an established
     * session. Which one it was is told by the preceding STATE_CONNECTED / STATE_RECONNECTING events, so
     * this code always reports the cause rather than the phase.
     **/
    SessionStopRemoteSdpSetFailed = SessionStopBaseCode + 19,
    /*! This value indicates that WebRTC failed to create the local offer/answer, before any SDP was
     * applied. This is a purely local, deterministic operation with no external input, so it is expected
     * to be unreachable in practice; receiving it indicates the PeerConnection was already closed or in an
     * unexpected state. Refer to the SDK logs for the failing step and the underlying WebRTC error.
     **/
    SessionStopLocalSdpCreateFailed = SessionStopBaseCode + 20,
    /*! This value indicates that the ClientSession assembled by the SDK carries no sdp, although the local
     * SDP had been produced successfully. This is an internal inconsistency of the SDK rather than a
     * WebRTC negotiation failure; the cloud would otherwise accept the request and return a ServerSession
     * with an empty sdp, which would surface the problem much later and point at the wrong component.
     **/
    SessionStopClientSessionInvalid = SessionStopBaseCode + 21
};

typedef NS_ENUM(NSInteger, CaiCode) {
    CAI_INVALID_PARAMS = 10001,
    CAI_INVALID_TOKEN = 10002,
    CAI_INVALID_OPERATE = 10003,
    CAI_REQUEST_FAILED = 10004,
    CAI_INTERNAL_ERR = 10005
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
    * This event indicates that an proxy relay endpoint is ready. <br>
    *
    * The associated event data is of type String and represents the relay info which is further used as a
    * parameter to start proxy.
    */
    PROXY_RELAY_AVAILABLE,
    /**
     * This event indicates that an openable url link was clicked. <br>
     *
     * The associated event data is NSString (the url);
     */
    OPEN_URL,
    /**
      * This event indicates that the camera status of the server has changed. <br>
      *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *     width:  number      // The width of the camera's resolution
     *     height: number     // The height of the camera's resolution
     *     status:  String       // The server camera open status. Valid values:
     *                          // `open_back`:  open back camera;
     *                          // `open_front`: open front camera;
     *                          // `close`: camera close;
     * }
     * }
     */
     CAMERA_STATUS_CHANGED,
    /**
      * This event indicates that the microphone status of the server has changed. <br>
      *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *     status:  String       // The server mic open status. Valid values:
     *                          // `open`:  microphone open;
     *                          // `close`: microphone close;
     * }
     * }
     */
     MIC_STATUS_CHANGED,
    /**
     * This event indicates the type of input method distributed when establishing a connection to the cloud device, determining whether to utilize the client-side local input method or the cloud device's input method.​.<br>
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *     ime_type: String     // The server ime status. Valid values:
     *                          // `cloud`: utilize the cloud-side local input method;
     *                          // `local`: utilize the client-side local input method;
     * }
     * }
     */
     IME_TYPE,
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
    /**
     * This event indicates that the cloud PC desktop information is updated. <br>
     */
    REMOTE_DESKTOP_INFO,
    /**
     * This event indicates that the configuration of the cloud phone screen configuration has been changed.<br>
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *   orientation: String    // Valid values: `landscape`/` portrait`
     *   degree: String //  Valid values: `0_degree`, `90_degree`, `180_degree`, `270_degree`
     *   width: number
     *   height: number
     * }
     * }
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
     * This event indicates that the user is in an idle state, that is, the user does not operate the mouse,
     * keyboard or screen for a while.<br>
     *
     * This event has no associated data.
     */
    CLIENT_IDLE,
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
     *
     *   status: String         // Only for Windows system.
     *                          // Valid values:
     *                          // `disable`: Disable client input.
     *                          //
     *                          // `enable`: Enable client input
     *   input_type: Interger // Bit definitions for an integer defining the basic content type of text held in an Editable object.
     *
     * }
     * }
     */
    INPUT_STATE_CHANGE,
    START_AUTO_LOGIN,
    
    /**
     * Message events sent by cloud applications to clients.
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *      package_name: String // 目标应用的包名（Android 应用标识）。
     *      msg: String // 透传的原始消息内容（字符串或 JSON 对象）。
     * }
     * }
     *
     * @note 使用场景：云手机
     */
    CAI_TRANS_MESSAGE,
    /**
     * Load information sent by the cloud application to the client
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *      cpu_usage: number // CPU usage（%，float）
     *      mem_usage: number // Memory usage（%，float）
     *      gpu_usage: number // GPU usage（%，float）
     * }
     * }
     *
     * @note 使用场景：云手机
     */
    CAI_SYSTEM_USAGE,
    /**
     * Remote clipboard content synchronization event. When the cloud device's clipboard content changes, the latest text is automatically sent to the client.
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *     text: String // The latest text content of the clipboard
     * }
     * }
     */
    CAI_CLIPBOARD,
    /**
     * Remote notification message sending event, when there is a new notification on the cloud phone, it is sent to the client
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *      package_name: String // The package name of the application that sends the notification.
     *      title: String // Notification title
     *      text: String // Notification text
     * }
     * }
     */
    CAI_NOTIFICATION,
    /**
     * Periodically call back to capture screenshots of cloud instances
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *      instanceId1: sceenshotUrl1,
     *      instanceId2: sceenshotUrl2,
     *      instanceId3: sceenshotUrl3,
     *      instanceId4: sceenshotUrl4,
     *      ...
     * }
     * }
     */
    CAI_IMAGE_EVENT,
    /**
     * Every 1 second, the cloud application sends the system status to the client via WebRTC
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *      nav_visible: bool // Is the navigation bar visible
     *      music_volume: number // System media volume, range 0-100
     * }
     * }
     */
    CAI_SYSTEM_STATUS,
    /**
     * This event indicates that the access token has expired.<br>
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *      // token expired detail, structure determined by server
     * }
     * }
     */
    TOKEN_EXPIRED,
    /**
     * This event indicates the distribute status. <br>
     *
     * The associated event data is of type NSDictionary in json format:
     * {@code
     * {
     *   state: String  // The distribute state
     *   package_name: String  // The package name of the distribute app
     * }
     * }
     *
     * Supported state values:
     *
     *   SUCCESS: Distribution completed (also sent if app was already distributed on cloud instance)
     *
     *   UNSUPPORTED: Current image doesn't support distribution
     *
     *   BUSY: Currently distributing another app
     *
     *   FAIL: Package distribution failed
     *
     * Recommended app handling:
     *
     *   SUCCESS: Remove default overlay if you added one on the video stream
     *
     *   UNSUPPORTED/FAIL/BUSY: Notification of distribution error and exit streaming session
     */
    DISTRIBUTE_STATUS_CHANGED,
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
