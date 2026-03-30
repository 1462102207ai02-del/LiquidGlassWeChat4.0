ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LiquidGlassWeChat

LiquidGlassWeChat_FILES = Tweak.xm
LiquidGlassWeChat_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable
LiquidGlassWeChat_FRAMEWORKS = UIKit CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
