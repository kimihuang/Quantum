#!/bin/bash
#
# Custom scripts to run inside the fakeroot environment
# Buildroot BR2_ROOTFS_FAKEROOT_SCRIPT hook
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
echo "Running fakeroot hook..."
echo "======================================"


echo "BOARD_DIR: $BOARD_DIR"
echo "PROJECT_ROOT: $PROJECT_ROOT"
echo "TARGET_DIR: ${TARGET_DIR:-not set}"
echo "BINARIES_DIR: ${BINARIES_DIR:-not set}"

# 这里可以添加 fakeroot 环境下的逻辑
# 例如：创建需要 root 权限的设备节点、设置文件所有权等

echo "======================================"
echo "Fakeroot hook completed"
echo "======================================"
