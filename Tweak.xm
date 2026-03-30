#import <UIKit/UIKit.h>

static BOOL isEnabled() {
    NSNumber *val = [[NSUserDefaults standardUserDefaults] objectForKey:@"lg_enable"];
    if (val) return [val boolValue];
    return YES;
}

static BOOL useShadow() {
    NSNumber *val = [[NSUserDefaults standardUserDefaults] objectForKey:@"lg_shadow"];
    if (val) return [val boolValue];
    return YES;
}

static void applyStyleToTabBar(UITabBar *tabBar) {
    if (!tabBar) return;

    tabBar.backgroundImage = [UIImage new];
    tabBar.shadowImage = [UIImage new];
    tabBar.backgroundColor = [UIColor clearColor];
    tabBar.clipsToBounds = NO;

    for (UIView *sub in tabBar.subviews) {
        if ([sub isKindOfClass:[UIVisualEffectView class]] || sub.bounds.size.height < 3) {
            sub.hidden = YES;
        }
    }

    CGRect frame = UIEdgeInsetsInsetRect(tabBar.bounds, UIEdgeInsetsMake(0, 16, 16, 16));
    CGFloat corner = 20.0f;

    UIBlurEffect *blur;
    if (@available(iOS 13.0, *)) {
        if (tabBar.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
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

    if (useShadow()) {
        glass.layer.shadowColor = UIColor.blackColor.CGColor;
        glass.layer.shadowOpacity = 0.28;
        glass.layer.shadowRadius = 12;
        glass.layer.shadowOffset = CGSizeMake(0, 6);
    }

    for (UIView *v in tabBar.subviews) {
        if ([v isKindOfClass:[UIVisualEffectView class]]) {
            [v removeFromSuperview];
        }
    }

    [tabBar insertSubview:glass atIndex:0];

    for (UIView *btn in tabBar.subviews) {
        if ([btn isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            btn.frame = CGRectOffset(btn.frame, 0, -8);
        }
    }
}

static void findAndApplyTabBarStyle() {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        for (UIView *view in window.subviews) {
            if ([view isKindOfClass:[UITabBar class]]) {
                applyStyleToTabBar((UITabBar *)view);
            }
        }
    }
}

%ctor {
    if (!isEnabled()) return;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        findAndApplyTabBarStyle();

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
            findAndApplyTabBarStyle();
        }];
    });
}
