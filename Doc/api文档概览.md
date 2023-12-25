- [English document](API_Documentation.md)

## TCRSDK

## TcrSdkInstance

### SDK 基础接口

| API                                                          | 描述                  |
| ------------------------------------------------------------ |---------------------|
| [setLogger](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/TCRLogDelegate.html) | 设置SDK的日志回调级别        |                                                                                                                | 设置OpenGL EGLContext |

## TcrSession

### 生命周期相关接口 

| API                                                          | 描述                                                       |
| ------------------------------------------------------------ | ---------------------------------------------------------- |
| [initWithParams](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/initWithParams:andDelegate:) | 初始化session |
| [start](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/start:) | 启动会话，拿到云端返回的serverSession后发起SDK到云端的连接 |
| [releaseSession](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/releaseSession) | 销毁会话，断开本地和云端的连接，释放资源                   |
| [setRenderView](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/setRenderView:) | 设置会话的渲染视图，SDK会将云端画面渲染到此视图上          |

### 音视频相关接口

| API                                                          | 描述                     |
| ------------------------------------------------------------ |------------------------|
| [pauseStreaming](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/pauseStreaming) | 暂停音视频传输                |
| [resumeStreaming](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/resumeStreaming) | 恢复音视频传输                |
| [setRemoteAudioPlayProfile]() | 设置音量放大系数               |
| [setEnableLocalAudio](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/setEnableLocalAudio:) | 启用禁用麦克风，默认值false不开启    |
| [setEnableLocalVideo](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/setEnableLocalVideo:) | 启用禁用本地视频上行，默认值false不开启 |
| [setLocalVideoProfile](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/setLocalVideoProfile:height:fps:minBitrate:maxBitrate:isFrontCamera:) | 设置摄像头的传输帧率和码率          |
| [setVideoSink](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/setVideoSink:) | 设置会话的视频流回调接口           |
| [setAudioSink](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/setAudioSink:) | 设置会话的音频流回调接口           |
| [setEnableAudioPlaying](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/setEnableAudioPlaying:) | 控制会话的音频播放开关            |
| [sendCustomAudioData](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/sendCustomAudioData:captureTimeNs:) | 发送自定义采集音频数据            |

### 云端应用交互接口

| API                                                          | 描述                       |
| ------------------------------------------------------------ | -------------------------- |
| [restartCloudApp](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/restartCloudApp) | 重启云端应用进程           |
| [pasteText](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/pasteText:) | 粘贴文本到云端应用的输入框 |
| [setRemoteDesktopResolution](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/setRemoteDesktopResolution:height:) | 设置云端桌面的分辨率   |
| [setDisableCloudInput](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/setDisableCloudInput:) | 关闭云端输入法          |

### 多人云游接口

| API                                                          | 描述               |
| ------------------------------------------------------------ | ------------------ |
| [changeSeat](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/changeSeat:targetRole:targetPlayerIndex:blk:) | 改变某个用户的坐席 |
| [requestChangeSeat](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/requestChangeSeat:targetRole:targetPlayerIndex:blk:) | 申请切换席位 |
| [setMicMute](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/setMicMute:micStatus:blk:) | 改变某个用户的麦克风状态 |
| [syncRoomInfo](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/syncRoomInfo) | 刷新房间信息 |

### 按键接口

| API                                                          | 描述                     |
| ------------------------------------------------------------ | ------------------------ |
| [getKeyBoard](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/getKeyboard) | 获取与云端键盘交互的对象 |
| [getMouse](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/getMouse) | 获取与云端鼠标交互的对象 |
| [getGamePad](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/getGamepad) | 获取与云端手柄交互的对象 |
| [getTouchScreen](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/getTouchScreen) | 获取与云端触摸屏交互的对象 |

### 数据通道接口

| API                                                          | 描述         |
| ------------------------------------------------------------ | ------------ |
| [createCustomDataChannel](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/TcrSession.html#//api/name/createCustomDataChannel:observer:) | 创建数据通道 |

### TcrSession.Observer
| API                                                          | 描述         |
| ------------------------------------------------------------ | ------------ |
| [onEvent]() | 事件通知 |

### TcrSession.Event
| 定义                                                          | 描述         |
| ------------------------------------------------------------ | ------------ |
| [STATE_INITED](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 初始化成功|
| [STATE_CONNECTED](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 连接成功 |
| [STATE_RECONNECTING](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 重连中 |
| [STATE_CLOSED](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 会话关闭 |
| [CLIENT_IDLE](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 用户无操作 |
| [CLIENT_LOW_FPS](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 帧率低状态 |
| [GAME_START_COMPLETE](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 远端游戏状态变化 |
| [ARCHIVE_LOAD_STATUS](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 存档加载状态变化 |
| [ARCHIVE_SAVE_STATUS](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 存档保存状态变化 |
| [INPUT_STATUS_CHANGED](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 远端是否允许输入 |
| [SCREEN_CONFIG_CHANGE](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 云端分辨率或横竖屏状态改变 |
| [CLIENT_STATS](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 性能数据通知 |
| [REMOTE_DESKTOP_INFO](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 远端桌面信息 |
| [CURSOR_STATE_CHANGE](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 鼠标显示状态变换 |
| [MULTI_USER_SEAT_INFO](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 多人云游房间信息刷新 |
| [MULTI_USER_ROLE_APPLY](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 角色切换申请信息 |
| [CURSOR_IMAGE_INFO](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 鼠标图片信息 |
| [VIDEO_STREAM_CONFIG_CHANGED](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 视频流分辨率变化 |
| [INPUT_STATE_CHANGE](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Constants/TcrEvent.html) | 输入框点击状态变化 |



## AudioSink

音频数据回调接口

| API                                                          | 描述         |
| ------------------------------------------------------------ | ------------ |
| [onAudioData](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/AudioSink.html#//api/name/onAudioData:) | 回调音频数据 |

## VideoSink
自定义视频数据帧回调，回调解码后的视频帧。
| API                                                          | 描述         |
| ------------------------------------------------------------ | ------------ |
| [onFrame]() | 视频帧数据回调 |

## Keyboard

云端键盘交互类

| API                                                          | 描述                     |
| ------------------------------------------------------------ | ------------------------ |
| [onKeyboard](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/Keyboard.html#//api/name/onKeyboard:down:) | 触发云端键盘按键事件     |
| [checkKeyboardCapsLock](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/Keyboard.html#//api/name/checkKeyboardCapsLock:) | 查询云端键盘的大小写状态 |
| [resetKeyboardCapsLock](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/Keyboard.html#//api/name/resetKeyboardCapsLock) | 重置云端键盘的大小写状态 |
| [resetKeyboard](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/Keyboard.html#//api/name/resetKeyboard) | 重置云端键盘的按键状态   |


## Mouse

云端鼠标交互类，直接操作云端鼠标，不会修改本地TcrRenderView鼠标状态

| API                                                          | 描述                   |
| ------------------------------------------------------------ | ---------------------- |
| [onMouseDeltaMove](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/Mouse.html#//api/name/onMouseDeltaMove:deltaY:) | 让云端鼠标相对移动距离 |
| [onMouseMoveTo](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/Mouse.html#//api/name/onMouseMoveTo:y:) | 让云端鼠标移动到坐标点 |
| [onMouseKey](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/Mouse.html#//api/name/onMouseKey:isDown:) | 触发云端鼠标的点击事件 |
| [onMouseScroll](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/Mouse.html#//api/name/onMouseScroll:) | 让云端鼠标滚轮滚动     |


## Gamepad

云端手柄交互类

| API                                                          | 描述                         |
| ------------------------------------------------------------ | ---------------------------- |
| [connectGamepad](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/Gamepad.html#//api/name/connectGamepad) | 触发云端手柄插入事件         |
| [disconnectGamepad](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/Gamepad.html#//api/name/disconnectGamepad) | 触发云端手柄断开事件         |
| [onGamepadStick](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/Gamepad.html#//api/name/onGamepadStick:x:y:) | 触发云端手柄摇杆事件         |
| [onGamepadKey](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/Gamepad.html#//api/name/onGamepadKey:down:) | 触发云端手柄按键事件         |
| [onGamepadTrigger](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/Gamepad.html#//api/name/onGamepadTrigger:value:down:) | 触发云端手柄的L2R2触发键事件 |


## TouchScreen

云端触摸屏交互类

| API                                                          | 描述                         |
| ------------------------------------------------------------ | ---------------------------- |
| [touch](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/TouchScreen.html#//api/name/touchWithX:y:eventType:fingerID:width:height:timestamp:) | 触发云端触摸屏的触摸事件。         |



## CustomDataChannel

数据通道相关接口

| API                                                          | 描述                 |
| ------------------------------------------------------------ | -------------------- |
| [send](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/CustomDataChannel.html#//api/name/send:) | 通过数据通道发送数据 |
| [close](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/CustomDataChannel.html#//api/name/close) | 关闭数据通道         |

## CustomDataChannel.Observer

数据通道监听器

| API                                                          | 描述                   |
| ------------------------------------------------------------ | ---------------------- |
| [onConnected](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/CustomDataChannelObserver.html#//api/name/onConnected:) | 创建数据通道成功的回调 |
| [onError](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/CustomDataChannelObserver.html#//api/name/onError:code:message:) | 发生错误的回调         |
| [onMessage](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Protocols/CustomDataChannelObserver.html#//api/name/onMessage:buffer:) | 接收云端消息           |


## PcTouchView

触摸事件处理类

| API                                                          | 描述                                  |
| ------------------------------------------------------------ | ------------------------------------- |
| [setCursorTouchMode](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/PcTouchView.html#//api/name/setCursorTouchMode:) | 设置鼠标触摸模式              |
| [setCursorIsShow](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/PcTouchView.html#//api/name/setCursorIsShow:) | 设置鼠标是否可见                          |
| [setCursorSensitive](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/PcTouchView.html#//api/name/setCursorSensitive:) | 设置鼠标灵敏度                          |
| [setCursorImage](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/PcTouchView.html#//api/name/setCursorImage:andRemoteFrame:) | 设置鼠标图片    |
| [setClickTypeIsLeft](https://tencentyun.github.io/cloudgame-ios-sdk/3.0.0/Classes/PcTouchView.html#//api/name/setClickTypeIsLeft:) | 设置点击按键         |



## TCRAudioSessionDelegate

AvAudioSession代理

| API                                                          | 描述                   |
| ------------------------------------------------------------ | ---------------------- |
| [onSetCategory]() | 创建数据通道成功的回调 |
| [onSetMode]() | 发生错误的回调         |
| [onSetActive]() | 接收云端消息           |