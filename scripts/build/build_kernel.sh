#!/bin/bash

# 编译内核的脚本

# 设置工作目录
KERNEL_SRC_DIR="../src/kernel"
BUILD_DIR="../../build"
OUTPUT_DIR="../../out"

# 创建输出目录
mkdir -p $OUTPUT_DIR

# 进入内核源代码目录
cd $KERNEL_SRC_DIR

# 执行编译命令
make -j$(nproc) O=$BUILD_DIR

# 将编译产物复制到输出目录
cp $BUILD_DIR/* $OUTPUT_DIR/

echo "内核编译完成，产物已输出到 $OUTPUT_DIR"