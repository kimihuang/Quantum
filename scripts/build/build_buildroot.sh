#!/bin/bash

# 进入Buildroot源代码目录
cd ../src/buildroot

# 设置Buildroot的输出目录
export BR2_OUTPUT=../../build

# 执行Buildroot的编译
make

# 将编译产物移动到输出目录
mv output/images/* ../../out/