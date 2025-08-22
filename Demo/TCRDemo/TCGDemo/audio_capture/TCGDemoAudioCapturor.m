#import "TCGDemoAudioCapturor.h"
#import <os/lock.h>
#import <AVFoundation/AVFoundation.h>

static const UInt32 kInputBus = 1;
static const UInt32 kOutputBus = 0;
static const UInt32 kAudioBitsPerChannel = 16;
static const NSUInteger kMaxBufferSize = 2048;

@interface TCGDemoAudioCapturor () {
    AudioUnit _audioUnit;
    AudioBufferList *_buffList;
    AudioStreamBasicDescription _asbd;
    os_unfair_lock _lock;
}
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@end

@implementation TCGDemoAudioCapturor

#pragma mark - 单例核心实现
+ (instancetype)shared {
    static TCGDemoAudioCapturor *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shared]; // 阻止额外实例化
}

- (instancetype)init {
    if (self = [super init]) {
        _lock = OS_UNFAIR_LOCK_INIT;
    }
    return self;
}

#pragma mark - 配置与启停
- (void)configureWithSampleRate:(Float64)sampleRate
                   channelCount:(UInt32)channelCount
                      dumpAudio:(BOOL)dumpEnabled {
    // 初始化音频格式
    [self _configureAudioFormat:&_asbd sampleRate:sampleRate channelCount:channelCount];
    
    // 初始化Dump文件
    if (dumpEnabled) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
                         stringByAppendingPathComponent:@"capture.pcm"];
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    }
    
    // 懒加载音频单元（首次调用start时再初始化）
}

- (void)startCapture {
    if (self.isRunning) return;
    
    if (!_audioUnit) {
        [self _setupAudioUnit]; // 延迟初始化
    }
    NSError *error = nil;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                         withOptions:AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionDefaultToSpeaker
                                           error:&error];
    if (error) {
        NSLog(@"AVAudioSession setCategory failed");
        return;
    }
    
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"AVAudioSession setActive failed");
        return;
    }
    
    OSStatus status = AudioOutputUnitStart(_audioUnit);
    if (status == noErr) {
        self.isRunning = YES;
    } else {
        [self _handleAudioError:status message:@"Start failed"];
    }
}

- (void)stopCapture {
    if (!self.isRunning) return;
    
    OSStatus status = AudioOutputUnitStop(_audioUnit);
    if (status == noErr) {
        self.isRunning = NO;
    } else {
        [self _handleAudioError:status message:@"Stop failed"];
    }
    
    if (_fileHandle) {
        [_fileHandle closeFile];
        _fileHandle = nil;
    }
}

#pragma mark - 音频单元生命周期
- (void)_setupAudioUnit {
    // 创建 AudioComponent（使用 VoiceProcessingIO 支持回声消除）
    AudioComponentDescription desc = {
        .componentType = kAudioUnitType_Output,
        .componentSubType = kAudioUnitSubType_VoiceProcessingIO,
        .componentManufacturer = kAudioUnitManufacturer_Apple
    };
    
    AudioComponent comp = AudioComponentFindNext(NULL, &desc);
    OSStatus status = AudioComponentInstanceNew(comp, &_audioUnit);
    if (status != noErr) {
        [self _handleAudioError:status message:@"Create AudioUnit failed"];
        return;
    }
    
    // 配置属性（启用输入、禁用输出、设置格式）
    UInt32 enable = 1;
    status = AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, kInputBus, &enable, sizeof(enable));
    UInt32 disable = 0;
    status |= AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, kOutputBus, &disable, sizeof(disable));
    status |= AudioUnitSetProperty(_audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, kInputBus, &_asbd, sizeof(_asbd));
    
    // 初始化缓冲区
    [self _setupAudioBuffers];
    
    // 设置回调
    AURenderCallbackStruct cb = {.inputProc = _audioCaptureCallback, .inputProcRefCon = (__bridge void *)self};
    status |= AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, kInputBus, &cb, sizeof(cb));
    
    // 初始化 AudioUnit
    status = AudioUnitInitialize(_audioUnit);
    if (status != noErr) {
        [self _handleAudioError:status message:@"Initialize failed"];
        [self _teardownAudioUnit];
    }
}

- (void)_setupAudioBuffers {
    _buffList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
    _buffList->mNumberBuffers = 1;
    _buffList->mBuffers[0].mNumberChannels = _asbd.mChannelsPerFrame;
    _buffList->mBuffers[0].mDataByteSize = kMaxBufferSize;
    _buffList->mBuffers[0].mData = malloc(kMaxBufferSize);
}

- (void)_teardownAudioUnit {
    if (!_audioUnit) return;
    
    AudioUnitUninitialize(_audioUnit);
    AudioComponentInstanceDispose(_audioUnit);
    _audioUnit = NULL;
    
    if (_buffList) {
        free(_buffList->mBuffers[0].mData);
        free(_buffList);
        _buffList = NULL;
    }
}

#pragma mark - 音频回调
static OSStatus _audioCaptureCallback(void *inRefCon,
                                     AudioUnitRenderActionFlags *ioActionFlags,
                                     const AudioTimeStamp *inTimeStamp,
                                     UInt32 inBusNumber,
                                     UInt32 inNumberFrames,
                                     AudioBufferList *ioData) {
    TCGDemoAudioCapturor *self = (__bridge TCGDemoAudioCapturor *)inRefCon;
    OSStatus status = AudioUnitRender(self->_audioUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, self->_buffList);
    if (status != noErr) return status;
    
    // 提取数据并回调
    AudioBuffer buf = self->_buffList->mBuffers[0];
    NSData *pcmData = [NSData dataWithBytes:buf.mData length:buf.mDataByteSize];
    uint64_t timestamp = (uint64_t)(inTimeStamp->mHostTime * 1e9); // 纳秒精度
    
    os_unfair_lock_lock(&self->_lock);
    if (self.fileHandle) {
        [self.fileHandle writeData:pcmData];
    }
    if (self.audioDataHandler) {
        self.audioDataHandler(pcmData, timestamp);
    }
    os_unfair_lock_unlock(&self->_lock);
    
    return noErr;
}

#pragma mark - 辅助方法
- (void)_configureAudioFormat:(AudioStreamBasicDescription *)asbd
                    sampleRate:(Float64)sampleRate
                  channelCount:(UInt32)channels {
    memset(asbd, 0, sizeof(*asbd));
    asbd->mSampleRate = sampleRate;
    asbd->mFormatID = kAudioFormatLinearPCM;
    asbd->mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    asbd->mBitsPerChannel = kAudioBitsPerChannel;
    asbd->mChannelsPerFrame = channels;
    asbd->mFramesPerPacket = 1;
    asbd->mBytesPerFrame = (asbd->mBitsPerChannel / 8) * asbd->mChannelsPerFrame;
    asbd->mBytesPerPacket = asbd->mBytesPerFrame * asbd->mFramesPerPacket;
}

- (void)_handleAudioError:(OSStatus)status message:(NSString *)msg {
    NSLog(@"[Audio] %@: %d", msg, (int)status);
}

- (void)dealloc {
    [self _teardownAudioUnit]; // 确保资源释放
}

@end
