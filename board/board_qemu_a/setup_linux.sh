#!/bin/bash
#
# Quantum QEMU 预构建脚本
# 在 lunch 时执行，用于准备构建环境
#


echo "======================================"
echo "执行预构建脚本..."
echo "======================================"

# 检查必要的环境变量
if [ -z "$PROJECT_ROOT" ]; then
    echo "错误: PROJECT_ROOT 未设置"
    exit 1
fi

if [ -z "$LINUX_ARCH_ARM64" ]; then
    echo "错误: LINUX_ARCH_ARM64 未设置"
    exit 1
fi

if [ -z "$LINUX_LOCAL_DIR" ]; then
    echo "错误: LINUX_LOCAL_DIR 未设置"
    exit 1
fi

# 检查源目录是否存在
if [ ! -d "$LINUX_ARCH_ARM64" ]; then
    echo "错误: ARM64 架构源码目录不存在: $LINUX_ARCH_ARM64"
    exit 1
fi

# 复制 ARM64 架构源码到本地目录
echo "复制 ARM64 架构源码..."
echo "  源: $LINUX_ARCH_ARM64"
echo "  目标: $LINUX_LOCAL_DIR"

cp -r "$LINUX_ARCH_ARM64" "$LINUX_LOCAL_DIR"

# 复制驱动模块到 Linux 源码 drivers 目录
if [ -d "$PROJECT_ROOT/src/modules" ]; then
    echo "======================================"
    echo "复制驱动模块到 Linux 源码..."
    echo "======================================"

    LINUX_DRIVERS_DIR="$LINUX_LOCAL_DIR/drivers"


    # 直接复制 modules 目录
    echo "复制目录: $PROJECT_ROOT/src/modules -> $LINUX_DRIVERS_DIR"
    cp -r "$PROJECT_ROOT/src/modules" "$LINUX_DRIVERS_DIR"

    # 更新 drivers/Kconfig，添加 modules 的引用
    KCONFIG_FILE="$LINUX_DRIVERS_DIR/Kconfig"
    if ! grep -q "source \"drivers/modules/Kconfig\"" "$KCONFIG_FILE"; then
        echo "更新 drivers/Kconfig 添加 modules 引用"
        # 在 menu "Device Drivers" 之后插入 source 行，方便在图形界面快速找到
        sed -i '/^menu "Device Drivers"$/a source "drivers/modules/Kconfig"' "$KCONFIG_FILE"
    fi

    # 更新 drivers/Makefile，添加 modules 的引用
    MAKEFILE_FILE="$LINUX_DRIVERS_DIR/Makefile"
    if ! grep -q "obj-y.*+= modules/" "$MAKEFILE_FILE"; then
        echo "更新 drivers/Makefile 添加 modules 引用"
        # 在适当位置添加 obj-y 行（使用实际 tab 字符）
        printf "obj-y\t\t+= modules/\n" >> "$MAKEFILE_FILE"
    fi

    echo "======================================"
    echo "驱动模块复制完成"
    echo "======================================"
else
    echo "警告: 驱动模块目录不存在: $PROJECT_ROOT/src/modules"
fi


echo "======================================"
echo "预构建脚本执行完成"
echo "======================================"
