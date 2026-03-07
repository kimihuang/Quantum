#!/bin/bash

# 设置构建环境变量
export PROJECT_ROOT=$(pwd)
export BUILD_DIR="$PROJECT_ROOT/build"
export OUT_DIR="$PROJECT_ROOT/out"
export SRC_DIR="$PROJECT_ROOT/src"

# ARM 交叉编译工具链目录
export ARM_TOOLCHAIN_DIR="$PROJECT_ROOT/tools/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu"

# 编译工具链前缀
export CROSS_COMPILE="aarch64-none-linux-gnu-"

# 将 ARM 工具链添加到 PATH（优先使用本地工具链）
if [ -d "$ARM_TOOLCHAIN_DIR/bin" ]; then
    if [[ ":$PATH:" != *":$ARM_TOOLCHAIN_DIR/bin:"* ]]; then
        export PATH="$ARM_TOOLCHAIN_DIR/bin:$PATH"
    fi
    echo "已添加 ARM 工具链到 PATH: $ARM_TOOLCHAIN_DIR/bin"
else
    echo "警告: ARM 工具链目录不存在: $ARM_TOOLCHAIN_DIR/bin"
    echo "将使用系统默认的 aarch64-linux-gnu- 工具链"
    # 回退到系统默认工具链
    export CROSS_COMPILE="aarch64-linux-gnu-"
fi

# 源码目录
export BUILDROOT_DIR="$SRC_DIR/buildroot/buildroot-2025.02-rc1"
export LINUX_LOCAL_DIR="$SRC_DIR/linux-6.1"
export LINUX_ARCH_ARM64="$SRC_DIR/linux_arch_arm64/arch"
export TFA_DIR="$SRC_DIR/tf-a"
export UBOOT_DIR="$SRC_DIR/u-boot"
export RTTHREAD_DIR="$SRC_DIR/rt-thread"
export MBEDTLS_DIR="$SRC_DIR/mbedtls"
export BUSYBOX_VERSION="1.36.1"
export BUSYBOX_DIR="$SRC_DIR/busybox-$BUSYBOX_VERSION"
export UBOOT_SRC_DIR="$SRC_DIR/u-boot-2026.01-rc5"

# QEMU 运行脚本目录
export QEMU_SCRIPTS_DIR="$PROJECT_ROOT/scripts/qemu"

# 添加构建目录到 PATH（避免重复添加）
if [[ ":$PATH:" != *":$BUILD_DIR:"* ]]; then
    export PATH="$PATH:$BUILD_DIR"
fi

# 加载 help 模块
if [ -f "$BUILD_DIR/help.sh" ]; then
    # shellcheck disable=SC1090
    source "$BUILD_DIR/help.sh"
fi

# 列出可用板卡
function list_boards() {
    local i=1
    for f in $PROJECT_ROOT/board/*.conf; do
        if [ -f "$f" ]; then
            name=$(basename "$f" .conf)
            echo "  $i. $name"
            i=$((i+1))
        fi
    done
}

export -f list_boards

# 配置 Buildroot
function config_buildroot() {
    if [ -z "$BOARD_OUT_DIR" ]; then
        echo "错误: BOARD_OUT_DIR 未设置，请先加载板卡配置"
        return 1
    fi

    if [ ! -d "$BUILDROOT_DIR" ]; then
        echo "警告: Buildroot 源码目录不存在: $BUILDROOT_DIR"
        return 1
    fi

    if [ ! -d "$BR2_EXTERNAL_DIR" ]; then
        echo "警告: BR2_EXTERNAL 目录不存在: $BR2_EXTERNAL_DIR"
        return 1
    fi

    echo "正在配置 Buildroot..."
    mkdir -p "$BOARD_OUT_DIR"

    # 检查 .config 是否已存在
    if [ -f "$BOARD_OUT_DIR/.config" ]; then
        echo "Buildroot 配置文件已存在: $BOARD_OUT_DIR/.config"
        echo "跳过配置，如需重新配置请删除该文件或运行 'make distclean'"
        echo "修改buildroot 配置后， 请注意更新到$BOARD_DIR/$BUILDROOT_DEFCONFIG  !!!"
    else
        make -C "$BUILDROOT_DIR" O="$BOARD_OUT_DIR" BR2_EXTERNAL="$BR2_EXTERNAL_DIR" "$BUILDROOT_DEFCONFIG"
        echo "Buildroot 配置完成: $BOARD_OUT_DIR/.config"
    fi
}

export -f config_buildroot

# 定义构建目标和板卡选择
function lunch() {
    local board_idx
    local board

    # 支持命令行参数: lunch <board_name> 或 lunch <board_idx>
    if [ $# -ge 1 ]; then
        local input="$1"
        # 检查是否为数字（板卡编号）
        if [[ "$input" =~ ^[0-9]+$ ]]; then
            board_list=()
            while IFS= read -r -d '' f; do
                name=$(basename "$f" .conf)
                board_list+=("$name")
            done < <(find "$PROJECT_ROOT/board" -maxdepth 1 -name "*.conf" -print0 | sort -z)

            if (( input >= 1 && input <= ${#board_list[@]} )); then
                board="${board_list[input-1]}"
            else
                echo "错误: 板卡编号超出范围 (1-${#board_list[@]})"
                return 1
            fi
        else
            # 按板卡名称查找
            if [ -f "$PROJECT_ROOT/board/${input}.conf" ]; then
                board="$input"
            elif [ -f "$PROJECT_ROOT/board/${input}" ]; then
                board=$(basename "$input" .conf)
            else
                echo "错误: 未找到板卡配置 '$input'"
                echo "可用板卡:"
                list_boards
                return 1
            fi
        fi
    else
        # 板卡选择（数字选择）
        echo "可用板卡："
        board_list=()
        i=1
        for f in $PROJECT_ROOT/board/*.conf; do
            name=$(basename "$f" .conf)
            echo "$i. $name"
            board_list+=("$name")
            i=$((i+1))
        done

        # read 提示符
        read -p "请输入板卡编号（回车默认最后一个）: " board_idx

        if [ -z "$board_idx" ]; then
            board_idx=${#board_list[@]}
        fi

        # 数组索引: board_list[0] 是第一个元素
        if [[ "$board_idx" =~ ^[0-9]+$ ]] && (( board_idx >= 1 && board_idx <= ${#board_list[@]} )); then
            board="${board_list[board_idx-1]}"
        else
            board="board_default"
        fi
    fi

    board_conf="$PROJECT_ROOT/board/${board}.conf"
    if [ -f "$board_conf" ]; then
        # shellcheck disable=SC1090
        source "$board_conf"
        # 板卡配置文件中已通过 export 导出所有变量，无需重复导出

        # 根据 BOARD_OUT_DIR 设置所有组件输出目录
        if [ -z "$BOARD_OUT_DIR" ]; then
            BOARD_OUT_DIR="$OUT_DIR/$board"
        fi

        BOARD_OUT_DIR="$OUT_DIR/$BOARD_NAME"

        # 可选: 加载 shell_build.sh（不推荐使用）
        # 注意: shell_build.sh 提供了构建变量的引用，但不建议使用
        # 推荐使用 Makefile 进行构建: make, make modules, make modules-clean
        # 如需使用，请取消下面注释:
        # if [ -f "$BUILD_DIR/shell_build.sh" ]; then
        #     source "$BUILD_DIR/shell_build.sh"
        # fi

        echo "已加载板卡配置: $board_conf"
        echo "板卡名称: $BOARD_NAME"
        echo "配置文件:"
        echo "  - Kernel: $KERNEL_DEFCONFIG"
        echo "  - U-Boot: $UBOOT_DEFCONFIG"
        echo "  - Buildroot: $BUILDROOT_DEFCONFIG"
        echo "板卡参数: QEMU=$QEMU_MACHINE, CPU=$QEMU_CPU, SMP=$QEMU_SMP, MEM=$QEMU_MEM MB"
        echo "输出目录: $BOARD_OUT_DIR"

        # 执行预构建脚本
        echo ""
        local pre_build_script="$BOARD_DIR/pre_build.sh"
        if [ -f "$pre_build_script" ]; then
            echo "执行预构建脚本: $pre_build_script"
            # shellcheck disable=SC1090
            source "$pre_build_script"
            echo ""
        fi

        # 执行 Buildroot defconfig 配置
        config_buildroot
    else
        echo "未找到板卡配置: $board_conf，使用默认配置。"
    fi
}

# 连接到 QEMU monitor
function qemu_monitor() {
    if [ -z "$BOARD_NAME" ]; then
        echo "错误: 未选择板卡配置，请先运行 lunch 命令"
        return 1
    fi

    local qemu_monitor_socket="$BOARD_OUT_DIR/qemu-monitor.sock"

    if [ ! -S "$qemu_monitor_socket" ]; then
        echo "错误: QEMU monitor socket 不存在"
        echo "  请先运行 boot monitor 命令启动 QEMU"
        return 1
    fi

    echo "连接到 QEMU monitor: $qemu_monitor_socket"
    echo "常用命令:"
    echo "  info qtree        - 查看设备树"
    echo "  info mem          - 查看内存信息"
    echo "  info cpus         - 查看 CPU 信息"
    echo "  stop              - 暂停系统"
    echo "  c                 - 继续运行"
    echo "  quit              - 退出 QEMU"
    echo ""
    echo "输入 Ctrl+D 退出 monitor"
    echo "======================================"
    echo ""

    socat - UNIX-CONNECT:"$qemu_monitor_socket"
}

export -f qemu_monitor

# QEMU 启动 Linux 内核
function boot() {
    # 检查是否已选择板卡配置
    if [ -z "$BOARD_NAME" ]; then
        echo "错误: 未选择板卡配置，请先运行 lunch 命令"
        return 1
    fi

    # 解析参数: monitor
    local enable_monitor=0
    while [ $# -gt 0 ]; do
        case "$1" in
            monitor)
                enable_monitor=1
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    # 设置内核镜像路径（优先使用 Buildroot 构建的 Image）
    if [ -f "$BOARD_OUT_DIR/images/Image" ]; then
        KERNEL_IMAGE="$BOARD_OUT_DIR/images/Image"
    else
        echo "错误: Linux 内核镜像不存在"
        echo "  尝试路径: $BOARD_OUT_DIR/images/Image"
        return 1
    fi

    # 设置根文件系统路径（优先使用 Buildroot 构建的 cpio）
    if [ -f "$BOARD_OUT_DIR/images/rootfs.cpio" ]; then
        ROOTFS_FILE="$BOARD_OUT_DIR/images/rootfs.cpio"
    else
        echo "错误: 根文件系统镜像不存在"
        echo "  尝试路径: $BOARD_OUT_DIR/images/rootfs.cpio"
        return 1
    fi

    # 设置 QEMU monitor 和设备树导出
    local qemu_dtb="$BOARD_OUT_DIR/images/quantum_qemu.dtb"
    local qemu_monitor_socket="$BOARD_OUT_DIR/qemu-monitor.sock"
    local monitor_args=""
    local dtb_args=""

    # 如果启用 monitor，添加 monitor 参数
    if [ $enable_monitor -eq 1 ]; then
        monitor_args="-monitor \"unix:$qemu_monitor_socket,server,nowait\""
    fi

    echo "======================================"
    echo "启动 QEMU 运行 Linux 内核..."
    echo "======================================"
    echo "板卡: $BOARD_NAME"
    echo "内核镜像: $KERNEL_IMAGE"
    echo "根文件系统: $ROOTFS_FILE"
    echo "QEMU Monitor: $([ $enable_monitor -eq 1 ] && echo "启用 ($qemu_monitor_socket)" || echo "未启用")"
    echo "QEMU 参数:"
    echo "  - 机器: $QEMU_MACHINE"
    echo "  - CPU: $QEMU_CPU"
    echo "  - SMP: $QEMU_SMP"
    echo "  - 内存: ${QEMU_MEM}M"
    echo "  - 内核参数: $KERNEL_CMDLINE"
    if [ $enable_monitor -eq 1 ]; then
        echo ""
        echo "导出设备树 (在 QEMU monitor 中):"
        echo "  在另一个终端运行: qemu_monitor"
        echo "  然后在 monitor 中执行: info qtree"
    fi
    # 如果 DTB 存在，则使用自定义 DTB
    if [ -f "$qemu_dtb" ]; then
        dtb_args="-dtb \"$qemu_dtb\""
        echo "设备树: 使用自定义 DTB ($qemu_dtb)"
    else
        echo "设备树: 使用 QEMU 自动生成的设备树"
    fi
    echo "======================================"
    echo ""

    # 启动 QEMU（带可选 monitor 和 DTB 支持）
    eval "qemu-system-aarch64 \
        -M \"$QEMU_MACHINE\" \
        -cpu \"$QEMU_CPU\" \
        -smp \"$QEMU_SMP\" \
        -m \"$QEMU_MEM\" \
        -nographic \
        $monitor_args \
        -kernel \"$KERNEL_IMAGE\" \
        $dtb_args \
        -initrd \"$ROOTFS_FILE\" \
        -append \"$KERNEL_CMDLINE\""
}

# 使函数可用
export -f lunch
export -f boot