//
//  TcrSdkInstance.h
//  tcrsdk
//
//  Created by xxhape on 2023/10/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AndroidInstance.h"
#import "TCRSdkConst.h"
NS_ASSUME_NONNULL_BEGIN

#pragma mark--- 日志接口 ---
@protocol TCRLogDelegate <NSObject>
@required
/*!
 日志打印回调接口
 @param logLevel 日志打印级别
 @param log log
 */
- (void)logWithLevel:(TCRLogLevel)logLevel log:(NSString *_Nullable)log;
@end

/*!
 * Session configuration information, which is obtained by the business backend calling the cloud API CreateAndroidInstancesAccessToken.
 */
@interface TcrConfig : NSObject
@property(nonatomic, copy)NSString* token;
@property(nonatomic, copy)NSString* accessInfo;

-(instancetype)initWithToken:(NSString*)token accessInfo:(NSString*)accessInfo;
@end

@interface TcrSdkInstance : NSObject

+ (instancetype)sharedInstance;

+ (void)setLogger:(id<TCRLogDelegate> _Nonnull)logger withMinLevel:(TCRLogLevel)minLevel;
/**
 * Set the AccessInfo and Token to TcrSdk
 *
 * @param tcrConfig Session configuration information, which is obtained by the business backend calling the cloud API CreateAndroidInstancesAccessToken.
 *
 */
- (void)setTcrConfig:(TcrConfig*) tcrConfig error:(NSError**)error;

/**
 * @brief Creates a new TcrSession instance.
 *
 * @discussion Initializes and returns a new TcrSession object with the specified parameters.
 * Returns a non-nil pointer on success, nil on failure. The caller is responsible for
 * managing the returned session's lifecycle (automatically handled under ARC).
 *
 * @param params Dictionary containing TcrSession configuration parameters.<br>
 *          Optional, the following key-value pairs can be selected:
 *         - @"preferredCodec": Optional values are @"H264", @"H265", @"VP8", and @"VP9". Used to set the preferred codec.
 *          If this field is set, the session will try to use the preferred codec for communication. If the preferred codec is not available,
 *          other available codecs will be used. If this field is not set or the setting is invalid, the session will use the default codec.
 *
 *         - @"preferredCodecList":  The value is an NSArray, which contains the optional values @"H264", @"H265", @"VP8", and @"VP9".
 *          Indicate preferred codecs, where the order of the elements in the list represents priority, such as index 0 being the highest priority
 *          preferred codec. If the set codecs cannot be selected for various reasons, other available codecs will be chosen.
 *
 *         - @"idleThreshold": The idle detection threshold, that is, the duration of user inactivity. The unit is Millisecond. When this threshold is reached, the event TcrEvent.CLIENT_IDLE will be triggered.
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
 * @return Newly created TcrSession instance, nil if creation fails.
 */
- (TcrSession*)createSessionWithParams:(NSDictionary*)params;

/**
 * @brief Destroys a session object.
 *
 * @param session Session object to destroy.
 */
-(void)destroySession:(TcrSession*) session;

/**
 * @brief Retrieves the AndroidInstance operator object.
 *
 * @discussion Returns the operator instance for interacting with cloud Android devices.
 * Returns nil if the SDK client hasn't been properly initialized.
 *
 * @return AndroidInstance operator object, nil if uninitialized.
 */
- (AndroidInstance*)getAndroidInstance;

/**
 * @brief Updates access tokens for all instances.
 *
 * @discussion Bulk updates access tokens for all created instances. This operation takes
 * immediate effect, and all subsequent requests will use the new token for authentication.
 *
 * @param token New access token string.
 */
- (void)updateToken:(NSString *)token;
@end
NS_ASSUME_NONNULL_END
