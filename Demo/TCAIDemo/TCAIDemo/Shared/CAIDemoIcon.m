#import "CAIDemoIcon.h"

@implementation CAIDemoIcon

+ (UIImage *)imageWithSystemName:(NSString *)systemName fallbackAssetName:(NSString *)fallbackAssetName {
    if (@available(iOS 13.0, *)) {
        UIImage *image = [UIImage systemImageNamed:systemName];
        if (image != nil) {
            return image;
        }
    }
    return [UIImage imageNamed:fallbackAssetName];
}

@end
