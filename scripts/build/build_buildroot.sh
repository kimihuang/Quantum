#!/bin/bash

# 使用 envsetup.sh 中定义的环境变量

# 检查 Buildroot 源码目录是否存在
if [ ! -d "$BUILDROOT_DIR" ]; then
    echo "错误: Buildroot 源码目录不存在: $BUILDROOT_DIR"
    echo "请下载 Buildroot 源码: ./scripts/download.sh buildroot"
    exit 1
fi

# 创建输出目录
mkdir -p "$OUT_DIR"

echo "开始编译 Buildroot..."

# 进入 Buildroot 源码目录
cd "$BUILDROOT_DIR"

# 设置 Buildroot 的输出目录
export BR2_OUTPUT="$PROJECT_ROOT/build"

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
