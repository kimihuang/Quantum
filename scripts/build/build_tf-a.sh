#!/bin/bash

ROOT_DIR=$(pwd)
ROOT_OUT_DIR="$ROOT_DIR/out"
TFA_OUT_DIR="$ROOT_OUT_DIR/tf-a_out"
TFA_SRC_DIR="$ROOT_DIR/src/tf-a"
MBEDTLS_DIR="$ROOT_DIR/src/mbedtls"

# 编译mbedtls
cd $MBEDTLS_DIR
make -j$(nproc)

cd $TFA_SRC_DIR
make distclean
# 编译TF-A
make -C $TFA_SRC_DIR \
    PLAT=qemu \
    ARCH=aarch64 \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CFLAGS='-O0 -g' \
    BL33=$ROOT_OUT_DIR/uboot_out/u-boot.bin \
    TRUSTED_BOARD_BOOT=0 \
    GENERATE_COT=0 \
    DEBUG=1 \
    all fip