//
//  CAIDemoGroupContorlVC.h
//  TCAIDemo
//
//  Created by Junfeng Gao on 2025/7/10.
//

#ifndef CAIDemoGroupContorlVC_h
#define CAIDemoGroupContorlVC_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <TCRSDK/TCRSDK.h>

@class ComponentCloudPhoneCell;
@protocol ComponentCloudPhoneCellDelegate <NSObject>

@optional
- (void)cellDidSelectMasterForInstanceId:(NSString *)instanceId;
- (void)cell:(ComponentCloudPhoneCell *)cell didChangeSlaveState:(BOOL)isSlave forInstanceId:(NSString *)instanceId;

@end

@interface ComponentCloudPhoneCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIButton *masterButton;
@property (strong, nonatomic) UIButton *slaveCheckbox;
@property (strong, nonatomic) NSString *instanceId;
@property (nonatomic, weak) id<ComponentCloudPhoneCellDelegate> delegate;
@end



@interface CAIDemoGroupControlVC: UIViewController
-(instancetype) initWithTcrSession:(TcrSession* )session instancesId: (NSArray*)instanceIds loadingView:(UIView *)loadingView;
@end

#endif /* CAIDemoGroupContorlVC_h */
