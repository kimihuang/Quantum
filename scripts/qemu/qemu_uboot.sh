#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量
UBOOT_BIN="$UBOOT_DIR/u-boot.bin"

# 检查 U-Boot 镜像是否存在
if [ ! -f "$UBOOT_BIN" ]; then
    echo "错误: U-Boot 镜像不存在: $UBOOT_BIN"
    echo "请先编译 U-Boot: ./scripts/build/build_uboot.sh"
    exit 1
fi

echo "启动 QEMU 运行 U-Boot..."
echo "U-Boot: $UBOOT_BIN"
echo ""

qemu-system-aarch64 \
    -M virt \
    -cpu cortex-a57 \
    -m 1024 \
    -nographic \
    -bios "$UBOOT_BIN" \
    -s \
    -S
