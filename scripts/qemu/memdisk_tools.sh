#!/bin/bash
#
# memdisk 工具脚本
# 用于在 QEMU 系统中拷贝 memdisk 到预留内存或从内存导出
#

# memdisk 在内存中的物理地址
MEMDISK_PHY_ADDR=0x78000000
MEMDISK_SIZE=268435456  # 256MB in bytes

# 主机端 memdisk.img 路径
PROJECT_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
HOST_MEMDISK="$PROJECT_ROOT/out/images/memdisk.img"

# 显示帮助信息
show_help() {
    echo "memdisk 工具脚本"
    echo ""
    echo "用法: $0 <command> [options]"
    echo ""
    echo "命令:"
    echo "  create              - 创建 memdisk.img 镜像"
    echo "  copy-to-mem <file>  - 拷贝文件到 QEMU 系统中的内存区域"
    echo "  copy-from-mem       - 从 QEMU 系统中的内存区域导出到文件"
    echo "  mount <offset>      - 挂载 memdisk 到指定偏移位置"
    echo "  umount <offset>     - 卸载 memdisk"
    echo "  help                - 显示此帮助信息"
    echo ""
    echo "内存地址: 0x$MEMDISK_PHY_ADDR ($((MEMDISK_SIZE / 1024 / 1024))MB)"
    echo "主机镜像: $HOST_MEMDISK"
    echo ""
    echo "示例:"
    echo "  # 创建 memdisk 镜像"
    echo "  $0 create"
    echo ""
    echo "  # 在 QEMU 中，通过 QEMU monitor 拷贝文件到内存"
    echo "  1. 启动 QEMU: boot monitor"
    echo "  2. 在另一个终端: $0 copy-to-mem /path/to/file"
    echo ""
    echo "  # 在 QEMU 系统中，将 memdisk 挂载到 /dev/memdisk"
    echo "  # 查看预留内存地址:"
    echo "  dmesg | grep -i reserved"
    echo ""
    echo "  # 使用 memmap 挂载内存区域"
    echo "  insmod drivers/misc/memmap.ko memmap=256M\$0x78000000"
    echo "  mount -t ext4 /dev/memblock0 /mnt/memdisk"
}

# 创建 memdisk 镜像
create_memdisk() {
    echo "创建 memdisk 镜像..."
    bash "$PROJECT_ROOT/scripts/create_memdisk.sh"
}

# 拷贝文件到 QEMU 内存（通过 QEMU monitor）
copy_to_mem() {
    local file=$1

    if [ -z "$file" ]; then
        echo "错误: 请指定要拷贝的文件"
        echo "用法: $0 copy-to-mem <file>"
        exit 1
    fi

    if [ ! -f "$file" ]; then
        echo "错误: 文件不存在: $file"
        exit 1
    fi

    echo "拷贝文件到 QEMU 内存..."
    echo "文件: $file"
    echo "目标地址: 0x$MEMDISK_PHY_ADDR"

    # 检查 QEMU monitor socket 是否存在
    local board_name=${BOARD_NAME:-board_qemu_a}
    local monitor_socket="$PROJECT_ROOT/out/$board_name/qemu-monitor.sock"

    if [ ! -S "$monitor_socket" ]; then
        echo "错误: QEMU monitor socket 不存在"
        echo "请先启动 QEMU: boot monitor"
        exit 1
    fi

    echo "正在通过 QEMU monitor 拷贝文件..."
    echo "注意: 此操作需要文件大小不超过预留内存区域"

    # 计算文件大小
    local file_size=$(stat -c%s "$file")
    echo "文件大小: $file_size bytes"

    if [ $file_size -gt $MEMDISK_SIZE ]; then
        echo "错误: 文件大小超过预留内存区域 ($MEMDISK_SIZE bytes)"
        exit 1
    fi

    # 使用 dd 和 socat 通过 QEMU monitor 写入内存
    # 注意: QEMU monitor 不直接支持文件写入到物理内存
    # 这里提供思路，实际实现需要使用其他方法
    echo ""
    echo "QEMU monitor 不直接支持文件写入物理内存"
    echo "请使用以下方法之一:"
    echo ""
    echo "方法 1: 在 QEMU 启动时使用 -initrd 加载 memdisk"
    echo "方法 2: 在 QEMU 系统中使用 wget/ssh 等工具获取文件"
    echo "方法 3: 使用 virtio 设备传递数据"
    echo ""
    echo "推荐的在 QEMU 系统中的操作:"
    echo "  # 将预留内存区域映射为字符设备"
    echo "  insmod drivers/char/mem.ko"
    echo ""
    echo "  # 使用 dd 拷贝数据"
    echo "  dd if=/path/to/file of=/dev/mem bs=1k seek=\$((0x78000000 / 1024))"
}

# 从 QEMU 内存导出（通过 QEMU monitor）
copy_from_mem() {
    echo "从 QEMU 内存导出数据..."
    echo "源地址: 0x$MEMDISK_PHY_ADDR"
    echo "输出文件: $HOST_MEMDISK"

    # 检查 QEMU monitor socket 是否存在
    local board_name=${BOARD_NAME:-board_qemu_a}
    local monitor_socket="$PROJECT_ROOT/out/$board_name/qemu-monitor.sock"

    if [ ! -S "$monitor_socket" ]; then
        echo "错误: QEMU monitor socket 不存在"
        echo "请先启动 QEMU: boot monitor"
        exit 1
    fi

    echo "正在通过 QEMU monitor 读取内存..."
    echo "输出文件: $HOST_MEMDISK"

    # 使用 QEMU monitor 的 pmemsave 命令
    # pmemsave <addr> <size> <filename>
    echo "执行命令: pmemsave $MEMDISK_PHY_ADDR $MEMDISK_SIZE $HOST_MEMDISK"

    # 连接到 QEMU monitor 并执行命令
    (
        echo "pmemsave $MEMDISK_PHY_ADDR $MEMDISK_SIZE $HOST_MEMDISK"
        echo "quit"
    ) | socat - UNIX-CONNECT:"$monitor_socket"

    if [ $? -eq 0 ]; then
        echo ""
        echo "导出成功!"
        echo "文件: $HOST_MEMDISK"
        ls -lh "$HOST_MEMDISK"
    else
        echo "导出失败!"
        exit 1
    fi
}

# 主函数
case "$1" in
    create)
        create_memdisk
        ;;
    copy-to-mem)
        copy_to_mem "$2"
        ;;
    copy-from-mem)
        copy_from_mem
        ;;
    mount)
        echo "挂载 memdisk 功能需要在 QEMU 系统内部执行"
        echo ""
        echo "在 QEMU 系统中执行:"
        echo "  # 方法 1: 使用 memmap 内核模块"
        echo "  insmod drivers/misc/memmap.ko memmap=256M\$0x78000000"
        echo "  mount -t ext4 /dev/memblock0 /mnt/memdisk"
        echo ""
        echo "  # 方法 2: 使用 /dev/mem 直接访问 (不推荐)"
        echo "  # 需要 CONFIG_DEVMEM 和 CONFIG_STRICT_DEVMEM 配置"
        ;;
    umount)
        echo "卸载 memdisk 功能需要在 QEMU 系统内部执行"
        echo ""
        echo "在 QEMU 系统中执行:"
        echo "  umount /mnt/memdisk"
        echo "  rmmod memmap"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac
