#!/bin/bash
#
# Custom scripts to run before commencing the build
# Buildroot BR2_ROOTFS_PRE_BUILD_SCRIPT hook
#
# Environment variables available:
# - BR2_CONFIG: Path to the .config file
# - HOST_DIR: Path to host directory
# - STAGING_DIR: Path to staging directory
# - TARGET_DIR: Path to target directory
# - BUILD_DIR: Path to build directory
# - BINARIES_DIR: Path to images directory
#

#set -e

echo "======================================"
echo "Running pre-build hook..."
echo "======================================"


echo "BOARD_DIR: $BOARD_DIR"
echo "PROJECT_ROOT: $PROJECT_ROOT"
echo "BR2_CONFIG: ${BR2_CONFIG:-not set}"
echo "BUILD_DIR: ${BUILD_DIR:-not set}"
echo "TARGET_DIR: ${TARGET_DIR:-not set}"

# 创建 memdisk staging directory，供其他 package 拷贝文件
if [ -n "$BUILD_DIR" ]; then
    echo "======================================"
    echo "Creating memdisk staging directory..."
    echo "======================================"
    MEMDISK_STAGING_DIR="$BUILD_DIR/memdisk-staging"

    # 如果目录已存在则跳过创建
    if [ -d "$MEMDISK_STAGING_DIR" ]; then
        echo "Memdisk staging directory already exists: $MEMDISK_STAGING_DIR"
    else
        mkdir -p "$MEMDISK_STAGING_DIR"
        mkdir -p "$MEMDISK_STAGING_DIR/data"
        mkdir -p "$MEMDISK_STAGING_DIR/logs"
        echo "Memdisk staging directory created at: $MEMDISK_STAGING_DIR"

        # 创建 info 文件
        echo "Memdisk staging directory created at: $(date)" > "$MEMDISK_STAGING_DIR/info.txt"
        echo "Buildroot build directory: $BUILD_DIR" >> "$MEMDISK_STAGING_DIR/info.txt"
    fi
fi

echo "======================================"
echo "Pre-build hook completed"
echo "======================================"
