#!/bin/bash
#
# Custom scripts to run before creating filesystem images
# Buildroot BR2_ROOTFS_PRE_IMAGE_SCRIPT hook
#
# Environment variables available:
# - BR2_CONFIG: Path to the .config file
# - HOST_DIR: Path to host directory
# - STAGING_DIR: Path to staging directory
# - TARGET_DIR: Path to target directory
# - BUILD_DIR: Path to build directory
# - BINARIES_DIR: Path to images directory
#
# Board environment variables (from board conf):
# - BOARD_NAME: Board name (e.g., board_qemu_a)
# - BOARD_DIR: Board configuration directory
# - PROJECT_ROOT: Project root directory
# - HOOKS_DIR: Hook scripts directory
#

#set -e

echo "======================================"
echo "Running pre-image hook..."
echo "======================================"

echo "BOARD_DIR: $BOARD_DIR"
echo "PROJECT_ROOT: $PROJECT_ROOT"
echo "TARGET_DIR: ${TARGET_DIR:-not set}"
echo "BINARIES_DIR: ${BINARIES_DIR:-not set}"

# 这里可以添加镜像创建前的逻辑
# 例如：准备镜像资源、检查依赖文件等

echo "======================================"
echo "Pre-image hook completed"
echo "======================================"
