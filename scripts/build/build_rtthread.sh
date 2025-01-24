#!/bin/bash

RTTHREAD_SRC_DIR="./src/rt-thread"

# 进入 RT-Thread 源码目录
cd $RTTHREAD_SRC_DIR

# 编译 RT-Thread
echo "开始编译 RT-Thread..."

# 进入 bsp/qemu-vexpress-a9目录
cd bsp/qemu-vexpress-a9

# 通过scons执行配置
# scons --menuconfig
scons --defconfig

# 清除编译产物
scons -c

# 编译 RT-Thread
scons -j2

# 检查编译结果
if [ $? -eq 0 ]; then
    echo "RT-Thread 编译成功！"
else
    echo "RT-Thread 编译失败！"
    exit 1
fi

# 输出编译产物到 out 目录
cp -r build/* ../../out/

echo "RT-Thread 编译产物已输出到 out 目录。"