#!/bin/bash
#
# 创建 memdisk.img 镜像文件
# 用于在 QEMU 启动后拷贝到预留的内存区域
#

set -e

# 镜像大小：256MB
MEMDISK_SIZE=256M

# 输出路径
PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUTPUT_DIR="$PROJECT_ROOT/out/images"
MEMDISK_IMG="$OUTPUT_DIR/memdisk.img"

echo "======================================"
echo "创建 memdisk.img 镜像..."
echo "======================================"
echo "大小: $MEMDISK_SIZE"
echo "输出: $MEMDISK_IMG"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 创建 256MB 的空镜像文件
echo "创建空镜像文件..."
dd if=/dev/zero of="$MEMDISK_IMG" bs=1M count=256 status=none

# 格式化为 ext4 文件系统
echo "格式化为 ext4 文件系统..."
mkfs.ext4 -F "$MEMDISK_IMG" > /dev/null 2>&1

# 创建临时挂载点
TEMP_MOUNT=$(mktemp -d)

echo "挂载镜像并创建目录结构..."
sudo mount -o loop "$MEMDISK_IMG" "$TEMP_MOUNT"

# 创建基本目录结构
sudo mkdir -p "$TEMP_MOUNT/data"
sudo mkdir -p "$TEMP_MOUNT/logs"
sudo mkdir -p "$TEMP_MOUNT/backup"

# 创建测试文件
echo "This is a test file in memdisk" | sudo tee "$TEMP_MOUNT/test.txt" > /dev/null
echo "Memdisk created at: $(date)" | sudo tee "$TEMP_DISK/info.txt" > /dev/null

# 设置权限
sudo chmod 755 "$TEMP_MOUNT/data"
sudo chmod 755 "$TEMP_MOUNT/logs"
sudo chmod 755 "$TEMP_MOUNT/backup"

# 卸载
sudo umount "$TEMP_MOUNT"
rmdir "$TEMP_MOUNT"

# 获取文件大小
FILE_SIZE=$(du -h "$MEMDISK_IMG" | cut -f1)

echo "======================================"
echo "memdisk.img 创建完成!"
echo "======================================"
echo "路径: $MEMDISK_IMG"
echo "大小: $FILE_SIZE"
echo "格式: ext4"
echo ""
echo "目录结构:"
echo "  /data      - 数据目录"
echo "  /logs      - 日志目录"
echo "  /backup    - 备份目录"
echo "  /test.txt  - 测试文件"
echo "======================================"

# 显示镜像信息
echo ""
echo "镜像信息:"
file "$MEMDISK_IMG"
