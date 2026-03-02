#!/bin/bash
#
# Shell 构建脚本
#
# 注意: 此脚本不推荐使用！
# 
# 原因:
#   1. 使用 shell 脚本进行模块化编译不如直接使用 Makefile 方便
#   2. Makefile 可以更好地处理依赖关系、增量编译和并行编译
#   3. Makefile 提供了更好的错误处理和日志记录
#   4. Shell 脚本维护成本高，不如 Makefile 规范
#
# 推荐使用方式:
#   - 使用顶层 Makefile 进行构建: make
#   - 或使用 Buildroot 的原生命令: make -C <buildroot_dir> <target>
#
# 如需使用此脚本，请在 lunch 后手动 source: source build/shell_build.sh

# 检查是否已选择板卡配置
if [ -z "$BOARD_NAME" ]; then
    echo "错误: 未选择板卡配置，请先执行: source build/envsetup.sh && lunch"
    return 1
fi

# 构建输出目录（这些变量在 lunch 时设置）
# 默认情况下这些变量已由 lunch 设置，这里只是声明以便参考
TFA_OUT_DIR="$BOARD_OUT_DIR/tf-a_out"
UBOOT_OUT_DIR="$BOARD_OUT_DIR/uboot_out"
KERNEL_OUT_DIR="$BOARD_OUT_DIR/kernel_out"
RTT_OUT_DIR="$BOARD_OUT_DIR/rtt_out"
ROOTFS_OUT_DIR="$BOARD_OUT_DIR/rootfs_out"


echo "Shell 构建脚本已加载"
echo "板卡: $BOARD_NAME"
echo "注意: 建议使用 Makefile 进行构建，不建议使用此脚本"
