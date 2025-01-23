#!/bin/bash

# lunch.sh - 选择构建目标

echo "请选择构建目标:"
echo "1) TF-A"
echo "2) U-Boot"
echo "3) Kernel"
echo "4) Buildroot"
echo "5) RT-Thread"
echo "6) All"
echo "7) Clean"

read -p "输入选项 (1-7): " option

case $option in
    1)
        TARGET="tf-a"
        ;;
    2)
        TARGET="uboot"
        ;;
    3)
        TARGET="kernel"
        ;;
    4)
        TARGET="buildroot"
        ;;
    5)
        TARGET="rtthread"
        ;;
    6)
        TARGET="all"
        ;;
    7)
        TARGET="clean"
        ;;
    *)
        echo "无效选项"
        exit 1
        ;;
esac

echo "选择的构建目标: $TARGET"
export TARGET