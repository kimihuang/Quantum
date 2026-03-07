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

$(eval $(generic-package))
