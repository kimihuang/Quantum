#!/bin/bash

# 设置构建环境变量
export PROJECT_ROOT=$(pwd)/..
export BUILD_DIR="$PROJECT_ROOT/build"
export OUT_DIR="$PROJECT_ROOT/out"
export SRC_DIR="$PROJECT_ROOT/src"

# 添加必要的路径
export PATH="$PATH:$BUILD_DIR"

# 定义构建目标
function lunch() {
    echo "选择构建目标："
    echo "1. TF-A"
    echo "2. U-Boot"
    echo "3. Kernel"
    echo "4. Buildroot"
    echo "5. RT-Thread"
    echo "6. All"
    echo "7. Clean"
    read -p "请输入目标编号: " target

    case $target in
        1) export TARGET="tf-a" ;;
        2) export TARGET="uboot" ;;
        3) export TARGET="kernel" ;;
        4) export TARGET="buildroot" ;;
        5) export TARGET="rtthread" ;;
        6) export TARGET="all" ;;
        7) export TARGET="clean" ;;
        *) echo "无效的选择"; return ;;
    esac

    echo "已选择构建目标: $TARGET"
}

# 提供构建目标的帮助信息
function help() {
    echo "可用的构建目标:"
    echo "tf-a, uboot, kernel, buildroot, rtthread, all, clean"
}

# 使函数可用
export -f lunch
export -f help