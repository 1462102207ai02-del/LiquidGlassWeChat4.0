#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, TabBarStyle) {
    TabBarStyleSystemAutomatic = 0,
    TabBarStyleLightGlass,
    TabBarStyleDarkGlass,
    TabBarStyleBlueGlass,
    TabBarStylePurpleGlass,
    TabBarStylePinkGlass,
    TabBarStyleGradientGlass
};

static NSInteger currentStyle() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"LiquidGlassWeChat_Style"];
}

static CGFloat globalAlpha() {
    CGFloat alpha = [[NSUserDefaults standardUserDefaults] floatForKey:@"LiquidGlassWeChat_Alpha"];
    return (alpha < 0.1) ? 0.7 : alpha;
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
    glow.backgroundColor = UIColor.clearColor.CGColor;
    glow.cornerRadius = toView.layer.cornerRadius;
    glow.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
    glow.borderWidth = 0.6;
    glow.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.4].CGColor;
    glow.shadowOpacity = 1;
    glow.shadowRadius = 6;
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
    self.layer.cornerRadius = tabBarCornerRadius();
    self.clipsToBounds = YES;

    for (UIView *sub in self.subviews) {
        if ([sub isKindOfClass:[UIVisualEffectView class]]) {
            [sub removeFromSuperview];
        }
    }

    UIBlurEffect *blurEffect;
    UIColor *overlayColor;
    CGFloat overlayAlpha = 0.12;
    CGFloat alpha = globalAlpha();
    NSInteger style = currentStyle();

    switch (style) {
        case TabBarStyleSystemAutomatic:
            if (@available(iOS 12.0, *)) {
                if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialDark];
                    overlayColor = [UIColor whiteColor];
                } else {
                    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialLight];
                    overlayColor = [UIColor blackColor];
                }
            } else {
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                overlayColor = [UIColor blackColor];
            }
            break;
        case TabBarStyleLightGlass:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            overlayColor = [UIColor whiteColor];
            overlayAlpha = 0.25;
            break;
        case TabBarStyleDarkGlass:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            overlayColor = [UIColor blackColor];
            overlayAlpha = 0.2;
            break;
        case TabBarStyleBlueGlass:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            overlayColor = [UIColor colorWithRed:0.2 green:0.45 blue:1.0 alpha:1.0];
            break;
        case TabBarStylePurpleGlass:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            overlayColor = [UIColor colorWithRed:0.65 green:0.25 blue:1.0 alpha:1.0];
            break;
        case TabBarStylePinkGlass:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            overlayColor = [UIColor colorWithRed:1.0 green:0.35 blue:0.6 alpha:1.0];
            break;
        case TabBarStyleGradientGlass:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            overlayColor = UIColor.clearColor;
            overlayAlpha = 0;
            break;
        default:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialLight];
            overlayColor = [UIColor blackColor];
            break;
    }

    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    effectView.frame = self.bounds;
    effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    effectView.userInteractionEnabled = NO;
    effectView.alpha = alpha;
    effectView.layer.cornerRadius = self.layer.cornerRadius;
    effectView.clipsToBounds = YES;

    UIView *colorView = [[UIView alloc] initWithFrame:effectView.bounds];
    colorView.backgroundColor = overlayColor;
    colorView.alpha = overlayAlpha;
    colorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [effectView.contentView addSubview:colorView];

    if (style == TabBarStyleGradientGlass) {
        applyGradientLayer(effectView);
    }

    [self insertSubview:effectView atIndex:0];

    if (enableGlowEffect()) {
        applyGlowLayer(self);
    }
}

%end

%hook UIView

- (void)setTransform:(CGAffineTransform)transform {
    if ([self.superview isKindOfClass:NSClassFromString(@"UITabBar")]) {
        CGFloat scale = tabBarIconScale();
        %orig(CGAffineTransformMakeScale(scale, scale));
        return;
    }
    %orig;
}

%end

%hook UITabBarItem

- (id)initWithTitle:(id)title image:(id)image selectedImage:(id)selectedImage {
    if (hideTabBarTitles()) {
        title = nil;
    }
    return %orig;
}

- (void)setTitle:(id)title {
    if (hideTabBarTitles()) return;
    %orig;
}

%end
