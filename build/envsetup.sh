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

# 提供构建目标的帮助信息
function help() {
    echo "可用的构建目标:"
    echo "tf-a, uboot, kernel, buildroot, rtthread, all, clean"
}

# 使函数可用
export -f lunch
export -f help