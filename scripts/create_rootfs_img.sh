#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量

echo "=========================================="
echo "制作 Rootfs 镜像"
echo "=========================================="
echo ""

# 检查 rootfs 目录是否存在
if [ ! -d "$ROOTFS_OUT_DIR/rootfs" ]; then
    echo "错误: Rootfs 目录不存在: $ROOTFS_OUT_DIR/rootfs"
    echo "请先运行: ./scripts/build/build_rootfs.sh"
    exit 1
fi

echo "配置信息:"
echo "  Rootfs 目录: $ROOTFS_OUT_DIR/rootfs"
echo "  输出镜像: $ROOTFS_OUT_DIR/rootfs.img"
echo ""

# 进入输出目录
cd "$ROOTFS_OUT_DIR"

# 创建 ext4 镜像 (256MB)
if [ -f "rootfs.img" ]; then
    echo "删除旧的 rootfs.img"
    rm -f rootfs.img
fi

echo "[1/3] 创建 256MB 镜像文件..."
dd if=/dev/zero of=rootfs.img bs=1M count=256 2>/dev/null

echo "[2/3] 格式化为 ext4 文件系统..."
mkfs.ext4 -F rootfs.img >/dev/null 2>&1

echo "[3/3] 写入 rootfs 内容到镜像..."

# 使用 fuse-ext2 (如果可用) 或 debugfs
MOUNT_SUCCESS=0

# 尝试方法1: loop 挂载
mkdir -p /tmp/rootfs_mnt
if mount -o loop rootfs.img /tmp/rootfs_mnt 2>/dev/null; then
    cp -r rootfs/* /tmp/rootfs_mnt/
    umount /tmp/rootfs_mnt
    MOUNT_SUCCESS=1
    echo "使用 loop 挂载成功"
fi

# 方法2: 使用 e2image 工具直接写入
if [ "$MOUNT_SUCCESS" = "0" ]; then
    echo "loop 挂载失败，尝试使用 e2tools..."

    # 检查是否有 e2tools
    if command -v e2cp &> /dev/null; then
        # 使用 e2tools 直接复制文件到 ext4 镜像
        echo "使用 e2tools 写入文件..."
        for file in $(cd rootfs && find . -type f); do
            dir=$(dirname "$file")
            # 创建目录
            if [ ! -d "/tmp/e2tmp/$dir" ]; then
                mkdir -p "/tmp/e2tmp/$dir"
            fi
            cp "rootfs/$file" "/tmp/e2tmp/$file"
        done

        # 批量复制
        cd /tmp/e2tmp
        find . -type d -exec e2mkdir -P rootfs.img {} \; 2>/dev/null || true
        find . -type f -exec e2cp {} rootfs.img:/{} \; 2>/dev/null || true
        cd -
        rm -rf /tmp/e2tmp

        # 验证是否成功
        if debugfs -R "ls /" rootfs.img 2>/dev/null | grep -q "etc"; then
            MOUNT_SUCCESS=1
            echo "使用 e2tools 写入成功"
        fi
    fi
fi


# 方法3: 降级为 cpio.gz 格式 (用于 initramfs)
if [ "$MOUNT_SUCCESS" = "0" ]; then
    echo "警告: 无法创建 ext4 镜像，降级为 cpio.gz 格式..."
    echo "注意: cpio.gz 格式适用于 initramfs，不支持持久化存储"

    cd rootfs
    find . | cpio -o -H newc 2>/dev/null | gzip -9 > ../rootfs.img
    cd -
fi

rm -rf /tmp/rootfs_mnt

# 获取镜像大小
IMG_SIZE=$(du -h rootfs.img | cut -f1)

echo ""
echo "=========================================="
echo "Rootfs 镜像制作成功!"
echo "=========================================="
echo "输出文件: $ROOTFS_OUT_DIR/rootfs.img"
echo "镜像大小: $IMG_SIZE"
if [ "$MOUNT_SUCCESS" = "0" ]; then
    echo "镜像格式: cpio.gz (initramfs)"
    echo "注意: 需要修改内核启动参数为 initrd=rootfs.img"
fi
echo ""
echo "使用方法:"
echo "  1. 确保 Linux 内核已编译"
echo "  2. 运行: ./scripts/qemu/qemu_kernel.sh"
echo ""
