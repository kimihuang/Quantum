#!/bin/bash

# 提供构建目标和板卡选择的帮助信息
function help() {
    cat << EOF
用法:
    1. 首先初始化构建环境: source build/envsetup.sh
    2. 下载源码: ./scripts/download.sh [all|tfa|uboot|kernel|buildroot|rt-thread]
    3. 选择目标板卡: lunch
    4. 编译目标组件
    5. (可选) 运行 QEMU 调试

板卡配置:
    lunch 命令会列出可用的板卡配置:
    - board_qemu_a - QEMU板卡A配置 (4核, 1GB内存, cortex-a57)
    - board_qemu_b - QEMU板卡B配置 (2核, 2GB内存, cortex-a57, preempt)
    - board_default - 默认板卡配置 (4核, 1GB内存, cortex-a57)

    通过输入编号选择对应的板卡配置文件 (board/<board_name>.conf)
    板卡配置包含:
      - 配置文件: kernel_defconfig, uboot_defconfig, buildroot_defconfig
      - 板卡参数: QEMU_MACHINE, QEMU_CPU, QEMU_SMP, QEMU_MEM, KERNEL_CMDLINE

源码下载:
    ./scripts/download.sh all        - 下载所有组件源码
    ./scripts/download.sh tfa       - 下载 TF-A 源码
    ./scripts/download.sh uboot     - 下载 U-Boot 源码
    ./scripts/download.sh kernel    - 下载 Linux 内核源码
    ./scripts/download.sh buildroot - 下载 Buildroot 源码
    ./scripts/download.sh rt-thread - 下载 RT-Thread 源码
    ./scripts/download.sh mbedtls   - 下载 MbedTLS 源码 (TF-A 依赖)
    ./scripts/download.sh busybox   - 下载 Busybox 源码 (Rootfs)
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
    ./scripts/build/build_rootfs.sh   - 编译 Busybox Rootfs
    注意: 构建前请确保对应的源码已下载到 src/ 目录

QEMU 运行脚本:
    ./scripts/qemu/qemu_kernel.sh     - 在 QEMU 中运行 Linux 内核
    ./scripts/qemu/qemu_uboot.sh       - 在 QEMU 中运行 U-Boot
    ./scripts/qemu/qemu_tfa.sh         - 在 QEMU 中运行 TF-A

快捷启动命令 (需要先执行 lunch):
    boot                              - 使用 QEMU 启动 Linux 内核
    boot monitor                      - 启动 QEMU 并启用 monitor
    qemu_monitor                      - 连接到 QEMU monitor (需先执行 boot monitor)
    config_buildroot                  - 配置 Buildroot
    注意: 运行前请先编译对应的组件，使用 -s -S 参数支持 GDB 调试

输出目录:
    编译产物将存放在 out/ 目录下

编译工具链:
    ARM 工具链: $ARM_TOOLCHAIN_DIR
    交叉编译前缀: $CROSS_COMPILE
    注意: 如果本地工具链不存在，将使用系统默认工具链 aarch64-linux-gnu-
EOF
}

export -f help
