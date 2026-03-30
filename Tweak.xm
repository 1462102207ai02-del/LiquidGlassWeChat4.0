#import <UIKit/UIKit.h>

%ctor {
    // 只在微信里生效
    if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.tencent.xinWeChat"]) return;

    // 延迟 5 秒，避开微信启动检测
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            for (UIView *view in window.subviews) {
                if ([view isKindOfClass:[UITabBar class]]) {
                    UITabBar *tabBar = (UITabBar *)view;

                    // 清除微信原生底栏
                    tabBar.backgroundImage = [UIImage new];
                    tabBar.shadowImage = [UIImage new];
                    tabBar.backgroundColor = [UIColor clearColor];
                    tabBar.clipsToBounds = NO;
                    tabBar.layer.cornerRadius = 0;

                    // 隐藏原生分割线和毛玻璃
                    for (UIView *sub in tabBar.subviews) {
                        if (sub.frame.size.height < 3 || [sub isKindOfClass:[UIVisualEffectView class]]) {
                            sub.hidden = YES;
                        }
                    }

                    // 悬浮内边距（和 Telegram 一致：左右/底部留白）
                    CGRect frame = UIEdgeInsetsInsetRect(tabBar.bounds, UIEdgeInsetsMake(0, 18, 18, 18));
                    CGFloat cornerRadius = 24; // 大圆角，和 Telegram 一致

                    // 自动适配浅色/深色毛玻璃
                    UIBlurEffect *blur;
                    if (@available(iOS 13.0, *)) {
                        if (window.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                            // 深色模式：深色通透毛玻璃
                            blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
                        } else {
                            // 浅色模式：浅色通透毛玻璃
                            blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
                        }
                    } else {
                        blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                    }

                    UIVisualEffectView *glassView = [[UIVisualEffectView alloc] initWithEffect:blur];
                    glassView.frame = frame;
                    glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    glassView.layer.cornerRadius = cornerRadius;
                    glassView.layer.masksToBounds = YES;
                    glassView.userInteractionEnabled = NO;

                    // 柔和阴影（营造悬浮感）
                    glassView.layer.shadowColor = [UIColor blackColor].CGColor;
                    glassView.layer.shadowOpacity = 0.25;
                    glassView.layer.shadowRadius = 10;
                    glassView.layer.shadowOffset = CGSizeMake(0, 6);

                    // 替换旧玻璃视图
                    for (UIView *v in tabBar.subviews) {
                        if ([v isKindOfClass:[UIVisualEffectView class]]) {
                            [v removeFromSuperview];
                        }
                    }
                    [tabBar insertSubview:glassView atIndex:0];

                    // 图标上移，避免被悬浮底栏遮挡
                    for (UIView *btn in tabBar.subviews) {
                        if ([btn isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
                            btn.frame = CGRectOffset(btn.frame, 0, -10);
                        }
                    }
                }
            }
        }

        // 监听深浅模式切换，自动更新玻璃效果
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                          object:nil queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *n) {
            for (UIWindow *window in [UIApplication sharedApplication].windows) {
                for (UIView *view in window.subviews) {
                    if ([view isKindOfClass:[UITabBar class]]) {
                        // 移除旧玻璃
                        for (UIView *v in view.subviews) {
                            if ([v isKindOfClass:[UIVisualEffectView class]]) {
                                [v removeFromSuperview];
                            }
                        }
                        // 重新应用新效果
                        UITabBar *tabBar = (UITabBar *)view;
                        CGRect frame = UIEdgeInsetsInsetRect(tabBar.bounds, UIEdgeInsetsMake(0, 18, 18, 18));
                        CGFloat cornerRadius = 24;

                        UIBlurEffect *blur;
                        if (@available(iOS 13.0, *)) {
                            if (window.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                                blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
                            } else {
                                blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
                            }
                        } else {
                            blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                        }

                        UIVisualEffectView *glassView = [[UIVisualEffectView alloc] initWithEffect:blur];
                        glassView.frame = frame;
                        glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                        glassView.layer.cornerRadius = cornerRadius;
                        glassView.layer.masksToBounds = YES;
                        glassView.userInteractionEnabled = NO;

                        glassView.layer.shadowColor = [UIColor blackColor].CGColor;
                        glassView.layer.shadowOpacity = 0.25;
                        glassView.layer.shadowRadius = 10;
                        glassView.layer.shadowOffset = CGSizeMake(0, 6);

                        [tabBar insertSubview:glassView atIndex:0];
                    }
                }
            }
        }];
    });
}
