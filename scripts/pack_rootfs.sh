#!/bin/bash
# 将 rootfs 目录打包为 cpio.gz 镜像

set -e

# 使用说明
if [ $# -lt 1 ]; then
    echo "用法: $0 <rootfs_dir> [output_file.gz] [compression_level]"
    echo ""
    echo "参数:"
    echo "  rootfs_dir        - rootfs 目录路径"
    echo "  output_file.gz    - (可选) 输出的 cpio.gz 镜像文件名"
    echo "                      如果不指定，则使用 rootfs_dir + .img.gz"
    echo "  compression_level - (可选) 压缩级别 (1-9, 默认 9)"
    echo "                      1 = 最快, 9 = 最小体积"
    echo ""
    echo "示例:"
    echo "  $0 rootfs"
    echo "  $0 rootfs rootfs_compressed.img.gz"
    echo "  $0 rootfs rootfs.img.gz 6"
    echo ""
    echo "说明:"
    echo "  此脚本将 rootfs 目录打包为 initramfs 格式的 cpio 归档，"
    echo "  然后使用 gzip 压缩生成最终镜像文件。"
    exit 1
fi

ROOTFS_DIR="$1"
OUTPUT_FILE="$2"
COMPRESSION_LEVEL="${3:-9}"

# 检查输入目录是否存在
if [ ! -d "$ROOTFS_DIR" ]; then
    echo "错误: rootfs 目录不存在: $ROOTFS_DIR"
    exit 1
fi

# 检查目录中是否有内容
if [ -z "$(ls -A $ROOTFS_DIR)" ]; then
    echo "错误: rootfs 目录为空: $ROOTFS_DIR"
    exit 1
fi

# 检查压缩级别是否有效
if ! [[ "$COMPRESSION_LEVEL" =~ ^[1-9]$ ]]; then
    echo "错误: 压缩级别必须是 1-9 之间的数字"
    exit 1
fi

# 生成输出文件名
if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="${ROOTFS_DIR}.img.gz"
fi

# 保存绝对路径
# 获取脚本所在目录的父目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 如果 OUTPUT_FILE 是相对路径，则相对于当前工作目录
if [[ "$OUTPUT_FILE" != /* ]]; then
    OUTPUT_ABS_FILE="$(pwd)/$OUTPUT_FILE"
else
    OUTPUT_ABS_FILE="$OUTPUT_FILE"
fi

# 获取输出文件的目录和文件名
OUTPUT_DIR_PATH="$(dirname "$OUTPUT_ABS_FILE")"
OUTPUT_FILENAME="$(basename "$OUTPUT_ABS_FILE")"

# 检查输出文件是否已存在
if [ -f "$OUTPUT_FILE" ]; then
    echo "警告: 输出文件已存在: $OUTPUT_FILE"
    read -p "是否覆盖？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消操作"
        exit 0
    fi
fi

# 获取目录大小
DIR_SIZE=$(du -sh "$ROOTFS_DIR" | cut -f1)
FILE_COUNT=$(find "$ROOTFS_DIR" -type f | wc -l)

echo "=========================================="
echo "打包 rootfs 目录为 cpio.gz 镜像"
echo "=========================================="
echo "rootfs 目录: $ROOTFS_DIR ($DIR_SIZE)"
echo "文件数量: $FILE_COUNT"
echo "输出文件: $OUTPUT_FILE"
echo "压缩级别: $COMPRESSION_LEVEL"
echo ""

# 打包并压缩
echo "正在打包 cpio 归档..."
echo "正在压缩 (级别 $COMPRESSION_LEVEL)..."

# 保存当前工作目录
ORIGINAL_PWD="$(pwd)"

# 进入 rootfs 目录
cd "$ROOTFS_DIR"
if find . | cpio -o -H newc 2>/dev/null | gzip -$COMPRESSION_LEVEL > "$OUTPUT_ABS_FILE" 2>/dev/null; then
    cd "$ORIGINAL_PWD" > /dev/null
    OUTPUT_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    DIR_BYTES=$(du -sb "$ROOTFS_DIR" | cut -f1)
    OUTPUT_BYTES=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE")
    SAVED_BYTES=$((DIR_BYTES - OUTPUT_BYTES))
    SAVED_PERCENT=$(echo "scale=1; 100 * $SAVED_BYTES / $DIR_BYTES" | bc 2>/dev/null || echo "0")

    echo ""
    echo "=========================================="
    echo "打包成功!"
    echo "=========================================="
    echo "输出文件: $OUTPUT_FILE"
    echo "文件大小: $OUTPUT_SIZE"
    echo "节省空间: $SAVED_PERCENT%"
    echo ""
    echo "使用方法:"
    echo "  QEMU: qemu-system-aarch64 ... -initrd $OUTPUT_FILE"
    echo ""
else
    cd "$ORIGINAL_PWD" > /dev/null
    echo "错误: 打包或压缩失败"
    rm -f "$OUTPUT_FILE"
    exit 1
fi
