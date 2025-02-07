# 1. 基础命令
# 启动、退出和运行
gdb <program>     # 启动GDB
quit (q)          # 退出GDB
run (r)           # 运行程序
kill             # 终止当前程序

# 断点管理
break (b) [行号|函数名|条件]  # 设置断点
disable [断点号]              # 禁用断点
enable [断点号]               # 启用断点
delete (d) [断点号]           # 删除断点
clear                        # 删除所有断点

# 2. 执行控制
continue (c)     # 继续执行
step (s)         # 单步进入
next (n)         # 单步跨过
finish           # 运行到函数返回
until (u)        # 执行到指定行

# 3. 检查命令
print (p) <变量>     # 打印变量值
display <变量>       # 设置跟踪变量
info break          # 显示断点信息
info registers      # 显示寄存器
x/[格式] <地址>      # 检查内存
backtrace (bt)      # 显示调用栈
frame [帧号]         # 选择栈帧

# 4. 高级功能
watch <表达式>      # 监视变量变化
rwatch <表达式>     # 监视变量读取
awatch <表达式>     # 监视变量读写
catch [事件]        # 设置捕获点
commands           # 设置断点命令
define             # 定义命令

# 5. 线程调试
info threads               # 显示线程信息
thread <ID>               # 切换线程
thread apply [ID] [命令]   # 对线程执行命令
set scheduler-locking on  # 锁定线程调度

# 6. 条件控制
break [位置] if [条件]     # 条件断点
ignore [断点号] [次数]      # 忽略断点次数

# 7. 远程调试
target remote [主机:端口]   # 连接远程目标
load                      # 加载程序
symbol-file [文件]         # 加载符号表