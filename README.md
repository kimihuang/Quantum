# Quantum 项目说明

提交代码
git push github HEAD:master
git push origin HEAD:main

该项目旨在创建一个类似于 Android 的构建系统，支持编译多个组件，包括 TF-A、U-Boot、内核、Buildroot 和 RT-Thread。以下是项目的主要组成部分及其功能：

## 目录结构

- **build/envsetup.sh**：设置构建环境，配置必要的环境变量和路径。
- **configs/board_configs/default_board.conf**：定义默认板卡的配置参数。
- **configs/products/default_product.mk**：定义默认产品的构建规则和参数。
- **Makefile**：主构建文件，定义各个目标的构建规则和依赖关系。
- **scripts/build/**：包含各个组件的编译脚本：
  - `build_buildroot.sh`：编译 Buildroot。
  - `build_kernel.sh`：编译内核。
  - `build_rtthread.sh`：编译 RT-Thread。
  - `build_tf-a.sh`：编译 TF-A。
  - `build_uboot.sh`：编译 U-Boot。
- **scripts/download.sh**：下载所需的源码仓库。
- **scripts/lunch.sh**：选择构建目标。
- **src/**：包含各个组件的源代码：
  - `buildroot`：Buildroot 源代码。
  - `kernel`：内核源代码。
  - `rtthread`：RT-Thread 源代码。
  - `tf-a`：TF-A 源代码。
  - `uboot`：U-Boot 源代码。
- **out/**：存放最终编译输出的产物。

## 使用说明

1. **环境设置**：运行 `source build/envsetup.sh` 来设置构建环境。
2. **选择目标**：使用 `./scripts/lunch.sh <Target>` 来选择要构建的目标。
3. **编译**：
- **编译 RT-Thread**：运行以下命令来编译 RT-Thread：
  ```sh
  ./scripts/build/build_rtthread.sh
  ```
  该脚本将自动下载 RT-Thread 源代码并进行编译，生成的二进制文件将存放在 `out/rtt_out` 目录中。
- **编译 U-Boot**：运行以下命令来编译 U-Boot：
  ```sh
  ./scripts/build/build_uboot.sh
  ```
  该脚本将自动下载 U-Boot 源代码并进行编译，生成的二进制文件将存放在 `out/uboot_out` 目录中。
- **编译内核**：运行以下命令来编译内核：
  ```sh
  ./scripts/build/build_kernel.sh
  ```
  该脚本将自动下载内核源代码并进行编译，生成的二进制文件将存放在 `out/kernel_out` 目录中。
