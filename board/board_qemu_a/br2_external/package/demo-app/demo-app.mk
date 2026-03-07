################################################################################
#
# demo-app
#
################################################################################

DEMO_APP_VERSION = 1.0
DEMO_APP_SITE = $(TOPDIR)/../../packages/demo-app
DEMO_APP_SITE_METHOD = local
DEMO_APP_LICENSE = GPL-2.0
DEMO_APP_LICENSE_FILES = COPYING

define DEMO_APP_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS)
endef

define DEMO_APP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/demo-app $(TARGET_DIR)/usr/bin/demo-app
endef

define DEMO_APP_INSTALL_TO_MEMDISK
	# Example: Copy demo-app executable to memdisk staging directory
	if [ -d "$(BUILD_DIR)/memdisk-staging" ]; then \
		$(INSTALL) -D -m 0755 $(@D)/demo-app \
			$(BUILD_DIR)/memdisk-staging/data/demo-app; \
		echo "Copied demo-app to memdisk staging directory"; \
	fi
endef

# Hook to install to memdisk before memdisk package builds
ifeq ($(BR2_PACKAGE_MEMDISK_TOOLS),y)
DEMO_APP_POST_INSTALL_TARGET_HOOKS += DEMO_APP_INSTALL_TO_MEMDISK
endif

$(eval $(generic-package))
