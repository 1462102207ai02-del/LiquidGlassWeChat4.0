#import <UIKit/UIKit.h>

static void styleTabBar(UITabBar *tabBar) {
    tabBar.backgroundImage = [UIImage new];
    tabBar.shadowImage = [UIImage new];
    tabBar.backgroundColor = [UIColor clearColor];
    tabBar.clipsToBounds = NO;

    // 隐藏分割线
    for (UIView *sub in tabBar.subviews) {
        if (sub.bounds.size.height < 3 || [sub isKindOfClass:[UIVisualEffectView class]]) {
            sub.hidden = YES;
        }
    }

    // 悬浮间距
    CGRect frame = UIEdgeInsetsInsetRect(tabBar.bounds, UIEdgeInsetsMake(0, 20, 20, 20));
    CGFloat cornerRadius = 24;

    // 深浅模式自动切换
    UIBlurEffect *blurEffect;
    if (@available(iOS 13.0, *)) {
        if (tabBar.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
        } else {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
        }
    } else {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }

    UIVisualEffectView *glassView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    glassView.frame = frame;
    glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    glassView.layer.cornerRadius = cornerRadius;
    glassView.layer.masksToBounds = YES;
    glassView.userInteractionEnabled = NO;

    // 阴影
    glassView.layer.shadowColor = [[UIColor blackColor] CGColor];
    glassView.layer.shadowOpacity = 0.28;
    glassView.layer.shadowRadius = 12;
    glassView.layer.shadowOffset = CGSizeMake(0, 6);

    // 清理旧玻璃
    for (UIView *v in tabBar.subviews) {
        if ([v isKindOfClass:[UIVisualEffectView class]]) {
            [v removeFromSuperview];
        }
    }

    [tabBar insertSubview:glassView atIndex:0];
}

static void traverseViews(UIView *view) {
    if (!view) return;
    if ([view isKindOfClass:[UITabBar class]]) {
        styleTabBar((UITabBar *)view);
    }
    for (UIView *sub in view.subviews) {
        traverseViews(sub);
    }
}

%ctor {
    if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.tencent.xinWeChat"]) {
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            traverseViews(window);
        }
    });
}
