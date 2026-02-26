#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量

# 检查 Buildroot 源码目录是否存在
if [ ! -d "$BUILDROOT_DIR" ]; then
    echo "错误: Buildroot 源码目录不存在: $BUILDROOT_DIR"
    echo "请下载 Buildroot 源码: ./scripts/download.sh buildroot"
    exit 1
fi

# 检查是否已选择板卡配置
if [ -z "$BOARD_NAME" ]; then
    echo "警告: 未选择板卡配置，请先运行 lunch 命令"
    echo "使用默认配置进行编译..."
    BOARD_NAME="board_default"
    BUILDROOT_DEFCONFIG="$PROJECT_ROOT/board/board_default/config/buildroot_defconfig"
fi

# 检查板卡配置文件是否存在
if [ ! -f "$BUILDROOT_DEFCONFIG" ]; then
    echo "错误: 板卡 Buildroot 配置文件不存在: $BUILDROOT_DEFCONFIG"
    echo "请运行 lunch 命令选择有效的板卡配置"
    exit 1
fi

# 创建输出目录
mkdir -p "$OUT_DIR"

echo "开始编译 Buildroot..."
echo "板卡: $BOARD_NAME"
echo "Buildroot 配置: $BUILDROOT_DEFCONFIG"
echo ""

# 进入 Buildroot 源码目录
cd "$BUILDROOT_DIR"

# 设置 Buildroot 的输出目录
export BR2_OUTPUT="$PROJECT_ROOT/build"

# 使用板卡配置文件
if [ -f "$BUILDROOT_DEFCONFIG" ]; then
    # 使用板卡特定的 defconfig
    cp "$BUILDROOT_DEFCONFIG" "$BUILDROOT_DIR/configs/board_defconfig"
    make board_defconfig
else
    # 回退到默认配置
    make defconfig
fi

# 执行 Buildroot 的编译
make

# 检查编译结果
if [ $? -eq 0 ]; then
    echo "Buildroot 编译成功！"

    # 将编译产物移动到输出目录
    mkdir -p "$OUT_DIR"
    mv output/images/* "$OUT_DIR/" 2>/dev/null || true

    echo "编译产物已输出到: $OUT_DIR"
else
    echo "Buildroot 编译失败！"
    exit 1
fi
