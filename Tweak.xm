#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

static CGFloat globalAlpha() {
    CGFloat alpha = [[NSUserDefaults standardUserDefaults] floatForKey:@"LiquidGlassWeChat_Alpha"];
    return (alpha < 0.1) ? 0.7 : alpha;
}

static NSInteger currentStyle() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"LiquidGlassWeChat_Style"];
}

static BOOL hideTabBarTitles() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"LiquidGlassWeChat_HideTitles"];
}

static CGFloat tabBarIconScale() {
    CGFloat scale = [[NSUserDefaults standardUserDefaults] floatForKey:@"LiquidGlassWeChat_IconScale"];
    return (scale < 0.1) ? 1.0 : scale;
}

static CGFloat tabBarCornerRadius() {
    CGFloat radius = [[NSUserDefaults standardUserDefaults] floatForKey:@"LiquidGlassWeChat_CornerRadius"];
    return (radius < 1) ? 20 : radius;
}

static BOOL enableGlowEffect() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"LiquidGlassWeChat_EnableGlow"];
}

static void applyGradientLayer(UIView *toView) {
    for (CALayer *layer in toView.layer.sublayers) {
        if ([layer.name isEqualToString:@"LiquidGlassGradient"]) {
            [layer removeFromSuperlayer];
        }
    }

    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.name = @"LiquidGlassGradient";
    gl.frame = toView.bounds;
    gl.colors = @[
        (__bridge id)[UIColor colorWithRed:0.35 green:0.55 blue:1.0 alpha:0.16].CGColor,
        (__bridge id)[UIColor colorWithRed:0.75 green:0.45 blue:1.0 alpha:0.16].CGColor
    ];
    gl.startPoint = CGPointMake(0, 0);
    gl.endPoint = CGPointMake(1, 1);
    [toView.layer insertSublayer:gl atIndex:0];
}

static void applyGlowLayer(UIView *toView) {
    for (CALayer *layer in toView.layer.sublayers) {
        if ([layer.name isEqualToString:@"LiquidGlassGlow"]) {
            [layer removeFromSuperlayer];
        }
    }

    CALayer *glow = [CALayer layer];
    glow.name = @"LiquidGlassGlow";
    glow.frame = toView.bounds;
    glow.cornerRadius = toView.layer.cornerRadius;
    glow.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
    glow.borderWidth = 0.6;
    glow.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.4].CGColor;
    glow.shadowOpacity = 1.0;
    glow.shadowRadius = 6.0;
    glow.shadowOffset = CGSizeZero;
    glow.masksToBounds = NO;
    [toView.layer insertSublayer:glow above:0];
}

%hook UITabBar

- (void)layoutSubviews {
    %orig;

    self.backgroundImage = [UIImage new];
    self.shadowImage = [UIImage new];
    self.backgroundColor = UIColor.clearColor;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = tabBarCornerRadius();

    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:NSClassFromString(@"UIVisualEffectView")]) {
            [v removeFromSuperview];
        }
    }

    UIBlurEffect *blurEffect;
    UIColor *overlayColor;
    CGFloat overlayAlpha = 0.12;
    NSInteger style = currentStyle();

    if (@available(iOS 12, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialDark];
        } else {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialLight];
        }
    } else {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }

    switch (style) {
        case 1:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            overlayColor = [UIColor whiteColor];
            overlayAlpha = 0.25;
            break;
        case 2:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            overlayColor = [UIColor blackColor];
            overlayAlpha = 0.2;
            break;
        case 3:
            overlayColor = [UIColor colorWithRed:0.2 green:0.45 blue:1.0 alpha:1.0];
            break;
        case 4:
            overlayColor = [UIColor colorWithRed:0.65 green:0.25 blue:1.0 alpha:1.0];
            break;
        case 5:
            overlayColor = [UIColor colorWithRed:1.0 green:0.35 blue:0.6 alpha:1.0];
            break;
        case 6:
            overlayColor = UIColor.clearColor;
            overlayAlpha = 0;
            break;
        default:
            overlayColor = [UIColor blackColor];
            break;
    }

    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    effectView.frame = self.bounds;
    effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    effectView.userInteractionEnabled = NO;
    effectView.alpha = globalAlpha();
    effectView.layer.cornerRadius = self.layer.cornerRadius;
    effectView.clipsToBounds = YES;

    UIView *colorOverlay = [[UIView alloc] initWithFrame:effectView.bounds];
    colorOverlay.backgroundColor = overlayColor;
    colorOverlay.alpha = overlayAlpha;
    colorOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [effectView.contentView addSubview:colorOverlay];

    if (style == 6) {
        applyGradientLayer(effectView);
    }

    [self insertSubview:effectView atIndex:0];

    if (enableGlowEffect()) {
        applyGlowLayer(self);
    }
}

%end

// 安全图标缩放（无报错）
%hook UIView
- (void)layoutSubviews {
    %orig;
    if ([self.superview isKindOfClass:NSClassFromString(@"UITabBar")]) {
        CGFloat scale = tabBarIconScale();
        if (scale != 1.0) {
            self.transform = CGAffineTransformMakeScale(scale, scale);
        }
    }
}
%end

// 安全隐藏文字（无报错）
%hook UILabel
- (void)setText:(NSString *)text {
    UIView *superView = self.superview;
    while (superView) {
        if ([superView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            if (hideTabBarTitles()) {
                %orig(nil);
                return;
            }
            break;
        }
        superView = superView.superview;
    }
    %orig;
}
%end
