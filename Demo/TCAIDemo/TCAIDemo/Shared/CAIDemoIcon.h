#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Demo 图标：统一处理 SF Symbols 与低版本回退
@interface CAIDemoIcon : NSObject

/**
 * 取图标：优先用 SF Symbols，取不到时回退到工程内图片资源。
 *
 * systemImageNamed: 是 iOS 13 才有的接口，本工程 Deployment Target 为 iOS 12，
 * 直接调用会在低版本系统上抛 unrecognized selector。
 */
+ (UIImage *)imageWithSystemName:(NSString *)systemName fallbackAssetName:(NSString *)fallbackAssetName;

@end

NS_ASSUME_NONNULL_END
