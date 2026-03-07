#!/bin/bash
#
# Custom scripts to run after creating filesystem images
# Buildroot BR2_ROOTFS_POST_IMAGE_SCRIPT hook
#
# Environment variables available:
# - BR2_CONFIG: Path to the .config file
# - HOST_DIR: Path to host directory
# - STAGING_DIR: Path to staging directory
# - TARGET_DIR: Path to target directory
# - BUILD_DIR: Path to build directory
# - BINARIES_DIR: Path to images directory
# - IMAGES: List of generated images (optional, depends on context)
#

#set -e

echo "======================================"
echo "Running post-image hook..."
echo "======================================"

# 获取 board 配置目录
BOARD_DIR="$(dirname "$(readlink -f "$0")")"
PROJECT_ROOT="$(readlink -f "$BOARD_DIR/../..")"

echo "BOARD_DIR: $BOARD_DIR"
echo "PROJECT_ROOT: $PROJECT_ROOT"
echo "TARGET_DIR: ${TARGET_DIR:-not set}"
echo "BINARIES_DIR: ${BINARIES_DIR:-not set}"

# 这里可以添加镜像创建后的逻辑
# 例如：打包镜像、生成校验和、复制到输出目录等

echo "======================================"
echo "Post-image hook completed"
echo "======================================"
