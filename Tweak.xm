#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static void findAndStyleTabBar(void);

__attribute__((constructor))
static void init(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
            addObserverForName:UIApplicationDidBecomeActiveNotification
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *note) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                findAndStyleTabBar();
            });
        }];
    });
}

static void styleTabBar(UITabBar *tabBar) {
    tabBar.backgroundImage = [UIImage new];
    tabBar.shadowImage = [UIImage new];
    tabBar.backgroundColor = [UIColor clearColor];

    for (UIView *v in tabBar.subviews) {
        if ([v isKindOfClass:[UIVisualEffectView class]] || v.bounds.size.height < 3) {
            v.hidden = YES;
        }
    }

    CGRect f = UIEdgeInsetsInsetRect(tabBar.bounds, UIEdgeInsetsMake(0, 20, 20, 20));
    UIBlurEffectStyle blurStyle = (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
        ? UIBlurEffectStyleSystemUltraThinMaterialDark
        : UIBlurEffectStyleSystemUltraThinMaterialLight;

    UIVisualEffectView *glass = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:blurStyle]];
    glass.frame = f;
    glass.autoresizingMask = UIViewAutoresizingMaskFlexibleWidth | UIViewAutoresizingMaskFlexibleHeight;
    glass.layer.cornerRadius = 24;
    glass.layer.masksToBounds = YES;
    glass.userInteractionEnabled = NO;

    glass.layer.shadowColor = UIColor.blackColor.CGColor;
    glass.layer.shadowOpacity = 0.25;
    glass.layer.shadowRadius = 10;
    glass.layer.shadowOffset = CGSizeMake(0, 6);

    for (UIView *v in tabBar.subviews) {
        if ([v isKindOfClass:[UIVisualEffectView class]]) [v removeFromSuperview];
    }
    [tabBar insertSubview:glass atIndex:0];
}

static void traverse(UIView *v) {
    if ([v isKindOfClass:[UITabBar class]]) styleTabBar((UITabBar *)v);
    for (UIView *sub in v.subviews) traverse(sub);
}

static void findAndStyleTabBar(void) {
    if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.tencent.xinWeChat"]) return;
    for (UIWindow *window in [UIApplication sharedApplication].windows) traverse(window);
}
