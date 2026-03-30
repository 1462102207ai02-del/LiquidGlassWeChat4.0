#import <UIKit/UIKit.h>

%hook UITabBar

- (void)layoutSubviews {
    %orig;

    self.backgroundImage = [UIImage new];
    self.shadowImage = [UIImage new];
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 20;

    for (UIView *sub in self.subviews) {
        if ([sub isKindOfClass:[UIVisualEffectView class]]) {
            [sub removeFromSuperview];
        }
    }

    UIBlurEffect *blurEffect;
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialDark];
        } else {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialLight];
        }
    } else {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }

    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    effectView.frame = self.bounds;
    effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    effectView.userInteractionEnabled = NO;
    effectView.alpha = 0.7;

    [self insertSubview:effectView atIndex:0];
}

%end
