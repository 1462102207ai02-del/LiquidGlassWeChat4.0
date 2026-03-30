#import <UIKit/UIKit.h>

%ctor {
    // 完全不 hook，微信永远不崩
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            for (UIView *view in window.subviews) {
                if ([view isKindOfClass:[UITabBar class]]) {
                    UITabBar *tabBar = (UITabBar *)view;
                    
                    // 核心：只做透明，不触发任何防护
                    tabBar.backgroundImage = [UIImage new];
                    tabBar.shadowImage = [UIImage new];
                    tabBar.backgroundColor = [UIColor clearColor];
                    
                    // 隐藏自带黑线
                    for (UIView *sub in tabBar.subviews) {
                        if (sub.frame.size.height < 3) {
                            sub.hidden = YES;
                        }
                    }
                }
            }
        }
    });
}
