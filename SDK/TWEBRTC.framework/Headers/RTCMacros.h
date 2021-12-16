/*
 *  Copyright 2016 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#ifndef SDK_OBJC_BASE_RTCMACROS_H_
#define SDK_OBJC_BASE_RTCMACROS_H_

#define RTC_OBJC_EXPORT __attribute__((visibility("default")))

#if defined(__cplusplus)
#define RTC_EXTERN extern "C" RTC_OBJC_EXPORT
#else
#define RTC_EXTERN extern RTC_OBJC_EXPORT
#endif

#ifdef __OBJC__
#define RTC_FWD_DECL_OBJC_CLASS(classname) @class classname
#else
#define RTC_FWD_DECL_OBJC_CLASS(classname) typedef struct objc_object classname
#endif

#ifdef RTC_IOS_BUILD_SYSBOL_RENAME
//prefix
#define kRTCFieldTrialFlexFec03Key TG_kRTCFieldTrialFlexFec03Key
#define kRTCG722CodecName TG_kRTCG722CodecName
#define kRTCDtmfCodecName TG_kRTCDtmfCodecName
#define RTCGetAndResetMetrics TG_RTCGetAndResetMetrics
#define kRTCH264CodecName TG_kRTCH264CodecName
#define kRTCComfortNoiseCodecName TG_kRTCComfortNoiseCodecName
#define RTCShutdownInternalTracer TG_RTCShutdownInternalTracer
#define kRTCRtxCodecName TG_kRTCRtxCodecName
#define kRTCFlexfecCodecName TG_kRTCFlexfecCodecName
#define RTCEnableMetrics TG_RTCEnableMetrics
#define kRTCIlbcCodecName TG_kRTCIlbcCodecName
#define kRTCFieldTrialSendSideBweWithOverheadKey TG_kRTCFieldTrialSendSideBweWithOverheadKey
#define RTCStartInternalCapture TG_RTCStartInternalCapture
#define kRTCFieldTrialMinimizeResamplingOnMobileKey TG_kRTCFieldTrialMinimizeResamplingOnMobileKey
#define kRTCPcmaCodecName TG_kRTCPcmaCodecName
#define kRTCVp8CodecName TG_kRTCVp8CodecName
#define RTCStopInternalCapture TG_RTCStopInternalCapture
#define kRTCFieldTrialFlexFec03AdvertisedKey TG_kRTCFieldTrialFlexFec03AdvertisedKey
#define RTCInitializeSSL TG_RTCInitializeSSL
#define kRTCFieldTrialAudioForceABWENoTWCCKey TG_kRTCFieldTrialAudioForceABWENoTWCCKey
#define kRTCPeerConnectionErrorDomain TG_kRTCPeerConnectionErrorDomain
#define kRTCUlpfecCodecName TG_kRTCUlpfecCodecName
#define kRTCFieldTrialH264HighProfileKey TG_kRTCFieldTrialH264HighProfileKey
#define kRTCMediaStreamTrackKindAudio TG_kRTCMediaStreamTrackKindAudio
#define kRTCFieldTrialEnabledValue TG_kRTCFieldTrialEnabledValue
#define kRTCFieldTrialAudioSendSideBweKey TG_kRTCFieldTrialAudioSendSideBweKey
#define kRTCRedCodecName TG_kRTCRedCodecName
#define kRTCIsacCodecName TG_kRTCIsacCodecName
#define RTCCleanupSSL TG_RTCCleanupSSL
#define kRTCMediaStreamTrackKindVideo TG_kRTCMediaStreamTrackKindVideo
#define RTCSetupInternalTracer TG_RTCSetupInternalTracer
#define kRTCPcmuCodecName TG_kRTCPcmuCodecName
#define kRTCL16CodecName TG_kRTCL16CodecName
#define kRTCOpusCodecName TG_kRTCOpusCodecName
#define kRTCVp9CodecName TG_kRTCVp9CodecName
#define kRTCFieldTrialAudioForceNoTWCCKey TG_kRTCFieldTrialAudioForceNoTWCCKey
#define RTCInitFieldTrialDictionary TG_RTCInitFieldTrialDictionary
#define RTCCreateProgram TG_RTCCreateProgram
#define RTCCreateProgramFromFragmentSource TG_RTCCreateProgramFromFragmentSource
#define RTCCreateShader TG_RTCCreateShader
#define RTCCreateVertexBuffer TG_RTCCreateVertexBuffer
#define RTCLogEx TG_RTCLogEx
#define RTCSetMinDebugLogLevel TG_RTCSetMinDebugLogLevel
#define RTCSetVertexData TG_RTCSetVertexData
#define RTCFileName TG_RTCFileName
#define RTCCodecSpecificInfo TG_RTCCodecSpecificInfo
#define RTCAudioSession                  TG_RTCAudioSession
#define RTCAudioSessionConfiguration                TG_RTCAudioSessionConfiguration
#define RTCEncodedImage                TG_RTCEncodedImage
#define RTCRtpFragmentationHeader                TG_RTCRtpFragmentationHeader
#define RTCVideoCapturer                TG_RTCVideoCapturer
#define RTCVideoCodecInfo                 TG_RTCVideoCodecInfo
#define RTCVideoEncoderQpThresholds                TG_RTCVideoEncoderQpThresholds
#define RTCVideoEncoderSettings                 TG_RTCVideoEncoderSettings
#define RTCVideoFrame                 TG_RTCVideoFrame
#define RTCAudioSource                 TG_RTCAudioSource
#define RTCAudioTrack                 TG_RTCAudioTrack

#define RTCDataBuffer                TG_RTCDataBuffer
#define RTCDataChannel                 TG_RTCDataChannel
#define RTCDataChannelConfiguration                 TG_RTCDataChannelConfiguration
#define RTCIceCandidate                 TG_RTCIceCandidate
#define RTCIceServer                TG_RTCIceServer
#define RTCIntervalRange                TG_RTCIntervalRange
#define RTCLegacyStatsReport                TG_RTCLegacyStatsReport
#define RTCMediaStream                TG_RTCMediaStream
#define RTCMediaStreamTrack                TG_RTCMediaStreamTrack
#define RTCMetricsSampleInfo                TG_RTCMetricsSampleInfo
#define RTCPeerConnection                TG_RTCPeerConnection
#define RTCPeerConnectionFactory                TG_RTCPeerConnectionFactory
#define RTCRtpCodecParameters                 TG_RTCRtpCodecParameters
#define RTCRtpEncodingParameters                TG_RTCRtpEncodingParameters
#define RTCRtpParameters                 TG_RTCRtpParameters
#define RTCRtpReceiver                TG_RTCRtpReceiver
#define RTCRtpSender                 TG_RTCRtpSender
#define RTCSessionDescription                TG_RTCSessionDescription
#define RTCVideoTrack                 TG_RTCVideoTrack
#define RTCDisplayLinkTimer                TG_RTCDisplayLinkTimer
#define RTCEAGLVideoView                 TG_RTCEAGLVideoView
#define RTCCameraVideoCapturer                 TG_RTCCameraVideoCapturer
#define RTCFileVideoCapturer                TG_RTCFileVideoCapturer
#define RTCCodecSpecificInfoH264                TG_RTCCodecSpecificInfoH264
#define RTCVideoDecoderFactoryH264               TG_RTCVideoDecoderFactoryH264
#define RTCVideoDecoderH264               TG_RTCVideoDecoderH264
#define RTCVideoEncoderFactoryH264               TG_RTCVideoEncoderFactoryH264
#define RTCVideoEncoderH264               TG_RTCVideoEncoderH264
#define RTCMTLI420Renderer                TG_RTCMTLI420Renderer
#define RTCMTLRenderer               TG_RTCMTLRenderer
#define RTCMTLNV12Renderer               TG_RTCMTLNV12Renderer
#define RTCMTLVideoView                TG_RTCMTLVideoView
#define RTCFileLogger               TG_RTCFileLogger
#define RTCDispatcher               TG_RTCDispatcher
     #define        RTCCameraPreviewView               TG_TCCameraPreviewView
#define RTCI420Buffer               TG_RTCI420Buffer
#define RTCMutableI420Buffer                TG_RTCMutableI420Buffer
#define RTCCVPixelBuffer                TG_RTCCVPixelBuffer
#define RTCMediaConstraints               TG_RTCMediaConstraints
#define RTCMediaSource               TG_RTCMediaSource
#define RTCDefaultShader               TG_RTCDefaultShader
#define RTCI420TextureCache                TG_RTCI420TextureCache
#define RTCNV12TextureCache               TG_RTCNV12TextureCache
#define RTCVideoSource                TG_RTCVideoSource
#define RTCVideoRendererAdapter               TG_RTCVideoRendererAdapter
#define RTCConfiguration TG_RTCConfiguration
#define RTCDefaultVideoDecoderFactory TG_RTCDefaultVideoDecoderFactory
#define RTCCallbackLogger TG_RTCCallbackLogger
#define RTCVideoEncoderVP9 TG_RTCVideoEncoderVP9
#define RTCWrappedNativeVideoEncoder TG_RTCWrappedNativeVideoEncoder
#define  RTCNativeAudioSessionDelegateAdapter    TG_RTCNativeAudioSessionDelegateAdapter
#define  RTCDefaultVideoDecoderFactory    TG_RTCDefaultVideoDecoderFactory
#define  RTCDefaultVideoEncoderFactory    TG_RTCDefaultVideoEncoderFactory
#define  RTCObjCVideoSourceAdapter    TG_RTCObjCVideoSourceAdapter
//#define  RTCCertificate    OBJRTCCertificate
#define  RTCCryptoOptions   TG_RTCCryptoOptions
#define  RTCDtmfSender   TG_RTCDtmfSender
#define  RTCPeerConnectionFactoryBuilder   TG_RTCPeerConnectionFactoryBuilder
#define  RTCPeerConnectionFactoryOptions    TG_RTCPeerConnectionFactoryOptions
#define  RTCRtcpParameters   TG_RTCRtcpParameters
#define  RTCRtpHeaderExtension   TG_RTCRtpHeaderExtension
#define  RTCRtpTransceiverInit    TG_RTCRtpTransceiverInit
#define  RTCRtpTransceiver    TG_RTCRtpTransceiver
#define  RTCStatistics    TG_RTCStatistics
#define  RTCStatisticsReport    TG_RTCStatisticsReport
#define  RTCH264ProfileLevelId    TG_RTCH264ProfileLevelId
#define  RTCMTLRGBRenderer   TG_RTCMTLRGBRenderer
#define  RTCCallbackLogger   TG_RTCCallbackLogger
#define  RTCWrappedEncodedImageBuffer    TG_RTCWrappedEncodedImageBuffer
#define  RTCWrappedNativeVideoDecoder   TG_RTCWrappedNativeVideoDecoder
#define  RTCWrappedNativeVideoEncoder  TG_RTCWrappedNativeVideoEncoder
//#define RTCSetMinDebugLogLevel TG_RTCSetMinDebugLogLevel

//#define RTCAudioSource TC_RTCAudioSource
//#define RTCAudioTrack TC_RTCAudioTrack
//#define RTCAudioSession TC_RTCAudioSession
//#define RTCAudioSessionConfiguration TC_RTCAudioSessionConfiguration
//#define RTCCVPixelBuffer TC_RTCCVPixelBuffer
//#define RTCCallbackLogger TC_RTCCallbackLogger
//#define RTCCameraPreviewView TC_RTCCameraPreviewView
//#define RTCCameraVideoCapturer TC_RTCCameraVideoCapturer
////#define RTCCertificate TC_RTCCertificate
//
//#define RTCCodecSpecificInfoH264 TC_RTCCodecSpecificInfoH264
////#define RTCConfiguration TC_RTCConfiguration
//#define RTCCryptoOptions TC_RTCCryptoOptions
//#define RTCDataBuffer TC_RTCDataBuffer

#endif

#endif  // SDK_OBJC_BASE_RTCMACROS_H_
