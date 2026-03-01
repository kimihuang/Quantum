#!/bin/bash

# 设置构建环境变量
export PROJECT_ROOT=$(pwd)
export BUILD_DIR="$PROJECT_ROOT/build"
export OUT_DIR="$PROJECT_ROOT/out"
export SRC_DIR="$PROJECT_ROOT/src"

# 检测 shell 类型并设置兼容性
if [ -n "$ZSH_VERSION" ]; then
    # zsh 环境
    autoload -Uz bashcompinit 2>/dev/null || true
    # zsh 不支持 export -f，函数自动在当前 shell 可用
    export ENVSETUP_SHELL="zsh"
elif [ -n "$BASH_VERSION" ]; then
    # bash 环境
    export ENVSETUP_SHELL="bash"
else
    export ENVSETUP_SHELL="unknown"
fi

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
export TFA_DIR="$SRC_DIR/tf-a"
export UBOOT_DIR="$SRC_DIR/u-boot"
export RTTHREAD_DIR="$SRC_DIR/rt-thread"
export MBEDTLS_DIR="$SRC_DIR/mbedtls"
export BUSYBOX_VERSION="1.36.1"
export BUSYBOX_DIR="$SRC_DIR/busybox-$BUSYBOX_VERSION"

# 输出目录（这些将在 lunch 中动态设置）
TFA_OUT_DIR=
UBOOT_OUT_DIR=
KERNEL_OUT_DIR=
RTT_OUT_DIR=
ROOTFS_OUT_DIR=
BOARD_OUT_DIR=

# QEMU 运行脚本目录
export QEMU_SCRIPTS_DIR="$PROJECT_ROOT/scripts/qemu"

# 添加构建目录到 PATH（避免重复添加）
if [[ ":$PATH:" != *":$BUILD_DIR:"* ]]; then
    export PATH="$PATH:$BUILD_DIR"
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

if [ "$ENVSETUP_SHELL" = "bash" ]; then
    export -f list_boards
fi

# 定义构建目标和板卡选择
function lunch() {
    local board_idx
    local board

    # 检测是否为交互式 shell
    if [[ ! -t 0 ]]; then
        echo "错误: lunch 需要在交互式终端中运行"
        echo "用法: source build/envsetup.sh 后执行 lunch"
        return 1
    fi

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

        # 兼容 bash 和 zsh 的 read 提示符语法
        if [ "$ENVSETUP_SHELL" = "zsh" ]; then
            # zsh 语法: read "?prompt"
            read "board_idx?请输入板卡编号（回车默认最后一个）: "
        else
            # bash 语法: read -p "prompt"
            read -p "请输入板卡编号（回车默认最后一个）: " board_idx
        fi

        if [ -z "$board_idx" ]; then
            board_idx=${#board_list[@]}
        fi

        # 兼容 bash 和 zsh 的数组索引差异
        # bash: 数组从 0 开始，board_list[0] 是第一个元素
        # zsh: 数组从 1 开始，board_list[1] 是第一个元素
        if [[ "$board_idx" =~ ^[0-9]+$ ]] && (( board_idx >= 1 && board_idx <= ${#board_list[@]} )); then
            if [ "$ENVSETUP_SHELL" = "zsh" ]; then
                # zsh 中直接使用索引
                board="${board_list[board_idx]}"
            else
                # bash 中索引需要减 1
                board="${board_list[board_idx-1]}"
            fi
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
        export TFA_OUT_DIR="$BOARD_OUT_DIR/tf-a_out"
        export UBOOT_OUT_DIR="$BOARD_OUT_DIR/uboot_out"
        export KERNEL_OUT_DIR="$BOARD_OUT_DIR/kernel_out"
        export RTT_OUT_DIR="$BOARD_OUT_DIR/rtt_out"
        export ROOTFS_OUT_DIR="$BOARD_OUT_DIR/rootfs_out"

        echo "已加载板卡配置: $board_conf"
        echo "板卡名称: $BOARD_NAME"
        echo "配置文件:"
        echo "  - Kernel: $KERNEL_DEFCONFIG"
        echo "  - U-Boot: $UBOOT_DEFCONFIG"
        echo "  - Buildroot: $BUILDROOT_DEFCONFIG"
        echo "板卡参数: QEMU=$QEMU_MACHINE, CPU=$QEMU_CPU, SMP=$QEMU_SMP, MEM=$QEMU_MEM MB"
        echo "输出目录: $BOARD_OUT_DIR"

        # 执行 Buildroot defconfig 配置
        if [ -d "$BUILDROOT_DIR" ] && [ -d "$BR2_EXTERNAL_DIR" ]; then
            echo ""
            echo "正在配置 Buildroot..."
            mkdir -p "$BOARD_OUT_DIR"
            make -C "$BUILDROOT_DIR" O="$BOARD_OUT_DIR" BR2_EXTERNAL="$BR2_EXTERNAL_DIR" "$BUILDROOT_DEFCONFIG"
            echo "Buildroot 配置完成: $BOARD_OUT_DIR/.config"
        else
            echo ""
            echo "警告: Buildroot 源码或 BR2_EXTERNAL 目录不存在，跳过配置"
            echo "  BUILDROOT_DIR: $BUILDROOT_DIR"
            echo "  BR2_EXTERNAL_DIR: $BR2_EXTERNAL_DIR"
        fi
    else
        echo "未找到板卡配置: $board_conf，使用默认配置。"
    fi
}

# QEMU 启动 Linux 内核
function boot() {
    # 检查是否已选择板卡配置
    if [ -z "$BOARD_NAME" ]; then
        echo "错误: 未选择板卡配置，请先运行 lunch 命令"
        return 1
    fi

    # 设置内核镜像路径（优先使用 Buildroot 构建的 Image）
    if [ -f "$BOARD_OUT_DIR/images/Image" ]; then
        KERNEL_IMAGE="$BOARD_OUT_DIR/images/Image"
    elif [ -f "$KERNEL_OUT_DIR/arch/$KERNEL_ARCH/boot/Image" ]; then
        KERNEL_IMAGE="$KERNEL_OUT_DIR/arch/$KERNEL_ARCH/boot/Image"
    else
        echo "错误: Linux 内核镜像不存在"
        echo "  尝试路径1: $BOARD_OUT_DIR/images/Image"
        echo "  尝试路径2: $KERNEL_OUT_DIR/arch/$KERNEL_ARCH/boot/Image"
        return 1
    fi

    # 设置根文件系统路径（优先使用 Buildroot 构建的 cpio）
    if [ -f "$BOARD_OUT_DIR/images/rootfs.cpio" ]; then
        ROOTFS_FILE="$BOARD_OUT_DIR/images/rootfs.cpio"
    elif [ -f "$ROOTFS_OUT_DIR/rootfs.img" ]; then
        ROOTFS_FILE="$ROOTFS_OUT_DIR/rootfs.img"
    else
        echo "错误: 根文件系统镜像不存在"
        echo "  尝试路径1: $BOARD_OUT_DIR/images/rootfs.cpio"
        echo "  尝试路径2: $ROOTFS_OUT_DIR/rootfs.img"
        return 1
    fi

    echo "======================================"
    echo "启动 QEMU 运行 Linux 内核..."
    echo "======================================"
    echo "板卡: $BOARD_NAME"
    echo "内核镜像: $KERNEL_IMAGE"
    echo "根文件系统: $ROOTFS_FILE"
    echo "QEMU 参数:"
    echo "  - 机器: $QEMU_MACHINE"
    echo "  - CPU: $QEMU_CPU"
    echo "  - SMP: $QEMU_SMP"
    echo "  - 内存: ${QEMU_MEM}M"
    echo "  - 内核参数: $KERNEL_CMDLINE"
    echo "======================================"
    echo ""

    # 启动 QEMU
    qemu-system-aarch64 \
        -M "$QEMU_MACHINE" \
        -cpu "$QEMU_CPU" \
        -smp "$QEMU_SMP" \
        -m "$QEMU_MEM" \
        -nographic \
        -kernel "$KERNEL_IMAGE" \
        -initrd "$ROOTFS_FILE" \
        -append "$KERNEL_CMDLINE"
}

# 提供构建目标和板卡选择的帮助信息
function help() {
    cat << EOF
用法:
    1. 首先初始化构建环境: source build/envsetup.sh
    2. 下载源码: ./scripts/download.sh [all|tfa|uboot|kernel|buildroot|rt-thread]
    3. 选择目标板卡: lunch
    4. 编译目标组件
    5. (可选) 运行 QEMU 调试

板卡配置:
    lunch 命令会列出可用的板卡配置:
    - board_qemu_a - QEMU板卡A配置 (4核, 1GB内存, cortex-a57)
    - board_qemu_b - QEMU板卡B配置 (2核, 2GB内存, cortex-a57, preempt)
    - board_default - 默认板卡配置 (4核, 1GB内存, cortex-a57)

    通过输入编号选择对应的板卡配置文件 (board/<board_name>.conf)
    板卡配置包含:
      - 配置文件: kernel_defconfig, uboot_defconfig, buildroot_defconfig
      - 板卡参数: QEMU_MACHINE, QEMU_CPU, QEMU_SMP, QEMU_MEM, KERNEL_CMDLINE

源码下载:
    ./scripts/download.sh all        - 下载所有组件源码
    ./scripts/download.sh tfa       - 下载 TF-A 源码
    ./scripts/download.sh uboot     - 下载 U-Boot 源码
    ./scripts/download.sh kernel    - 下载 Linux 内核源码
    ./scripts/download.sh buildroot - 下载 Buildroot 源码
    ./scripts/download.sh rt-thread - 下载 RT-Thread 源码
    ./scripts/download.sh mbedtls   - 下载 MbedTLS 源码 (TF-A 依赖)
    ./scripts/download.sh busybox   - 下载 Busybox 源码 (Rootfs)
    源码将下载到 src/ 目录下

Makefile 构建目标:
    make all        - 编译所有组件 (当前为 buildroot)
    make buildroot  - 编译 Buildroot 根文件系统
    make clean      - 清理编译输出
    make distclean  - 完全清理 (包括配置)
    make menuconfig - 配置 Buildroot

独立构建脚本:
    ./scripts/build/build_tf-a.sh     - 编译 TF-A (Trusted Firmware-A)
    ./scripts/build/build_uboot.sh    - 编译 U-Boot 引导程序
    ./scripts/build/build_kernel.sh   - 编译 Linux 内核
    ./scripts/build/build_rtthread.sh - 编译 RT-Thread 实时操作系统
    ./scripts/build/build_rootfs.sh   - 编译 Busybox Rootfs
    注意: 构建前请确保对应的源码已下载到 src/ 目录

QEMU 运行脚本:
    ./scripts/qemu/qemu_kernel.sh     - 在 QEMU 中运行 Linux 内核
    ./scripts/qemu/qemu_uboot.sh       - 在 QEMU 中运行 U-Boot
    ./scripts/qemu/qemu_tfa.sh         - 在 QEMU 中运行 TF-A

快捷启动命令 (需要先执行 lunch):
    boot                              - 使用 QEMU 启动 Linux 内核
    注意: 运行前请先编译对应的组件，使用 -s -S 参数支持 GDB 调试

输出目录:
    编译产物将存放在 out/ 目录下

编译工具链:
    ARM 工具链: $ARM_TOOLCHAIN_DIR
    交叉编译前缀: $CROSS_COMPILE
    注意: 如果本地工具链不存在，将使用系统默认工具链 aarch64-linux-gnu-
EOF
}

# 使函数可用
if [ "$ENVSETUP_SHELL" = "bash" ]; then
    # bash 需要显式导出函数
    export -f lunch
    export -f help
    export -f boot
fi
# zsh 中 source 后函数自动可用，无需 export -f