#!/bin/bash
# 解压 cpio.gz 镜像到 rootfs 目录

set -e

# 使用说明
if [ $# -lt 1 ]; then
    echo "用法: $0 <rootfs.img.gz> [output_dir]"
    echo ""
    echo "参数:"
    echo "  rootfs.img.gz - cpio.gz 格式的 rootfs 镜像文件"
    echo "  output_dir    - (可选) 解压到的输出目录"
    echo "                  如果不指定，则使用 rootfs (不包含 .img.gz)"
    echo ""
    echo "示例:"
    echo "  $0 rootfs.img.gz"
    echo "  $0 rootfs.img.gz myrootfs"
    echo ""
    echo "说明:"
    echo "  此脚本将 cpio.gz 镜像文件解压到指定目录。"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_DIR="$2"

# 检查输入文件是否存在
if [ ! -f "$INPUT_FILE" ]; then
    echo "错误: 输入文件不存在: $INPUT_FILE"
    exit 1
fi

# 检查文件是否为 gzip 格式
if ! file "$INPUT_FILE" | grep -q "gzip compressed"; then
    echo "警告: 文件 $INPUT_FILE 不是 gzip 压缩格式"
    echo "尝试解压..."
fi

# 生成输出目录名
if [ -z "$OUTPUT_DIR" ]; then
    if [[ "$INPUT_FILE" == *.img.gz ]]; then
        OUTPUT_DIR="${INPUT_FILE%.img.gz}"
        OUTPUT_DIR="${OUTPUT_DIR##*/}"
    elif [[ "$INPUT_FILE" == *.gz ]]; then
        OUTPUT_DIR="${INPUT_FILE%.gz}"
        OUTPUT_DIR="${OUTPUT_DIR##*/}"
    else
        OUTPUT_DIR="rootfs"
    fi
fi

# 检查输出目录是否已存在
if [ -d "$OUTPUT_DIR" ]; then
    echo "警告: 输出目录已存在: $OUTPUT_DIR"
    echo "目录内容："
    ls -la "$OUTPUT_DIR" | head -10
    echo ""
    read -p "是否删除并重新解压？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "删除旧目录..."
        rm -rf "$OUTPUT_DIR"
    else
        echo "取消操作"
        exit 0
    fi
fi

# 获取原始文件大小
INPUT_SIZE=$(du -h "$INPUT_FILE" | cut -f1)

echo "=========================================="
echo "解压 cpio.gz 镜像到目录"
echo "=========================================="
echo "输入文件: $INPUT_FILE ($INPUT_SIZE)"
echo "输出目录: $OUTPUT_DIR"
echo ""

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 解压文件
echo "正在解压..."
cd "$OUTPUT_DIR"
if gzip -dc "../${INPUT_FILE##*/}" 2>/dev/null | cpio -idm 2>/dev/null; then
    cd - > /dev/null
    DIR_SIZE=$(du -sh "$OUTPUT_DIR" | cut -f1)
    FILE_COUNT=$(find "$OUTPUT_DIR" -type f | wc -l)

    echo ""
    echo "=========================================="
    echo "解压成功!"
    echo "=========================================="
    echo "输出目录: $OUTPUT_DIR"
    echo "目录大小: $DIR_SIZE"
    echo "文件数量: $FILE_COUNT"
    echo ""
    echo "目录结构（前 20 项）："
    ls -la "$OUTPUT_DIR" | head -20
    echo ""
else
    cd - > /dev/null
    echo "错误: 解压失败"
    rm -rf "$OUTPUT_DIR"
    exit 1
fi
