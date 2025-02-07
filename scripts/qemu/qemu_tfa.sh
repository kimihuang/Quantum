#!/bin/bash

ROOT_DIR=$(pwd)
ROOT_OUT_DIR="$ROOT_DIR/out"
TFA_OUT_DIR="$ROOT_OUT_DIR/tf-a_out"
TFA_SRC_DIR="$ROOT_DIR/src/tf-a"
TFA_RELEASE_DIR="$TFA_SRC_DIR/build/qemu/release"
TFA_DEBUG_DIR="$TFA_SRC_DIR/build/qemu/debug"

qemu-system-aarch64 \
    -M virt,secure=on \
    -cpu cortex-a57 \
    -smp 2 \
    -m 1024 \
    -bios $TFA_DEBUG_DIR/bl1.bin \
    -device loader,file=$TFA_DEBUG_DIR/fip.bin,addr=0x50000000 \
    -nographic \
    -s -S