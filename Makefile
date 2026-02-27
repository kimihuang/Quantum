# 顶层Makefile，用于编译 Buildroot
# 注意：此 Makefile 需要先执行 source build/envsetup.sh 和 lunch 选择板卡



# buildroot 源码路径由环境变量 BUILDROOT_DIR 提供
# 注意：必须先执行 source build/envsetup.sh 才能使用此变量

# 板卡配置文件路径和环境变量（由 envsetup.sh 和 lunch 设置）
# BUILDROOT_DEFCONFIG: 板卡特定的 Buildroot 配置文件
# BOARD_OUT_DIR: 板卡输出目录（如 out/board_qemu_a）
# 以上变量必须通过 lunch 选择板卡后才能使用

# 日志目录（基于板卡输出目录）
BOARD_LOG_DIR ?= $(BOARD_OUT_DIR)/log

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
	@mkdir -p "$(BOARD_OUT_DIR)" "$(BOARD_LOG_DIR)"
	@echo "开始编译 Buildroot..."
	@echo "板卡: $(BOARD_NAME)"
	@echo "Buildroot 配置: $(BUILDROOT_DEFCONFIG)"
	@echo "输出目录: $(BOARD_OUT_DIR)"
	@echo "日志目录: $(BOARD_LOG_DIR)"
	@echo ""
	@cp "$(BUILDROOT_DEFCONFIG)" "$(BUILDROOT_DIR)/configs/board_defconfig"
	$(MAKE) -C "$(BUILDROOT_DIR)" O="$(BOARD_OUT_DIR)" board_defconfig 2>&1 | tee "$(BOARD_LOG_DIR)/log_$$(date +%Y%m%d_%H%M%S).log"
	$(MAKE) -C "$(BUILDROOT_DIR)" O="$(BOARD_OUT_DIR)" 2>&1 | tee "$(BOARD_LOG_DIR)/log_$$(date +%Y%m%d_%H%M%S).log"

menuconfig:
	@echo "打开 Buildroot 配置菜单..."
	@if [ -n "$(BOARD_OUT_DIR)" ]; then \
		$(MAKE) -C "$(BUILDROOT_DIR)" O="$(BOARD_OUT_DIR)" menuconfig; \
	else \
		$(MAKE) -C "$(BUILDROOT_DIR)" menuconfig; \
	fi

clean:
	@if [ -n "$(BOARD_OUT_DIR)" ]; then \
		echo "清理 Buildroot 编译产物: $(BOARD_OUT_DIR)"; \
		rm -rf "$(BOARD_OUT_DIR)"/*; \
	else \
		$(MAKE) -C "$(BUILDROOT_DIR)" clean; \
	fi

distclean:
	@if [ -n "$(BOARD_OUT_DIR)" ]; then \
		echo "完全清理 Buildroot: $(BOARD_OUT_DIR)"; \
		rm -rf "$(BOARD_OUT_DIR)"; \
	else \
		$(MAKE) -C "$(BUILDROOT_DIR)" distclean; \
	fi
