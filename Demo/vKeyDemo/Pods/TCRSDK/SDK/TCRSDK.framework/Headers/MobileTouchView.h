//
//  MobileTouchView.h
//  TCRSDK
//
//  Created by xxhape on 2023/9/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class TcrSession;
NS_ASSUME_NONNULL_BEGIN

@interface MobileTouchView : UIView

- (instancetype)initWithFrame:(CGRect)frame session:(TcrSession *)session;
/*
 Clear locally stored touch events (for key stuck situations)
 */
- (void)cleanTouchEvent;
@end

NS_ASSUME_NONNULL_END
