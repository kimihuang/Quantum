#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量

# 检查 U-Boot 源码目录是否存在
if [ ! -d "$UBOOT_DIR" ]; then
    echo "错误: U-Boot 源码目录不存在: $UBOOT_DIR"
    echo "请下载 U-Boot 源码: ./scripts/download.sh uboot"
    exit 1
fi

# 创建输出目录
mkdir -p "$UBOOT_OUT_DIR"

echo "开始编译 U-Boot..."

# 进入 U-Boot 源码目录
cd "$UBOOT_DIR"

# 清理之前的构建产物
make clean

# 配置 qemu 编译环境
make CROSS_COMPILE="$CROSS_COMPILE" qemu_arm64_defconfig

# 编译
make CROSS_COMPILE="$CROSS_COMPILE" KCFLAGS="-g" -j$(nproc)

# 检查编译是否成功
if [ $? -eq 0 ]; then
    echo "U-Boot 编译成功！"

    # 将编译产物移动到输出目录
    cp "$UBOOT_DIR/u-boot" "$UBOOT_OUT_DIR"
    cp "$UBOOT_DIR/u-boot."* "$UBOOT_OUT_DIR" 2>/dev/null || true

    echo "编译产物已输出到: $UBOOT_OUT_DIR"
else
    echo "U-Boot 编译失败！"
    exit 1
fi
