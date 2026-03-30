#import <UIKit/UIKit.h>

// 全局 UIView 透明测试（确保 tweak 生效）
%hook UIView

- (void)didMoveToWindow {
    %orig;
    
    // 避免影响系统关键窗口
    if ([self isKindOfClass:[UIWindow class]]) return;
    
    self.alpha = 0.95;
}

%end
