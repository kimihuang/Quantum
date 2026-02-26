#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量

# 检查是否已选择板卡配置
if [ -z "$BOARD_NAME" ]; then
    echo "警告: 未选择板卡配置，请先运行 lunch 命令"
    echo "使用默认 QEMU 参数..."
    QEMU_MACHINE=virt
    QEMU_CPU=cortex-a57
    QEMU_MEM=1024
fi

# 使用环境变量
UBOOT_BIN="$UBOOT_DIR/u-boot.bin"

# 检查 U-Boot 镜像是否存在
if [ ! -f "$UBOOT_BIN" ]; then
    echo "错误: U-Boot 镜像不存在: $UBOOT_BIN"
    echo "请先编译 U-Boot: ./scripts/build/build_uboot.sh"
    exit 1
fi

echo "启动 QEMU 运行 U-Boot..."
echo "板卡: ${BOARD_NAME:-board_default}"
echo "U-Boot: $UBOOT_BIN"
echo "QEMU 参数:"
echo "  - 机器: $QEMU_MACHINE"
echo "  - CPU: $QEMU_CPU"
echo "  - 内存: ${QEMU_MEM}M"
echo ""

qemu-system-aarch64 \
    -M "$QEMU_MACHINE" \
    -cpu "$QEMU_CPU" \
    -m "$QEMU_MEM" \
    -nographic \
    -bios "$UBOOT_BIN" \
    -s \
    -S
