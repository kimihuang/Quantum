#!/bin/bash

# 下载所需的源码仓库
#REPO_URLS=(
#    "https://github.com/ARM-software/arm-trusted-firmware.git"
#    "https://source.denx.de/u-boot/u-boot.git"
#    "https://kernel.org/pub/linux/kernel/v5.x/linux-5.10.17.tar.xz"
#    "https://buildroot.org/downloads/buildroot-2021.02.tar.gz"
#    "https://github.com/RT-Thread/rt-thread.git"
#)

REPO_URLS=(
    "https://source.denx.de/u-boot/u-boot.git"
    "https://buildroot.org/downloads/buildroot-2021.02.tar.gz"
    "https://github.com/RT-Thread/rt-thread.git"
)

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