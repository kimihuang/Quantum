#!/bin/bash

# 设置 U-Boot 构建相关路径
ROOT_DIR=$(pwd)
ROOT_OUT_DIR="$ROOT_DIR/out"
UBOOT_OUT_DIR="$ROOT_OUT_DIR/uboot_out"
UBOOT_SRC_DIR="$ROOT_DIR/src/u-boot"


# 判断 U-Boot 源码目录是否存在
if [ ! -d "$UBOOT_SRC_DIR" ]; then
    echo "U-Boot 源码目录不存在，请下载 U-Boot 源码 \
        请参考：./scripts/download.sh"
    exit 1
fi

# 判断 U-Boot 输出目录是否存在，如果不存在则创建
if [ ! -d "$UBOOT_OUT_DIR" ]; then
    mkdir -p "$UBOOT_OUT_DIR"
    if [ $? -ne 0 ]; then
        echo "创建 U-Boot 输出目录失败"
        exit 1
    fi
fi

# 进入 U-Boot 源码目录
cd $UBOOT_SRC_DIR

# 清理之前的构建产物
make clean

# 配置qemu编译环境
make CROSS_COMPILE=aarch64-linux-gnu- qemu_arm64_defconfig

# 配置编译选项
make CROSS_COMPILE=aarch64-linux-gnu-  KCFLAGS="-g"

# 检查编译是否成功
if [ $? -eq 0 ]; then
    echo "U-Boot 编译成功"
else
    echo "U-Boot 编译失败"
    exit 1
fi

# 将编译产物移动到输出目录
cp $UBOOT_SRC_DIR/u-boot $UBOOT_OUT_DIR
cp $UBOOT_SRC_DIR/u-boot.* $UBOOT_OUT_DIR|| { echo "移动编译产物失败"; exit 1; }