//
//  CAIDemoAudioCapturor.m
//  CAIDemo
//
//  Created by 高峻峰 on 2023/10/10.
//

#import "CAIDemoAudioCapturor.h"
#import <AudioToolbox/AudioToolbox.h>

#define kAudioPCMFramesPerPacket 1
#define KAudioBitsPerChannel 16

#define INPUT_BUS 1   ///< A I/O unit's bus 1 connects to input hardware (microphone).
#define OUTPUT_BUS 0  ///< A I/O unit's bus 0 connects to output hardware (speaker).

const static NSString *kModuleName = @"CAIDemoAudioCapturor";

static AudioUnit m_audioUnit;
static AudioBufferList *m_buffList;
static AudioStreamBasicDescription m_audioDataFormat;

@interface CAIDemoAudioCapturor ()

@property (nonatomic, assign, readwrite) BOOL isRunning;

@end

@implementation CAIDemoAudioCapturor

static CAIDemoAudioCapturor *sharedInstance = nil;
static TcrSession *_tcr_session = nil;
static NSInteger _sampleRate;
static NSInteger _channelCount;
static BOOL _isDump;
static BOOL _isConfigured = NO;
static NSFileHandle *_fileHandle;

static OSStatus AudioCaptureCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber,
    UInt32 inNumberFrames, AudioBufferList *ioData) {
    AudioUnitRender(m_audioUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, m_buffList);

    // 采集时刻时间戳，SDK 要求纳秒（sendCustomAudioData:captureTimeNs:）
    Float64 currentTimeSec = CMTimeGetSeconds(CMClockMakeHostTimeFromSystemUnits(inTimeStamp->mHostTime));
    uint64_t captureTimeNs = (uint64_t)(currentTimeSec * NSEC_PER_SEC);

    void *bufferData = m_buffList->mBuffers[0].mData;
    UInt32 bufferSize = m_buffList->mBuffers[0].mDataByteSize;

    NSData *audioData = [NSData dataWithBytes:bufferData length:bufferSize];

    if (_fileHandle) {
        [_fileHandle writeData:audioData];
    }

    if (_tcr_session) {
        [_tcr_session sendCustomAudioData:audioData captureTimeNs:captureTimeNs];
    }
    return noErr;
}

#pragma mark - Public
+ (void)configureAudioCapturor:(NSInteger)sampleRate channelCount:(NSInteger)channelCount dumpAudio:(BOOL)isDump {
    _sampleRate = sampleRate;
    _channelCount = channelCount;
    _isDump = isDump;
    _isConfigured = YES;
}

// 未调用 configureAudioCapturor: 配置时返回 nil（对其发消息为空操作），
// 避免以非法采样率创建 AudioUnit。
+ (instancetype)getInstance {
    if (!_isConfigured) {
        NSLog(@"%@: audio capturor is not configured, call configureAudioCapturor first \n", kModuleName);
        return nil;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithParams:_sampleRate channelCount:_channelCount isDump:_isDump];
    });
    return sharedInstance;
}

- (void)startAudioCapture:(TcrSession *)tcrSession {
    _tcr_session = tcrSession;
    [self startAudioCaptureWithAudioUnit:m_audioUnit isRunning:&_isRunning];
}

- (void)stopAudioCapture {
    _tcr_session = nil;
    [self stopAudioCaptureWithAudioUnit:m_audioUnit isRunning:&_isRunning];
    if (_fileHandle) {
        [_fileHandle closeFile];
    }
}

- (void)freeAudioUnit {
    [self freeAudioUnit:m_audioUnit];
    self.isRunning = NO;
}
- (AudioStreamBasicDescription)getAudioDataFormat {
    return m_audioDataFormat;
}

#pragma mark - Init
- (instancetype)initWithParams:(NSInteger)sampleRate channelCount:(NSInteger)channelCount isDump:(BOOL)isDump {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 如果要dump录制的音频，那么要先创建文件
        if (isDump) {
            NSString *audioPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
                stringByAppendingPathComponent:@"test.pcm"];
            NSLog(@"PCM file path: %@", audioPath);
            [[NSFileManager defaultManager] removeItemAtPath:audioPath error:nil];
            [[NSFileManager defaultManager] createFileAtPath:audioPath contents:nil attributes:nil];
            _fileHandle = [NSFileHandle fileHandleForWritingAtPath:audioPath];
        }

        sharedInstance = [super init];

        // Note: audioBufferSize couldn't more than durationSec max size.
        [sharedInstance configureAudioInfoWithDataFormat:&m_audioDataFormat formatID:kAudioFormatLinearPCM sampleRate:sampleRate
                                            channelCount:channelCount
                                         audioBufferSize:2048
                                             durationSec:0.02
                                                callBack:AudioCaptureCallback];
    });
    return sharedInstance;
}

#pragma mark - Private
- (void)configureAudioInfoWithDataFormat:(AudioStreamBasicDescription *)dataFormat
                                formatID:(UInt32)formatID
                              sampleRate:(Float64)sampleRate
                            channelCount:(UInt32)channelCount
                         audioBufferSize:(int)audioBufferSize
                             durationSec:(float)durationSec
                                callBack:(AURenderCallback)callBack {
    // Configure ASBD
    [self configureAudioToAudioFormat:dataFormat byParamFormatID:formatID sampleRate:sampleRate channelCount:channelCount];

    // Set sample time
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:durationSec error:NULL];

    // Configure Audio Unit
    m_audioUnit = [self configreAudioUnitWithDataFormat:*dataFormat audioBufferSize:audioBufferSize callBack:callBack];
}

- (void)startAudioCaptureWithAudioUnit:(AudioUnit)audioUnit isRunning:(BOOL *)isRunning {
    OSStatus status;

    if (*isRunning) {
        NSLog(@"%@:  %s - start recorder repeat \n", kModuleName, __func__);
        return;
    }

    // RemoteIO 不会自行把 AVAudioSession 拉到录音态：若当前不是录音态（category 非
    // PlayAndRecord/Record，例如 SDK 把 session 切回了 Playback，或异步配置尚未生效），
    // 直接启动采集会无声。此时延迟重试，等 SDK 的开麦配置生效后再启动。
    // 注意按 category（录音能力）判断而非 mode——audioSessionMode=Default 时 mode 恒为 Default。
    NSString *category = [AVAudioSession sharedInstance].category;
    BOOL isRecordCategory = [category isEqualToString:AVAudioSessionCategoryPlayAndRecord]
        || [category isEqualToString:AVAudioSessionCategoryRecord];
    if (!isRecordCategory) {
        NSLog(@"%@:  %s - session category is %@, not ready for capture, retry after 300ms \n", kModuleName, __func__, category);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startAudioCaptureWithAudioUnit:audioUnit isRunning:isRunning];
        });
        return;
    }

    status = AudioOutputUnitStart(audioUnit);
    if (status == noErr) {
        *isRunning = YES;
        NSLog(@"%@:  %s - start audio unit success \n", kModuleName, __func__);
    } else {
        *isRunning = NO;
        NSLog(@"%@:  %s - start audio unit failed \n", kModuleName, __func__);
    }
}

- (void)stopAudioCaptureWithAudioUnit:(AudioUnit)audioUnit isRunning:(BOOL *)isRunning {
    if (*isRunning == NO) {
        NSLog(@"%@:  %s - stop capture repeat \n", kModuleName, __func__);
        return;
    }

    *isRunning = NO;
    if (audioUnit != NULL) {
        OSStatus status = AudioOutputUnitStop(audioUnit);
        if (status != noErr) {
            NSLog(@"%@:  %s - stop audio unit failed. \n", kModuleName, __func__);
        } else {
            NSLog(@"%@:  %s - stop audio unit successful", kModuleName, __func__);
        }
    }
}

- (void)freeAudioUnit:(AudioUnit)audioUnit {
    if (!audioUnit) {
        NSLog(@"%@:  %s - repeat call!", kModuleName, __func__);
        return;
    }

    OSStatus result = AudioOutputUnitStop(audioUnit);
    if (result != noErr) {
        NSLog(@"%@:  %s - stop audio unit failed.", kModuleName, __func__);
    }

    result = AudioUnitUninitialize(m_audioUnit);
    if (result != noErr) {
        NSLog(@"%@:  %s - uninitialize audio unit failed, status : %d", kModuleName, __func__, result);
    }

    // It will trigger audio route change repeatedly
    result = AudioComponentInstanceDispose(m_audioUnit);
    if (result != noErr) {
        NSLog(@"%@:  %s - dispose audio unit failed. status : %d", kModuleName, __func__, result);
    } else {
        audioUnit = nil;
    }
}

#pragma mark - Audio Unit
- (AudioUnit)configreAudioUnitWithDataFormat:(AudioStreamBasicDescription)dataFormat
                             audioBufferSize:(int)audioBufferSize
                                    callBack:(AURenderCallback)callBack {
    AudioUnit audioUnit = [self createAudioUnitObject];

    if (!audioUnit) {
        return NULL;
    }

    [self initCaptureAudioBufferWithAudioUnit:audioUnit channelCount:dataFormat.mChannelsPerFrame dataByteSize:audioBufferSize];

    [self setAudioUnitPropertyWithAudioUnit:audioUnit dataFormat:dataFormat];

    [self initCaptureCallbackWithAudioUnit:audioUnit callBack:callBack];

    // Calls to AudioUnitInitialize() can fail if called back-to-back on different ADM instances. A fall-back solution is to allow multiple sequential
    // calls with as small delay between each. This factor sets the max number of allowed initialization attempts.
    OSStatus status = AudioUnitInitialize(audioUnit);
    if (status != noErr) {
        NSLog(@"%@:  %s - couldn't init audio unit instance, status : %d \n", kModuleName, __func__, status);
    }

    return audioUnit;
}

- (AudioUnit)createAudioUnitObject {
    AudioUnit audioUnit;
    AudioComponentDescription audioDesc;
    audioDesc.componentType = kAudioUnitType_Output;
    // 本文件是 sendCustomAudioData 的【自定义采集实现示例】，演示用 AudioUnit 采集 PCM 上行。
    // 已接入第三方音频 SDK（声网/火山等）的客户无需使用本文件——直接在第三方模块的原始音频帧回调里
    // 转发 sendCustomAudioData 即可，采集子类型/参数由客户在第三方模块侧自行权衡。
    //
    // 对使用本示例的客户，子类型选择需知（VPIO 与 AVAudioSession mode 的相互作用是普适机制）：
    // - VoiceProcessingIO（本示例默认）：自带系统 AEC/AGC，但输入侧启用时系统会隐式把 session mode 拉为
    //   VoiceChat（不经 AVAudioSession ObjC 接口，无法拦截），此时 audioSessionMode=Default 传参被覆盖失效；
    // - RemoteIO：纯 IO 单元、无语音处理、不改 session mode，配合 audioSessionMode=Default 可全程无
    //   VoiceChat（代价：失去系统 AEC/AGC，需自行处理回声）。
    audioDesc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;  // kAudioUnitSubType_RemoteIO;
    audioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    audioDesc.componentFlags = 0;
    audioDesc.componentFlagsMask = 0;

    AudioComponent inputComponent = AudioComponentFindNext(NULL, &audioDesc);
    OSStatus status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    if (status != noErr) {
        NSLog(@"%@:  %s - create audio unit failed, status : %d \n", kModuleName, __func__, status);
        return NULL;
    } else {
        return audioUnit;
    }
}

- (void)initCaptureAudioBufferWithAudioUnit:(AudioUnit)audioUnit channelCount:(int)channelCount dataByteSize:(int)dataByteSize {
    // Disable AU buffer allocation for the recorder, we allocate our own.
    UInt32 flag = 0;
    OSStatus status
        = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Output, INPUT_BUS, &flag, sizeof(flag));
    if (status != noErr) {
        NSLog(@"%@:  %s - couldn't allocate buffer of callback, status : %d \n", kModuleName, __func__, status);
    }

    AudioBufferList *buffList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
    buffList->mNumberBuffers = 1;
    buffList->mBuffers[0].mNumberChannels = channelCount;
    buffList->mBuffers[0].mDataByteSize = dataByteSize;
    buffList->mBuffers[0].mData = (UInt32 *)malloc(dataByteSize);
    m_buffList = buffList;
}

- (void)setAudioUnitPropertyWithAudioUnit:(AudioUnit)audioUnit dataFormat:(AudioStreamBasicDescription)dataFormat {
    OSStatus status;
    status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, INPUT_BUS, &dataFormat, sizeof(dataFormat));
    if (status != noErr) {
        NSLog(@"%@:  %s - set audio unit stream format failed, status : %d \n", kModuleName, __func__, status);
    }

    /*
     // remove echo but can't effect by testing.
     UInt32 echoCancellation = 0;
     AudioUnitSetProperty(m_audioUnit,
     kAUVoiceIOProperty_BypassVoiceProcessing,
     kAudioUnitScope_Global,
     0,
     &echoCancellation,
     sizeof(echoCancellation));
     */

    UInt32 enableFlag = 1;
    status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, INPUT_BUS, &enableFlag, sizeof(enableFlag));
    if (status != noErr) {
        NSLog(@"%@:  %s - could not enable input on AURemoteIO, status : %d \n", kModuleName, __func__, status);
    }

    UInt32 disableFlag = 0;
    status
        = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, OUTPUT_BUS, &disableFlag, sizeof(disableFlag));
    if (status != noErr) {
        NSLog(@"%@:  %s - could not enable output on AURemoteIO, status : %d \n", kModuleName, __func__, status);
    }
}

- (void)initCaptureCallbackWithAudioUnit:(AudioUnit)audioUnit callBack:(AURenderCallback)callBack {
    AURenderCallbackStruct captureCallback;
    captureCallback.inputProc = callBack;
    captureCallback.inputProcRefCon = (__bridge void *)self;
    OSStatus status = AudioUnitSetProperty(
        audioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, INPUT_BUS, &captureCallback, sizeof(captureCallback));

    if (status != noErr) {
        NSLog(@"%@:  %s - Audio Unit set capture callback failed, status : %d \n", kModuleName, __func__, status);
    }
}

#pragma mark - ASBD Audio Format
- (void)configureAudioToAudioFormat:(AudioStreamBasicDescription *)audioFormat
                    byParamFormatID:(UInt32)formatID
                         sampleRate:(Float64)sampleRate
                       channelCount:(UInt32)channelCount {
    AudioStreamBasicDescription dataFormat = { 0 };
    UInt32 size = sizeof(dataFormat.mSampleRate);
    // Get hardware origin sample rate. (Recommended it)
    Float64 hardwareSampleRate = 0;
    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &hardwareSampleRate);
    // Manual set sample rate
    dataFormat.mSampleRate = sampleRate;

    size = sizeof(dataFormat.mChannelsPerFrame);
    // Get hardware origin channels number. (Must refer to it)
    UInt32 hardwareNumberChannels = 0;
    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareInputNumberChannels, &size, &hardwareNumberChannels);
    dataFormat.mChannelsPerFrame = channelCount;

    dataFormat.mFormatID = formatID;

    if (formatID == kAudioFormatLinearPCM) {
        dataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        dataFormat.mBitsPerChannel = KAudioBitsPerChannel;
        dataFormat.mBytesPerPacket = dataFormat.mBytesPerFrame = (dataFormat.mBitsPerChannel / 8) * dataFormat.mChannelsPerFrame;
        dataFormat.mFramesPerPacket = kAudioPCMFramesPerPacket;
    }

    memcpy(audioFormat, &dataFormat, sizeof(dataFormat));
    NSLog(@"%@:  %s - sample rate:%f, channel count:%d", kModuleName, __func__, sampleRate, channelCount);
}

@end
