#!/bin/bash

# Dot 转换脚本
# 功能：将指定的 .dot 文件或所有 .dot 文件转换为 PNG 并保存到指定目录

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

ROOT_DIR="$(pwd)"

# 显示帮助信息
show_help() {
    echo -e "${YELLOW}Usage:${NC}"
    echo "  ./dot.sh <input_file> <output_dir>"
    echo ""
    echo -e "${YELLOW}Parameters:${NC}"
    echo "  input_file 指定要转换的 .dot 文件 或 'all'（转换当前目录所有 .dot 文件）"
    echo "  output_dir 指定生成的 PNG 文件存放的目录"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  ./dot.sh diagram.dot ./output"
    echo "  ./dot.sh all ./output"
    echo ""
    exit 0
}

# 检查依赖
check_dependencies() {
    if ! command -v dot &> /dev/null; then
        echo -e "${RED}错误: Dot 未安装${NC}"
        echo "请先执行: sudo apt install graphviz"
        exit 1
    fi
}

prepare_output_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo -e "${YELLOW}创建输出目录: ${dir}${NC}"
        mkdir -p "$dir" || {
            echo -e "${RED}错误: 无法创建目录 ${dir}${NC}"
            exit 1
        }
    fi
}

convert_file() {
    local input_file="$1"
    local output_dir="$2"
    local base_name="${input_file##*/}"
    local file_name="${base_name%.dot}"
    local output_file="${output_dir}/${file_name}.png"

    if [ ! -f "$input_file" ]; then
        echo -e "${RED}错误: 文件 ${input_file} 不存在${NC}"
        return 1
    fi

    if [[ "$base_name" != *.dot ]]; then
        echo -e "${RED}错误: 文件 ${input_file} 不是 .dot 文件${NC}"
        return 1
    fi

    echo -e "${GREEN}正在转换: ${input_file} -> ${output_file}.png${NC}"

    dot -Tpng "$input_file" -o ${output_file}

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}成功: ${output_file}.png 已生成${NC}"
    else
        echo -e "${RED}错误: 转换 ${input_file} 失败${NC}"
    fi
}

convert_all() {
    local output_dir="$1"
    local dot_files=(*.dot)

    if [ ${#dot_files[@]} -eq 0 ]; then
        echo -e "${YELLOW}警告: 当前目录没有 .dot 文件${NC}"
        return 1
    fi

	find "$ROOT_DIR" -type f -name "*.dot" | while read -r dot_file; do
		relative_path="${dot_file#$ROOT_DIR/}"
		output_subdir="$output_dir/$(dirname "$relative_path")"
		mkdir -p "$output_subdir"
        convert_file "$dot_file" "$output_subdir"
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

    #check_dependencies
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
# 执行主函数
main "$@"
# 结束脚本
