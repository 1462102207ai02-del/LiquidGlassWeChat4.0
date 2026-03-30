#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// 递归查找 TabBar
static void traverseViews(UIView *view) {
    if (!view) return;
    for (UIView *sub in view.subviews) {
        if ([sub isKindOfClass:[UITabBar class]]) {
            UITabBar *tabBar = (UITabBar *)sub;
            
            // 清除原生
            tabBar.backgroundImage = [UIImage new];
            tabBar.shadowImage = [UIImage new];
            tabBar.backgroundColor = [UIColor clearColor];
            tabBar.clipsToBounds = NO;
            
            // 隐藏线条
            for (UIView *v in tabBar.subviews) {
                if (v.bounds.size.height < 3 || [v isKindOfClass:[UIVisualEffectView class]]) {
                    v.hidden = YES;
                }
            }
            
            // 悬浮样式
            CGRect f = UIEdgeInsetsInsetRect(tabBar.bounds, UIEdgeInsetsMake(0,20,20,20));
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
            if (@available(iOS 13.0, *)) {
                if (UITraitCollection.currentTraitCollection.userInterfaceStyle != UIUserInterfaceStyleDark) {
                    blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
                }
            }
            
            UIVisualEffectView *glass = [[UIVisualEffectView alloc] initWithEffect:blur];
            glass.frame = f;
            glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            glass.layer.cornerRadius = 24;
            glass.layer.masksToBounds = YES;
            glass.userInteractionEnabled = NO;
            
            glass.layer.shadowColor = UIColor.blackColor.CGColor;
            glass.layer.shadowOpacity = 0.3;
            glass.layer.shadowRadius = 12;
            glass.layer.shadowOffset = CGSizeMake(0,6);
            
            for (UIView *v in tabBar.subviews) {
                if ([v isKindOfClass:[UIVisualEffectView class]]) [v removeFromSuperview];
            }
            [tabBar insertSubview:glass atIndex:0];
        }
        traverseViews(sub);
    }
}

// 微信 8.0.68 / TrollStore 唯一能触发的方式
@implementation UIApplication (LiquidGlass)
+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.tencent.xinWeChat"]) return;
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            traverseViews(window);
        }
    });
}
@end
