//
//  tcgsdk.m
//  tcgsdk
//
//  Created by okhowang(王沛文) on 2020/3/25.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "tcgsdk.h"

#import <WebRTC/WebRTC.h>
#import <stdatomic.h>

#import "TcgSdkDefaultLogger.h"
#import "TcgSdkOverlayView.h"
#import "TcgSdkReport+Private.h"
#import "TcgSdkUtils.h"
#import "macros.h"

@interface TcgSdkCommonResponse : NSObject
// common field
@property NSNumber *code;
@property NSString *message;
@property NSString *timestamp;
@property NSNumber *seq;
@property NSDictionary *data;
// other field
@property NSDictionary *raw_;
@end

@implementation TcgSdkCommonResponse
- (NSString *)description {
    return [NSString stringWithFormat:@"Response{%@}", self.raw_];
}
@end

@interface TcgSdk () <RTCPeerConnectionDelegate, RTCDataChannelDelegate, RTCVideoViewDelegate>
@end

@implementation TcgSdk {
    __weak id<TcgSdkDelegate> _delegate;
    __weak UIView *_view;
    __weak UIView<RTCVideoRenderer> *_videoView;
    TcgSdkOverlayView *_overlayView;
    CGSize _videoRawSize;
    bool cursorShowing;

    float _mouseX, _mouseY;
    RTCPeerConnection *_connection;
    RTCDataChannel *_kmDataChannel;
    RTCDataChannel *_hbDataChannel;
    RTCDataChannel *_ackDataChannel;
    RTCDataChannel *_cdDataChannel;
    RTCVideoTrack *_remoteVideoTrack;
    RTCSessionDescription *_sdp;
    NSTimer *_hbTimer;
    atomic_uint_fast64_t _eventIndex;
    atomic_uint_fast64_t _seqIndex;
    NSMutableDictionary<NSNumber *, void (^)(TcgSdkCommonResponse *)> *_ackCallback;
    NSMutableDictionary<NSNumber *, NSTimer *> *_ackTimer;

    id<TcgSdkLogger> _logger;
    TcgSdkLogLevel _logLevel;
    TcgSdkReport *_report;

    dispatch_queue_t _queue;
}

#define __FILENAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)
#define LOG(self, level, fmt, ...)                                                           \
    do {                                                                                     \
        if (level > self->_logLevel) break;                                                  \
        [self->_logger logWithLevel:level                                                    \
                             andStr:[NSString stringWithFormat:@"(%s:%d)" fmt, __FILENAME__, \
                                                               __LINE__, ##__VA_ARGS__]];    \
    } while (0)
#define LOG_TRACE(fmt, ...) LOG(self, TcgSdkLogLevelTrace, fmt, ##__VA_ARGS__)
#define LOG_DEBUG(fmt, ...) LOG(self, TcgSdkLogLevelDebug, fmt, ##__VA_ARGS__)
#define LOG_INFO(fmt, ...) LOG(self, TcgSdkLogLevelInfo, fmt, ##__VA_ARGS__)
#define LOG_WARNING(fmt, ...) LOG(self, TcgSdkLogLevelWarning, fmt, ##__VA_ARGS__)
#define LOG_ERROR(fmt, ...) LOG(self, TcgSdkLogLevelError, fmt, ##__VA_ARGS__)
#define LOG_FATAL(fmt, ...) LOG(self, TcgSdkLogLevelFatail, fmt, ##__VA_ARGS__)
#define LOG_NONE(fmt, ...) LOG(self, TcgSdkLogLevelNone, fmt, ##__VA_ARGS__)
#pragma mark - Public

+ (TcgSdkDefaultLogger *)defaultLogger {
    static TcgSdkDefaultLogger *logger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      logger = [TcgSdkDefaultLogger new];
    });
    return logger;
}

- (void)setLogger:(id<TcgSdkLogger>)logger {
    self->_logger = logger ? logger : [TcgSdk defaultLogger];
}

- (void)setLogLevel:(TcgSdkLogLevel)level {
    self->_logLevel = level;
}

- (instancetype)initWithParams:(TcgSdkParams *)params andDelegate:(id<TcgSdkDelegate>)listener {
    RTCSetMinDebugLogLevel(RTCLoggingSeverityNone);
    if (self = [super init]) {
        _delegate = listener;
        _view = params.view;
        _queue = dispatch_queue_create("tcgsdk-queue", DISPATCH_QUEUE_CONCURRENT);
        _logger = [TcgSdk defaultLogger];
        _report = [TcgSdkReport new];

        RTCConfiguration *config = [RTCConfiguration new];
        config.sdpSemantics = RTCSdpSemanticsUnifiedPlan;
        RTCMediaConstraints *constraints =
            [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:nil];
        _connection = [[TcgSdk factory] peerConnectionWithConfiguration:config
                                                            constraints:constraints
                                                               delegate:self];

        _ackCallback = [NSMutableDictionary new];
        _ackTimer = [NSMutableDictionary new];

        RTCDataChannelConfiguration *dataChannelConfiguration = [RTCDataChannelConfiguration new];
        dataChannelConfiguration.isOrdered = true;
        _kmDataChannel = [_connection dataChannelForLabel:@"km"
                                            configuration:dataChannelConfiguration];
        _kmDataChannel.delegate = self;
        _ackDataChannel = [_connection dataChannelForLabel:@"ack"
                                             configuration:dataChannelConfiguration];
        _ackDataChannel.delegate = self;
        _hbDataChannel = [_connection dataChannelForLabel:@"hb"
                                            configuration:dataChannelConfiguration];
        _hbDataChannel.delegate = self;
        _cdDataChannel = [_connection dataChannelForLabel:@"cd"
                                            configuration:dataChannelConfiguration];
        _cdDataChannel.delegate = self;

        CGRect rect = [_view convertRect:_view.frame fromView:_view.superview];
#if defined(RTC_SUPPORTS_METAL)
        // Using metal (arm64 only)
        RTCMTLVideoView *renderer = [[RTCMTLVideoView alloc] initWithFrame:_view.frame];
        renderer.videoContentMode = UIViewContentModeScaleAspectFit;
#else
        // Using OpenGLES for the rest
        RTCEAGLVideoView *renderer = [[RTCEAGLVideoView alloc] initWithFrame:rect];
#endif
        [_view addSubview:renderer];
        renderer.delegate = self;
        _videoView = renderer;
        _overlayView = [[TcgSdkOverlayView alloc] initWithFrame:rect];
        [_view addSubview:_overlayView];

        RTCRtpTransceiverInit *transceiverInit = [RTCRtpTransceiverInit new];
        transceiverInit.direction = RTCRtpTransceiverDirectionRecvOnly;

        [_connection addTransceiverOfType:RTCRtpMediaTypeVideo init:transceiverInit];
        [_connection addTransceiverOfType:RTCRtpMediaTypeAudio init:transceiverInit];
        RTCMediaConstraints *mediaConstraints =
            [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:nil];
        [_connection offerForConstraints:mediaConstraints
                       completionHandler:^(RTCSessionDescription *sdp, NSError *error) {
                         if (error != nil) {
                             [self->_delegate tcg:self didInit:error andView:self->_videoView];
                             return;
                         }
                         __weak TcgSdk *weakSelf = self;
                         LOG_DEBUG("offer %@", sdp.sdp);
                         [self->_connection setLocalDescription:sdp
                                              completionHandler:^(NSError *error) {
                                                TcgSdk *strongSelf = weakSelf;
                                                if (error != nil) {
                                                    [strongSelf->_delegate
                                                            tcg:weakSelf
                                                        didInit:error
                                                        andView:strongSelf->_videoView];
                                                    return;
                                                }
                                                self->_sdp = sdp;
                                                [strongSelf->_delegate tcg:weakSelf
                                                                   didInit:nil
                                                                   andView:strongSelf->_videoView];
                                              }];
                       }];
    }
    return self;
}

- (NSString *)getClientSession {
    NSString *profile;
    NSNumber *profileType;
    [self getH264Info:&profile andType:&profileType];
    NSDictionary *json = @{
        @"type" : [RTCSessionDescription stringForType:_sdp.type],
        @"sdp" : _sdp.sdp,
        @"isPlanB" : NSBOOL([self isPlanB]),
        @"payloadType" : @98,
        @"profile" : @"level-asymmetry-allowed=1;packetization-mode=1;profile-"
                     @"level-id=42e02a",
    };
    NSData *data = toJSON(json);
    return [data base64EncodedStringWithOptions:0];
}

- (bool)start:(NSString *)serverSession {
    NSData *session =
        [[NSData alloc] initWithBase64EncodedString:serverSession
                                            options:NSDataBase64DecodingIgnoreUnknownCharacters];
    LOG_DEBUG("answer->%@", [[NSString alloc] initWithData:session encoding:NSUTF8StringEncoding]);
    NSError *error;
    TcgSdkCommonResponse *response = [self parseJSONCommon:session error:&error];
    if (error != nil || response == nil) {
        LOG_ERROR("parse response error %@ %@", error, response);
        return false;
    }
    NSString *tips = nil;
    long code = response.code ? [[response code] longValue] : -1;
    switch (code) {
        case 0:
            break;
        case 1:
            tips = [NSString stringWithFormat:@"系统繁忙,请稍后重试.code=%ld", code];
            break;
        case 2:
            tips = [NSString stringWithFormat:@"票据不合法.code=%ld", code];
            break;
        case 3:
            tips = [NSString
                stringWithFormat:@"我们建议您使用超过10Mbps的带宽以完美体验腾讯云云游戏.code=%ld",
                                 code];
            break;
        case 4:
            tips = [NSString stringWithFormat:@"资源不足,请稍后重试.code=%ld", code];
            break;
        case 5:
            tips = [NSString stringWithFormat:@"票据失效.code=%ld", code];
            break;
        case 6:
            tips = [NSString stringWithFormat:@"SDP错误信息错误.code=%ld", code];
            break;
        case 7:
            tips = [NSString stringWithFormat:@"游戏拉起失败.code=%ld", code];
            break;
        case 8:
            tips = [NSString stringWithFormat:@"下载用户游戏存档失败.code=%ld", code];
            break;
        default:
            tips = [NSString stringWithFormat:@"其他错误.code=%ld", code];
            break;
    }
    if (tips) {
        // TODO show tips
    }
    if (code) return false;
    id typeObj = response.raw_[@"type"];
    id sdpObj = response.raw_[@"sdp"];
    LOG_DEBUG("answer %@", sdpObj);
    __weak TcgSdk *weakSelf = self;
    [_connection
        setRemoteDescription:[[RTCSessionDescription alloc]
                                 initWithType:[RTCSessionDescription typeForString:typeObj]
                                          sdp:sdpObj]
           completionHandler:^(NSError *error) {
             TcgSdk *strongSelf = weakSelf;
             if (error != nil) {
                 LOG(strongSelf, TcgSdkLogLevelError, "set remote description error %@", error);
                 [strongSelf->_delegate tcg:strongSelf didConnect:error];
                 return;
             }
             dispatch_async(dispatch_get_main_queue(), ^{
               TcgSdk *strongSelf = weakSelf;
               strongSelf->_hbTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                       target:self
                                                                     selector:@selector(timer:)
                                                                     userInfo:nil
                                                                      repeats:true];
             });
           }];
    self->_report.serverIP = toType(response.raw_[@"server_ip"], [NSString class]);
    self->_report.region = toType(response.raw_[@"region"], [NSString class]);
    LOG_INFO("server ip %@", response.raw_[@"server_ip"]);
    LOG_INFO("region %@", response.raw_[@"region"]);
    return true;
}

- (void)destroy {
    [self disconnectWithCode:@-1 andMessage:@"user operation"];
}

- (void)sendKeyEvent:(NSInteger)key down:(bool)down {
    NSDictionary *data = [[[TcgSdkEvent alloc] initKeyEvent:TcgSdkEventTypeKeyboard
                                                     andKey:key
                                                    andDown:down] data];
    [self sendKmRawData:toJSON(data)];
}

- (void)mouseMoveX:(float)x andY:(float)y {
    if (_tabletMouseMode) {
        @synchronized(self) {
            self->_mouseX += x;
            self->_mouseY += y;
            if (self->_mouseX < 0) self->_mouseX = 0;
            if (self->_mouseY < 0) self->_mouseY = 0;
            if (self->_mouseX > self->_videoRawSize.width)
                self->_mouseX = self->_videoRawSize.width;
            if (self->_mouseY > self->_videoRawSize.height)
                self->_mouseY = self->_videoRawSize.height;
        }
        NSDictionary *data = [[[TcgSdkEvent alloc]
            initLocationEvent:self->cursorShowing ? TcgSdkEventTypeMouseMove
                                                  : TcgSdkEventTypeMouseDeltaMove
                         andX:self->_mouseX
                         andY:self->_mouseY] data];
        [self sendKmRawData:toJSON(data)];
        dispatch_async(dispatch_get_main_queue(), ^{
          self->_overlayView.mousePoint = CGPointMake(
              self->_mouseX / self->_videoRawSize.width * self->_videoView.frame.size.width,
              self->_mouseY / self->_videoRawSize.height * self->_videoView.frame.size.height);
        });
    } else {
        float mappedX = x * _videoRawSize.width / _videoView.frame.size.width;
        float mappedY = y * _videoRawSize.height / _videoView.frame.size.height;
        NSDictionary *data = [[[TcgSdkEvent alloc]
            initLocationEvent:self->cursorShowing ? TcgSdkEventTypeMouseMove
                                                  : TcgSdkEventTypeMouseDeltaMove
                         andX:mappedX
                         andY:mappedY] data];
        [self sendKmRawData:toJSON(data)];
        self->_overlayView.mousePoint = CGPointMake(x, y);
        _mouseX = mappedX;
        _mouseY = mappedY;
    }
}

- (void)sendRawEvent:(TcgSdkEvent *)event {
    NSDictionary *data = [event data];
    [self sendAckData:data withTimeout:0 completionHandler:nil];
}

- (void)sendRawEvents:(NSArray<TcgSdkEvent *> *)events {
    NSMutableArray *data = [NSMutableArray new];
    for (TcgSdkEvent *event in events) {
        [data addObject:toJSONString([event data])];
    }
    [self sendKmRawData:toJSON(@{@"type" : @"key_seq", @"keys" : data})];
}

- (void)setCursorMode:(TcgSdkCursorMode)mode {
    _cursorMode = mode;
    [self sendAckData:@{@"type" : @"set_cursor", @"show" : @(mode)}
              withTimeout:1
        completionHandler:^(TcgSdkCommonResponse *rsp) {
          self->_overlayView.drawMouse = (mode != TcgSdkCursorModeRemote) && self->cursorShowing;
        }];
}

- (void)setStreamProfileWithFps:(NSUInteger)fps
                  andMaxBitRate:(NSUInteger)max
                  andMinBitRate:(NSUInteger)min {
    [self sendAckData:@{
        @"type" : @"res_mode",
        @"res" : @"",
        @"fps" : @(fps),
        @"min_bitrate" : @(min),
        @"max_bitrate" : @(max)
    }
              withTimeout:0
        completionHandler:nil];
}

- (void)setVolume:(float)volume {
    for (RTCRtpTransceiver *transceiver in [self->_connection transceivers]) {
        if (transceiver.mediaType == RTCRtpMediaTypeAudio &&
            transceiver.direction == RTCRtpTransceiverDirectionRecvOnly) {
            RTCAudioTrack *track = (RTCAudioTrack *)transceiver.receiver.track;
            track.source.volume = volume;
        }
    }
}

- (void)restart {
    [self sendAckData:@{@"type" : @"game_op", @"op" : @"restart"}
              withTimeout:0
        completionHandler:nil];
}

#pragma mark - Private

- (bool)isPlanB {
    return [_sdp.sdp rangeOfString:@"mid:video"].location != NSNotFound ||
           [_sdp.sdp rangeOfString:@"mid:audio"].location != NSNotFound ||
           [_sdp.sdp rangeOfString:@"mid:data"].location != NSNotFound;
}

- (void)getH264Info:(NSString **)profile andType:(NSNumber **)type {
    NSError *error;
    NSRegularExpression *h264 =
        [[NSRegularExpression alloc] initWithPattern:@"^a=rtpmap:(\\d+) H264/"
                                             options:0
                                               error:&error];
    assert(h264);
    assert(error == nil);
    NSRegularExpression *fmtp =
        [[NSRegularExpression alloc] initWithPattern:@"^a=fmtp:(\\d+) (\\S+)$"
                                             options:0
                                               error:&error];
    assert(fmtp);
    assert(error == nil);
    *profile = @"";
    *type = @0;
    NSArray<NSString *> *lines = [_sdp.sdp componentsSeparatedByString:@"\r\n"];
    NSMutableArray<NSString *> *profileTypes = [NSMutableArray new];
    NSMutableDictionary<NSString *, NSString *> *profiles = [NSMutableDictionary new];
    for (NSString *line in lines) {
        NSTextCheckingResult *result = [h264 firstMatchInString:line
                                                        options:0
                                                          range:NSMakeRange(0, line.length)];
        if (result != nil) {
            NSRange id = [result rangeAtIndex:1];
            NSString *stype = [line substringWithRange:id];
            [profileTypes addObject:stype];
            continue;
        }
        result = [fmtp firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
        if (result != nil) {
            NSRange id = [result rangeAtIndex:1];
            NSRange value = [result rangeAtIndex:2];
            NSString *stype = [line substringWithRange:id];
            if ([profileTypes containsObject:stype]) {
                NSString *sprofile = [line substringWithRange:value];
                profiles[stype] = sprofile;
            }
        }
    }
    NSRegularExpression *profileRegexp =
        [[NSRegularExpression alloc] initWithPattern:@"profile-level-id=(\\S+)"
                                             options:0
                                               error:&error];
    assert(profileRegexp);
    assert(error == nil);
    for (NSString *payloadType in profiles) {
        NSString *profileCandidate = profiles[payloadType];
        NSTextCheckingResult *result =
            [profileRegexp firstMatchInString:profileCandidate
                                      options:0
                                        range:NSMakeRange(0, [profileCandidate length])];
        if (result == nil) continue;
        RTCH264ProfileLevelId *profileId = [[RTCH264ProfileLevelId alloc]
            initWithHexString:[profileCandidate substringWithRange:[result rangeAtIndex:1]]];
        if (profileId.profile == RTCH264ProfileConstrainedBaseline) {
            *type = [[NSNumberFormatter new] numberFromString:payloadType];
            *profile = profileCandidate;
        }
    }
    LOG_DEBUG("%@", profiles);
}

- (void)timer:(NSTimer *)timer {
    [_connection statsForTrack:nil
              statsOutputLevel:RTCStatsOutputLevelDebug
             completionHandler:^(NSArray<RTCLegacyStatsReport *> *reports) {
               [self->_report retrieveFromRTCStatsReports:reports];

               NSDictionary *obj =
                   @{@"timestamp" : @((long)[[NSDate date] timeIntervalSince1970] * 1000)};
               NSData *data = toJSON(obj);
               if (self->_hbDataChannel.readyState == RTCDataChannelStateOpen)
                   [self->_hbDataChannel sendData:[[RTCDataBuffer alloc] initWithData:data
                                                                             isBinary:false]];
               else
                   LOG_WARNING("hb channel not open yet");
               LOG_DEBUG("send hb data");
               self->_overlayView.debugInfo = self->_debugDisplay ? self->_report.description : nil;

               if ([self->_delegate respondsToSelector:@selector(tcg:didStats:)])
                   [self->_delegate tcg:self didStats:self->_report];
             }];
}

+ (RTCPeerConnectionFactory *)factory {
    static RTCPeerConnectionFactory *factory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      factory = [RTCPeerConnectionFactory new];
    });
    return factory;
}

+ (id)parseObj:(id)obj withClass:(Class)aClass {
    if ([obj isKindOfClass:aClass]) return obj;
    return nil;
}

- (TcgSdkCommonResponse *)parseJSONCommon:(NSData *)buffer error:(NSError **)error {
    id json = [NSJSONSerialization JSONObjectWithData:buffer options:0 error:error];
    if (*error != nil || ![json isKindOfClass:[NSDictionary class]]) {
        LOG_ERROR("json serialization error %@ %@", *error, json);
        return nil;
    }
    NSDictionary *obj = (NSDictionary *)json;
    TcgSdkCommonResponse *response = [TcgSdkCommonResponse new];
    response.code = toType(obj[@"code"], [NSNumber class]);
    response.message = toType(obj[@"message"], [NSString class]);
    response.data = toType(obj[@"data"], [NSDictionary class]);
    response.timestamp = [TcgSdk parseObj:obj[@"data"] withClass:[NSNumber class]];
    response.seq = [TcgSdk parseObj:obj[@"seq"] withClass:[NSNumber class]];
    response.raw_ = obj;
    return response;
}

- (void)disconnectWithCode:(NSNumber *)code andMessage:(NSString *)message {
    LOG_INFO("disconnectWithCode %@ %@", code, message);
    [_hbTimer invalidate];
    [_kmDataChannel close];
    _kmDataChannel = nil;
    [_hbDataChannel close];
    _hbDataChannel = nil;
    [_ackDataChannel close];
    _ackDataChannel = nil;
    [_delegate tcg:self didDisconnectWithCode:code andMessage:message];
}

- (void)setupGestureForView {
    UITapGestureRecognizer *touch =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];

    [self->_videoView addGestureRecognizer:touch];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    NSDictionary *dict = @{
        @"type" : @"touched",
        @"id" : @(atomic_fetch_add(&self->_eventIndex, 1)),
        @"x" : @(location.x),
        @"y" : @(location.y),
    };
    [self sendAckData:dict withTimeout:0 completionHandler:nil];
}

- (void)sendAckData:(nonnull NSDictionary *)data
          withTimeout:(NSTimeInterval)timeout
    completionHandler:(void (^)(TcgSdkCommonResponse *))handler {
    if (self->_ackDataChannel.readyState != RTCDataChannelStateOpen) {
        LOG_WARNING("ack data channel is not open, don't send data");
        return;
    }
    NSNumber *seq = @(atomic_fetch_add(&self->_seqIndex, 1));
    NSDictionary *dict = @{
        @"seq" : seq,
        @"data" : data,
    };
    NSData *json = toJSON(dict);
    if (timeout != 0 && handler != nil) {
        dispatch_sync(_queue, ^{
          @synchronized(self) {
              _ackCallback[seq] = handler;
              self->_ackTimer[seq] =
                  [NSTimer scheduledTimerWithTimeInterval:timeout
                                                   target:self
                                                 selector:@selector(onAckTimeout:)
                                                 userInfo:seq
                                                  repeats:false];
          }
          LOG_DEBUG("add callback %@", seq);
        });
    }
    [self sendAckRawData:json];
}

- (void)sendAckRawData:(nonnull NSData *)data {
    if (self->_ackDataChannel.readyState != RTCDataChannelStateOpen) {
        LOG_WARNING("ack data channel is not open, don't send data");
        return;
    }
    [self->_ackDataChannel sendData:[[RTCDataBuffer alloc] initWithData:data isBinary:false]];
    LOG_TRACE("send ack data %@", [[NSString alloc] initWithData:data
                                                        encoding:NSUTF8StringEncoding]);
}

- (void)sendKmRawData:(nonnull NSData *)data {
    if (self->_kmDataChannel.readyState != RTCDataChannelStateOpen) {
        LOG_WARNING("ack data channel is not open, don't send data");
        return;
    }
    [self->_kmDataChannel sendData:[[RTCDataBuffer alloc] initWithData:data isBinary:false]];
    LOG_TRACE("send km data %@", [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding]);
}

- (void)onAckTimeout:(NSTimer *)timer {
    LOG_INFO(@"ack timeout %@", timer.userInfo);
    // TODO callback
    @synchronized(self) {
        [_ackTimer removeObjectForKey:timer.userInfo];
        [_ackCallback removeObjectForKey:timer.userInfo];
    }
}

- (void)updateViewFrame {
    if (self->_videoRawSize.height == 0 || self->_videoRawSize.width == 0) return;
    CGSize size = self->_videoRawSize;
    CGRect frame = self->_view.frame;
    CGFloat rawRatio = size.width / size.height;
    CGFloat viewRatio = frame.size.width / frame.size.height;
    CGRect newFrame;
    if (fabsl(rawRatio - viewRatio) < 1e-3) {
        newFrame = frame;
    } else if (rawRatio > viewRatio) {
        newFrame.size.width = frame.size.width;
        newFrame.size.height = frame.size.width / rawRatio;
        newFrame.origin.x = 0;
        newFrame.origin.y = (frame.size.height - newFrame.size.height) / 2;
    } else {
        newFrame.size.height = frame.size.height;
        newFrame.size.width = frame.size.height * rawRatio;
        newFrame.origin.y = 0;
        newFrame.origin.x = (frame.size.width - newFrame.size.width) / 2;
    }
    LOG_INFO(@"video size %f %f, frame size %f %f", size.width, size.height, frame.size.width,
             frame.size.height);
    dispatch_async(dispatch_get_main_queue(), ^{
      [self->_videoView setFrame:newFrame];
      [self->_overlayView setFrame:newFrame];
      [self->_overlayView setNeedsDisplay];
      [self->_delegate tcg:self didFrameChanged:newFrame];
    });
}

#pragma mark - RTCPeerConnectionDelegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didChangeSignalingState:(RTCSignalingState)stateChanged {
    LOG_INFO(@"didChangeSignalingState %zd", stateChanged);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream {
    LOG_INFO(@"addStream %zu", stream.videoTracks.count);
    if (stream.videoTracks.firstObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
          LOG_DEBUG(@"add renderer");
          self->_remoteVideoTrack = stream.videoTracks.firstObject;
          [self->_remoteVideoTrack addRenderer:self->_videoView];
        });
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
       didRemoveStream:(RTCMediaStream *)stream {
    LOG_INFO(@"didRemoteStream %zu", stream.videoTracks.count);
}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection {
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didChangeIceConnectionState:(RTCIceConnectionState)newState {
    LOG_INFO(@"didChangeIceConnectionState %zd", newState);
    if (newState == RTCIceConnectionStateDisconnected) {
        [self disconnectWithCode:@-1 andMessage:@"disconnected, please retry"];
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didChangeIceGatheringState:(RTCIceGatheringState)newState {
    LOG_INFO(@"didChangeIceGatheringState %zd", newState);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didGenerateIceCandidate:(RTCIceCandidate *)candidate {
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didRemoveIceCandidates:(NSArray<RTCIceCandidate *> *)candidates {
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didOpenDataChannel:(RTCDataChannel *)dataChannel {
    LOG_INFO(@"didOpenDataChannel %@", dataChannel.label);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didChangeConnectionState:(RTCPeerConnectionState)newState {
    LOG_INFO(@"didChangeConnectionState %zd", newState);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didStartReceivingOnTransceiver:(RTCRtpTransceiver *)transceiver {
    LOG_INFO(@"didStartReceivingOnTransceiver %@", transceiver.mid);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
        didAddReceiver:(RTCRtpReceiver *)rtpReceiver
               streams:(NSArray<RTCMediaStream *> *)mediaStreams {
    LOG_INFO(@"didAddReceiver %@", rtpReceiver.receiverId);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
     didRemoveReceiver:(RTCRtpReceiver *)rtpReceiver {
    LOG_INFO(@"didRemoveReceiver %@", rtpReceiver.receiverId);
}

#pragma mark - RTCDataChannelDelegate

- (void)dataChannelDidChangeState:(RTCDataChannel *)dataChannel {
    LOG_INFO(@"dataChannelDidChangeState %@ %zd", dataChannel.label, dataChannel.readyState);
    if ([dataChannel.label isEqualToString:@"ack"] &&
        dataChannel.readyState == RTCDataChannelStateOpen) {
        [self->_delegate tcg:self didConnect:nil];
    }
}

- (void)dataChannel:(RTCDataChannel *)dataChannel
    didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer {
    NSString *label = [dataChannel label];
    LOG_TRACE("recv data %@ %@", label,
              [[NSString alloc] initWithData:buffer.data encoding:NSUTF8StringEncoding]);
    if ([label isEqualToString:@"km"]) {
        [self onKmMessage:buffer];
    } else if ([label isEqualToString:@"ack"]) {
        [self onAckMessage:buffer];
    } else if ([label isEqualToString:@"hb"]) {
        [self onHbMessage:buffer];
    } else if ([label isEqualToString:@"cd"]) {
        [self onCdMessage:buffer];
    } else {
        LOG_INFO(@"unknown data channel label:%@", label);
    }
}

- (void)dataChannel:(RTCDataChannel *)dataChannel didChangeBufferedAmount:(uint64_t)amount {
}

- (void)onCdMessage:(RTCDataBuffer *)buffer {
    NSError *error = nil;
    TcgSdkCommonResponse *response = [self parseJSONCommon:buffer.data error:&error];
    if (error != nil || response == nil) {
        LOG_WARNING(@"bad cd message %@ %@", error, response);
        return;
    }
    NSString *imgBase64 = [TcgSdk parseObj:response.data withClass:[NSString class]];
    if (imgBase64 == nil) {
        LOG_WARNING(@"bad cd message, data %@", response);
        return;
    }
    NSData *imgData = [[NSData alloc] initWithBase64EncodedString:imgBase64 options:0];
    if (imgData == nil) {
        LOG_WARNING(@"bad cd message base64, %@", imgBase64);
        return;
    }
    [_overlayView setMouseImage:imgData];
}

- (void)onAckMessage:(RTCDataBuffer *)buffer {
    NSError *error = nil;
    TcgSdkCommonResponse *response = [self parseJSONCommon:buffer.data error:&error];
    if (error != nil || response == nil) {
        LOG_WARNING(@"bad ack response %@ %@", error, response);
        return;
    }
    LOG_TRACE(@"got ack response %@", response);
    if ([response seq]) {
        void (^callback)(TcgSdkCommonResponse *);
        NSTimer *timer;
        @synchronized(self) {
            callback = _ackCallback[response.seq];
            timer = _ackTimer[response.seq];
        }
        if (callback) {
            LOG_DEBUG(@"process callback seq %@", response.seq);
            [timer invalidate];
            callback(response);
            @synchronized(self) {
                [_ackCallback removeObjectForKey:response.seq];
                [_ackTimer removeObjectForKey:response.seq];
            }
        }
    }
    //    if ([@"cursor_state" isEqual:[response data][@"type"]]) {
    //        NSString *state = toType(response.data[@"state"], [NSString class]);
    //        if(state != nil){
    //            bool showing = [state isEqualToString:@"showing"];
    //            self->_overlayView.drawMouse = showing;
    //        }
    //    }
    id hitInput = [TcgSdk parseObj:response.data[@"hit_input"] withClass:[NSNumber class]];
    if (hitInput != nil && [[response data][@"type"] isEqualToString:@"mouseleft"]) {
        [self->_delegate tcg:self didInputStateChange:[hitInput boolValue]];
    }
}

- (void)onHbMessage:(RTCDataBuffer *)buffer {
    NSError *error = nil;
    TcgSdkCommonResponse *response = [self parseJSONCommon:buffer.data error:&error];
    if (error != nil || response == nil) {
        LOG_WARNING(@"bad hb response %@ %@", error, response);
        return;
    }
    long code = response.code ? [[response code] longValue] : -1;
    switch (code) {
        case 0:
        case 1:
            LOG_TRACE(@"got hb message %@", [response message]);
            [self disconnectWithCode:@(code) andMessage:[response message]];
            break;
        default:
            // TODO set RTT
            break;
    }
}

- (void)onKmMessage:(RTCDataBuffer *)buffer {
    NSError *error = nil;
    TcgSdkCommonResponse *response = [self parseJSONCommon:buffer.data error:&error];
    if (error != nil || response == nil) {
        LOG_WARNING(@"bad km response %@ %@", error, response);
        return;
    }
    LOG_TRACE("got km response %@", response);
    NSNumber *cursorShowing = toType(response.raw_[@"cursor_showing"], [NSNumber class]);
    if (cursorShowing != nil) {
        self->cursorShowing = [cursorShowing boolValue];
        self->_overlayView.drawMouse = [cursorShowing boolValue] && (_cursorMode != TcgSdkCursorModeRemote);
    }
    [self->_report retrieveFromDictionary:response.raw_];
}

#pragma mark - video

- (void)videoView:(id<RTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size {
    LOG_INFO(@"didChangeVideoSize %g %g", size.height, size.width);
    self->_videoRawSize = size;
    [self updateViewFrame];
}
@end
