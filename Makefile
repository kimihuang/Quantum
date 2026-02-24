# 顶层Makefile，用于编译src/buildroot/buildroot-2025.02-rc1/



# buildroot源码路径由环境变量BUILDROOT_DIR提供，Makefile内部变量名避免冲突
BUILDROOT_PATH ?= $(BUILDROOT_DIR)
ifeq ($(BUILDROOT_PATH),)
BUILDROOT_PATH := src/buildroot/buildroot-2025.02-rc1
endif

.PHONY: all buildroot clean distclean menuconfig

all: buildroot

buildroot:
	$(MAKE) -C $(BUILDROOT_PATH)

menuconfig:
	$(MAKE) -C $(BUILDROOT_PATH) menuconfig

clean:
	$(MAKE) -C $(BUILDROOT_PATH) clean

distclean:
	$(MAKE) -C $(BUILDROOT_PATH) distclean
