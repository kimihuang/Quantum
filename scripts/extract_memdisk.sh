#!/bin/bash
#
# Extract memdisk.img to a directory
#

#set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 默认 memdisk.img 路径
BOARD_NAME="${BOARD_NAME:-board_qemu_a}"
DEFAULT_MEMDISK_IMG="out/${BOARD_NAME}/images/memdisk.img"

################################################################################
# memdisk_extract 函数
# 用法: memdisk_extract <memdisk.img> [output_dir]
################################################################################
memdisk_extract() {
    local MEMDISK_IMG="${1:-}"
    local OUTPUT_DIR="${2:-}"

    # 使用默认路径
    if [ -z "$MEMDISK_IMG" ]; then
        MEMDISK_IMG="$DEFAULT_MEMDISK_IMG"
        echo "Using default memdisk.img: $MEMDISK_IMG"
    fi

    # 检查文件是否存在
    if [ ! -f "$MEMDISK_IMG" ]; then
        echo "Error: memdisk.img not found: $MEMDISK_IMG"
        return 1
    fi

    # 使用默认输出目录（当前目录下的 memdisk 目录）
    if [ -z "$OUTPUT_DIR" ]; then
        OUTPUT_DIR="$(pwd)/memdisk"
    fi

    # 创建输出目录
    mkdir -p "$OUTPUT_DIR"

    echo "======================================"
    echo "Extracting memdisk.img..."
    echo "======================================"
    echo "Source: $MEMDISK_IMG"
    echo "Output: $OUTPUT_DIR"
    echo ""

    # 使用 debugfs 提取
    if command -v debugfs &> /dev/null; then
        echo "Using debugfs to extract..."
        debugfs -R "rdump / $OUTPUT_DIR" "$MEMDISK_IMG"
        echo "Extraction completed!"
    else
        echo "Error: debugfs command not found."
        echo "Please install: sudo apt-get install e2fsprogs"
        return 1
    fi

    echo ""
    echo "======================================"
    echo "Extraction summary:"
    echo "======================================"
    echo "Output directory: $OUTPUT_DIR"
    du -sh "$OUTPUT_DIR"
    echo ""
    echo "Contents:"
    ls -lah "$OUTPUT_DIR"

    return 0
}

# 导出函数供其他脚本使用
export -f memdisk_extract

# 如果直接运行脚本（而不是被 source）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # 显示帮助
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "Usage: $0 [memdisk.img] [output_dir]"
        echo ""
        echo "Extract memdisk.img to a directory"
        echo ""
        echo "Arguments:"
        echo "  memdisk.img   Path to memdisk.img file (default: $DEFAULT_MEMDISK_IMG)"
        echo "  output_dir   Directory to extract to (default: ./memdisk)"
        echo ""
        echo "Examples:"
        echo "  $0"
        echo "  BOARD_NAME=board_qemu_a $0 out/\${BOARD_NAME}/images/memdisk.img"
        echo "  $0 out/\${BOARD_NAME}/images/memdisk.img /tmp/my_memdisk"
        echo ""
        echo "Or source this script and use the function:"
        echo "  source scripts/extract_memdisk.sh"
        echo "  memdisk_extract out/\${BOARD_NAME}/images/memdisk.img"
        exit 0
    fi

    # 调用函数
    memdisk_extract "$@"
fi
