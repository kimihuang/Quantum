# Buildroot External Packages for Quantum Board

## Directory Structure

```
br2_external/
├── Config.in              # External package menu configuration
├── external.desc          # Description of this external tree
├── external.mk            # External tree makefile
├── configs/               # Board-specific defconfigs
├── package/               # External packages
│   ├── demo-app/          # Demo application package
│   │   ├── Config.in      # Package Kconfig
│   │   ├── demo-app.mk    # Package makefile
│   │   └── demo-app.hash  # Package hashes
│   └── demo-module/       # Demo kernel module package
│       ├── Config.in      # Package Kconfig
│       ├── demo-module.mk # Package makefile
│       └── demo-module.hash
└── README.md              # This file
```

## Demo Packages

### demo-app
A simple user-space application demonstrating:
- Basic Buildroot package structure
- Local source package with `SITE_METHOD = local`
- Install to `/usr/bin/`

### demo-module
A kernel module package demonstrating:
- Kernel module integration with Buildroot
- Building against target kernel
- Install modules to target filesystem

## Adding New Packages

1. Create package directory:
   ```bash
   mkdir -p br2_external/package/my-package
   ```

2. Create package files:
   - `Config.in` - Package configuration
   - `my-package.mk` - Package makefile
   - `my-package.hash` - Hashes for integrity checking

3. Add package to Config.in:
   ```
   source "package/my-package/Config.in"
   ```

4. Place source code:
   - For local packages: `src/packages/my-package/`
   - For remote packages: use URL in `.mk` file

5. Reconfigure Buildroot:
   ```bash
   make menuconfig
   # Enable your package under "Board options -> Quantum Board Packages"
   ```

6. Build:
   ```bash
   make my-package
   ```

## Package Makefile Format

```makefile
MY_PACKAGE_VERSION = 1.0
MY_PACKAGE_SITE = $(TOPDIR)/../src/packages/my-package
MY_PACKAGE_SITE_METHOD = local
MY_PACKAGE_LICENSE = GPL-2.0
MY_PACKAGE_LICENSE_FILES = COPYING

define MY_PACKAGE_BUILD_CMDS
    # Build commands here
endef

define MY_PACKAGE_INSTALL_TARGET_CMDS
    # Install commands here
endef

$(eval $(generic-package))
```

## Kernel Modules

For kernel modules, use:
```makefile
DEMO_MODULE_SITE = $(TOPDIR)/../src/modules/demo-module
DEMO_MODULE_SITE_METHOD = local

define DEMO_MODULE_BUILD_CMDS
    $(MAKE) -C $(LINUX_DIR) M=$(@D) ARCH=$(KERNEL_ARCH) \
        CROSS_COMPILE=$(TARGET_CROSS) modules
endef

define DEMO_MODULE_INSTALL_TARGET_CMDS
    $(MAKE) -C $(LINUX_DIR) M=$(@D) ARCH=$(KERNEL_ARCH) \
        CROSS_COMPILE=$(TARGET_CROSS) INSTALL_MOD_PATH=$(TARGET_DIR) \
        modules_install
endef
```

## References
- Buildroot Manual: https://buildroot.org/manual.html
- External Packages: https://buildroot.org/manual.html#add-pkg-external
