#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量

# 检查内核源码目录是否存在
if [ ! -d "$LINUX_DIR" ]; then
    echo "错误: Linux 内核源码目录不存在: $LINUX_DIR"
    echo "请下载 Linux 内核源码: ./scripts/download.sh kernel"
    exit 1
fi

# 检查是否已选择板卡配置
if [ -z "$BOARD_NAME" ]; then
    echo "警告: 未选择板卡配置，请先运行 lunch 命令"
    echo "使用默认配置进行编译..."
    BOARD_NAME="board_default"
    KERNEL_DEFCONFIG="$PROJECT_ROOT/board/board_default/config/kernel_defconfig"
    KERNEL_ARCH=arm64
    KERNEL_CMDLINE="console=ttyAMA0 root=/dev/vda rw nokaslr earlycon=pl011,0x9000000 debug loglevel=8"
fi

# 检查板卡配置文件是否存在
if [ ! -f "$KERNEL_DEFCONFIG" ]; then
    echo "错误: 板卡内核配置文件不存在: $KERNEL_DEFCONFIG"
    echo "请运行 lunch 命令选择有效的板卡配置"
    exit 1
fi

# 创建输出目录
mkdir -p "$KERNEL_OUT_DIR"

echo "开始编译 Linux 内核..."
echo "板卡: $BOARD_NAME"
echo "内核配置: $KERNEL_DEFCONFIG"
echo "内核架构: $KERNEL_ARCH"
echo "内核启动参数: $KERNEL_CMDLINE"
echo "输出目录: $KERNEL_OUT_DIR"
echo ""

# 进入内核源码目录
cd "$LINUX_DIR"

# 清理编译产物
make ARCH="$KERNEL_ARCH" CROSS_COMPILE="$CROSS_COMPILE" O="$KERNEL_OUT_DIR" mrproper

# 使用板卡配置文件配置内核
if [ -f "$KERNEL_DEFCONFIG" ]; then
    # 使用板卡特定的 defconfig
    cp "$KERNEL_DEFCONFIG" "$LINUX_DIR/arch/$KERNEL_ARCH/configs/board_defconfig"
    make ARCH="$KERNEL_ARCH" CROSS_COMPILE="$CROSS_COMPILE" O="$KERNEL_OUT_DIR" board_defconfig
else
    # 回退到默认 defconfig
    make ARCH="$KERNEL_ARCH" CROSS_COMPILE="$CROSS_COMPILE" O="$KERNEL_OUT_DIR" defconfig
fi

# 执行编译命令，使用 O 参数指定输出目录
make ARCH="$KERNEL_ARCH" CROSS_COMPILE="$CROSS_COMPILE" O="$KERNEL_OUT_DIR" -j$(nproc)

if [ $? -eq 0 ]; then
    echo "Linux 内核编译成功！"
    echo "编译产物已输出到: $KERNEL_OUT_DIR"
    echo "内核镜像: $KERNEL_OUT_DIR/arch/$KERNEL_ARCH/boot/Image"
else
    echo "Linux 内核编译失败！"
    exit 1
fi
