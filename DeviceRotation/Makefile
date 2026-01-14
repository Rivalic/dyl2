TARGET = iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DeviceRotation

DeviceRotation_FILES = DeviceRotation.m FloatingButton.m
DeviceRotation_CFLAGS = -fobjc-arc
DeviceRotation_FRAMEWORKS = UIKit Foundation AdSupport CoreGraphics QuartzCore
DeviceRotation_LDFLAGS = -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/tweak.mk
