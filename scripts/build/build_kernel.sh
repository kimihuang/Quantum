#!/bin/bash

# 设置 Kernel 构建相关路径
ROOT_DIR=$(pwd)
ROOT_OUT_DIR="$ROOT_DIR/out"
KERNEL_OUT_DIR="$ROOT_OUT_DIR/kernel_out"
KERNEL_SRC_DIR="$ROOT_DIR/src/kernel"


# 判断 kernel out 目录是否存在，不存在则创建
if [ ! -d "$KERNEL_OUT_DIR" ]; then
    echo "kernel out directory not found, creating $KERNEL_OUT_DIR"
    mkdir -p "$KERNEL_OUT_DIR"
fi

# 判断 kernel 源码目录是否存在，不存在则输出调试信息后退出
if [ ! -d "$KERNEL_SRC_DIR" ] && [ ! -L "$KERNEL_SRC_DIR" ]; then
    # 创建软链接到 linux 源码目录
    echo "kernel source directory is not a symlink, creating soft link to $KERNEL_SRC_DIR"
    ln -s /home/lighthouse/sourcecode/linux-master $KERNEL_SRC_DIR
fi

# 进入内核源码目录
cd $KERNEL_SRC_DIR

# 清理编译产物
#make ARCH=arm64 mrproper
make  ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- mrproper

# 配置内核以适配 QEMU
make  ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig

# 执行编译命令
make  ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)


echo "内核编译完成，产物已输出到 $KERNEL_OUT_DIR"