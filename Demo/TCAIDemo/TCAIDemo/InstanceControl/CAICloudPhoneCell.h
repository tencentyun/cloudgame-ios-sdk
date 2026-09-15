#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CAICloudPhoneCell;

@protocol CAICloudPhoneCellDelegate <NSObject>

@optional
- (void)cellDidSelectMasterForInstanceId:(NSString *)instanceId;
- (void)cell:(CAICloudPhoneCell *)cell didChangeSlaveState:(BOOL)isSlave forInstanceId:(NSString *)instanceId;

@end

/// 实例卡片：显示截图预览，并提供「设为主控」「被控」两个操作
@interface CAICloudPhoneCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIButton *masterButton;
@property (strong, nonatomic) UIButton *slaveCheckbox;
@property (strong, nonatomic) NSString *instanceId;
@property (nonatomic, weak) id<CAICloudPhoneCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
