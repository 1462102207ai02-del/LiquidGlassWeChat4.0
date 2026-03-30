#import <UIKit/UIKit.h>
#import <objc/runtime.h>

%hook UITabBar

- (void)didMoveToWindow {
    %orig;

    // 背景毛玻璃
    UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial]];
    blur.frame = self.bounds;
    blur.userInteractionEnabled = NO;
    blur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:blur atIndex:0];

    // 动态流光效果
    CAGradientLayer *glow = [CAGradientLayer layer];
    glow.frame = self.bounds;
    glow.colors = @[
        (__bridge id)[UIColor colorWithWhite:1 alpha:0.15].CGColor,
        (__bridge id)[UIColor colorWithWhite:1 alpha:0.05].CGColor,
        (__bridge id)[UIColor colorWithWhite:1 alpha:0.15].CGColor
    ];
    glow.startPoint = CGPointMake(0, 0.5);
    glow.endPoint = CGPointMake(1, 0.5);
    glow.locations = @[@0, @0.5, @1];
    [self.layer addSublayer:glow];

    // 流光动画
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"locations"];
    anim.fromValue = @[@-1, @-0.5, @0];
    anim.toValue = @[@1, @1.5, @2];
    anim.duration = 2;
    anim.repeatCount = HUGE_VALF;
    [glow addAnimation:anim forKey:@"flow"];
}

%end

// 推送头像自定义（只在微信通知里）
%hook UIView
- (void)didMoveToWindow {
    %orig;

    if ([self isKindOfClass:NSClassFromString(@"_UIStatusBarNotificationView")]) {
        for (UIView *sub in self.subviews) {
            if ([sub isKindOfClass:NSClassFromString(@"UIImageView")]) {
                UIImageView *imgView = (UIImageView *)sub;
                // 替换成你想的头像，示例：
                imgView.image = [UIImage imageNamed:@"custom_avatar"];
            }
        }
    }
}

%end
