%hook UIView

- (void)didMoveToWindow {
    %orig;
    self.alpha = 0.95; // 简单效果：全局微透明
}

%end
