#!/bin/bash

# 设置构建环境变量
export PROJECT_ROOT=$(pwd)
export BUILD_DIR="$PROJECT_ROOT/build"
export OUT_DIR="$PROJECT_ROOT/out"
export SRC_DIR="$PROJECT_ROOT/src"
# 添加BUILDROOT_DIR环境变量
export BUILDROOT_DIR="$SRC_DIR/buildroot/buildroot-2025.02-rc1"

# 添加必要的路径，避免重复添加
if [[ ":$PATH:" != *":$BUILD_DIR:"* ]]; then
    export PATH="$PATH:$BUILD_DIR"
fi

# 定义构建目标和板卡选择
function lunch() {
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
    read -p "请输入板卡编号（回车默认最后一个）: " board_idx
    if [ -z "$board_idx" ]; then
        board_idx=${#board_list[@]}
    fi
    if [[ "$board_idx" =~ ^[0-9]+$ ]] && (( board_idx >= 1 && board_idx <= ${#board_list[@]} )); then
        board="${board_list[board_idx-1]}"
    else
        board="board_default"
    fi
    board_conf="$PROJECT_ROOT/board/${board}.conf"
    if [ -f "$board_conf" ]; then
        # shellcheck disable=SC1090
        source "$board_conf"
        export BOARD_NAME
        export KERNEL_CONFIG
        export UBOOT_CONFIG
        export BUILDROOT_CONFIG
        echo "已加载板卡配置: $board_conf"
    else
        echo "未找到板卡配置: $board_conf，使用默认配置。"
    fi
}

# 提供构建目标和板卡选择的帮助信息
function help() {
    cat << EOF
用法:
    1. 首先初始化构建环境: source build/envsetup.sh
    2. 下载源码: ./scripts/download.sh [all|tfa|uboot|kernel|buildroot|rt-thread]
    3. 选择目标板卡: lunch
    4. 编译目标组件

板卡配置:
    lunch 命令会列出可用的板卡配置:
    - board_a
    - board_b
    - board_default
    通过输入编号选择对应的板卡配置文件 (board/<board_name>.conf)

源码下载:
    ./scripts/download.sh all        - 下载所有组件源码
    ./scripts/download.sh tfa       - 下载 TF-A 源码
    ./scripts/download.sh uboot     - 下载 U-Boot 源码
    ./scripts/download.sh kernel    - 下载 Linux 内核源码
    ./scripts/download.sh buildroot - 下载 Buildroot 源码
    ./scripts/download.sh rt-thread - 下载 RT-Thread 源码
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
    注意: 构建前请确保对应的源码已下载到 src/ 目录

输出目录:
    编译产物将存放在 out/ 目录下
EOF
}

# 使函数可用
export -f lunch
export -f help