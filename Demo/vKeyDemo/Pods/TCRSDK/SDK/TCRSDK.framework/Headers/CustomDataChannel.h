//
//  CustomDataChannel.h
//  TCRSDK
//
//  Created by xxhape on 2023/9/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A class can implement the <code>Observer</code> protocol when it wants to be informed of events
 * in CustomDataChannel objects.
 */
@protocol CustomDataChannelObserver <NSObject>

/**
 * This method is called when the listened <code>CustomDataChannel</code> is connected successfully.
 *
 * @param port The identify of the listened <code>CustomDataChannel</code>.
 */
- (void)onConnected:(NSInteger)port;

/**
 * This method is called whenever some error is happened in the listened <code>CustomDataChannel</code>.
 *
 * @param port The identify of the listened <code>CustomDataChannel</code>.
 * @param code The error code.
 * @param msg The error message.
 */
- (void)onError:(NSInteger)port code:(NSInteger)code message:(NSString *)msg;

/**
 * This method is called whenever the listened <code>CustomDataChannel</code> receives cloud message.
 *
 * <p>NOTE: |buffer.data| will be freed once this function returns so callers who want to use the data
 * asynchronously must make sure to copy it first.</p>
 *
 * @param port The identify of the listened <code>CustomDataChannel</code>.
 * @param buffer The message sent from the cloud.
 */
- (void)onMessage:(NSInteger)port buffer:(NSData *)buffer;

@end

@interface CustomDataChannel : NSObject

@property (nonatomic, weak) id<CustomDataChannelObserver> delegate;
@property (nonatomic, copy, readonly) NSString *channelLabel;
@property (nonatomic, assign, readonly) int remoteUdpPort;
/**
 * Send data to the cloud Application.
 *
 * @param data The data to be sent, which cannot exceed 1,200 bytes.
 * @return true if success, false otherwise.
 */
- (BOOL)send:(NSData *)data;

/**
 * Close this data channel.
 */
- (void)close;
@end

NS_ASSUME_NONNULL_END
