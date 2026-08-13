> 本文档汇总 TCRSDK 常用 API，各 API 的详细说明请见在线文档：<https://tencentyun.github.io/cloudgame-ios-sdk/>

## TCRSDK

## TcrSdkInstance

### SDK 基础接口

| API                                                          | 描述                  |
| ------------------------------------------------------------ |---------------------|
| `setLogger` | 设置SDK的日志回调级别 |

## TcrSession

### 生命周期相关接口 

| API                                                          | 描述                                                       |
| ------------------------------------------------------------ | ---------------------------------------------------------- |
| `initWithParams` | 初始化session |
| `start` | 启动会话，拿到云端返回的serverSession后发起SDK到云端的连接 |
| `releaseSession` | 销毁会话，断开本地和云端的连接，释放资源                   |
| `setRenderView` | 设置会话的渲染视图，SDK会将云端画面渲染到此视图上          |

### 音视频相关接口

| API                                                          | 描述                     |
| ------------------------------------------------------------ |------------------------|
| `pauseStreaming` | 暂停音视频传输                |
| `resumeStreaming` | 恢复音视频传输                |
| `setRemoteAudioPlayProfile` | 设置音量放大系数               |
| `setEnableLocalAudio` | 启用禁用麦克风，默认值false不开启    |
| `setEnableLocalVideo` | 启用禁用本地视频上行，默认值false不开启 |
| `setLocalVideoProfile` | 设置摄像头的传输帧率和码率          |
| `setVideoSink` | 设置会话的视频流回调接口           |
| `setAudioSink` | 设置会话的音频流回调接口           |
| `setEnableAudioPlaying` | 控制会话的音频播放开关            |
| `sendCustomAudioData` | 发送自定义采集音频数据            |

### 云端应用交互接口

| API                                                          | 描述                       |
| ------------------------------------------------------------ | -------------------------- |
| `restartCloudApp` | 重启云端应用进程           |
| `pasteText` | 粘贴文本到云端应用的输入框 |
| `setRemoteDesktopResolution` | 设置云端桌面的分辨率   |
| `setDisableCloudInput` | 关闭云端输入法          |

### 多人云游接口

| API                                                          | 描述               |
| ------------------------------------------------------------ | ------------------ |
| `changeSeat` | 改变某个用户的坐席 |
| `requestChangeSeat` | 申请切换席位 |
| `setMicMute` | 改变某个用户的麦克风状态 |
| `syncRoomInfo` | 刷新房间信息 |

### 按键接口

| API                                                          | 描述                     |
| ------------------------------------------------------------ | ------------------------ |
| `getKeyBoard` | 获取与云端键盘交互的对象 |
| `getMouse` | 获取与云端鼠标交互的对象 |
| `getGamePad` | 获取与云端手柄交互的对象 |
| `getTouchScreen` | 获取与云端触摸屏交互的对象 |

### 数据通道接口

| API                                                          | 描述         |
| ------------------------------------------------------------ | ------------ |
| `createCustomDataChannel` | 创建数据通道 |

### TcrSession.Observer
| API                                                          | 描述         |
| ------------------------------------------------------------ | ------------ |
| `onEvent` | 事件通知 |

### TcrSession.Event
| 定义                                                          | 描述         |
| ------------------------------------------------------------ | ------------ |
| `STATE_INITED` | 初始化成功|
| `STATE_CONNECTED` | 连接成功 |
| `STATE_RECONNECTING` | 重连中 |
| `STATE_CLOSED` | 会话关闭 |
| `CLIENT_IDLE` | 用户无操作 |
| `CLIENT_LOW_FPS` | 帧率低状态 |
| `GAME_START_COMPLETE` | 远端游戏状态变化 |
| `ARCHIVE_LOAD_STATUS` | 存档加载状态变化 |
| `ARCHIVE_SAVE_STATUS` | 存档保存状态变化 |
| `INPUT_STATUS_CHANGED` | 远端是否允许输入 |
| `SCREEN_CONFIG_CHANGE` | 云端分辨率或横竖屏状态改变 |
| `CLIENT_STATS` | 性能数据通知 |
| `REMOTE_DESKTOP_INFO` | 远端桌面信息 |
| `CURSOR_STATE_CHANGE` | 鼠标显示状态变换 |
| `MULTI_USER_SEAT_INFO` | 多人云游房间信息刷新 |
| `MULTI_USER_ROLE_APPLY` | 角色切换申请信息 |
| `CURSOR_IMAGE_INFO` | 鼠标图片信息 |
| `VIDEO_STREAM_CONFIG_CHANGED` | 视频流分辨率变化 |
| `INPUT_STATE_CHANGE` | 输入框点击状态变化 |



## AudioSink

音频数据回调接口

| API                                                          | 描述         |
| ------------------------------------------------------------ | ------------ |
| `onAudioData` | 回调音频数据 |

## VideoSink
自定义视频数据帧回调，回调解码后的视频帧。
| API                                                          | 描述         |
| ------------------------------------------------------------ | ------------ |
| `onFrame` | 视频帧数据回调 |

## Keyboard

云端键盘交互类

| API                                                          | 描述                     |
| ------------------------------------------------------------ | ------------------------ |
| `onKeyboard` | 触发云端键盘按键事件     |
| `checkKeyboardCapsLock` | 查询云端键盘的大小写状态 |
| `resetKeyboardCapsLock` | 重置云端键盘的大小写状态 |
| `resetKeyboard` | 重置云端键盘的按键状态   |


## Mouse

云端鼠标交互类，直接操作云端鼠标，不会修改本地TcrRenderView鼠标状态

| API                                                          | 描述                   |
| ------------------------------------------------------------ | ---------------------- |
| `onMouseDeltaMove` | 让云端鼠标相对移动距离 |
| `onMouseMoveTo` | 让云端鼠标移动到坐标点 |
| `onMouseKey` | 触发云端鼠标的点击事件 |
| `onMouseScroll` | 让云端鼠标滚轮滚动     |


## Gamepad

云端手柄交互类

| API                                                          | 描述                         |
| ------------------------------------------------------------ | ---------------------------- |
| `connectGamepad` | 触发云端手柄插入事件         |
| `disconnectGamepad` | 触发云端手柄断开事件         |
| `onGamepadStick` | 触发云端手柄摇杆事件         |
| `onGamepadKey` | 触发云端手柄按键事件         |
| `onGamepadTrigger` | 触发云端手柄的L2R2触发键事件 |


## TouchScreen

云端触摸屏交互类

| API                                                          | 描述                         |
| ------------------------------------------------------------ | ---------------------------- |
| `touch` | 触发云端触摸屏的触摸事件。         |



## CustomDataChannel

数据通道相关接口

| API                                                          | 描述                 |
| ------------------------------------------------------------ | -------------------- |
| `send` | 通过数据通道发送数据 |
| `close` | 关闭数据通道         |

## CustomDataChannel.Observer

数据通道监听器

| API                                                          | 描述                   |
| ------------------------------------------------------------ | ---------------------- |
| `onConnected` | 创建数据通道成功的回调 |
| `onError` | 发生错误的回调         |
| `onMessage` | 接收云端消息           |


## PcTouchView

触摸事件处理类

| API                                                          | 描述                                  |
| ------------------------------------------------------------ | ------------------------------------- |
| `setCursorTouchMode` | 设置鼠标触摸模式              |
| `setCursorIsShow` | 设置鼠标是否可见                          |
| `setCursorSensitive` | 设置鼠标灵敏度                          |
| `setCursorImage` | 设置鼠标图片    |
| `setClickTypeIsLeft` | 设置点击按键         |



## TCRAudioSessionDelegate

AvAudioSession代理

| API                                                          | 描述                   |
| ------------------------------------------------------------ | ---------------------- |
| `onSetCategory` | 创建数据通道成功的回调 |
| `onSetMode` | 发生错误的回调         |
| `onSetActive` | 接收云端消息           |