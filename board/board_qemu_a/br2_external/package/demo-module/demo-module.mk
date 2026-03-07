################################################################################
#
# demo-module
#
################################################################################

DEMO_MODULE_VERSION = 1.0
DEMO_MODULE_SITE = $(TOPDIR)/../../modules/demo-module
DEMO_MODULE_SITE_METHOD = local
DEMO_MODULE_LICENSE = GPL-2.0
DEMO_MODULE_LICENSE_FILES = COPYING

DEMO_MODULE_DEPENDENCIES = linux
DEMO_MODULE_MAKE_INSTALL_TARGET = DEMO_MODULE_INSTALL_TARGET_CMDS

# Build as kernel module
define DEMO_MODULE_BUILD_CMDS
	$(MAKE) -C $(LINUX_DIR) M=$(@D) \
		ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE=$(TARGET_CROSS) \
		modules
endef

define DEMO_MODULE_INSTALL_TARGET_CMDS
	$(MAKE) -C $(LINUX_DIR) M=$(@D) \
		ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE=$(TARGET_CROSS) \
		INSTALL_MOD_PATH=$(TARGET_DIR) \
		modules_install
endef

$(eval $(generic-package))
