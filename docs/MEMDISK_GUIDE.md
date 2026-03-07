# Memdisk 使用指南

## 概述

memdisk 是一个预留的 256MB 内存区域，可以在 QEMU 中作为临时存储使用。它位于物理地址 `0x78000000`，可以在主机和 QEMU 系统之间传递数据。

## 架构

```
+-------------------+-------------------+
|  物理内存布局     |  说明             |
+-------------------+-------------------+
| 0x40000000        |  系统内存 (1GB)   |
| 0x78000000        |  Memdisk (256MB)  |
| 0x88000000        |  保留区域         |
+-------------------+-------------------+
```

## 使用步骤

### 1. 修改设备树（已完成）

设备树已预留 256MB 内存区域：

```dts
reserved-memory {
    memdisk_reserved: memdisk@78000000 {
        compatible = "shared-dma-pool";
        reg = <0x00 0x78000000 0x00 0x10000000>; /* 256MB */
        no-map;
    };
};
```

### 2. 创建 memdisk.img 镜像

在主机上运行：

```bash
# 确保已选择板卡
source build/envsetup.sh
lunch board_qemu_a

# 创建镜像
./scripts/create_memdisk.sh
```

或者使用工具脚本：

```bash
./scripts/qemu/memdisk_tools.sh create
```

这会创建一个 256MB 的 ext4 格式镜像文件：`out/images/memdisk.img`

### 3. 编译内核

确保内核配置了以下选项：

```bash
# Device Drivers
#   -> Character devices
#       -> /dev/mem virtual device support (CONFIG_DEVMEM=y)
#   -> Misc devices
#       -> BIOS memory driver (CONFIG_MEM_MAP=y)
```

编译内核：

```bash
make
```

### 4. 启动 QEMU

```bash
source build/envsetup.sh
lunch board_qemu_a
boot
```

### 5. 在 QEMU 系统中使用 memdisk

将 `memdisk_utils.sh` 拷贝到 QEMU 系统中，或直接在 QEMU shell 中执行：

```bash
# 设置 memdisk
sudo /path/to/memdisk_utils.sh setup

# 挂载 memdisk
sudo /path/to/memdisk_utils.sh mount /mnt/memdisk

# 查看内容
ls -la /mnt/memdisk

# 拷贝文件到 memdisk
sudo /path/to/memdisk_utils.sh copy-in /tmp/data.bin

# 从 memdisk 拷贝文件
sudo /path/to/memdisk_utils.sh copy-out /tmp/exported_data

# 卸载
sudo /path/to/memdisk_utils.sh umount
```

## 从主机拷贝数据到 memdisk

### 方法 1: 使用 QEMU Monitor（推荐）

```bash
# 启动 QEMU 时启用 monitor
boot monitor

# 在主机另一个终端
./scripts/qemu/memdisk_tools.sh copy-from-mem
```

这会将 QEMU 内存中的 memdisk 导出到 `out/images/memdisk.img`

### 方法 2: 使用 virtio 设备

在 QEMU 启动参数中添加 virtio 设备，然后在系统中使用网络或串口传输数据。

### 方法 3: 使用共享文件系统

Buildroot 配置支持 NFS 或 9pfs 共享目录，可以直接读写。

## 从 memdisk 拷贝数据到主机

```bash
# 确保在 QEMU 中有数据写入 memdisk

# 在主机终端执行
./scripts/qemu/memdisk_tools.sh copy-from-mem

# 导出的文件保存在
ls -lh out/images/memdisk.img

# 可以挂载查看
sudo mount -o loop out/images/memdisk.img /mnt/memdisk_export
ls -la /mnt/memdisk_export
sudo umount /mnt/memdisk_export
```

## 高级用法

### 直接内存访问（需要 root）

```bash
# 在 QEMU 系统中
sudo dd if=/dev/zero of=/dev/mem bs=1M seek=$((0x78000000/1024/1024)) count=256
```

### 使用 memmap 内核模块

```bash
# 加载模块，映射内存为块设备
sudo modprobe memmap memmap=256M\$0x78000000

# 设备会出现在 /dev/memblock0
sudo mkfs.ext4 /dev/memblock0
sudo mount /dev/memblock0 /mnt/memdisk
```

### 格式化 memdisk

```bash
# 格式化为 ext4
sudo /path/to/memdisk_utils.sh format ext4

# 格式化为 vfat
sudo /path/to/memdisk_utils.sh format vfat
```

## 故障排查

### 问题 1: /dev/mem 不可用

**解决方案**: 检查内核配置

```bash
# 检查配置
grep CONFIG_DEVMEM /boot/config-$(uname -r)

# 应该显示
CONFIG_DEVMEM=y
```

### 问题 2: memmap 模块找不到

**解决方案**: 编译内核模块

```bash
# 在内核源码目录
make drivers/misc/memmap.ko
sudo insmod drivers/misc/memmap.ko memmap=256M\$0x78000000
```

### 问题 3: 内存访问被拒绝

**解决方案**: 关闭 STRICT_DEVMEM

在内核启动参数中添加：

```
iomem=relaxed
```

或者在内核配置中关闭 `CONFIG_STRICT_DEVMEM`

### 问题 4: 预留内存不可见

**解决方案**: 检查设备树

```bash
# 查看预留内存
dmesg | grep -i reserved
dmesg | grep 0x78000000
```

## 性能优化

### 使用大块大小

```bash
# 使用 1MB 块大小以提高性能
dd if=file of=/dev/mem bs=1M
```

### 使用异步 I/O

```bash
# 使用 async-dd 或类似工具
```

## 安全注意事项

1. 直接内存访问需要 root 权限
2. 错误的内存操作可能导致系统崩溃
3. 预留内存会被内核标记为 no-map，不会被分配给其他进程
4. 建议使用 memmap 内核模块而非直接访问 /dev/mem

## 参考文档

- Linux 内核文档: Documentation/driver-api/memmap_dev.rst
- QEMU Monitor 命令: `help pmemsave`, `help pmemload`
- Device Tree 文档: Documentation/devicetree/bindings/reserved-memory/
