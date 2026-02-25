# Quantum 项目说明

该项目旨在创建一个类似于 Android 的构建系统，支持编译多个组件，包括 TF-A、U-Boot、Linux 内核、Buildroot 和 RT-Thread。

## 提交代码

```bash
git push origin HEAD:master
git push origin HEAD:main
```

## 目录结构

- **build/envsetup.sh**：设置构建环境，配置必要的环境变量和路径，提供 lunch 和 help 命令
- **board/**：板卡配置目录，包含不同板卡的配置文件（board_a.conf、board_b.conf、board_default.conf）
- **Makefile**：主构建文件，定义 buildroot 的构建规则
- **scripts/**：脚本目录
  - `download.sh`：下载所需的源码仓库
  - `build/`：包含各个组件的编译脚本
    - `build_tf-a.sh`：编译 TF-A (Trusted Firmware-A)
    - `build_uboot.sh`：编译 U-Boot 引导程序
    - `build_kernel.sh`：编译 Linux 内核
    - `build_rtthread.sh`：编译 RT-Thread 实时操作系统
    - `build_buildroot.sh`：编译 Buildroot 根文件系统
  - `qemu/`：QEMU 运行脚本
    - `qemu_kernel.sh`：在 QEMU 中运行 Linux 内核
    - `qemu_uboot.sh`：在 QEMU 中运行 U-Boot
    - `qemu_tfa.sh`：在 QEMU 中运行 TF-A
- **src/**：包含各个组件的源代码
  - `tf-a`：TF-A 源代码
  - `u-boot`：U-Boot 源代码
  - `linux-6.1`：Linux 内核源代码
  - `rt-thread`：RT-Thread 源代码
  - `buildroot`：Buildroot 源代码
  - `mbedtls`：MbedTLS 源代码（TF-A 依赖）
- **out/**：存放最终编译输出的产物
- **tools/**：辅助工具
  - `rootfs_busybox/`：Busybox 根文件系统构建脚本

## 使用说明

### 1. 快速开始

```bash
# 1. 初始化构建环境
source build/envsetup.sh

# 2. 查看帮助信息
help

# 3. 下载源码（可选择下载所有或单个组件）
./scripts/download.sh all

# 4. 选择板卡配置
lunch

# 5. 编译组件
./scripts/build/build_kernel.sh
```

### 2. 详细步骤

#### 2.1 环境设置

运行以下命令来设置构建环境：
```bash
source build/envsetup.sh
```

该命令会：
- 设置 PROJECT_ROOT、SRC_DIR、OUT_DIR 等环境变量
- 导出各组件源码目录和输出目录
- 设置交叉编译工具链前缀（aarch64-linux-gnu-）
- 提供 lunch 和 help 命令

#### 2.2 下载源码

使用 download.sh 脚本下载所需的源码：

```bash
# 下载所有组件源码
./scripts/download.sh all

# 或单独下载某个组件
./scripts/download.sh kernel      # 下载 Linux 内核
./scripts/download.sh tfa         # 下载 TF-A
./scripts/download.sh uboot       # 下载 U-Boot
./scripts/download.sh buildroot   # 下载 Buildroot
./scripts/download.sh rt-thread   # 下载 RT-Thread
./scripts/download.sh mbedtls     # 下载 MbedTLS (TF-A 依赖)
```

源码将下载到 `src/` 目录下。

#### 2.3 选择板卡配置

使用 lunch 命令选择目标板卡：
```bash
lunch
```

该命令会列出可用的板卡配置：
- board_a
- board_b
- board_default

板卡配置文件位于 `board/` 目录，定义了板卡的 KERNEL_CONFIG、UBOOT_CONFIG、BUILDROOT_CONFIG 等参数。

#### 2.4 编译组件

**编译 TF-A：**
```bash
./scripts/build/build_tf-a.sh
```
- 输出目录：`out/tf-a_out`
- 依赖：需要先下载 mbedtls 源码

**编译 U-Boot：**
```bash
./scripts/build/build_uboot.sh
```
- 输出目录：`out/uboot_out`

**编译 Linux 内核：**
```bash
./scripts/build/build_kernel.sh
```
- 输出目录：`out/kernel_out`
- 架构：ARM64 (cortex-a57)

**编译 RT-Thread：**
```bash
./scripts/build/build_rtthread.sh
```
- 输出目录：`out/rtt_out`
- 目标平台：qemu-vexpress-a9

**编译 Buildroot：**
```bash
./scripts/build/build_buildroot.sh
# 或使用 make
make buildroot
```
- 输出目录：`out/`

**使用 Makefile 编译：**
```bash
make all        # 编译所有组件 (当前为 buildroot)
make buildroot  # 编译 Buildroot 根文件系统
make clean      # 清理编译输出
make distclean  # 完全清理 (包括配置)
make menuconfig # 配置 Buildroot
```

#### 2.5 运行 QEMU 调试

**运行 Linux 内核：**
```bash
./scripts/qemu/qemu_kernel.sh
```
- 需要：编译好的内核镜像和根文件系统
- 支持 GDB 调试（使用 -s -S 参数）

**运行 U-Boot：**
```bash
./scripts/qemu/qemu_uboot.sh
```
- 需要：编译好的 u-boot.bin

**运行 TF-A：**
```bash
./scripts/qemu/qemu_tfa.sh
```
- 需要：编译好的 bl1.bin 和 fip.bin
- 启动参数：-M virt,secure=on

### 3. 环境变量说明

执行 `source build/envsetup.sh` 后，将设置以下环境变量：

**源码目录：**
- `LINUX_DIR`：Linux 内核源码目录 (`src/linux-6.1`)
- `TFA_DIR`：TF-A 源码目录 (`src/tf-a`)
- `UBOOT_DIR`：U-Boot 源码目录 (`src/u-boot`)
- `RTTHREAD_DIR`：RT-Thread 源码目录 (`src/rt-thread`)
- `BUILDROOT_DIR`：Buildroot 源码目录 (`src/buildroot/buildroot-2025.02-rc1`)
- `MBEDTLS_DIR`：MbedTLS 源码目录 (`src/mbedtls`)

**输出目录：**
- `KERNEL_OUT_DIR`：内核输出目录 (`out/kernel_out`)
- `TFA_OUT_DIR`：TF-A 输出目录 (`out/tf-a_out`)
- `UBOOT_OUT_DIR`：U-Boot 输出目录 (`out/uboot_out`)
- `RTT_OUT_DIR`：RT-Thread 输出目录 (`out/rtt_out`)
- `OUT_DIR`：通用输出目录 (`out/`)

**其他：**
- `CROSS_COMPILE`：交叉编译工具链前缀 (`aarch64-linux-gnu-`)
- `ROOTFS_DIR`：根文件系统目录 (`tools/rootfs_busybox`)

### 4. 交叉编译工具链

项目使用 `aarch64-linux-gnu-` 交叉编译工具链。如果未安装，可以安装：

```bash
# Ubuntu/Debian
sudo apt-get install gcc-aarch64-linux-gnu

# 或使用 aptitude
sudo aptitude install gcc-aarch64-linux-gnu
```

### 5. 注意事项

1. **构建顺序建议**：
   - 先编译 mbedtls（TF-A 依赖）
   - 再编译 TF-A
   - 然后编译 U-Boot
   - 最后编译内核和其他组件

2. **编译前检查**：所有构建脚本都会检查源码目录是否存在，请确保先下载源码。

3. **QEMU 运行**：QEMU 脚本使用 `-s -S` 参数支持 GDB 调试，可以附加 GDB 进行源码级调试。

4. **板卡配置**：板卡配置文件定义了不同硬件平台的编译选项，使用 lunch 选择合适的板卡配置。

## 开发者资源

更多帮助信息请运行：
```bash
source build/envsetup.sh
help
```
