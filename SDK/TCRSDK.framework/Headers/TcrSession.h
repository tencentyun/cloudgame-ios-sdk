//
//  TcrSession.h
//  TCRSDK
//
//  Created by xxhape on 2023/9/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TCRSDK/TCRSdkConst.h>
#import <AVFoundation/AVFoundation.h>
#import <tcrsdk/TcrRenderView.h>
#import <tcrsdk/AudioSink.h>
#import <tcrsdk/VideoSink.h>
#import <tcrsdk/Mouse.h>
#import <tcrsdk/Keyboard.h>
#import <tcrsdk/GamePad.h>
#import <tcrsdk/TouchScreen.h>
#import <tcrsdk/CustomDataChannel.h>

#pragma mark --- session事件回调 ---
@protocol TcrSessionObserver <NSObject>
@required
- (void)onEvent:(TcrEvent)event eventData:(id _Nullable )eventData;

@end

#pragma mark --- audioDelegate ---
/*!
 * sdk audioSession代理，实现并通过addTCGAudioSessionDelegate后。sdk中将不再操作AudioSession，而是将AudioSession相关操作通过该代理回调到APP
 * 处理，APP根据实际需要根据参数对AVAudioSession进行设置。
 */
@protocol TCGAudioSessionDelegate <NSObject>
@optional
- (BOOL)onSetCategory:(NSString *_Nonnull)category
        withOptions:(AVAudioSessionCategoryOptions)options
                error:(NSError *_Nullable*_Nullable)outError;
- (BOOL)onSetMode:(NSString *_Nonnull)mode error:(NSError *_Nullable*_Nullable)outError;
- (BOOL)onSetActive:(BOOL)active error:(NSError *_Nullable*_Nullable)outError;
@end


@interface TcrSession : NSObject

- (instancetype)initWithParams:(NSDictionary *)params;

- (instancetype)initWithParams:(NSDictionary *)params andDelegate:(id<TcrSessionObserver>)Observer;

- (void)setTcrSessionObserver:(id<TcrSessionObserver>)Observer;
/**
 * Starts the session. This method should only be called once.
 *
 * @param serverSession The ServerSessionreturned from CreateSessionAPI.
 * @return true if success, false otherwise.
 */
- (BOOL)start:(NSString*_Nonnull)serverSession;

/**
 * Release the session. <br>
 * The session will disconnect from the sever, and the local resources of this
 * session will be released. Once released, this session instance cannot be used anymore.
 */
- (void)releaseSession;

/**
 * Set the rendering view for this session, and thus the SDK will render the streaming content to the view.
 *
 * @param renderView The rendering view to be set. This can be null to remove any existing renderView.
 */
- (void)setRenderView:(TcrRenderView* _Nullable)renderView;


/**
 * Sets a video sink for this session. After that, the SDK will callback the decoded video frame data to the
 * videoSink.
 *
 * <p>You may use this interface to post-process or render video images.</p>
 *
 * @param videoSink The view sink to be set.This can be null to remove any existing one.
 */
- (void)setVideoSink:(id<VideoSink>_Nullable)videoSink;

/**
 * Sets a audio sink for this session. After that, the SDK will callback the audio data to the audioSink
 *
 * @param audioSink The audio sink to be set.
 */
- (void)setAudioSink:(id<AudioSink>_Nullable)audioSink;

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

- (void)setRemoteVideoProfile:(int)fps minBitrate:(int)minBitrate maxBitrate:(int)maxBitrate;

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

//////////////////////////////////////////////// 云端外设交互 ////////////////////////////////////////////////

/**
 * Return the interface to interact with the cloud keyboard in this session.
 *
 * @return The interface to interact with the cloud keyboard in this session.
 */
- (id<Keyboard>_Nonnull)getKeyboard;

/**
 * Return the interface to interact with the cloud Mouse in this session.
 *
 * @return The interface to interact with the cloud Mouse in this session.
 */
- (id<Mouse>_Nonnull)getMouse;

/**
 * Return the interface to interact with the cloud Gamepad in this session.
 *
 * @return The interface to interact with the cloud Gamepad in this session.
 */
- (id<Gamepad>_Nonnull)getGamepad;

/**
 * Return the interface to interact with the cloud TouchScreen in this session.
 *
 * @return The interface to interact with the cloud TouchScreen in this session.
 */
- (id<TouchScreen>_Nonnull)getTouchScreen;

/**
 * Creates a custom data channel.
 *
 * @param port The cloud port number uniquely identifying the data channel.
 * @param observer The {@link CustomDataChannel.Observer}.
 * @return the created data channel.
 * @see CustomDataChannel
 */
- (CustomDataChannel*_Nonnull)createCustomDataChannel:(int)port observer:(id<CustomDataChannelObserver>_Nullable)observer;

//////////////////////////////////////////////// 多人互动云游 ////////////////////////////////////////////////

/**
 * Switch the role and seat of a user (`userID`) to `targetRole` and `targetPlayerIndex` respectively.
 *
 * @param userId The target user ID
 * @param targetRole The target role `{@link Role}`
 * @param targetPlayerIndex The target seat. This parameter can take effect only for the `Player` role and
 *         will be `0` for the `Viewer` role.
 */
- (void)changeSeat:(NSString *_Nonnull)userId targetRole:(NSString *_Nonnull)targetRole targetPlayerIndex:(int)targetPlayerIndex blk:(void(^_Nullable)(int retCode))finishBlk;

/**
 * Apply to the room owner to switch the role and seat of a player (`userID`) to `targetRole` and
 * `targetPlayerIndex` respectively.
 *
 * @param userId The target user ID
 * @param targetRole The target role `{@link Role}`
 * @param targetPlayerIndex The target seat. This parameter can take effect only for the `Player` role and
 *         will be `0` for the `Viewer` role.
 */
- (void)requestChangeSeat:(NSString *_Nonnull)userId targetRole:(NSString *_Nonnull)targetRole targetPlayerIndex:(int)targetPlayerIndex blk:(void(^_Nullable)(int retCode))finishBlk;


- (void)setMicMute:(NSString *_Nonnull)userID micStatus:(int)micStatus blk:(void(^_Nullable)(int retCode))finishBlk;

- (void)syncRoomInfo;
+ (void)setAudioSessionDelegate:(id<TCGAudioSessionDelegate>)delegate;

@end


