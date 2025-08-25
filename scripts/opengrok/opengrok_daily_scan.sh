#!/bin/bash

# 配置执行时间点和命令
OPENGROK_DIR="/home/huang.liang29/workdir/tools/opengrok-1.14.1"
TIMES=("12:30" "17:50" "05:00" )
LOG_FILE="$OPENGROK_DIR/log/scheduler.log"

echo "定时执行器启动: $(date)" | tee -a "$LOG_FILE"

while true; do
    CURRENT_TIME=$(date +%H:%M)
	for TIME in "${TIMES[@]}"; do
		if [[ "$CURRENT_TIME" == "$TIME" ]]; then
			echo "$(date): 执行扫描 "
			$OPENGROK_DIR/opengrok.sh
			echo "$(date): 命令执行完成" | tee -a "$LOG_FILE"
			# 避免同一分钟重复执行
			sleep 60
			break
		fi

	done
	sleep 30
done

