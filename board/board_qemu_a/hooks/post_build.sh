#!/bin/bash
#
# Custom scripts to run after the build is complete
# Buildroot BR2_ROOTFS_POST_BUILD_SCRIPT hook
#
# Environment variables available:
# - BR2_CONFIG: Path to the .config file
# - HOST_DIR: Path to host directory
# - STAGING_DIR: Path to staging directory
# - TARGET_DIR: Path to target directory (completed, but before images)
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
echo "Running post-build hook..."
echo "======================================"


echo "BOARD_DIR: $BOARD_DIR"
echo "PROJECT_ROOT: $PROJECT_ROOT"
echo "TARGET_DIR: ${TARGET_DIR:-not set}"
echo "BINARIES_DIR: ${BINARIES_DIR:-not set}"

# 这里可以添加后构建逻辑
# 例如：修改 target 目录内容、添加配置文件、调整权限等

echo "======================================"
echo "Post-build hook completed"
echo "======================================"
