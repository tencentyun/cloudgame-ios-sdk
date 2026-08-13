//
//  CAIDemoUtils.m
//  CAIDemo
//
//  Created by LyleYu on 2021/6/23.
//

#import "CAIDemoUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <dlfcn.h>
#import <os/lock.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#import <mach-o/nlist.h>

#pragma mark - 音频审计（AudioAudit）
//
// 通过 fishhook 方式重绑定各镜像（主二进制、TWEBRTC.framework 等）中对 AudioUnit
// 创建/销毁/启停函数的引用，监听进程内 AudioUnit 活动，并打印 AVAudioSession 的
// category/mode，用于审计 SDK 对音频的影响。仅作 Demo 调试用途，对业务流程无侵入。

static os_unfair_lock gAudioAuditLock = OS_UNFAIR_LOCK_INIT;
static NSMapTable<NSValue *, NSString *> *gLiveAudioUnits;  // key: AudioUnit 实例, value: 子类型描述

// AudioUnit 子类型的可读描述：vpio=VoiceProcessingIO（语音处理单元，SDK 播放/采集使用），rio =RemoteIO
static NSString *CAIAudioSubtypeDesc(UInt32 subType) {
    switch (subType) {
        case kAudioUnitSubType_VoiceProcessingIO:
            return @"vpio(VoiceProcessingIO)";
        case kAudioUnitSubType_RemoteIO:
            return @"rio (RemoteIO)";
        default: {
            char str[5] = { (char)(subType >> 24), (char)(subType >> 16), (char)(subType >> 8), (char)subType, 0 };
            return [NSString stringWithFormat:@"%s(0x%08X)", str, subType];
        }
    }
}

static NSString *CAIAudioUnitDesc(AudioUnit unit) {
    os_unfair_lock_lock(&gAudioAuditLock);
    NSString *desc = [gLiveAudioUnits objectForKey:[NSValue valueWithPointer:unit]];
    os_unfair_lock_unlock(&gAudioAuditLock);
    return desc ?: @"unknown";
}

static OSStatus (*origAudioComponentInstanceNew)(AudioComponent, AudioComponentInstance *);
static OSStatus (*origAudioComponentInstanceDispose)(AudioComponentInstance);
static OSStatus (*origAudioOutputUnitStart)(AudioUnit);
static OSStatus (*origAudioOutputUnitStop)(AudioUnit);

static OSStatus CAIAudioComponentInstanceNewHook(AudioComponent comp, AudioComponentInstance *outInstance) {
    OSStatus status = origAudioComponentInstanceNew(comp, outInstance);
    if (status == noErr && outInstance != NULL && *outInstance != NULL) {
        AudioComponentDescription desc = { 0 };
        NSString *subtype = @"unknown";
        if (AudioComponentGetDescription(comp, &desc) == noErr) {
            subtype = CAIAudioSubtypeDesc(desc.componentSubType);
        }
        os_unfair_lock_lock(&gAudioAuditLock);
        [gLiveAudioUnits setObject:subtype forKey:[NSValue valueWithPointer:*outInstance]];
        os_unfair_lock_unlock(&gAudioAuditLock);
        NSLog(@"[AudioAudit] AudioUnit 创建: subtype=%@ instance=%p", subtype, *outInstance);
    }
    return status;
}

static OSStatus CAIAudioComponentInstanceDisposeHook(AudioComponentInstance unit) {
    NSLog(@"[AudioAudit] AudioUnit 销毁: subtype=%@ instance=%p", CAIAudioUnitDesc(unit), unit);
    os_unfair_lock_lock(&gAudioAuditLock);
    [gLiveAudioUnits removeObjectForKey:[NSValue valueWithPointer:unit]];
    os_unfair_lock_unlock(&gAudioAuditLock);
    return origAudioComponentInstanceDispose(unit);
}

static OSStatus CAIAudioOutputUnitStartHook(AudioUnit unit) {
    NSLog(@"[AudioAudit] AudioUnit 启动: subtype=%@ instance=%p", CAIAudioUnitDesc(unit), unit);
    return origAudioOutputUnitStart(unit);
}

static OSStatus CAIAudioOutputUnitStopHook(AudioUnit unit) {
    NSLog(@"[AudioAudit] AudioUnit 停止: subtype=%@ instance=%p", CAIAudioUnitDesc(unit), unit);
    return origAudioOutputUnitStop(unit);
}

#pragma mark - fishhook 重绑定

// 在单个镜像中查找目标符号的 GOT 槽位（懒绑定/非懒绑定指针表）并替换为 Hook 函数
static void CAIFishRebindInImage(const struct mach_header *header, intptr_t slide) {
    const struct mach_header_64 *header64 = (const struct mach_header_64 *)header;
    if (header64->magic != MH_MAGIC_64) {
        return;
    }

    // 第一遍：收集 __LINKEDIT / 符号表 / 动态符号表
    struct segment_command_64 *linkeditSeg = NULL;
    struct symtab_command *symtabCmd = NULL;
    struct dysymtab_command *dysymtabCmd = NULL;
    uintptr_t cursor = (uintptr_t)header + sizeof(struct mach_header_64);
    for (uint32_t i = 0; i < header64->ncmds; i++) {
        struct load_command *cmd = (struct load_command *)cursor;
        if (cmd->cmd == LC_SEGMENT_64 && strcmp(((struct segment_command_64 *)cmd)->segname, SEG_LINKEDIT) == 0) {
            linkeditSeg = (struct segment_command_64 *)cmd;
        } else if (cmd->cmd == LC_SYMTAB) {
            symtabCmd = (struct symtab_command *)cmd;
        } else if (cmd->cmd == LC_DYSYMTAB) {
            dysymtabCmd = (struct dysymtab_command *)cmd;
        }
        cursor += cmd->cmdsize;
    }
    if (!linkeditSeg || !symtabCmd || !dysymtabCmd) {
        return;
    }

    uintptr_t linkeditBase = slide + linkeditSeg->vmaddr - linkeditSeg->fileoff;
    struct nlist_64 *symtab = (struct nlist_64 *)(linkeditBase + symtabCmd->symoff);
    char *strtab = (char *)(linkeditBase + symtabCmd->stroff);
    uint32_t *indirectSymtab = (uint32_t *)(linkeditBase + dysymtabCmd->indirectsymoff);

    static const struct {
        const char *name;
        void *replacement;
    } rebindings[] = {
        { "AudioComponentInstanceNew", (void *)CAIAudioComponentInstanceNewHook },
        { "AudioComponentInstanceDispose", (void *)CAIAudioComponentInstanceDisposeHook },
        { "AudioOutputUnitStart", (void *)CAIAudioOutputUnitStartHook },
        { "AudioOutputUnitStop", (void *)CAIAudioOutputUnitStopHook },
    };

    // 第二遍：遍历 __DATA/__DATA_CONST 的符号指针表
    cursor = (uintptr_t)header + sizeof(struct mach_header_64);
    for (uint32_t i = 0; i < header64->ncmds; i++) {
        struct load_command *cmd = (struct load_command *)cursor;
        cursor += cmd->cmdsize;
        if (cmd->cmd != LC_SEGMENT_64) {
            continue;
        }
        struct segment_command_64 *seg = (struct segment_command_64 *)cmd;
        if (strcmp(seg->segname, SEG_DATA) != 0 && strcmp(seg->segname, "__DATA_CONST") != 0) {
            continue;
        }
        bool isDataConst = strcmp(seg->segname, "__DATA_CONST") == 0;
        struct section_64 *sect = (struct section_64 *)((uintptr_t)seg + sizeof(struct segment_command_64));
        for (uint32_t j = 0; j < seg->nsects; j++, sect++) {
            uint32_t type = sect->flags & SECTION_TYPE;
            if (type != S_LAZY_SYMBOL_POINTERS && type != S_NON_LAZY_SYMBOL_POINTERS) {
                continue;
            }
            uint32_t *indices = indirectSymtab + sect->reserved1;
            void **bindings = (void **)(slide + sect->addr);
            if (isDataConst) {
                // __DATA_CONST 在加载后被 dyld 置为只读，替换前需临时放开写权限（页对齐）
                vm_address_t pageStart = (vm_address_t)bindings & ~(vm_page_size - 1);
                vm_size_t protSize
                    = (((vm_address_t)bindings + sect->size - pageStart) + vm_page_size - 1) & ~((vm_size_t)vm_page_size - 1);
                vm_protect(mach_task_self(), pageStart, protSize, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
            }
            for (uint32_t k = 0; k < sect->size / sizeof(void *); k++) {
                uint32_t symIndex = indices[k];
                if (symIndex == INDIRECT_SYMBOL_ABS || symIndex == INDIRECT_SYMBOL_LOCAL
                    || symIndex == (INDIRECT_SYMBOL_LOCAL | INDIRECT_SYMBOL_ABS)) {
                    continue;
                }
                char *symbolName = strtab + symtab[symIndex].n_un.n_strx;
                if (!(symbolName[0] && symbolName[1])) {
                    continue;
                }
                for (uint32_t r = 0; r < sizeof(rebindings) / sizeof(rebindings[0]); r++) {
                    if (strcmp(&symbolName[1], rebindings[r].name) == 0) {
                        bindings[k] = rebindings[r].replacement;
                        break;
                    }
                }
            }
            if (isDataConst) {
                vm_address_t pageStart = (vm_address_t)bindings & ~(vm_page_size - 1);
                vm_size_t protSize
                    = (((vm_address_t)bindings + sect->size - pageStart) + vm_page_size - 1) & ~((vm_size_t)vm_page_size - 1);
                vm_protect(mach_task_self(), pageStart, protSize, FALSE, VM_PROT_READ);
            }
        }
    }
}

__attribute__((constructor)) static void CAIAudioAuditInit(void) {
    origAudioComponentInstanceNew = dlsym(RTLD_NEXT, "AudioComponentInstanceNew");
    origAudioComponentInstanceDispose = dlsym(RTLD_NEXT, "AudioComponentInstanceDispose");
    origAudioOutputUnitStart = dlsym(RTLD_NEXT, "AudioOutputUnitStart");
    origAudioOutputUnitStop = dlsym(RTLD_NEXT, "AudioOutputUnitStop");
    gLiveAudioUnits = [NSMapTable strongToStrongObjectsMapTable];
    // 对所有已加载及后续加载的镜像执行重绑定（回调会立即对已加载镜像各调用一次）
    _dyld_register_func_for_add_image(CAIFishRebindInImage);
}

// 登录成功后由服务端下发的鉴权 Cookie，后续请求需带上（与 Android 端 ExpServerRequest 对齐）
static NSString *sCAICookie = nil;

@implementation CAIDemoUtils

+ (UIColor *)CAI_colorValue:(NSString *)colorStr {
    if ([colorStr length] == 6 || [colorStr length] == 8) {
        CGFloat alpha = 1.0;
        CGFloat red, green, blue;
        char subStr[3] = { 0 };
        char *ptr;
        subStr[0] = [colorStr characterAtIndex:0];
        subStr[1] = [colorStr characterAtIndex:1];
        red = strtol(subStr, &ptr, 16) / 255.0f;
        subStr[0] = [colorStr characterAtIndex:2];
        subStr[1] = [colorStr characterAtIndex:3];
        green = strtol(subStr, &ptr, 16) / 255.0f;
        subStr[0] = [colorStr characterAtIndex:4];
        subStr[1] = [colorStr characterAtIndex:5];
        blue = strtol(subStr, &ptr, 16) / 255.0f;
        if ([colorStr length] == 8) {
            subStr[0] = [colorStr characterAtIndex:6];
            subStr[1] = [colorStr characterAtIndex:7];
            alpha = strtol(subStr, &ptr, 16) / 255.0f;
        }
        return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        ;
    }
    return [UIColor clearColor];
}

+ (void)CAI_postUrl:(NSString *)url params:(NSDictionary *)params finishBlk:(httpResponseBlk)finishBlk {
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:url]];
    [request setHTTPMethod:@"POST"];
    // 必要请求头（与 Android 端 ExpServerRequest.getHeaders 对齐）
    [request addValue:@"ap-shenzhen" forHTTPHeaderField:@"Request-Host"];
    [request addValue:@"https://mouhong.test-cai-experience.crtrcloud.com" forHTTPHeaderField:@"Origin"];
    if (sCAICookie.length > 0) {
        [request addValue:sCAICookie forHTTPHeaderField:@"Cookie"];
    }
    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    if (error != nil || body == nil) {
        NSLog(@"JSON serialization error:%@", error);
        if (finishBlk) {
            finishBlk(nil, nil, error);
        }
        return;
    }
    [request setHTTPBody:body];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // 保存服务端下发的 Set-Cookie，供后续请求鉴权使用
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            NSString *setCookie = httpResp.allHeaderFields[@"Set-Cookie"];
            if (setCookie.length > 0) {
                sCAICookie = setCookie;
            }
            NSLog(@"[CAI] %@ -> HTTP %ld", url, (long)httpResp.statusCode);
        }
        // 打印原始响应体，便于排查非 JSON 响应（如网关错误页）
        if (data.length > 0) {
            NSString *raw = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"[CAI] response body: %@", raw);
        }
        if (finishBlk) {
            finishBlk(data, response, error);
        }
    }] resume];
}

// 打印当前音频状态：AVAudioSession category/mode + 存活 AudioUnit 子类型列表
+ (void)CAI_dumpAudioStateWithTag:(NSString *)tag {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSMutableString *units = [NSMutableString string];
    os_unfair_lock_lock(&gAudioAuditLock);
    NSUInteger count = gLiveAudioUnits.count;
    for (NSValue *key in gLiveAudioUnits) {
        [units appendFormat:@"\n    instance=%p subtype=%@", key.pointerValue, [gLiveAudioUnits objectForKey:key]];
    }
    os_unfair_lock_unlock(&gAudioAuditLock);
    if (count == 0) {
        [units appendString:@" 无"];
    }
    NSLog(@"[AudioAudit] ===== %@ =====\n"
          @"  AVAudioSession category: %@\n"
          @"  AVAudioSession mode: %@\n"
          @"  AVAudioSession categoryOptions: 0x%lx\n"
          @"  存活 AudioUnit(%lu 个):%@",
          tag, session.category, session.mode, (unsigned long)session.categoryOptions, (unsigned long)count, units);
}

@end
