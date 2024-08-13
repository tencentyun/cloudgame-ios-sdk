[中文文档](历史版本.md)

### Version 3.2.5 (2023-6.24)
Bug Fixes 
- Fixed an issue that would trigger a crash under certain circumstances

### Version 3.2.4 (2024-6.19)
Features 
- sdk adds privacy info list

### Version 3.2.3 (2023-5.20)
Bug Fixes 
- Fix and optimize some known issues

### Version 3.2.2 (2023-4.7)
Bug Fixes   
- Fixed the problem of incorrect message sent by data channel

### Version 3.2.1 (2023-3.14)
Features  
- MinimumOSVersion upgraded to 12

### Version 3.2.0 (2023-3.13)
Features  
- TcrEvent adds OPEN_URL event

### Version 3.1.6 (2023-5.20)
Bug Fixes 
- Fix and optimize some known issues

### Version 3.1.5 (2023-4.7)
Features  
- Fixed the problem of incorrect message sent by data channel

### Version 3.1.4 (2023-3.25)
Bug Fixes 
- Fixed an issue that would trigger a crash under certain circumstances

### Version 3.1.1 (2023-3.1)
Bug Fixes  
- Fix reported errors

### Version 3.1.0 (2023-2.22)
Features  
- Added TcrEnvTest for demo request experience

### Version 3.0.9 (2023-1.11)
Bug Fixes 
- Fix packet_lost unsigned integer display problem

### Version 3.0.8 (2023-1.10)
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

