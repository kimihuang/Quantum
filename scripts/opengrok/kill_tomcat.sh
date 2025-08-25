#!/bin/bash

# 查找并终止Tomcat进程
pids=$(ps aux | grep -i 'org.apache.catalina.startup.Bootstrap' | awk '{print $2}')

if [ -z "$pids" ]; then
	 echo "未找到Tomcat进程"
	 exit 0
fi

echo "发现Tomcat进程(PID): $pids"
kill -9 $pids 2>/dev/null && echo "已终止进程" || echo "终止失败"
