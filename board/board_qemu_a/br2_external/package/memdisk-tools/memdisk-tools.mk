################################################################################
#
# memdisk-tools
#
################################################################################

MEMDISK_TOOLS_VERSION = 1.0
MEMDISK_TOOLS_SITE = $(TOPDIR)/../../../scripts
MEMDISK_TOOLS_SITE_METHOD = local
MEMDISK_TOOLS_LICENSE = GPL-2.0

# Memdisk staging directory path for other packages to copy files
MEMDISK_STAGING_DIR = $(BUILD_DIR)/memdisk-staging

# Export memdisk_extract script for host tools
MEMDISK_EXTRACT_SCRIPT = $(TOPDIR)/../../../scripts/extract_memdisk.sh

# Depend on all packages that may copy files to memdisk staging directory
# This ensures memdisk-tools is built after all other packages
MEMDISK_TOOLS_DEPENDENCIES += $(call qstrip,$(BR2_PACKAGE_MEMDISK_DEPENDENCIES))
MEMDISK_TOOLS_DEPENDENCIES += host-e2fsprogs

# Get configured size
MEMDISK_SIZE_ARG = $(call qstrip,$(BR2_PACKAGE_MEMDISK_SIZE))

# Convert size to MB count
ifeq ($(MEMDISK_SIZE_ARG),1G)
MEMDISK_SIZE_MB = 1024
else ifeq ($(MEMDISK_SIZE_ARG),512M)
MEMDISK_SIZE_MB = 512
else ifeq ($(MEMDISK_SIZE_ARG),256M)
MEMDISK_SIZE_MB = 256
else ifeq ($(MEMDISK_SIZE_ARG),128M)
MEMDISK_SIZE_MB = 128
else ifeq ($(MEMDISK_SIZE_ARG),64M)
MEMDISK_SIZE_MB = 64
else
MEMDISK_SIZE_MB = 256
endif

define MEMDISK_TOOLS_BUILD_CMDS
	# Create memdisk image directly using mkfs.ext4
	@echo "Creating memdisk.img of size $(MEMDISK_SIZE_ARG) ($(MEMDISK_SIZE_MB) MB)..."
	@echo "Using staging directory: $(MEMDISK_STAGING_DIR)"
	$(Q)$(HOST_DIR)/sbin/mkfs.ext4 \
		-d $(MEMDISK_STAGING_DIR) \
		-F \
		$(@D)/memdisk.img \
		"$(MEMDISK_SIZE_ARG)" > /dev/null 2>&1

	@echo "memdisk.img created successfully"
endef

define MEMDISK_TOOLS_INSTALL_TARGET_CMDS
	# Install memdisk.img to images directory
	$(INSTALL) -D -m 0644 $(@D)/memdisk.img $(BINARIES_DIR)/memdisk.img
	@echo "memdisk.img installed to $(BINARIES_DIR)/memdisk.img"

	# Install memdisk_extract script to host directory for other packages to use
	$(INSTALL) -D -m 0755 $(MEMDISK_EXTRACT_SCRIPT) $(HOST_DIR)/bin/memdisk_extract
	@echo "memdisk_extract script installed to $(HOST_DIR)/bin/memdisk_extract"
endef

$(eval $(generic-package))
