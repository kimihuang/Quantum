# 顶层Makefile，用于编译 Buildroot
# 注意：此 Makefile 需要先执行 source build/envsetup.sh && lunch 选择板卡



# buildroot 源码路径由环境变量 BUILDROOT_DIR 提供
# 注意：必须先执行 source build/envsetup.sh 才能使用此变量

# 板卡配置文件路径和环境变量（由 envsetup.sh 和 lunch 设置）
# BR2_EXTERNAL_DIR: Buildroot 外部扩展目录（如 board/board_qemu_a/br2_external）
#                   defconfig 存放在 BR2_EXTERNAL_DIR/configs/buildroot_defconfig
# BOARD_OUT_DIR: 板卡输出目录（如 out/board_qemu_a）
# 以上变量必须通过 lunch 选择板卡后才能使用

# 日志目录（基于板卡输出目录）
BOARD_LOG_DIR ?= $(BOARD_OUT_DIR)/log
TIMESTAMP ?= $(shell date +%Y%m%d_%H%M%S)
LOG_FILE := $(BOARD_LOG_DIR)/buildroot_log_$(TIMESTAMP).log

# 如果没有指定目标，默认编译 Buildroot
.DEFAULT_GOAL := all

.PHONY: all help menuconfig

all:
	@if [ -z "$(BOARD_NAME)" ]; then \
		echo "错误: 未选择板卡配置，请先执行: source build/envsetup.sh && lunch"; \
		exit 1; \
	fi
	@mkdir -p "$(BOARD_OUT_DIR)" "$(BOARD_LOG_DIR)"
	@echo "开始编译 Buildroot..."
	@echo "板卡: $(BOARD_NAME)"
	@echo "输出目录: $(BOARD_OUT_DIR)"
	@echo "外部扩展目录: $(BR2_EXTERNAL_DIR)"
	@echo "日志目录: $(BOARD_LOG_DIR)"
	@echo ""
	@echo "注意: Buildroot 配置已在 lunch 时完成"
	$(MAKE) -C "$(BUILDROOT_DIR)" O="$(BOARD_OUT_DIR)" BR2_EXTERNAL="$(BR2_EXTERNAL_DIR)" 2>&1 | tee "$(LOG_FILE)"

# menuconfig 不使用 tee，避免 TUI 界面显示异常
menuconfig:
	@if [ -z "$(BOARD_NAME)" ]; then \
		echo "错误: 未选择板卡配置，请先执行: source build/envsetup.sh && lunch"; \
		exit 1; \
	fi
	@mkdir -p "$(BOARD_OUT_DIR)" "$(BOARD_LOG_DIR)"
	@$(MAKE) -C "$(BUILDROOT_DIR)" O="$(BOARD_OUT_DIR)" BR2_EXTERNAL="$(BR2_EXTERNAL_DIR)" menuconfig

# 接受任意参数并传递给 Buildroot
# 对于 *-menuconfig 目标，不使用 tee，避免 TUI 界面显示异常
%-menuconfig:
	@if [ -z "$(BOARD_NAME)" ]; then \
		echo "错误: 未选择板卡配置，请先执行: source build/envsetup.sh && lunch"; \
		exit 1; \
	fi
	@mkdir -p "$(BOARD_OUT_DIR)" "$(BOARD_LOG_DIR)"
	@$(MAKE) -C "$(BUILDROOT_DIR)" O="$(BOARD_OUT_DIR)" BR2_EXTERNAL="$(BR2_EXTERNAL_DIR)" $@

# 接受其他任意参数并传递给 Buildroot
%:
	@if [ -z "$(BOARD_NAME)" ]; then \
		echo "错误: 未选择板卡配置，请先执行: source build/envsetup.sh && lunch"; \
		exit 1; \
	fi
	@mkdir -p "$(BOARD_OUT_DIR)" "$(BOARD_LOG_DIR)"
	@echo "执行 Buildroot 目标: $@"
	$(MAKE) -C "$(BUILDROOT_DIR)" O="$(BOARD_OUT_DIR)" BR2_EXTERNAL="$(BR2_EXTERNAL_DIR)" $@ 2>&1 | tee "$(LOG_FILE)"

help:
	@echo "可用目标:"
	@echo "  make 或 make all       - 编译 Buildroot (默认)"
	@echo ""
	@echo "  或者直接使用任何 Buildroot 支持的目标，例如:"
	@echo "  make menuconfig          - 打开 Buildroot 配置菜单"
	@echo "  make clean               - 清理编译产物"
	@echo "  make distclean           - 完全清理"
	@echo "  make linux-menuconfig    - 打开 Linux 内核配置菜单"
	@echo "  make linux-rebuild       - 重新编译 Linux 内核"
	@echo "  make busybox-menuconfig  - 打开 Busybox 配置菜单"
	@echo "  make uboot-rebuild       - 重新编译 U-Boot"
