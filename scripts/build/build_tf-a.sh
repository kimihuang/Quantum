#!/bin/bash

# 编译TF-A的脚本

# 设置TF-A源代码路径
TF_A_SRC_DIR="../src/tf-a"

# 输出目录
OUTPUT_DIR="../../out"

# 创建输出目录（如果不存在）
mkdir -p $OUTPUT_DIR

# 进入TF-A源代码目录
cd $TF_A_SRC_DIR

# 执行编译命令
make clean
make

# 将编译产物复制到输出目录
cp build/* $OUTPUT_DIR/

echo "TF-A编译完成，产物已输出到 $OUTPUT_DIR"