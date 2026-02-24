#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量
TFA_DEBUG_DIR="$TFA_DIR/build/qemu/release"

# 检查 TF-A 镜像是否存在
if [ ! -f "$TFA_DEBUG_DIR/bl1.bin" ]; then
    echo "错误: TF-A 镜像不存在: $TFA_DEBUG_DIR/bl1.bin"
    echo "请先编译 TF-A: ./scripts/build/build_tf-a.sh"
    exit 1
fi

if [ ! -f "$TFA_DEBUG_DIR/fip.bin" ]; then
    echo "错误: TF-A FIP 镜像不存在: $TFA_DEBUG_DIR/fip.bin"
    echo "请先编译 TF-A: ./scripts/build/build_tf-a.sh"
    exit 1
fi

echo "启动 QEMU 运行 TF-A..."
echo "BL1: $TFA_DEBUG_DIR/bl1.bin"
echo "FIP: $TFA_DEBUG_DIR/fip.bin"
echo ""

qemu-system-aarch64 \
    -M virt,secure=on \
    -cpu cortex-a57 \
    -smp 2 \
    -m 1024 \
    -bios "$TFA_DEBUG_DIR/bl1.bin" \
    -device loader,file="$TFA_DEBUG_DIR/fip.bin",addr=0x44000000 \
    -nographic \
    -s -S