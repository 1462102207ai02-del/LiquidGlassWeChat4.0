#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define LG_DEBUG 0

#if LG_DEBUG
#define LGLog(FMT, ...) NSLog(@"[LiquidTabBar] " FMT, ##__VA_ARGS__)
#else
#define LGLog(FMT, ...)
#endif

static const void *kLGNavGlassKey = &kLGNavGlassKey;
static const void *kLGTabGlassKey = &kLGTabGlassKey;

@interface LGGlassView : UIView
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *tintView;
@property (nonatomic, strong) UIView *highlightView;
@property (nonatomic, strong) CAGradientLayer *highlightLayer;
@property (nonatomic, strong) CAShapeLayer *borderLayer;
@property (nonatomic, assign) CGFloat cornerRadiusOverride;
- (instancetype)initWithCornerRadiusOverride:(CGFloat)cornerRadiusOverride;
- (void)refreshMaterial;
@end

@implementation LGGlassView

- (instancetype)initWithCornerRadiusOverride:(CGFloat)cornerRadiusOverride {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = UIColor.clearColor;
        self.opaque = NO;
        self.clipsToBounds = NO;
        self.layer.masksToBounds = NO;
        self.cornerRadiusOverride = cornerRadiusOverride;

        UIBlurEffect *effect = nil;
        if (@available(iOS 13.0, *)) {
            effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
        } else {
            effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        }

        self.blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
        self.blurView.userInteractionEnabled = NO;
        self.blurView.clipsToBounds = YES;
        self.blurView.backgroundColor = UIColor.clearColor;
        [self addSubview:self.blurView];

        self.tintView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tintView.userInteractionEnabled = NO;
        [self.blurView.contentView addSubview:self.tintView];

        self.highlightView = [[UIView alloc] initWithFrame:CGRectZero];
        self.highlightView.userInteractionEnabled = NO;
        self.highlightView.backgroundColor = UIColor.clearColor;
        self.highlightView.clipsToBounds = YES;
        [self addSubview:self.highlightView];

        self.highlightLayer = [CAGradientLayer layer];
        self.highlightLayer.startPoint = CGPointMake(0.15, 0.0);
        self.highlightLayer.endPoint = CGPointMake(0.85, 1.0);
        [self.highlightView.layer addSublayer:self.highlightLayer];

        self.borderLayer = [CAShapeLayer layer];
        self.borderLayer.fillColor = UIColor.clearColor.CGColor;
        self.borderLayer.lineWidth = 1.0;
        [self.layer addSublayer:self.borderLayer];

        if (@available(iOS 13.0, *)) {
            self.blurView.layer.cornerCurve = kCACornerCurveContinuous;
            self.highlightView.layer.cornerCurve = kCACornerCurveContinuous;
            self.layer.cornerCurve = kCACornerCurveContinuous;
        }

        [self refreshMaterial];
    }
    return self;
}

- (CGFloat)effectiveCornerRadius {
    if (self.cornerRadiusOverride > 0.0) {
        return self.cornerRadiusOverride;
    }
    CGFloat radius = MIN(self.bounds.size.height * 0.42, 24.0);
    return MAX(radius, 14.0);
}

- (void)refreshMaterial {
    BOOL dark = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);

    self.tintView.backgroundColor = dark
        ? [UIColor colorWithWhite:1.0 alpha:0.045]
        : [UIColor colorWithWhite:1.0 alpha:0.11];

    self.highlightLayer.colors = @[
        (__bridge id)[UIColor colorWithWhite:1.0 alpha:(dark ? 0.16 : 0.34)].CGColor,
        (__bridge id)[UIColor colorWithWhite:1.0 alpha:(dark ? 0.07 : 0.16)].CGColor,
        (__bridge id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor
    ];
    self.highlightLayer.locations = @[@0.0, @0.28, @1.0];

    self.borderLayer.strokeColor = (dark
        ? [UIColor colorWithWhite:1.0 alpha:0.20]
        : [UIColor colorWithWhite:1.0 alpha:0.30]).CGColor;

    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = dark ? 0.22f : 0.10f;
    self.layer.shadowRadius = dark ? 18.0f : 14.0f;
    self.layer.shadowOffset = CGSizeMake(0.0, 8.0);
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self refreshMaterial];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat radius = [self effectiveCornerRadius];
    CGRect bounds = self.bounds;

    self.blurView.frame = bounds;
    self.tintView.frame = self.blurView.contentView.bounds;
    self.highlightView.frame = bounds;
    self.highlightLayer.frame = self.highlightView.bounds;

    self.blurView.layer.cornerRadius = radius;
    self.highlightView.layer.cornerRadius = radius;

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:radius];
    self.borderLayer.path = path.CGPath;
    self.layer.shadowPath = path.CGPath;
}

@end

static inline BOOL LGViewVisible(UIView *view) {
    return view && !view.hidden && view.alpha > 0.01 && CGRectGetWidth(view.bounds) > 1.0 && CGRectGetHeight(view.bounds) > 1.0;
}

static void LGHideSystemBarBackground(UIView *bar) {
    if (!bar) return;

    for (UIView *subview in bar.subviews) {
        NSString *cls = NSStringFromClass([subview class]);
        if ([cls containsString:@"_UIBarBackground"] || [cls containsString:@"BarBackground"]) {
            subview.hidden = YES;
            subview.alpha = 0.0;
        }
    }
}

static void LGConfigureNavigationBar(UINavigationBar *bar) {
    if (!LGViewVisible(bar)) return;

    bar.translucent = YES;
    bar.backgroundColor = UIColor.clearColor;
    bar.clipsToBounds = NO;

    @try {
        [bar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        bar.shadowImage = [UIImage new];
    } @catch (__unused NSException *exception) {}

    LGHideSystemBarBackground(bar);

    LGGlassView *glass = objc_getAssociatedObject(bar, kLGNavGlassKey);
    if (!glass) {
        glass = [[LGGlassView alloc] initWithCornerRadiusOverride:18.0];
        glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        objc_setAssociatedObject(bar, kLGNavGlassKey, glass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [bar insertSubview:glass atIndex:0];
    }

    CGFloat sideInset = 8.0;
    CGFloat topInset = 4.0;
    CGFloat bottomInset = 4.0;
    CGRect frame = CGRectInset(bar.bounds, sideInset, 0.0);
    frame.origin.y += topInset;
    frame.size.height -= (topInset + bottomInset);

    if (CGRectGetHeight(frame) < 28.0) {
        frame.size.height = MAX(CGRectGetHeight(bar.bounds) - 2.0, 28.0);
        frame.origin.y = 1.0;
    }

    glass.frame = CGRectIntegral(frame);
    [bar sendSubviewToBack:glass];
}

static void LGConfigureTabBar(UITabBar *bar) {
    if (!LGViewVisible(bar)) return;

    bar.translucent = YES;
    bar.backgroundColor = UIColor.clearColor;
    bar.clipsToBounds = NO;

    @try {
        bar.backgroundImage = [UIImage new];
        bar.shadowImage = [UIImage new];
    } @catch (__unused NSException *exception) {}

    LGHideSystemBarBackground(bar);

    LGGlassView *glass = objc_getAssociatedObject(bar, kLGTabGlassKey);
    if (!glass) {
        glass = [[LGGlassView alloc] initWithCornerRadiusOverride:22.0];
        glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        objc_setAssociatedObject(bar, kLGTabGlassKey, glass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [bar insertSubview:glass atIndex:0];
    }

    CGFloat sideInset = 8.0;
    CGFloat verticalInset = 6.0;
    CGRect frame = CGRectInset(bar.bounds, sideInset, verticalInset);
    if (CGRectGetHeight(frame) < 44.0) {
        frame = CGRectInset(bar.bounds, sideInset, 2.0);
    }

    glass.frame = CGRectIntegral(frame);
    [bar sendSubviewToBack:glass];
}

%hook UINavigationBar

- (void)layoutSubviews {
    %orig;
    @autoreleasepool {
        LGConfigureNavigationBar((UINavigationBar *)self);
    }
}

%end

%hook UITabBar

- (void)layoutSubviews {
    %orig;
    @autoreleasepool {
        LGConfigureTabBar((UITabBar *)self);
    }
}

%end

%ctor {
    @autoreleasepool {
        LGLog(@"loaded");
    }
}
