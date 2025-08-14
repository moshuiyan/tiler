#!/bin/bash

# 目录统计脚本 - 统计文件数量和大小
# 用法: ./dir_stats_fast.sh [目录路径]
# 如果不提供路径，默认统计当前目录

# 获取目标目录
TARGET_DIR="${1:-.}"

# 检查目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
    echo "错误: 目录 '$TARGET_DIR' 不存在"
    exit 1
fi

# 转换为绝对路径用于显示
ABS_PATH=$(cd "$TARGET_DIR" && pwd)

echo "目录统计报告"
echo "=============="
echo "时间: $(date)"
echo "目标目录: $ABS_PATH"
echo ""

# 进入目标目录
cd "$TARGET_DIR" || exit 1

# 统计当前目录总计
echo "目录总计:"
total_files=$(find . -type f | wc -l)
total_size=$(du -sh . | cut -f1)
echo "  总文件数: $total_files"
echo "  总大小: $total_size"
echo ""

echo "各子目录统计:"
echo "目录名称                文件数量        大小"
echo "------------------------------------------------"

# 各子目录统计
for dir in */; do
    if [ -d "$dir" ]; then
        dir_name=${dir%/}
        
        # 并行统计文件数量和大小
        {
            file_count=$(find "$dir" -type f | wc -l)
            size=$(du -sh "$dir" | cut -f1)
            printf "%-20s %12s %12s\n" "$dir_name" "$file_count" "$size"
        } &
        
        # 控制并发数，避免系统过载
        if (( $(jobs -r | wc -l) >= 4 )); then
            wait  # 等待所有后台任务完成
        fi
    fi
done

# 等待所有后台任务完成
wait

echo ""
echo "统计完成!"