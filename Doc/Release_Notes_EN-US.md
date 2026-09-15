[中文文档](历史版本.md)

### Version 3.17.0
**Features**
- Added `setAccessToken:token:error:` to `TcrSdkInstance` for setting the AccessInfo and Token of cloud phone instances. Entries are merged by instance id, so renewing credentials does not affect already created sessions, and the method can be called again whenever credentials are about to expire. (2026-09-15)
- Added cloud phone app management APIs to `TcrSession`: `distributeApp:` (distributes and installs the APK of the given package name, with the result reported through the `DISTRIBUTE_STATUS_CHANGED` event), `preserveApps:` (keeps only the given apps), `keepAppInForeground:` (keeps the given app persistently in the foreground) and `disableForegroundApp` (disables the persistent foreground mode). (2026-09-15)
- Added the `DISTRIBUTE_STATUS_CHANGED` (app distribution status changed) event to `TcrEvent`. (2026-09-15)
- Added granular connection failure codes to `TcrSession`'s STATE_CLOSED event: `SessionStopConnectFailedDisconnected`(104011), `SessionStopConnectFailedNetwork`(104012), `SessionStopConnectFailedResponseInvalid`(104013), `SessionStopServerSessionParseFailed`(104014), `SessionStopConnectFailedInvalidState`(104015), `SessionStopConnectFailedAccessInfoMissing`(104016), `SessionStopLocalSdpSetFailed`(104018), `SessionStopRemoteSdpSetFailed`(104019), `SessionStopLocalSdpCreateFailed`(104020), `SessionStopClientSessionInvalid`(104021). (2026-09-15)
- Reworked the cloud phone demo (TCAIDemo): the login, instance list, instance operation and streaming pages are now split per page, with added examples for instance properties, app management, file transfer and screenshot APIs. (2026-09-16)

**Bug Fixes**
- Fixed an issue where setting the credentials again invalidated the credentials of already created sessions and made subsequent connections fail. (2026-09-12)

**Attention (Behavior Change)**
- **The minimum supported system version is raised from iOS 12.0 to iOS 15.0.** If your app still needs to support iOS 12 to 14, stay on 3.16.0. When upgrading, raise your project's iOS Deployment Target to 15.0 or above, otherwise `pod install` will fail.
- The return type of `TcrSession`'s `start:` changed from `BOOL` to `void`. The connection result is always reported through the `TcrSessionObserver` `onEvent` callback: STATE_CONNECTED on success, and STATE_CLOSED carrying the specific failure code on failure. The former return value only indicated whether the request had been sent and could not represent the connection result, which made it easy to mistake for a successful connection. If your code used that return value, please check `onEvent` instead.
- The credential APIs are consolidated into `setAccessToken:token:error:`. The following are removed: the `TcrConfig` class, `setTcrConfig:error:`, `updateToken:` and `updateInstanceAccessInfo:token:error:`. What used to take two steps (building a `TcrConfig` and then setting it) is now a single call, used both for the initial setup and for later renewals.
- `TcrEnvTest` is no longer a public class. It was only used by the demo to call the trial server and is not part of the SDK integration surface, so do not use it in your code.
- On connection failure, the SDK no longer reports `SessionStopConnectFailedSdp`(104010) and reports one of the granular SDP codes above instead. The constant is kept for compatibility but will no longer be delivered.

### Version 3.16.0
**Features**
- Added the `TOKEN_EXPIRED` (access token expired) event to `TcrEvent`. (2026-07-03)
- Cloud phone instance authentication aligned with Android: the SDK stores authentication info by instance InstanceId and passes it through during standalone/group connections. (2026-07-31)
- Audio session parameterization: `TcrSession initWithParams:andDelegate:` adds `audioSessionCategoryOptions` and `audioSessionMode` parameters to customize the AVAudioSession category options and mode written by the SDK, for coexisting with third-party audio SDKs. (2026-08-12)
- Updated TWEBRTC.framework. (2026-08-12)
- Added granular connection failure codes to `TcrSession`'s STATE_CLOSED event: `SessionStopConnectFailedServerRejected`(104009), `SessionStopConnectFailedSdp`(104010), `SessionStopServerSessionInvalid`(104008). (2026-08-13)

**Bug Fixes**
- Fixed an issue with custom audio capture. (2026-08-12)
- Fixed the Demo login failure and the SDK standalone/group connection failure issues. (2026-07-31)

**Attention (Behavior Change)**
- On connection failure, the SDK no longer reports SessionStopConnectFailed(104007) and reports one of the granular codes above instead. If your code matches 104007 exactly, please adapt it to the granular codes, or treat 104007 as a fallback for unknown connection failures.
- When the ServerSession returned by the cloud is invalid, the SDK no longer reports SessionStopServerUnknown(104001) and reports SessionStopServerSessionInvalid(104008) instead.

### Version 3.15.12 (2026-4.21)
Bug Fixes Gamepad

### Version 3.15.9 (2026-4.2)
Bug Fixes
- reconnection.

### Version 3.15.8 (2026-3.9)
Bug Fixes
- release camera.

### Version 3.15.7 (2026-2.3)
Bug Fixes
- H264 Profile level too low.

### Version 3.15.2 (2026-1.21)
Features
- Added sessionMode config to TcrSession

### Version 3.15.1 (2025-12.11)
Bug Fixes
- Fix and optimize some known issues

### Version 3.15.0 (2025-12.11)
Features
- Added inputText:mode:indexAfterOverride interface to TcrSession

### Version 3.14.0 (2025-12.10)
Features
- Added setRemoteVideoProfile:minBitrate:maxBitrate:width:height interface to TcrSession

### Version 3.13.1 (2025-12.9)
Bug Fixes
- Fix and optimize some known issues

### Version 3.13.0 (2025-12.8)
Features
- Added updateInstanceAccessInfo:token:error interface to TcrSdkInstance

### Version 3.12.2 (2025-12.5)
Bug Fixes
- Fix and optimize some known issues

### Version 3.12.1 (2025-11.19)
Bug Fixes
- Fix and optimize some known issues

### Version 3.12.0 (2025-11.19)
Features
- Added a new uplink video weak network degradation strategy interface to TcrSession. Strategies include: [disabled], [Maintain frame rate], [Maintain resolution], [Balanced].
- Added uplink resolution, uplink packet loss rate, and uplink encoding bitrate metrics to CLIENT_STATS.

- Bug Fixes
- Fixed and optimized some known issues.

### Version 3.11.0 (2025-10.29)
Features
- CLIENT_STATS event adds audio and video upstream frame rate data.

### Version 3.10.3 (2025-10.27)
Bug Fixes
- Fix and optimize some known issues

### Version 3.10.2 (2025-9.4)
Bug Fixes
- Fix and optimize some known issues

### Version 3.10.1 (2025-9.1)
Bug Fixes
- Fix and optimize some known issues

### Version 3.10.0 (2025-8.30)
Features
- Pass proxy relay information through the PROXY_RELAY_AVAILABLE event.

### Version 3.9.1 (2025-8.2)
Bug Fixes
- Fix and optimize some known issues

### Version 3.9.0 (2025-8.20)
Features
- The new TcrSession sendCustomVideoPixelBuffer:rotation:captureTimeNsinterface is used to send custom captured video frames. This capability must be enabled and take effect through the enableCustomVideoCapture field in TcrSession initWithParams.

### Version 3.8.3 (2025-8.14)
Bug Fixes
- Fix and optimize some known issues

### Version 3.8.2 (2025-8.12)
Bug Fixes
- Fix and optimize some known issues

### Version 3.8.1 (2025-8.11)
Bug Fixes
- Fix and optimize some known issues

### Version 3.8.0 (2025-8.6)
Features
- TcrRenderView adds resetRenderState interface to reset the triggering of onFirstFrameRendered event.

### Version 3.7.1 (2025-8.5)
Bug Fixes
- Fix and optimize some known issues

### Version 3.7.0 (2025-8.1)
Features
- Optimize mic permission, request on-demand instead of during setup.

### Version 3.6.0 (2025-7.24)
Features
- Added cloud phone interface
- Added the MIC_STATUS_CHANGED event to TcrEvent

### Version 3.5.0 (2025-7.8)
Features
- Added idle detection: When creating a TcrSession, you can now set an idle time threshold via the idleThreshold parameter. If user inactivity persists beyond this threshold, it triggers the CLIENT_IDLE callback.
- onLocationChanged: Sets longitude and latitude for cloud devices.
- onSimulateSensorEvent: Triggers simulated sensor events

### Version 3.4.0 (2024-11.28)
Features  
- Added new sensor data transfer interface MotionSensor

### Version 3.3.1 (2024-11.18)
Features  
- TcrEvent change CAMERA_STATUS event data

### Version 3.3.0 (2024-11.15)
Features  
- TcrEvent adds CAMERA_STATUS event

Bug Fixes 
- Fix and optimize some known issues

### Version 3.2.5 (2024-6.24)
Bug Fixes 
- Fixed an issue that would trigger a crash under certain circumstances

### Version 3.2.4 (2024-6.19)
Features 
- sdk adds privacy info list

### Version 3.2.3 (2024-5.20)
Bug Fixes 
- Fix and optimize some known issues

### Version 3.2.2 (2024-4.7)
Bug Fixes   
- Fixed the problem of incorrect message sent by data channel

### Version 3.2.1 (2024-3.14)
Features  
- MinimumOSVersion upgraded to 12

### Version 3.2.0 (2024-3.13)
Features  
- TcrEvent adds OPEN_URL event

### Version 3.1.6 (2024-5.20)
Bug Fixes 
- Fix and optimize some known issues

### Version 3.1.5 (2024-4.7)
Features  
- Fixed the problem of incorrect message sent by data channel

### Version 3.1.4 (2024-3.25)
Bug Fixes 
- Fixed an issue that would trigger a crash under certain circumstances

### Version 3.1.1 (2024-3.1)
Bug Fixes  
- Fix reported errors

### Version 3.1.0 (2024-2.22)
Features  
- Added TcrEnvTest for demo request experience

### Version 3.0.9 (2024-1.11)
Bug Fixes 
- Fix packet_lost unsigned integer display problem

### Version 3.0.8 (2024-1.10)
Bug Fixes 
- Fix the problem of MobileTouch failure in some cases

### Version 3.0.7 (2023-12.26)
Bug Fixes 
- Fixed an issue that would trigger a crash under certain circumstances

### Version 3.0.6 (2023-12.22)
Bug Fixes 
- Fix and optimize some known issues

### Version 3.0.5 (2023-12.21)
Refactor  
- Modify the initial parameters of AvAudioSession

Bug Fixes 
- Fix and optimize some known issues

### Version 3.0.4 (2023-12.11)
Features  
- Performance data callback adds new field decode/drop frame fps

### Version 3.0.3 (2023-12.11)
Bug Fixes 
- Fixed an issue that would trigger a crash under certain circumstances

### Version 3.0.2 (2023-12.7)
Bug Fixes 
- Fixed the problem of failure to load image resources in the virtual key library
- Fix and optimize some known issues

### Version 3.0.1 (2023-12.5)
Features
- Optimize reconnection

### Version 3.0.0 (2023-12.3)
Features
- Update the underlying TWEBRTC library
- Optimize reconnection
- Added getRequestID interface

Bug Fixes
- Fix and optimize some known issues

### Version 2.2.0 (2023-11.9)
Features
- Added adaptation of virtual key library

Bug Fixes
- Fix and optimize some known issues

### Version 2.1.8 (2023-11.3)
Bug Fixes
- Fix and optimize some known issues.

### Version 2.1.7 (2023-11.3)
Bug Fixes
- Fix and optimize some known issues.

### Version 2.1.6 (2023-11.3)
Bug Fixes
- Fix the problem of incorrect performance data acquisition

### Version 2.1.5 (2023-11.2)
Bug Fixes
- Fix the problem of absolute mouse movement and click

### Version 2.1.4 (2023-11.1)
Bug Fixes
- Fix and optimize some known issues.

### Version 2.1.3 (2023-10.31)
Bug Fixes
- Fixed the problem of occasional data channel creation failure

### Version 2.1.2 (2023-10.30)
Bug Fixes
- Fix and optimize some known issues.

### Version 2.1.1 (2023-10.20)
Bug Fixes
- Fix and optimize some known issues.

### Version 2.1.0 (2023-10.19)
Features
- Added video uplink function interface
- Added self-collection audio interface

Bug Fixes
- Fixed the problem of black screen when exiting the background and returning to the foreground
- Fixed some known issues

### Version 2.0.0 (2023-10.12)
Features 
- SDK reconstruction interface design

### Version 1.6.17 (2024-12.5)
Bug Fixes
-Fix leaks that appear when sdk exits

### Version 1.6.16 (2024-11.27)
Bug Fixes
- Fix sdk log reporting error

### Version 1.6.15 (2024-8.13)
Bug Fixes
- Fixed the problem of uninitialized videoView frame causing rendering failure

### Version 1.6.14 (2024-7.25)
Bug Fixes   
- Fix and optimize some known issues.

### Version 1.6.13 (2024-6.19)
Features 
- sdk adds privacy info list

### Version 1.6.12 (2024-4.19)
Bug Fixes   
- Fixed the issue where the microphone failed after being turned on and off repeatedly

### Version 1.6.11 (2023-3.1)
Bug Fixes  
- Fix reported errors

### Version 1.6.10 (2023-12.5)
Features
- Optimize reconnection

### Version 1.6.9 (2023-11.17)
Bug Fixes
- Fixed the problem of invalid setting of audio playback switch

### Version 1.6.8 (2023-11.14)
Bug Fixes
- Fixed the problem of disabling the microphone previously set after reconnection.

### Version 1.6.7 (2023-10.31)
Bug Fixes
- Fixed the problem of occasional data channel creation failure

### Version 1.6.6 (2023-10.27)
Bug Fixes
- Fix and optimize some known issues.

### Version 1.6.5 (2023-10.27)
Bug Fixes
- Optimized the problem of main thread deadlock caused by heartbeat timer

### Version 1.6.4 (2023-10.26)
Bug Fixes
- Fix and optimize some known issues.

### Version 1.6.3 (2023-10.26)
Bug Fixes
- Fix and optimize some known issues.

### Version 1.6.2 (2023-10.20)
Bug Fixes
- Fix and optimize some known issues.

### Version 1.6.1 (2023-10.17)
Bug Fixes
- Fixed the problem of black screen when exiting the background and returning to the foreground
- Fixed an issue where startup parameters were not passed correctly when custom audio collection was turned on

### Version 1.6.0 (2023-10.13)
Features
- Support for custom audio capture.

### Version 1.5.1 (2023-9.20)
Bug Fixes
- Fix and optimize some known issues.

### Version 1.5.0 (2023-9.19)
Features  
- TCGGamePlayer adds a new startup parameter `preferredCodec`, which is used to set the preferred codec. If this field is set, the session will attempt to communicate using the preferred codec, or use other available codecs if the preferred codec is not available. If this field is not set, the session will use the default codec.
  
### Version 1.4.2 (2023-9.18)
Bug Fixes
- Fix and optimize some known issues.

### Version 1.4.1 (2023-9.15)
Bug Fixes
- Fixed the problem of timer failure in SDK in certain scenarios

### Version 1.4.0 (2023-9.14)
Features
-TCGGamePlayer adds `onGameProcessStopped` callback

Bug Fixes
-Fixed the problem of reconnection timeout when the network is not restored

### Version 1.3.14 (2023-9.13)
Bug Fixes
- Fixed the issue where audio track volume settings failed after reconnection

### Version 1.3.13 (2023-9.13)
Features 
- TCGVideoFrame adds `timestamp` field

### Version 1.3.12 (2023-9.13)
Bug Fixes
- Fix the problem of ·rtt· statistics error
### Version 1.3.11 (2023-9.12)
Bug Fixes
- Fix and optimize some known issues.
### Version 1.3.10 (2023-9.12)
Bug Fixes
- Fix and optimize some known issues.

### Version 1.3.9 (2023-9.7)
Bug Fixes
- Fix and optimize some known issues.

### Version 1.3.8 (2023-9.5)
Features
- TCGGamePlayer#currentStatisReport adds audio downlink bitrate field
### Version 1.3.7 (2023-9.1)
Bug Fixes
- Fix the problem that the volume adjustment interface ‘setVolume’ fails

### Version 1.3.6 (2023-8.30)
Bug Fixes
- Fix and optimize some known issues.

### Version 1.3.5 (2023-8.25)
Features
- The audio and video data callback interface adds a configuration switch for internal rendering and playback

### Version 1.3.4 (2023-8.22)
Bug Fixes
- Fix and optimize some known issues.
### Version 1.3.3 (2023-8.17)
Features
- The new startup parameter `software_aec` is used to enable software echo cancellation
### Version 1.3.2 (2023-8.14)
Features
- Added TCGMultiPlayer interface class
- Log proxy module refactoring

Bug Fixes
- Fix and optimize some known issues.

### Version 1.3.1 (2023-8.9)
Bug Fixes
- Fix the echo problem after turning on the microphone
### Version 1.3.0 (2023-8.9)
Features
- TCGGamePlayer adds interface setVideoSink && setAudioSink for callback audio and video data
- Added TCGVideoFrame && TCGAudioFrame

### Version 1.2.2 (2023-8.9)
Bug Fixes
- Fix and optimize some known issues.
### Version 1.2.1 (2023-7.17)
Bug Fixes
- Fix and optimize some known issues.
### Version 1.2.0 (2023-7.6)
Features
- Added TCGMultiPlayer interface class

### Version 1.1.9.6 (2023-8-7)
Bug Fixes
- Fix and optimize some known issues.
### Version 1.1.9.5 (2023-8-3)
Bug Fixes
- Fix and optimize some known issues.
### Version 1.1.9.4 (2023-8-2)
Features
- Added TCGAudioSessionDelegate agent, which is used to call back the parameters of operating audiosession in sdk, and stop sdk from operating these parameters
- New interface setEnableLocalAudio is used to enable and disable the local microphone
### Version 1.1.9.2 (2023-7-19)
Features
- Add configurable audioSession parameters for creating TCGGameplayer
Bug Fixes
- Fix and optimize some known issues.
### Version 1.1.9.1 (2023-4-12)
Bug Fixes
- Fix and optimize some known issues.

### Version 1.1.9 (2022-11-15)
Features
- TCGGamePlayer newly added method setRemoteDesktopResolution(int, int) for setting the resolution of cloud desktop.

### Version 1.1.8.22 (2022-5-10)
Bug Fixes
- Fix and optimize some known issues.

### Version 1.1.8.21 (2021-12-10)
Features
- Replaced the WebRTC-based reconnection API with the reconnection delegate API.
- Fixed some potential issues.

### Version 1.1.7.20 (2021-10-29)
Features
- Optimized some details of virtual keys.
- Fixed the issue where the performance log reporting didn't stop due to an exception.

