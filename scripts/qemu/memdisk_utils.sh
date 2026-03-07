#!/bin/bash
#
# memdisk 工具脚本 - QEMU 系统内部版本
# 在 QEMU 运行的 Linux 系统中使用
#

MEMDISK_PHY_ADDR=0x78000000
MEMDISK_SIZE=$((256 * 1024 * 1024))  # 256MB
MEMDISK_BLOCK_SIZE=512
MEMDISK_SECTORS=$((MEMDISK_SIZE / MEMDISK_BLOCK_SIZE))

# 显示帮助信息
show_help() {
    cat << EOF
memdisk 系统内部工具

用法: $0 <command> [options]

命令:
  setup               - 设置 memdisk（创建设备节点）
  mount <path>        - 挂载 memdisk 到指定路径
  umount              - 卸载 memdisk
  copy-in <file>      - 拷贝文件到 memdisk
  copy-out <file>     - 从 memdisk 拷贝文件到主机
  format <fstype>     - 格式化 memdisk (ext4/vfat)
  status              - 显示 memdisk 状态
  help                - 显示此帮助信息

内存信息:
  物理地址: 0x$MEMDISK_PHY_ADDR
  大小: $((MEMDISK_SIZE / 1024 / 1024))MB
  扇区数: $MEMDISK_SECTORS

示例:
  # 设置并挂载 memdisk
  $0 setup
  $0 mount /mnt/memdisk

  # 格式化为 ext4
  $0 format ext4

  # 拷贝文件
  $0 copy-in /tmp/data.bin
  dd if=/dev/mem of=/dev/memdisk bs=1M

  # 卸载
  $0 umount

EOF
}

# 检查权限
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "错误: 此脚本需要 root 权限"
        echo "请使用: sudo $0 $*"
        exit 1
    fi
}

# 设置 memdisk
setup_memdisk() {
    check_root

    echo "设置 memdisk..."
    echo "物理地址: 0x$MEMDISK_PHY_ADDR"
    echo "大小: $((MEMDISK_SIZE / 1024 / 1024))MB"

    # 检查 /dev/mem 是否可用
    if [ ! -c /dev/mem ]; then
        echo "错误: /dev/mem 不可用"
        echo "请确保内核配置了 CONFIG_DEVMEM"
        exit 1
    }

    # 创建字符设备节点（如果不存在）
    if [ ! -c /dev/memdisk ]; then
        echo "创建 /dev/memdisk 字符设备..."
        mknod /dev/memdisk c 1 1 2>/dev/null || true
    fi

    # 方法 1: 使用 memmap 内核模块（推荐）
    if modinfo memmap &>/dev/null; then
        echo "使用 memmap 内核模块..."
        # 卸载旧模块
        rmmod memmap 2>/dev/null || true
        # 加载模块，映射内存区域
        modprobe memmap memmap=256M\$0x78000000
        echo "memmap 模块已加载"

        # 查找创建的设备
        if [ -e /dev/memblock0 ]; then
            echo "设备已创建: /dev/memblock0"
            ln -sf /dev/memblock0 /dev/memdisk_block
        fi
    fi

    # 方法 2: 使用 loop 设备
    echo "创建 loop 设备映射..."

    # 先卸载所有相关设备
    losetup -D 2>/dev/null || true

    # 方法 3: 直接使用 /dev/mem 访问（需要 CONFIG_STRICT_DEVMEM 关闭）
    # 注意: 这需要修改内核启动参数

    echo ""
    echo "memdisk 设置完成"
    echo ""
    echo "可用设备:"
    [ -c /dev/memdisk_block ] && echo "  - /dev/memdisk_block (memmap)"
    [ -c /dev/mem ] && echo "  - /dev/mem (直接内存访问)"
    echo ""
    echo "下一步: $0 mount /mnt/memdisk"
}

# 挂载 memdisk
mount_memdisk() {
    check_root

    local mount_path=${1:-/mnt/memdisk}

    echo "挂载 memdisk 到 $mount_path..."

    # 创建挂载点
    mkdir -p "$mount_path"

    # 尝试不同的设备
    local device=""
    if [ -b /dev/memdisk_block ]; then
        device=/dev/memdisk_block
    elif [ -b /dev/memblock0 ]; then
        device=/dev/memblock0
    else
        echo "错误: 找不到 memdisk 块设备"
        echo "请先运行: $0 setup"
        exit 1
    fi

    echo "使用设备: $device"

    # 尝试挂载
    if mount -t ext4 "$device" "$mount_path" 2>/dev/null; then
        echo "memdisk 已挂载 (ext4)"
    elif mount -t vfat "$device" "$mount_path" 2>/dev/null; then
        echo "memdisk 已挂载 (vfat)"
    else
        echo "错误: 挂载失败，设备可能未格式化"
        echo "尝试格式化: $0 format ext4"
        exit 1
    fi

    echo ""
    echo "挂载成功!"
    echo "路径: $mount_path"
    echo "内容:"
    ls -la "$mount_path"
}

# 卸载 memdisk
umount_memdisk() {
    check_root

    local mount_path=${1:-/mnt/memdisk}

    echo "卸载 memdisk..."

    if mountpoint -q "$mount_path"; then
        umount "$mount_path"
        echo "已卸载: $mount_path"
    else
        echo "警告: $mount_path 未挂载"
    fi
}

# 格式化 memdisk
format_memdisk() {
    check_root

    local fstype=${1:-ext4}

    echo "格式化 memdisk ($fstype)..."

    # 查找设备
    local device=""
    if [ -b /dev/memdisk_block ]; then
        device=/dev/memdisk_block
    elif [ -b /dev/memblock0 ]; then
        device=/dev/memblock0
    else
        echo "错误: 找不到 memdisk 块设备"
        exit 1
    fi

    echo "格式化设备: $device"

    case "$fstype" in
        ext4)
            mkfs.ext4 -F "$device"
            ;;
        vfat)
            mkfs.vfat -F 32 "$device"
            ;;
        *)
            echo "错误: 不支持的文件系统类型: $fstype"
            exit 1
            ;;
    esac

    echo "格式化完成"
}

# 拷贝文件到 memdisk
copy_in_memdisk() {
    check_root

    local file=$1

    if [ -z "$file" ]; then
        echo "错误: 请指定文件"
        exit 1
    fi

    if [ ! -f "$file" ]; then
        echo "错误: 文件不存在: $file"
        exit 1
    fi

    local file_size=$(stat -c%s "$file")

    echo "拷贝文件到 memdisk..."
    echo "文件: $file"
    echo "大小: $file_size bytes"

    # 检查挂载点
    local mount_path="/mnt/memdisk"
    if ! mountpoint -q "$mount_path"; then
        echo "错误: memdisk 未挂载"
        echo "请先运行: $0 mount"
        exit 1
    fi

    # 拷贝文件
    cp "$file" "$mount_path/"
    echo "拷贝完成: $mount_path/$(basename "$file")"
}

# 从 memdisk 拷贝文件
copy_out_memdisk() {
    check_root

    local dest=$1

    if [ -z "$dest" ]; then
        echo "错误: 请指定目标文件"
        exit 1
    fi

    echo "从 memdisk 导出数据..."

    # 检查挂载点
    local mount_path="/mnt/memdisk"
    if ! mountpoint -q "$mount_path"; then
        echo "错误: memdisk 未挂载"
        echo "请先运行: $0 mount"
        exit 1
    fi

    # 创建目标目录
    mkdir -p "$(dirname "$dest")"

    # 拷贝所有内容
    cp -r "$mount_path"/* "$(dirname "$dest")/"

    echo "导出完成: $dest"
}

# 显示状态
show_status() {
    echo "memdisk 状态:"
    echo ""
    echo "物理地址: 0x$MEMDISK_PHY_ADDR"
    echo "大小: $((MEMDISK_SIZE / 1024 / 1024))MB"
    echo ""
    echo "预留内存:"
    dmesg | grep -i "reserved" | grep "0x78000000" || echo "  (未找到)"
    echo ""
    echo "设备:"
    [ -b /dev/memdisk_block ] && echo "  /dev/memdisk_block: 存在"
    [ -b /dev/memblock0 ] && echo "  /dev/memblock0: 存在"
    [ -c /dev/mem ] && echo "  /dev/mem: 存在"
    echo ""
    echo "挂载状态:"
    mount | grep -i memdisk || echo "  未挂载"
    echo ""
    echo "内核模块:"
    lsmod | grep memmap || echo "  memmap: 未加载"
}

# 主函数
case "$1" in
    setup)
        setup_memdisk
        ;;
    mount)
        mount_memdisk "$2"
        ;;
    umount)
        umount_memdisk "$2"
        ;;
    format)
        format_memdisk "$2"
        ;;
    copy-in)
        copy_in_memdisk "$2"
        ;;
    copy-out)
        copy_out_memdisk "$2"
        ;;
    status)
        show_status
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo "错误: 未知命令: $1"
        show_help
        exit 1
        ;;
esac
