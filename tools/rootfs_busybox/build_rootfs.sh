#!/bin/bash

# 1. 下载并解压busybox
wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2
tar xf busybox-1.36.1.tar.bz2
cd busybox-1.36.1

# 2. 配置和编译busybox
make CROSS_COMPILE=aarch64-linux-gnu- defconfig
# 修改配置为静态编译
sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
make CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
make CROSS_COMPILE=aarch64-linux-gnu- install

# 3. 创建rootfs目录结构
mkdir -p rootfs
cd rootfs
mkdir -p bin sbin etc proc sys usr/bin usr/sbin root tmp var
cp -a ../busybox-1.36.1/_install/* .

# 4. 创建基本配置文件
cat > etc/inittab << EOF
::sysinit:/etc/init.d/rcS
::askfirst:-/bin/sh
::ctrlaltdel:/sbin/reboot
::shutdown:/sbin/swapoff -a
::shutdown:/bin/umount -a -r
::restart:/sbin/init
EOF

# 创建初始化脚本
mkdir -p etc/init.d
cat > etc/init.d/rcS << EOF
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t debugfs none /sys/kernel/debug
/sbin/mdev -s
EOF
chmod +x etc/init.d/rcS

# 5. 创建设备文件
mkdir -p dev
sudo mknod dev/console c 5 1
sudo mknod dev/null c 1 3
sudo mknod dev/tty1 c 4 1

# 6. 制作rootfs镜像
dd if=/dev/zero of=rootfs.img bs=1M count=100
mkfs.ext4 rootfs.img
mkdir -p /tmp/mnt
sudo mount rootfs.img /tmp/mnt
sudo cp -r * /tmp/mnt/
sudo umount /tmp/mnt
