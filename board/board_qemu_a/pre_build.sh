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

echo "======================================"
echo "预构建脚本执行完成"
echo "======================================"
