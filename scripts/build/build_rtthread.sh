#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量
QEMU_VEXPRESS_A9_DIR="$RTTHREAD_DIR/bsp/qemu-vexpress-a9"

# 检查 RT-Thread 源码目录是否存在
if [ ! -d "$RTTHREAD_DIR" ]; then
    echo "错误: RT-Thread 源码目录不存在: $RTTHREAD_DIR"
    echo "请下载 RT-Thread 源码: ./scripts/download.sh rt-thread"
    exit 1
fi

# 创建输出目录
mkdir -p "$RTT_OUT_DIR"

echo "开始编译 RT-Thread..."

# 进入 bsp/qemu-vexpress-a9 目录
cd "$QEMU_VEXPRESS_A9_DIR"

# 通过 scons 执行配置
scons --defconfig

# 清除编译产物
scons -c

# 编译 RT-Thread
scons -j$(nproc)

# 检查编译结果
if [ $? -eq 0 ]; then
    echo "RT-Thread 编译成功！"

    # 输出编译产物到 out 目录
    cp -rf "$QEMU_VEXPRESS_A9_DIR/build" "$RTT_OUT_DIR"
    cp -v "$QEMU_VEXPRESS_A9_DIR"/rtthread.* "$RTT_OUT_DIR" 2>/dev/null || true

    echo "编译产物已输出到: $RTT_OUT_DIR"
else
    echo "RT-Thread 编译失败！"
    exit 1
fi
