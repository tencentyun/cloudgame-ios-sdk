#ifndef CAIDemoVC_h
#define CAIDemoVC_h

#import <UIKit/UIKit.h>
#import <TCRSDK/TCRSDK.h>

typedef void(^tStopControlBlk)(void);

@interface CAIDemoMasterControlVC : UIViewController
@property(nonatomic, copy) tStopControlBlk stopControlBlk;

- (instancetype)initWithPlay:(TcrSession *)play loadingView:(UIView *)loadingView;

@end

#endif /* CAIDemoVC_h */
