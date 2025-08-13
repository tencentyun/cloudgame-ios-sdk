//
//  TCGDemoLoadingView.m
//  TCGDemo
//
//  Created by LyleYu on 2021/7/14.
//

#import "TCGDemoLoadingView.h"
#import "TCGDemoUtils.h"

@interface TCGDemoLoadingView () {
    UILabel *_processLab;
    CGRect _processFrame;
    UIView *_processView;
    NSTimer *_fakeProcessTimer;
}

@end

@implementation TCGDemoLoadingView

- (instancetype)initWithFrame:(CGRect)frame process:(int)process {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        self.processValue = process;
    }
    return self;
}

- (void)setProcessValue:(int)processValue {
    processValue = MAX(0, MIN(processValue, 100));
    if (_processValue == processValue) {
        return;
    }
    _processValue = processValue;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (processValue >= 100) {
            self.hidden = YES;
            return;
        }
        self->_processLab.text = [NSString stringWithFormat:@"正在全力加载游戏···%d%%", processValue];
        CGRect newFrame = self->_processFrame;
        newFrame.size.width = self->_processFrame.size.width * processValue / 100;
        self->_processView.frame = newFrame;
    });
    NSLog(@"setProcessValue:%d", processValue);
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        if (_fakeProcessTimer) {
            [_fakeProcessTimer invalidate];
            _fakeProcessTimer = nil;
        }
    } else {
        if (_fakeProcessTimer) {
            [_fakeProcessTimer invalidate];
        }
        _fakeProcessTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer *_Nonnull timer) {
            if (self.processValue < 98) {
                self.processValue += 1;
            }
        }];
    }
}

- (void)startFakeProcess {
    // 默认4秒
    _fakeProcessTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 repeats:YES block:^(NSTimer *_Nonnull timer) {
        if (self.processValue < 98) {
            self.processValue += 1;
        }
    }];
}

- (void)initSubviews {
    CGFloat perPixel = self.bounds.size.width / 1920.0f;
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [bgImageView setImage:[UIImage imageNamed:@"loading_bg"]];
    [self addSubview:bgImageView];

    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(520 * perPixel, 226 * perPixel, 880 * perPixel, 268 * perPixel)];
    [iconImageView setImage:[UIImage imageNamed:@"tcg_cloud"]];
    [self addSubview:iconImageView];

    _processLab = [[UILabel alloc] initWithFrame:CGRectMake(750 * perPixel, 570 * perPixel, 420 * perPixel, 46 * perPixel)];
    _processLab.font = [UIFont systemFontOfSize:(33 * perPixel)];
    _processLab.textColor = [TCGDemoUtils tcg_colorValue:@"81868C"];
    [self addSubview:_processLab];

    _processFrame = CGRectMake(660 * perPixel, 656 * perPixel, 600 * perPixel, 18 * perPixel);
    UIView *processBgView = [[UIView alloc] initWithFrame:_processFrame];
    processBgView.layer.cornerRadius = 9 * perPixel;
    processBgView.layer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2].CGColor;
    [self addSubview:processBgView];

    _processView = [[UIView alloc] initWithFrame:_processFrame];
    _processView.layer.cornerRadius = 9 * perPixel;
    _processView.layer.backgroundColor = [TCGDemoUtils tcg_colorValue:@"2684FF"].CGColor;
    [self addSubview:_processView];
}

@end
