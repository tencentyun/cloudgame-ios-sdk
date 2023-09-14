[中文文档](历史版本.md)

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

