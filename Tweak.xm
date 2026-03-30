#import <UIKit/UIKit.h>

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            for (UIView *view in window.subviews) {
                if ([view isKindOfClass:[UITabBar class]]) {
                    UITabBar *tabBar = (UITabBar *)view;
                    tabBar.backgroundImage = [UIImage new];
                    tabBar.shadowImage = [UIImage new];
                    tabBar.backgroundColor = [UIColor clearColor];
                }
            }
        }
    });
}
