#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量

# 检查是否已选择板卡配置
if [ -z "$BOARD_NAME" ]; then
    echo "警告: 未选择板卡配置，请先运行 lunch 命令"
    echo "使用默认 QEMU 参数..."
    QEMU_MACHINE=virt
    QEMU_CPU=cortex-a57
    QEMU_SMP=4
    QEMU_MEM=1024
    KERNEL_CMDLINE="console=ttyAMA0 root=/dev/vda rw nokaslr earlycon=pl011,0x9000000 debug loglevel=8"
fi

# 使用环境变量（内核镜像在输出目录）
KERNEL_IMAGE="$KERNEL_OUT_DIR/arch/$KERNEL_ARCH/boot/Image"

# 检查 Linux 内核镜像是否存在
if [ ! -f "$KERNEL_IMAGE" ]; then
    echo "错误: Linux 内核镜像不存在: $KERNEL_IMAGE"
    echo "请先编译 Linux 内核: ./scripts/build/build_kernel.sh"
    exit 1
fi

# 检查根文件系统是否存在
if [ ! -f "$ROOTFS_OUT_DIR/rootfs.img" ]; then
    echo "警告: 根文件系统镜像不存在: $ROOTFS_OUT_DIR/rootfs.img"
    echo "请先构建根文件系统: ./scripts/build/build_rootfs.sh"
    exit 1
fi

# 检测 rootfs 格式
ROOTFS_FILE="$ROOTFS_OUT_DIR/rootfs.img"
if file "$ROOTFS_FILE" | grep -q "gzip compressed"; then
    echo "$ROOTFS_FILE 文件为gzip格式，使用 initramfs 启动内核... "
    ROOTFS_FORMAT="initramfs"
    INITRD_PARAM="-initrd $ROOTFS_FILE"
    ROOTFS_PARAM=
    # initramfs 模式：内核会自动解压 cpio.gz 到 rootfs，不需要指定 root 设备
    # 注意：使用 -initrd 参数时，内核将其识别为 initrd，需要 root=/dev/ram0
    # 但通过 CONFIG_BLK_DEV_INITRD 和 CONFIG_RD_GZIP 支持，内核会自动处理 cpio.gz
    if [[ "$KERNEL_CMDLINE" != *root=* ]]; then
        KERNEL_CMDLINE="$KERNEL_CMDLINE root=/dev/ram0"
    fi
    # 确保 init 参数正确
    if [[ "$KERNEL_CMDLINE" != *init=* ]]; then
        KERNEL_CMDLINE="$KERNEL_CMDLINE init=/linuxrc"
    fi
else
    ROOTFS_FORMAT="disk"
    INITRD_PARAM=
    ROOTFS_PARAM="-drive if=none,file=$ROOTFS_FILE,format=raw,id=hd -device virtio-blk-device,drive=hd"
fi

echo "启动 QEMU 运行 Linux 内核..."
echo "板卡: ${BOARD_NAME:-board_default}"
echo "内核镜像: $KERNEL_IMAGE"
echo "根文件系统: $ROOTFS_FILE"
echo "Rootfs 格式: $ROOTFS_FORMAT"
echo "QEMU 参数:"
echo "  - 机器: $QEMU_MACHINE"
echo "  - CPU: $QEMU_CPU"
echo "  - SMP: $QEMU_SMP"
echo "  - 内存: ${QEMU_MEM}M"
echo "  - 内核参数: $KERNEL_CMDLINE"
echo "  - 根文件系统参数: $ROOTFS_PARAM"
echo "  - initrd 参数: $INITRD_PARAM"
echo ""


qemu-system-aarch64 \
    -M "$QEMU_MACHINE" \
    -cpu "$QEMU_CPU" \
    -smp "$QEMU_SMP" \
    -m "$QEMU_MEM" \
    -nographic \
    -kernel "$KERNEL_IMAGE" \
    -append "$KERNEL_CMDLINE" \
    -initrd "$ROOTFS_FILE" \
#    $ROOTFS_PARAM \
 #   -s \
#    -S
