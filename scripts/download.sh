#!/bin/bash


# 检查参数
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 [all|kernel|tfa|uboot|buildroot|rt-thread|mbedtls|busybox|toolchain]"
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
            "https://github.com/Mbed-TLS/mbedtls.git"
            "https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"
            "https://developer.arm.com/-/media/Files/downloads/gnu/13.3.rel1/binrel/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu.tar.xz"
        )
        ;;
    kernel)
        echo "Downloading kernel repositories..."
        REPO_URLS=("https://github.com/torvalds/linux/archive/refs/tags/v6.1-rc8.zip")
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
    mbedtls)
        echo "Downloading mbedtls repositories..."
        REPO_URLS=("https://github.com/Mbed-TLS/mbedtls.git")
        ;;
    busybox)
        echo "Downloading busybox repositories..."
        REPO_URLS=("https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2")
        ;;
    toolchain)
        echo "Downloading arm-gnu-toolchain..."
        REPO_URLS=("https://developer.arm.com/-/media/Files/downloads/gnu/13.3.rel1/binrel/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu.tar.xz")
        ;;
    *)
        echo "Invalid option: $1"
        echo "Usage: $0 [all|kernel|tfa|uboot|buildroot|rt-thread|mbedtls|busybox|toolchain]"
        exit 1
        ;;
esac

# 下载源码
for REPO in "${REPO_URLS[@]}"; do
    echo "正在下载: $REPO"
    if [[ $REPO == *.git ]]; then
        git clone $REPO src/$(basename $REPO .git)
    elif [[ $REPO == *.tar.xz ]] || [[ $REPO == *.tar.gz ]] || [[ $REPO == *.tar.bz2 ]]; then
        # 下载压缩包并解压到 tools/ 目录
        FILENAME=$(basename $REPO)
        wget $REPO -O tools/$FILENAME
        echo "解压: tools/$FILENAME"
        cd tools/
        if [[ $FILENAME == *.tar.xz ]]; then
            tar xf $FILENAME
        elif [[ $FILENAME == *.tar.gz ]]; then
            tar xzf $FILENAME
        elif [[ $FILENAME == *.tar.bz2 ]]; then
            tar xjf $FILENAME
        fi
        # 删除压缩包
        rm -f $FILENAME
        cd ..
    else
        wget $REPO -P src/
    fi
done

echo "源码下载完成。"
