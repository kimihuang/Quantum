#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量
# 检查源码目录是否存在
if [ ! -d "$TFA_DIR" ]; then
    echo "错误: TF-A 源码目录不存在: $TFA_DIR"
    echo "请下载 TF-A 源码: ./scripts/download.sh tfa"
    exit 1
fi

if [ ! -d "$MBEDTLS_DIR" ]; then
    echo "错误: MbedTLS 源码目录不存在: $MBEDTLS_DIR"
    echo "请下载 MbedTLS 源码: ./scripts/download.sh mbedtls"
    exit 1
fi

# 创建输出目录
mkdir -p "$TFA_OUT_DIR"

echo "开始编译 TF-A..."

# 编译 mbedtls
cd "$MBEDTLS_DIR"
make -j$(nproc)
if [ $? -ne 0 ]; then
    echo "MbedTLS 编译失败"
    exit 1
fi

# 编译 TF-A
cd "$TFA_DIR"
make distclean

make -C "$TFA_DIR" \
    PLAT=qemu \
    ARCH=aarch64 \
    CROSS_COMPILE="$CROSS_COMPILE" \
    CFLAGS='-O0 -g' \
    BL33="$OUT_DIR/uboot_out/u-boot.bin" \
    TRUSTED_BOARD_BOOT=0 \
    GENERATE_COT=0 \
    DEBUG=1 \
    all fip

if [ $? -eq 0 ]; then
    echo "TF-A 编译成功！"
else
    echo "TF-A 编译失败！"
    exit 1
fi
