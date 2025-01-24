#!/bin/bash

ROOT_DIR=$(pwd)
ROOT_OUT_DIR="$ROOT_DIR/out"
UBOOT_OUT_DIR="$ROOT_OUT_DIR/uboot_out"
UBOOT_SRC_DIR="$ROOT_DIR/src/u-boot"

qemu-system-aarch64 \
    -M virt \
    -cpu cortex-a57 \
    -m 1024 \
    -nographic \
    -bios $UBOOT_SRC_DIR/u-boot.bin \
    -s 
    #-S 
