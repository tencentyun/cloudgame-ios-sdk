//
//  AudioQueuePlay.h
//  TCGDemo
//
//  Created by xxhape on 2023/8/9.
//

#import <Foundation/Foundation.h>
#import <TCRSDK/TCRSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface AudioQueuePlay : NSObject
- (void)playWithData: (NSData *)data;
- (void)start;
- (void)stop;

- (instancetype)initWithFrame:(TCRAudioFrame*)frame;
@end

NS_ASSUME_NONNULL_END
