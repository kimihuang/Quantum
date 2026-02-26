#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量

# 检查是否已选择板卡配置
if [ -z "$BOARD_NAME" ]; then
    echo "警告: 未选择板卡配置，请先运行 lunch 命令"
    echo "使用默认 QEMU 参数..."
    QEMU_MACHINE=virt,secure=on
    QEMU_CPU=cortex-a57
    QEMU_SMP=2
    QEMU_MEM=1024
fi

# 使用环境变量
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
echo "板卡: ${BOARD_NAME:-board_default}"
echo "BL1: $TFA_DEBUG_DIR/bl1.bin"
echo "FIP: $TFA_DEBUG_DIR/fip.bin"
echo "QEMU 参数:"
echo "  - 机器: $QEMU_MACHINE"
echo "  - CPU: $QEMU_CPU"
echo "  - SMP: $QEMU_SMP"
echo "  - 内存: ${QEMU_MEM}M"
echo ""

qemu-system-aarch64 \
    -M "$QEMU_MACHINE" \
    -cpu "$QEMU_CPU" \
    -smp "$QEMU_SMP" \
    -m "$QEMU_MEM" \
    -bios "$TFA_DEBUG_DIR/bl1.bin" \
    -device loader,file="$TFA_DEBUG_DIR/fip.bin",addr=0x44000000 \
    -nographic \
    -s -S
