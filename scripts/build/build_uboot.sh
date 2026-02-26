#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量

# 检查 U-Boot 源码目录是否存在
if [ ! -d "$UBOOT_DIR" ]; then
    echo "错误: U-Boot 源码目录不存在: $UBOOT_DIR"
    echo "请下载 U-Boot 源码: ./scripts/download.sh uboot"
    exit 1
fi

# 检查是否已选择板卡配置
if [ -z "$BOARD_NAME" ]; then
    echo "警告: 未选择板卡配置，请先运行 lunch 命令"
    echo "使用默认配置进行编译..."
    BOARD_NAME="board_default"
    UBOOT_DEFCONFIG="$PROJECT_ROOT/board/board_default/config/uboot_defconfig"
    UBOOT_ARCH=arm64
fi

# 检查板卡配置文件是否存在
if [ ! -f "$UBOOT_DEFCONFIG" ]; then
    echo "错误: 板卡 U-Boot 配置文件不存在: $UBOOT_DEFCONFIG"
    echo "请运行 lunch 命令选择有效的板卡配置"
    exit 1
fi

# 创建输出目录
mkdir -p "$UBOOT_OUT_DIR"

echo "开始编译 U-Boot..."
echo "板卡: $BOARD_NAME"
echo "U-Boot 配置: $UBOOT_DEFCONFIG"
echo "U-Boot 架构: $UBOOT_ARCH"
echo ""

# 进入 U-Boot 源码目录
cd "$UBOOT_DIR"

# 清理之前的构建产物
make clean

# 使用板卡配置文件配置 U-Boot
if [ -f "$UBOOT_DEFCONFIG" ]; then
    # 使用板卡特定的 defconfig
    cp "$UBOOT_DEFCONFIG" "$UBOOT_DIR/configs/board_defconfig"
    make ARCH="$UBOOT_ARCH" CROSS_COMPILE="$CROSS_COMPILE" board_defconfig
else
    # 回退到 qemu_arm64_defconfig
    make ARCH="$UBOOT_ARCH" CROSS_COMPILE="$CROSS_COMPILE" qemu_arm64_defconfig
fi

# 编译
make ARCH="$UBOOT_ARCH" CROSS_COMPILE="$CROSS_COMPILE" KCFLAGS="-g" -j$(nproc)

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
