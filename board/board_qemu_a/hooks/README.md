# Buildroot Hooks for board_qemu_a

## Overview

This directory contains custom scripts that run at various points during the Buildroot build process.

## Hook Scripts

| Hook Script | Description | Buildroot Config Option |
|-------------|-------------|-------------------------|
| `pre_build.sh` | Runs before commencing the build | `BR2_ROOTFS_PRE_BUILD_SCRIPT` |
| `post_build.sh` | Runs after the build is complete | `BR2_ROOTFS_POST_BUILD_SCRIPT` |
| `pre_image.sh` | Runs before creating filesystem images | `BR2_ROOTFS_PRE_IMAGE_SCRIPT` |
| `fakeroot.sh` | Runs inside the fakeroot environment | `BR2_ROOTFS_FAKEROOT_SCRIPT` |
| `post_image.sh` | Runs after creating filesystem images | `BR2_ROOTFS_POST_IMAGE_SCRIPT` |

## Environment Variables

All hooks have access to these Buildroot environment variables:

- `BR2_CONFIG` - Path to the .config file
- `HOST_DIR` - Path to host directory
- `STAGING_DIR` - Path to staging directory
- `TARGET_DIR` - Path to target directory
- `BUILD_DIR` - Path to build directory
- `BINARIES_DIR` - Path to images directory

## Board-Specific Variables

Source `../board_env.sh` to access board-specific variables:

```bash
source "$(dirname "$0")/../board_env.sh"
```

Available variables:

- `BOARD_DIR` - Board configuration directory
- `BOARD_NAME` - Board name
- `PROJECT_ROOT` - Project root directory
- `HOOKS_DIR` - Hooks directory
- `MEMDISK_STAGING_DIR` - Memdisk staging directory

## Hook Execution Order

1. `pre_build.sh` - Before any packages are built
2. Build all packages
3. `post_build.sh` - After all packages are built to TARGET_DIR
4. `pre_image.sh` - Before creating filesystem images
5. `fakeroot.sh` - Inside fakeroot environment (for creating devices, setting ownership)
6. Create filesystem images
7. `post_image.sh` - After images are created

## Usage

To use these hooks, configure them in Buildroot:

```
make menuconfig
```

Navigate to:
- `System configuration` → `Custom scripts to run before commencing the build` → Set to `board/board_qemu_a/hooks/pre_build.sh`
- `System configuration` → `Custom scripts to run after the build is complete` → Set to `board/board_qemu_a/hooks/post_build.sh`
- `System configuration` → `Custom scripts to run before creating filesystem images` → Set to `board/board_qemu_a/hooks/pre_image.sh`
- `System configuration` → `Custom scripts to run inside the fakeroot environment` → Set to `board/board_qemu_a/hooks/fakeroot.sh`
- `System configuration` → `Custom scripts to run after creating filesystem images` → Set to `board/board_qemu_a/hooks/post_image.sh`

Or directly in `.config`:

```makefile
BR2_ROOTFS_PRE_BUILD_SCRIPT="board/board_qemu_a/hooks/pre_build.sh"
BR2_ROOTFS_POST_BUILD_SCRIPT="board/board_qemu_a/hooks/post_build.sh"
BR2_ROOTFS_PRE_IMAGE_SCRIPT="board/board_qemu_a/hooks/pre_image.sh"
BR2_ROOTFS_FAKEROOT_SCRIPT="board/board_qemu_a/hooks/fakeroot.sh"
BR2_ROOTFS_POST_IMAGE_SCRIPT="board/board_qemu_a/hooks/post_image.sh"
```
