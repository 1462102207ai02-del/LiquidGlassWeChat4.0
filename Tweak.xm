#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// 从设置读取开关
static BOOL isEnabled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"lg_enable" defaultValue:YES];
}
static CGFloat cornerRadius() {
    return [[NSUserDefaults standardUserDefaults] floatForKey:@"lg_corner" defaultValue:20];
}
static CGFloat paddingBottom() {
    return [[NSUserDefaults standardUserDefaults] floatForKey:@"lg_padding" defaultValue:16];
}
static BOOL useShadow() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"lg_shadow" defaultValue:YES];
}

%ctor {
    if (!isEnabled()) return;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            [self applyToWindow:window];
        }

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                          object:nil queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *n) {
            for (UIWindow *window in [UIApplication sharedApplication].windows) {
                [self applyToWindow:window];
            }
        }];
    });
}

+ (void)applyToWindow:(UIWindow *)window {
    for (UIView *v in window.subviews) {
        if ([v isKindOfClass:NSClassFromString(@"UITabBar")]) {
            UITabBar *tab = (UITabBar *)v;

            tab.backgroundImage = UIImage.new;
            tab.shadowImage = UIImage.new;
            tab.backgroundColor = UIColor.clearColor;
            tab.clipsToBounds = NO;

            for (UIView *sub in tab.subviews) {
                if ([sub isKindOfClass:UIVisualEffectView.class] || sub.bounds.size.height < 3) {
                    sub.hidden = YES;
                }
            }

            CGFloat pad = paddingBottom();
            CGRect f = UIEdgeInsetsInsetRect(tab.bounds, UIEdgeInsetsMake(0,16,pad,16));
            CGFloat r = cornerRadius();

            UIBlurEffect *blur;
            if (@available(iOS 13, *)) {
                if (window.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
                } else {
                    blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
                }
            } else {
                blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            }

            UIVisualEffectView *glass = [[UIVisualEffectView alloc] initWithEffect:blur];
            glass.frame = f;
            glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            glass.layer.cornerRadius = r;
            glass.layer.masksToBounds = YES;
            glass.userInteractionEnabled = NO;

            if (useShadow()) {
                glass.layer.shadowColor = UIColor.blackColor.CGColor;
                glass.layer.shadowOpacity = 0.28;
                glass.layer.shadowRadius = 12;
                glass.layer.shadowOffset = CGSizeMake(0,6);
            }

            for (UIView *sub in tab.subviews) {
                if ([sub isKindOfClass:UIVisualEffectView.class] && sub != glass) [sub removeFromSuperview];
            }
            [tab insertSubview:glass atIndex:0];

            for (UIView *btn in tab.subviews) {
                if ([btn isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
                    btn.frame = CGRectOffset(btn.frame, 0, -8);
                }
            }
        }
        [self applyToView:v];
    }
}

+ (void)applyToView:(UIView *)root {
    for (UIView *v in root.subviews) {
        if ([v isKindOfClass:NSClassFromString(@"UITabBar")]) {
            [self applyToWindow:v.window];
        }
        [self applyToView:v];
    }
}

@implementation NSUserDefaults (Additions)
- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)def {
    if (![self objectForKey:key]) return def;
    return [self boolForKey:key];
}
- (CGFloat)floatForKey:(NSString *)key defaultValue:(CGFloat)def {
    if (![self objectForKey:key]) return def;
    return [self floatForKey:key];
}
@end
