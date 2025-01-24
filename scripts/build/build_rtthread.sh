#!/bin/bash

ROOT_DIR=$(pwd)
ROOT_OUT_DIR="$ROOT_DIR/out"
RTT_OUT_DIR="$ROOT_OUT_DIR/rtt_out"
RTTHREAD_SRC_DIR="$ROOT_DIR/src/rt-thread"
QEMU_VEXPRESS_A9_DIR="$RTTHREAD_SRC_DIR/bsp/qemu-vexpress-a9"


# 判断 RTTHREAD_SRC_DIR 是否存在
if [ ! -d "$RTTHREAD_SRC_DIR" ]; then
    echo "RT-Thread 源码目录不存在，请先执行下载 RT-Thread 源码。\
        请参考：./scripts/build/download.sh"
    exit 1
fi

# 判断 ROOT_DIR 是否存在 out/rtt_out 目录，如果没有则创建
if [ ! -d "$RTT_OUT_DIR" ]; then
    mkdir -p "$RTT_OUT_DIR"
fi

# 进入 bsp/qemu-vexpress-a9目录
cd $QEMU_VEXPRESS_A9_DIR

# 编译 RT-Thread
echo "开始编译 RT-Thread qemu_vexpress ..."

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
cp -rf $QEMU_VEXPRESS_A9_DIR/build $RTT_OUT_DIR
cp -v $QEMU_VEXPRESS_A9_DIR/rtthread.* $RTT_OUT_DIR

echo "RT-Thread 编译产物已输出到 $RTT_OUT_DIR 目录。"