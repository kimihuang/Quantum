#!/bin/bash

ROOT_DIR=$(pwd)
ROOT_OUT_DIR="$ROOT_DIR/out"
KERNEL_OUT_DIR="$ROOT_OUT_DIR/kernel_out"
KERNEL_SRC_DIR="$ROOT_DIR/src/kernel"
ROOTFS_DIR="$ROOT_DIR/tools/rootfs_busybox"

qemu-system-aarch64 \
    -M virt \
    -cpu cortex-a57 \
    -smp 4 \
    -m 1024 \
    -nographic \
    -kernel $KERNEL_SRC_DIR/arch/arm64/boot/Image \
    -append "console=ttyAMA0 root=/dev/vda rw nokaslr" \
    -drive if=none,file=$ROOTFS_DIR/rootfs.img,format=raw,id=hd \
    -device virtio-blk-device,drive=hd \
    -s \
    -S 

# 下面这个qemu 配置启动kernel也可以调试kernel，并进行源码调试， 主要添加的配置是nokaslr
#qemu-system-aarch64 \
#-machine virt,virtualization=true,gic-version=3 \
#    -nographic \
#    -m size=2048M \
#    -cpu cortex-a53 \
#    -smp 2 \
#    -kernel $KERNEL_SRC_DIR/arch/arm64/boot/Image \
#    -drive format=raw,file=$ROOTFS_DIR/rootfs.img \
#    -s \
#    -append "root=/dev/vda rw nokaslr" \
#    -S