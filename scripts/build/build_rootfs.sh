#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量

echo "=========================================="
echo "基于 Busybox 构建最小系统 Rootfs"
echo "=========================================="
echo ""

# 检查是否已选择板卡配置
if [ -z "$BOARD_NAME" ]; then
    echo "警告: 未选择板卡配置，请先运行 lunch 命令"
    echo "使用默认配置..."
    BOARD_NAME="board_default"
    KERNEL_ARCH=arm64
fi

# 检查交叉编译工具链
if [ -z "$CROSS_COMPILE" ]; then
    echo "错误: 未找到交叉编译工具链"
    echo "请先运行: source build/envsetup.sh"
    exit 1
fi

# 检查 busybox 源码是否存在
BUSYBOX_FILE="$SRC_DIR/busybox-${BUSYBOX_VERSION}.tar.bz2"
if [ ! -f "$BUSYBOX_FILE" ]; then
    echo "错误: Busybox 源码不存在: $BUSYBOX_FILE"
    echo "请先下载: ./scripts/download.sh busybox"
    exit 1
fi

# 解压源码（如果还未解压）
if [ ! -d "$BUSYBOX_DIR" ]; then
    echo "解压 Busybox 源码..."
    cd "$SRC_DIR"
    tar xf "$BUSYBOX_FILE"
    if [ $? -ne 0 ]; then
        echo "错误: 解压 Busybox 失败"
        exit 1
    fi
fi

echo "配置信息:"
echo "  板卡: $BOARD_NAME"
echo "  架构: $KERNEL_ARCH"
echo "  交叉编译: $CROSS_COMPILE"
echo "  Busybox 源码: $BUSYBOX_DIR"
echo "  Rootfs 输出: $ROOTFS_OUT_DIR/rootfs.img"
echo ""

# 1. 配置和编译 busybox
echo "[1/5] 配置和编译 Busybox..."
cd "$BUSYBOX_DIR"

# 使用默认配置
make ARCH="$KERNEL_ARCH" CROSS_COMPILE="$CROSS_COMPILE" defconfig

# 修改配置为静态编译
sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config

# 启用必要特性
sed -i 's/^# CONFIG_FEATURE_INITRD is not set/CONFIG_FEATURE_INITRD=y/' .config
sed -i 's/^# CONFIG_ASH is not set/CONFIG_ASH=y/' .config
sed -i 's/^# CONFIG_FEATURE_SH_STANDALONE is not set/CONFIG_FEATURE_SH_STANDALONE=y/' .config

echo "编译 Busybox (使用 $(nproc) 核)..."
make ARCH="$KERNEL_ARCH" CROSS_COMPILE="$CROSS_COMPILE" -j$(nproc)

if [ $? -ne 0 ]; then
    echo "错误: Busybox 编译失败"
    exit 1
fi

echo "安装 Busybox..."
make ARCH="$KERNEL_ARCH" CROSS_COMPILE="$CROSS_COMPILE" install

if [ $? -ne 0 ]; then
    echo "错误: Busybox 安装失败"
    exit 1
fi

# 2. 创建 rootfs 目录结构
echo "[2/5] 创建 Rootfs 目录结构..."
mkdir -p "$ROOTFS_OUT_DIR"
rm -rf "$ROOTFS_OUT_DIR/rootfs"
mkdir -p "$ROOTFS_OUT_DIR/rootfs"/{bin,sbin,etc,proc,sys,dev,usr/{bin,sbin},root,tmp,var,lib,mnt}

echo "复制 Busybox 安装文件..."
cp -a "$BUSYBOX_DIR/_install/"* "$ROOTFS_OUT_DIR/rootfs/"

# 删除 busybox 自动创建的 linuxrc 软链接，使用自定义脚本
rm -f "$ROOTFS_OUT_DIR/rootfs/linuxrc"

# 创建 linuxrc 启动脚本
cat > "$ROOTFS_OUT_DIR/rootfs/linuxrc" << 'EOF'
#!/bin/sh

echo "Starting initramfs..."

# 挂载虚拟文件系统
mount -t proc none /proc
mount -t sysfs none /sys
mount -t debugfs none /sys/kernel/debug
mount -t devtmpfs devtmpfs /dev

# 创建设备节点
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts

# 加载 mdev
/sbin/mdev -s

# 设置主机名
hostname qemu-aarch64

# 挂载 tmpfs
mkdir -p /tmp
mount -t tmpfs tmpfs /tmp

# 打印启动信息
echo ""
echo "=========================================="
echo "  Minimal Busybox Rootfs System"
echo "  Architecture: $(uname -m)"
echo "  Kernel: $(uname -r)"
echo "=========================================="
echo ""
echo "Welcome to Quantum Linux!"
echo "Type 'help' for available commands."
echo ""

# 启动 shell（保持 initramfs 运行）
echo "Dropping to shell..."
exec /bin/sh
EOF
chmod +x "$ROOTFS_OUT_DIR/rootfs/linuxrc"

# 3. 创建基本配置文件
echo "[3/5] 创建系统配置文件..."

# 创建 inittab
cat > "$ROOTFS_OUT_DIR/rootfs/etc/inittab" << 'EOF'
::sysinit:/etc/init.d/rcS
::askfirst:-/bin/sh
::ctrlaltdel:/sbin/reboot
::shutdown:/sbin/swapoff -a
::shutdown:/bin/umount -a -r
::restart:/sbin/init
EOF

# 创建初始化脚本
mkdir -p "$ROOTFS_OUT_DIR/rootfs/etc/init.d"
cat > "$ROOTFS_OUT_DIR/rootfs/etc/init.d/rcS" << 'EOF'
#!/bin/sh

# 挂载虚拟文件系统
mount -t proc none /proc
mount -t sysfs none /sys
mount -t debugfs none /sys/kernel/debug
mount -t devtmpfs devtmpfs /dev

# 创建设备节点
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts

# 加载 mdev
/sbin/mdev -s

# 设置主机名
hostname qemu-aarch64

# 挂载 tmpfs
mkdir -p /tmp
mount -t tmpfs tmpfs /tmp

# 打印启动信息
echo ""
echo "=========================================="
echo "  Minimal Busybox Rootfs System"
echo "  Architecture: $(uname -m)"
echo "  Kernel: $(uname -r)"
echo "=========================================="
echo ""
echo "Welcome to Quantum Linux!"
echo "Type 'help' for available commands."
echo ""
EOF
chmod +x "$ROOTFS_OUT_DIR/rootfs/etc/init.d/rcS"

# 创建 fstab
cat > "$ROOTFS_OUT_DIR/rootfs/etc/fstab" << 'EOF'
proc        /proc   proc    defaults        0   0
sysfs       /sys    sysfs   defaults        0   0
debugfs     /sys/kernel/debug  debugfs defaults        0   0
devtmpfs    /dev    devtmpfs defaults        0   0
tmpfs       /tmp    tmpfs   defaults        0   0
EOF

# 创建 profile
cat > "$ROOTFS_OUT_DIR/rootfs/etc/profile" << 'EOF'
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export HOME=/root
export TERM=linux
export PS1='[\u@\h \W]\$ '
alias ll='ls -la'
EOF

# 创建 hostname
echo "qemu-aarch64" > "$ROOTFS_OUT_DIR/rootfs/etc/hostname"

# 创建 passwd
cat > "$ROOTFS_OUT_DIR/rootfs/etc/passwd" << 'EOF'
root::0:0:root:/root:/bin/sh
daemon:x:1:1:daemon:/var:/bin/false
nobody:x:99:99:nobody:/var:/bin/false
EOF

# 创建 group
cat > "$ROOTFS_OUT_DIR/rootfs/etc/group" << 'EOF'
root:x:0:
daemon:x:1:
nogroup:x:99:
nobody:x:99:
EOF

# 创建 resolv.conf
cat > "$ROOTFS_OUT_DIR/rootfs/etc/resolv.conf" << 'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

# 4. 创建必要的设备文件
echo "[4/5] 创建设备节点..."
cd "$ROOTFS_OUT_DIR/rootfs/dev"

# 检查是否已有 devtmpfs，如果有则不需要手动创建
if [ ! -c console ]; then
    echo "创建基本设备节点..."
    mknod console c 5 1
    mknod null c 1 3
    mknod zero c 1 5
    mknod tty1 c 4 1
    mknod tty2 c 4 2
    mknod tty3 c 4 3
    mknod tty4 c 4 4
    mknod ttyAMA0 c 204 64
    mknod vda b 254 0
    mknod vda1 b 254 1
    mknod ram0 b 1 0
    chmod 666 console null zero
fi

# 5. 制作 rootfs 镜像
echo "[5/5] 制作 Rootfs 镜像..."
echo "请调用: ./scripts/create_rootfs_img.sh 制作rootfs.img"
echo ""

