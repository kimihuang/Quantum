#!/bin/bash

# 检查参数
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 [all|kernel|tfa|uboot|buildroot|rt-thread]"
    exit 1
fi

# 根据参数设置要下载的仓库
case "$1" in
    all)
        echo "Downloading all repositories..."
        REPO_URLS=(
            "https://github.com/u-boot/u-boot.git"
            "https://buildroot.org/downloads/buildroot-2021.02.tar.gz"
            "https://github.com/RT-Thread/rt-thread.git"
            "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
            "https://github.com/ARM-software/arm-trusted-firmware.git"
        )
        ;;
    kernel)
        echo "Downloading kernel repositories..."
        REPO_URLS=("https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git")
        ;;
    tfa)
        echo "Downloading arm-trusted-firmware repositories..."
        REPO_URLS=("https://github.com/ARM-software/arm-trusted-firmware.git")
        ;;
    uboot)
        echo "Downloading uboot repositories..."
        REPO_URLS=("https://github.com/u-boot/u-boot.git")
        ;;
    buildroot)
        echo "Downloading buildroot repositories..."
        REPO_URLS=("https://buildroot.org/downloads/buildroot-2024.08.tar.xz")
        ;;
    rt-thread)
        echo "Downloading rt-thread repositories..."
        REPO_URLS=("https://github.com/RT-Thread/rt-thread.git")
        ;;
    *)
        echo "Invalid option: $1"
        echo "Usage: $0 [all|uboot|buildroot|rt-thread]"
        exit 1
        ;;
esac

# 下载源码
for REPO in "${REPO_URLS[@]}"; do
    echo "正在下载: $REPO"
    if [[ $REPO == *.git ]]; then
        git clone $REPO src/$(basename $REPO .git)
    else
        wget $REPO -P src/
    fi
done

echo "源码下载完成。"