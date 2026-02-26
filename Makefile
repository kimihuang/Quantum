# 顶层Makefile，用于编译 Buildroot
# 注意：此 Makefile 需要先执行 source build/envsetup.sh 和 lunch 选择板卡



# buildroot 源码路径由环境变量 BUILDROOT_DIR 提供
BUILDROOT_PATH ?= $(BUILDROOT_DIR)
ifeq ($(BUILDROOT_PATH),)
BUILDROOT_PATH := src/buildroot/buildroot-2025.02-rc1
endif

# 板卡配置文件路径和环境变量（由 envsetup.sh 和 lunch 设置）
# BUILDROOT_DEFCONFIG: 板卡特定的 Buildroot 配置文件
# BOARD_OUT_DIR: 板卡输出目录（如 out/board_qemu_a）
# 以上变量必须通过 lunch 选择板卡后才能使用

.PHONY: all buildroot clean distclean menuconfig

all: buildroot

buildroot:
	@if [ -z "$(BOARD_NAME)" ]; then \
		echo "错误: 未选择板卡配置，请先执行: source build/envsetup.sh && lunch"; \
		exit 1; \
	fi
	@if [ -z "$(BUILDROOT_DEFCONFIG)" ] || [ ! -f "$(BUILDROOT_DEFCONFIG)" ]; then \
		echo "错误: 板卡 Buildroot 配置文件不存在: $(BUILDROOT_DEFCONFIG)"; \
		exit 1; \
	fi
	@echo "开始编译 Buildroot..."
	@echo "板卡: $(BOARD_NAME)"
	@echo "Buildroot 配置: $(BUILDROOT_DEFCONFIG)"
	@echo "输出目录: $(BOARD_OUT_DIR)"
	@echo ""
	@mkdir -p "$(BOARD_OUT_DIR)"
	@cd "$(BUILDROOT_PATH)" && \
		cp "$(BUILDROOT_DEFCONFIG)" configs/board_defconfig && \
		make O="$(BOARD_OUT_DIR)" board_defconfig && \
		make O="$(BOARD_OUT_DIR)"

menuconfig:
	@echo "打开 Buildroot 配置菜单..."
	@if [ -n "$(BOARD_OUT_DIR)" ]; then \
		cd "$(BUILDROOT_PATH)" && make O="$(BOARD_OUT_DIR)" menuconfig; \
	else \
		cd "$(BUILDROOT_PATH)" && make menuconfig; \
	fi

clean:
	@if [ -n "$(BOARD_OUT_DIR)" ]; then \
		echo "清理 Buildroot 编译产物: $(BOARD_OUT_DIR)"; \
		rm -rf "$(BOARD_OUT_DIR)"/*; \
	else \
		cd "$(BUILDROOT_PATH)" && make clean; \
	fi

distclean:
	@if [ -n "$(BOARD_OUT_DIR)" ]; then \
		echo "完全清理 Buildroot: $(BOARD_OUT_DIR)"; \
		rm -rf "$(BOARD_OUT_DIR)"; \
	else \
		cd "$(BUILDROOT_PATH)" && make distclean; \
	fi
