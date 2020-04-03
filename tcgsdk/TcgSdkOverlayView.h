//
//  TcgSdkOverlay.h
//  tcgsdk
//
//  Created by okhowang(王沛文) on 2020/4/1.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TcgSdkOverlayView : UIView

@property(nonatomic) NSString *debugInfo;
// mouse
@property(nonatomic) bool drawMouse;
@property(nonatomic) CGPoint mousePoint;
- (void)setMouseImage:(nullable NSData *)data;

@end

NS_ASSUME_NONNULL_END
