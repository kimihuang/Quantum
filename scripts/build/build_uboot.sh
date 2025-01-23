#!/bin/bash

# 编译 U-Boot 的脚本

# 设置 U-Boot 源码路径
UBOOT_SRC_DIR="./src/uboot"

# 进入 U-Boot 源码目录
cd $UBOOT_SRC_DIR || { echo "U-Boot 源码目录不存在"; exit 1; }

# 清理之前的构建产物
make clean

# 配置编译环境
make CROSS_COMPILE=aarch64-linux-gnu- qemu_arm64_defconfig

# 配置编译选项
make CROSS_COMPILE=aarch64-linux-gnu-

# 检查编译是否成功
if [ $? -eq 0 ]; then
    echo "U-Boot 编译成功"
else
    echo "U-Boot 编译失败"
    exit 1
fi

# 将编译产物移动到输出目录
mv u-boot.bin ../../out/ || { echo "移动编译产物失败"; exit 1; }