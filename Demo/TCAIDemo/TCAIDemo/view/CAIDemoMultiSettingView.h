//
//  CAIDemoMultiSettingView.h
//  CAIDemo
//
//  Created by xxhape on 2023/10/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CAIDemoMultiSettingViewDelegate <NSObject>

- (void)onApplySeatChange:(NSString*)userid index:(int)index role:(NSString*)role;
- (void)onSeatChange:(NSString*)userid index:(int)index role:(NSString*)role;
- (void)onSyscRoomInfo;
- (void)onsetMicMute:(NSString*)userid enable:(BOOL)index;

@end
@interface CAIDemoMultiSettingView : UIView
@property(nonatomic, weak) id<CAIDemoMultiSettingViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
