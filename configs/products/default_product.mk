# 默认产品构建规则和参数

PRODUCT_NAME := default_product

# 定义支持的目标
TARGETS := tf-a uboot kernel buildroot rtthread all clean

# 默认目标
all: $(TARGETS)

# TF-A构建规则
tf-a:
	@echo "Building TF-A..."
	$(MAKE) -C ../src/tf-a

# U-Boot构建规则
uboot:
	@echo "Building U-Boot..."
	$(MAKE) -C ../src/uboot

# 内核构建规则
kernel:
	@echo "Building Kernel..."
	$(MAKE) -C ../src/kernel

# Buildroot构建规则
buildroot:
	@echo "Building Buildroot..."
	$(MAKE) -C ../src/buildroot

# RT-Thread构建规则
rtthread:
	@echo "Building RT-Thread..."
	$(MAKE) -C ../src/rtthread

# 清理目标
clean:
	@echo "Cleaning up..."
	$(MAKE) -C ../src/tf-a clean
	$(MAKE) -C ../src/uboot clean
	$(MAKE) -C ../src/kernel clean
	$(MAKE) -C ../src/buildroot clean
	$(MAKE) -C ../src/rtthread clean

.PHONY: $(TARGETS)