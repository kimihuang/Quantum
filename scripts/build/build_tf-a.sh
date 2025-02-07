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
    CFLAGS='-O1 -g' \
    ARM_ROTPK_LOCATION=devel_rsa \
    GENERATE_COT=1 \
    MBEDTLS_DIR=$MBEDTLS_DIR \
    BL33=$ROOT_OUT_DIR/uboot_out/u-boot.bin \
    TRUSTED_BOARD_BOOT=1 \
    DEBUG=1 \
    all fip