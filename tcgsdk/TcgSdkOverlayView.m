//
//  TcgSdkOverlay.m
//  tcgsdk
//
//  Created by okhowang(王沛文) on 2020/4/1.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TcgSdkOverlayView.h"

@implementation TcgSdkOverlayView {
    UIImage *_curMouseImage;
}

+ (UIImage *)defaultMouseImage {
    static UIImage *image = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
      image = [UIImage imageNamed:@"cursor.png"
                               inBundle:[NSBundle bundleForClass:[self class]]
          compatibleWithTraitCollection:nil];
      assert(image);
    });
    return image;
}

- (void)setMousePoint:(CGPoint)mousePoint {
    bool needUpdate =
        (_drawMouse && (_mousePoint.x != mousePoint.x || _mousePoint.y != mousePoint.y));
    _mousePoint = mousePoint;
    if (needUpdate)
        dispatch_async(dispatch_get_main_queue(), ^{
          [self setNeedsDisplay];
        });
}

- (void)setDrawMouse:(bool)drawMouse {
    bool needUpdate = (_drawMouse != drawMouse);
    _drawMouse = drawMouse;
    if (needUpdate)
        dispatch_async(dispatch_get_main_queue(), ^{
          [self setNeedsDisplay];
        });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor alloc] initWithWhite:1 alpha:0];
        self.mousePoint = CGPointMake(0, 0);
        self.drawMouse = true;
        [self setMouseImage:nil];
    }
    return self;
}

- (void)setMouseImage:(NSData *)mouseImage {
    UIImage *image = nil;
    if (mouseImage != nil) {
        image = [UIImage imageWithData:mouseImage];
    }
    if (_curMouseImage != nil) {
        if (mouseImage != nil) {
            _curMouseImage = image;
            dispatch_async(dispatch_get_main_queue(), ^{
              [self setNeedsDisplay];
            });
        }
    } else {
        _curMouseImage = image ? image : [TcgSdkOverlayView defaultMouseImage];
        dispatch_async(dispatch_get_main_queue(), ^{
          [self setNeedsDisplay];
        });
    }
}

- (void)setDebugInfo:(NSString *)debugInfo {
    // 这里就是要比较指针 不一样就更新
    if (_debugInfo != debugInfo) {
        _debugInfo = debugInfo;
        dispatch_async(dispatch_get_main_queue(), ^{
          [self setNeedsDisplay];
        });
    }
}

- (void)drawRect:(CGRect)rect {
    if (self.drawMouse) {
        [_curMouseImage drawAtPoint:_mousePoint];
    };
    if (_debugInfo != nil) {
        NSDictionary *stringAttrs = @{};
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:_debugInfo
                                                                      attributes:stringAttrs];

        [attrStr drawAtPoint:CGPointMake(10.f, 10.f)];
    }
}

@end
