#import <UIKit/UIKit.h>

static void _findTabBars(UIView *root, void (^callback)(UITabBar *)) {
    for (UIView *v in root.subviews) {
        if ([v isKindOfClass:[UITabBar class]]) {
            callback((UITabBar *)v);
        }
        _findTabBars(v, callback);
    }
}

static void _applyStyleToTabBar(UITabBar *tabBar) {
    if (!tabBar) return;

    tabBar.backgroundImage = [UIImage new];
    tabBar.shadowImage = [UIImage new];
    tabBar.backgroundColor = [UIColor clearColor];
    tabBar.clipsToBounds = NO;

    for (UIView *sub in tabBar.subviews) {
        if (sub.bounds.size.height < 3 || [sub isKindOfClass:[UIVisualEffectView class]]) {
            sub.hidden = YES;
        }
    }

    CGRect frame = UIEdgeInsetsInsetRect(tabBar.bounds, UIEdgeInsetsMake(0, 18, 18, 18));
    CGFloat corner = 24;

    UIBlurEffect *blur;
    if (@available(iOS 13.0, *)) {
        if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
        } else {
            blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
        }
    } else {
        blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }

    UIVisualEffectView *glass = [[UIVisualEffectView alloc] initWithEffect:blur];
    glass.frame = frame;
    glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    glass.layer.cornerRadius = corner;
    glass.layer.masksToBounds = YES;
    glass.userInteractionEnabled = NO;

    glass.layer.shadowColor = [UIColor blackColor].CGColor;
    glass.layer.shadowOpacity = 0.25;
    glass.layer.shadowRadius = 10;
    glass.layer.shadowOffset = CGSizeMake(0, 6);

    for (UIView *v in tabBar.subviews) {
        if ([v isKindOfClass:[UIVisualEffectView class]]) [v removeFromSuperview];
    }
    [tabBar insertSubview:glass atIndex:0];

    for (UIView *btn in tabBar.subviews) {
        if ([btn isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            btn.frame = CGRectOffset(btn.frame, 0, -10);
        }
    }
}

%ctor {
    if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.tencent.xinWeChat"]) return;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            _findTabBars(window, ^(UITabBar *tabBar) {
                _applyStyleToTabBar(tabBar);
            });
        }

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n) {
            for (UIWindow *window in [UIApplication sharedApplication].windows) {
                _findTabBars(window, ^(UITabBar *tabBar) {
                    _applyStyleToTabBar(tabBar);
                });
            }
        }];
    });
}
