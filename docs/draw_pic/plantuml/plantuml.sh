#!/bin/bash

# PlantUML 转换脚本
# 功能：将指定的 .puml 文件或所有 .puml 文件转换为 PNG 并保存到指定目

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

ROOT_DIR="$(pwd)"

# 显示帮助信息
show_help() {
    echo -e "${YELLOW}Usage:${NC}"
	echo "  ./plantuml.sh <input_file> <output_dir>"
	echo -e "${YELLOW}Parameters:${NC}"
	echo "  input_file 指定要转换的 .puml 文件 或 'all'（转换当前目录所有 .puml 文件）"
	echo "  output_dir 指定生成的 PNG 文件存放的目录"
	echo -e "${YELLOW}Examples:${NC}"
	echo "  ./plantuml.sh diagram.puml ./output"
	echo "  ./plantuml.sh all ./output"
	exit 0
}

check_dependencies() {
	if ! command -v plantuml &> /dev/null; then
		echo -e "${RED}错误: PlantUML 未安装${NC}"
		echo "请先执行: sudo apt install -y plantuml default-jdk"
		exit 1
	fi
}

# 检查并创建输出目录
prepare_output_dir() {
	local dir="$1"
    if [ ! -d "$dir" ]; then
		mkdir -p "$dir"
	fi
}

# 转换单个文件
convert_file() {
	local input_file="$1"
    local output_dir="$2"
	local base_name="${input_file##*/}"
    local file_name="${base_name%.puml}"
	local output_file="${output_dir}"

	echo -e "${GREEN}正在转换: ${input_file} -> ${output_file}"
	java -jar ./plantuml.jar  "$input_file" -o ${output_file}

}

convert_all() {
    local output_dir="$1"
	local puml_files=(*.puml)

	find "$ROOT_DIR" -type f -name "*.puml" | while read -r puml_file; do
		relative_path="${puml_file#$ROOT_DIR/}"
		output_subdir="$output_dir/$(dirname "$relative_path")"
		mkdir -p "$output_subdir"
		convert_file "$puml_file" "$output_subdir"
    done

}

main() {
    # 参数检查
    if [ $# -ne 2 ]; then
		show_help
    fi

	output_dir=$2
	output_dir=$(realpath "$output_dir")
	prepare_output_dir $output_dir

	 case "$1" in
        "all")
            convert_all "$output_dir"
            ;;
        *)
           convert_file "$1" "$output_dir"
            ;;
	esac
}

main "$@"
