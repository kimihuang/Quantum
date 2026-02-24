#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量

# 检查内核源码目录是否存在
if [ ! -d "$LINUX_DIR" ]; then
    echo "错误: Linux 内核源码目录不存在: $LINUX_DIR"
    echo "请下载 Linux 内核源码: ./scripts/download.sh kernel"
    exit 1
fi

# 创建输出目录
mkdir -p "$KERNEL_OUT_DIR"

echo "开始编译 Linux 内核..."

# 进入内核源码目录
cd "$LINUX_DIR"

# 清理编译产物
make ARCH=arm64 CROSS_COMPILE="$CROSS_COMPILE" mrproper

# 配置内核以适配 QEMU
make ARCH=arm64 CROSS_COMPILE="$CROSS_COMPILE" defconfig

# 执行编译命令
make ARCH=arm64 CROSS_COMPILE="$CROSS_COMPILE" -j$(nproc)

if [ $? -eq 0 ]; then
    echo "Linux 内核编译成功！"
    echo "编译产物已输出到: $KERNEL_OUT_DIR"
else
    echo "Linux 内核编译失败！"
    exit 1
fi
