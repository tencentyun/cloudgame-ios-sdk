//
//  TcrSession.h
//  TCRSDK
//
//  Created by xxhape on 2023/9/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <tcrsdk/TCRSdkConst.h>
#import <AVFoundation/AVFoundation.h>
#import <TCRSDK/TcrRenderView.h>
#import <TCRSDK/AudioSink.h>
#import <TCRSDK/VideoSink.h>
#import <TCRSDK/Mouse.h>
#import <TCRSDK/Keyboard.h>
#import <TCRSDK/GamePad.h>
#import <TCRSDK/TouchScreen.h>
#import <TCRSDK/CustomDataChannel.h>

#pragma mark--- session event callback ---
@protocol TcrSessionObserver <NSObject>
@required
- (void)onEvent:(TcrEvent)event eventData:(id _Nullable)eventData;

@end

#pragma mark--- audioDelegate ---
/*!
 * sdk audioSession proxy, after implementing and passing addTCGAudioSessionDelegate.
 * AudioSession will no longer be operated in the sdk, but AudioSession related operations will be called back 
 * to the APP through the proxy for processing. The APP will set the AVAudioSession 
 * according to the parameters according to actual needs.
 */
@protocol TCRAudioSessionDelegate <NSObject>
@optional
- (BOOL)onSetCategory:(NSString *_Nonnull)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError *_Nullable *_Nullable)outError;
- (BOOL)onSetMode:(NSString *_Nonnull)mode error:(NSError *_Nullable *_Nullable)outError;
- (BOOL)onSetActive:(BOOL)active error:(NSError *_Nullable *_Nullable)outError;
@end

@interface TcrSession : NSObject

/**
 * Initialize local resources, asynchronously callback results
 * @param params Optional, the following key-value pairs can be selected:
 *         - @"preferredCodec": Optional values are @"H264", @"H265", @"VP8", and @"VP9". Used to set the preferred codec.
 *          If this field is set, the session will try to use the preferred codec for communication. If the preferred codec is not available,
 *          other available codecs will be used. If this field is not set or the setting is invalid, the session will use the default codec.
 *
 *         - @"preferredCodecList":  The value is an NSArray, which contains the optional values @"H264", @"H265", @"VP8", and @"VP9".
 *          Indicate preferred codecs, where the order of the elements in the list represents priority, such as index 0 being the highest priority
 *          preferred codec. If the set codecs cannot be selected for various reasons, other available codecs will be chosen.
 *
 *         - @"local_video": Optional value is of bool type. Used to enable the local camera.
 *
 *         - @"local_audio": Optional value is of bool type. Used to enable the local microphone.
 *
 *         - @"enableCustomAudioCapture":@{@"sampleRate":NSInteger, @"useStereoInput": BOOL}, enable custom audio capture and bring the sample rate
 *           and channel count of the custom captured audio (both parameters are required). 
 *           e.g. @"enableCustomAudioCapture":@{@"sampleRate":@(48000), @"useStereoInput":@(false)} means a sample rate of 48000 and mono data.
 *           In addition, to enable custom audio capture, you also need to set @"local_audio" to enable local audio upstream.
 *
 *         - @"remoteDesktopResolution":@{@"width":NSInteger , @"height":NSInteger} ,Set the resolution of Cloud Desktop. If the cloud PC
 *           application is in full-screen mode, the resolution of the downstream video stream will also change accordingly.
 *           NOTE：This param  is only for PC application, and the mobile application is not supported.
 * @param Observer The delegate of the TcrSession, listening for callback of events.
 */
- (instancetype _Nonnull)initWithParams:(NSDictionary *_Nullable)params andDelegate:(id<TcrSessionObserver> _Nonnull)Observer;

/**
 * setOberServer for session
 *
 * @param Observer session Observer
 */

- (void)setTcrSessionObserver:(id<TcrSessionObserver> _Nonnull)Observer;

/**
 * Starts the session. This method should only be called once.
 *
 * @param serverSession The ServerSessionreturned from CreateSessionAPI.
 *
 * @return true if success, false otherwise.
 */
- (BOOL)start:(NSString *_Nonnull)serverSession;

/**
 * Release the session. <br>
 * The session will disconnect from the sever, and the local resources of this
 * session will be released. Once released, this session instance cannot be used anymore.
 */
- (void)releaseSession;

/**
 * Get the current connection's requestId.
 *
 * It takes effect after calling TcrSession.start().
 */
- (NSString*_Nonnull) getRequestId;

/**
 * Set the rendering view for this session, and thus the SDK will render the streaming content to the view.
 *
 * @param renderView The rendering view to be set. This can be null to remove any existing renderView.
 */
- (void)setRenderView:(TcrRenderView *_Nullable)renderView;

/**
 * Sets a video sink for this session. After that, the SDK will callback the decoded video frame data to the
 * videoSink.
 *
 * <p>You may use this interface to post-process or render video images.</p>
 *
 * @param videoSink The view sink to be set.This can be null to remove any existing one.
 */
- (void)setVideoSink:(id<VideoSink> _Nullable)videoSink;

/**
 * Sets a audio sink for this session. After that, the SDK will callback the audio data to the audioSink
 *
 * @param audioSink The audio sink to be set.
 */
- (void)setAudioSink:(id<AudioSink> _Nullable)audioSink;

/**
 * Set whether the SDK plays audio.
 *
 * @param enable true to enable audio playback, false otherwise.
 */
- (void)setEnableAudioPlaying:(BOOL)enable;

/**
 * Enable or disable the local audio track that is captured from the mic.
 *
 * @param enable true to enable the local audio, false otherwise.
 */
- (void)setEnableLocalAudio:(BOOL)enable;

/**
 * Enable or disable the local video track that is captured from the camera.
 *
 * @param enable true to enable the local video, false otherwise.
 */
- (void)setEnableLocalVideo:(BOOL)enable;

//////////////////////////////////////////////// 上下行音视频流控制 ////////////////////////////////////////////////

/**
 * Pause the media stream.
 */
- (void)pauseStreaming;

/**
 * Resume the media stream.
 */
- (void)resumeStreaming;

/**
 * Set the remote video profile.
 *
 * @param fps The frame rate. Value range: [10,60]. Default value: `60`.
 * @param minBitrate The minimum bitrate in Kbps. Value range: [1000,15000]. Default value: `1000`.
 * @param maxBitrate The maximum bitrate in Kbps. Value range: [1000,15000]. Default value: `15000`.
 */

- (void)setRemoteVideoProfile:(int)fps minBitrate:(int)minBitrate maxBitrate:(int)maxBitrate DEPRECATED_MSG_ATTRIBUTE();

/**
 * Set the local video profile.
 *
 * @param width The frame width, range[128, 1920]. Suggested value: 1280.
 * @param height The frame height, range[128, 1920]. Suggested value: 720.
 * @param fps The frame rate must be greater than 0 Default value: `30`.
 * @param minBitrate The minimum bitrate in Kbps. Value range: [1000,15000]. Default value: `1000`.
 * @param maxBitrate The maximum bitrate in Kbps. Value range: [1000,15000]. Default value: `15000`.
 */
- (void)setLocalVideoProfile:(int)width
                      height:(int)height
                         fps:(int)fps
                  minBitrate:(int)minBitrate
                  maxBitrate:(int)maxBitrate
               isFrontCamera:(BOOL)isFrontCamera;

/**
 * Set the playing profile of the remote audio.
 *
 * @param volume The volume scalar in the range of [0,10] that will be set on this remote audio stream.
 */
- (void)setRemoteAudioProfile:(float)volume;

/**
 * Restart the cloud application process.
 */
- (void)restartCloudApp;

/**
 * Send the text to the input box in the cloud application.<br>
 * The input box of the cloud application must have obtained the focus and allow the user to paste text from the
 * clipboard.<br>
 *
 * For Android cloud applications, sent text replaces the input box content.<br>
 * For Windows cloud applications, sent text is added to the existing content in the input box.<br>
 *
 * @param text The text to be sent
 */
- (void)pasteText:(NSString *_Nonnull)text;

/**
 * Disable the Cloud input.<br>
 * When the cloud input is disable, the cloud application's soft keyboard won't appear.<br>
 * <br>
 * This function is only supported for mobile cloud applications.<br>
 * <br>
 *
 * @param disableCloudInput true disables the cloud input. <br>
 *         false enables the cloud input, allowing the soft keyboard to appear for user interaction with
 *         the cloud application via touch screen. <br>
 */
- (void)setDisableCloudInput:(BOOL)disableCloudInput;

/**
 * Set the resolution of Cloud Desktop. If the cloud PC application is in full-screen mode, the resolution of the
 * downstream video stream will also change accordingly.<br>
 * This method is currently only valid for scenarios where the cloud is a PC application, and the scenario where the
 * cloud is a mobile application is to be supported.
 *
 * @param width Width of cloud desktop.
 * @param height Height of cloud desktop.
 */
- (void)setRemoteDesktopResolution:(int)width height:(int)height;

/**
 * Send custom audio data.
 * <br>
 * This method is only effective when custom audio capture is enabled.
 * <br>
 * To enable custom audio capture, see initWithParams
 *
 * @param audioData The non-null NSData object containing the PCM data(16-bit) to be sent.
 * @param captureTimeNs The capture time of the audio data in nanoseconds.
 *
 * @return The result of send custom audio data.
 */
- (BOOL)sendCustomAudioData:(NSData *_Nonnull)audioData captureTimeNs:(uint64_t)captureTimeNs;

//////////////////////////////////////////////// 云端外设交互 ////////////////////////////////////////////////

/**
 * Return the interface to interact with the cloud keyboard in this session.
 *
 * @return The interface to interact with the cloud keyboard in this session.
 */
- (id<Keyboard> _Nonnull)getKeyboard;

/**
 * Return the interface to interact with the cloud Mouse in this session.
 *
 * @return The interface to interact with the cloud Mouse in this session.
 */
- (id<Mouse> _Nonnull)getMouse;

/**
 * Return the interface to interact with the cloud Gamepad in this session.
 *
 * @return The interface to interact with the cloud Gamepad in this session.
 */
- (id<Gamepad> _Nonnull)getGamepad;

/**
 * Return the interface to interact with the cloud TouchScreen in this session.
 *
 * @return The interface to interact with the cloud TouchScreen in this session.
 */
- (id<TouchScreen> _Nonnull)getTouchScreen;

/**
 * send keycode message to cloud
 */
- (void)sendKeycodeMessage:(NSDictionary *_Nonnull)msg;

/**
 * Creates a custom data channel.
 *
 * @param port The cloud port number uniquely identifying the data channel.
 * @param observer The CustomDataChannel.CustomDataChannelObserver object .
 *
 * @return the created data channel.
 */
- (CustomDataChannel *_Nonnull)createCustomDataChannel:(int)port observer:(id<CustomDataChannelObserver> _Nullable)observer;

//////////////////////////////////////////////// 多人互动云游 ////////////////////////////////////////////////

/**
 * Switch the role and seat of a user (`userID`) to `targetRole` and `targetPlayerIndex` respectively.
 *
 * @param userId The target user ID
 * @param targetRole The target role,. valid value: ( 'player' / 'viewer' )
 * @param targetPlayerIndex The target seat. This parameter can take effect only for the `Player` role and
 *         will be `0` for the `Viewer` role.
 * @param finishBlk Execution result callback. retcode: TcrCode#ErrMultiPlayerBaseCode
 */
- (void)changeSeat:(NSString *_Nonnull)userId
           targetRole:(NSString *_Nonnull)targetRole
    targetPlayerIndex:(int)targetPlayerIndex
                  blk:(void (^_Nullable)(int retCode))finishBlk;

/**
 * Apply to the room owner to switch the role and seat of a player (`userID`) to `targetRole` and
 * `targetPlayerIndex` respectively.
 *
 * @param userId The target user ID
 * @param targetRole The target role,. valid value: ( 'player' / 'viewer' )
 * @param targetPlayerIndex The target seat. This parameter can take effect only for the `Player` role and
 *         will be `0` for the `Viewer` role.
 * @param finishBlk Execution result callback. retcode: TcrCode#ErrMultiPlayerBaseCode
 */
- (void)requestChangeSeat:(NSString *_Nonnull)userId
               targetRole:(NSString *_Nonnull)targetRole
        targetPlayerIndex:(int)targetPlayerIndex
                      blk:(void (^_Nullable)(int retCode))finishBlk;

/**
 * Apply to the room owner to switch the role and seat of a player (`userID`) to `targetRole` and
 * `targetPlayerIndex` respectively.
 *
 * @param userId The target user ID
 * @param micStatus The mic Status set. 
 * @param finishBlk Execution result callback.  retcode: TcrCode#ErrMultiPlayerBaseCode
 */
- (void)setMicMute:(NSString *_Nonnull)userId micStatus:(int)micStatus blk:(void (^_Nullable)(int retCode))finishBlk;

/*!
* Apply to synchronize room information and return the result through TcrEvent#MULTI_USER_SEAT_INFO
*/
- (void)syncRoomInfo;

/**
 * Set audiosession proxy
 *
 * @param delegate The delegate to set
 */
+ (void)setAudioSessionDelegate:(id<TCRAudioSessionDelegate>_Nonnull)delegate;

@end
