#!/bin/bash

# 编译 RT-Thread
echo "开始编译 RT-Thread..."

# 进入 RT-Thread 源码目录
cd ../src/rtthread

# 执行编译命令
make

# 检查编译结果
if [ $? -eq 0 ]; then
    echo "RT-Thread 编译成功！"
else
    echo "RT-Thread 编译失败！"
    exit 1
fi

# 输出编译产物到 out 目录
cp -r build/* ../../out/

echo "RT-Thread 编译产物已输出到 out 目录。"