ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LiquidTabBar

LiquidTabBar_FILES = Tweak.xm
LiquidTabBar_CFLAGS = -fobjc-arc
LiquidTabBar_FRAMEWORKS = UIKit QuartzCore
LiquidTabBar_INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS_MAKE_PATH)/tweak.mk
