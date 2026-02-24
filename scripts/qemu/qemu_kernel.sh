#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量
KERNEL_IMAGE="$LINUX_DIR/arch/arm64/boot/Image"

# 检查 Linux 内核镜像是否存在
if [ ! -f "$KERNEL_IMAGE" ]; then
    echo "错误: Linux 内核镜像不存在: $KERNEL_IMAGE"
    echo "请先编译 Linux 内核: ./scripts/build/build_kernel.sh"
    exit 1
fi

# 检查根文件系统是否存在
if [ ! -f "$ROOTFS_DIR/rootfs.img" ]; then
    echo "警告: 根文件系统镜像不存在: $ROOTFS_DIR/rootfs.img"
    echo "请先构建根文件系统: $ROOTFS_DIR/build_rootfs.sh"
    exit 1
fi

echo "启动 QEMU 运行 Linux 内核..."
echo "内核镜像: $KERNEL_IMAGE"
echo "根文件系统: $ROOTFS_DIR/rootfs.img"
echo ""

qemu-system-aarch64 \
    -M virt \
    -cpu cortex-a57 \
    -smp 4 \
    -m 1024 \
    -nographic \
    -kernel "$KERNEL_IMAGE" \
    -append "console=ttyAMA0 root=/dev/vda rw nokaslr earlycon=pl011,0x9000000 debug loglevel=8" \
    -drive if=none,file="$ROOTFS_DIR/rootfs.img",format=raw,id=hd \
    -device virtio-blk-device,drive=hd \
    -s \
    -S

# 备用 QEMU 配置：启动 kernel 并支持源码调试（nokaslr）
# qemu-system-aarch64 \
#     -machine virt,virtualization=true,gic-version=3 \
#     -nographic \
#     -m size=2048M \
#     -cpu cortex-a53 \
#     -smp 2 \
#     -kernel "$KERNEL_IMAGE" \
#     -drive format=raw,file="$ROOTFS_DIR/rootfs.img" \
#     -s \
#     -append "root=/dev/vda rw nokaslr" \
#     -S