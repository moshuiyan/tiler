#!/bin/bash

# 检查Go是否已安装
if ! command -v go &> /dev/null
then
    echo "Go 未安装，请先安装Go"
    exit 1
fi

# 检查Go版本
GO_VERSION=$(go version | cut -d ' ' -f 3)
REQUIRED_VERSION="go1.15"

if [[ "$GO_VERSION" < "$REQUIRED_VERSION" ]]
then
    echo "Go版本过低，需要至少$REQUIRED_VERSION"
    exit 1
fi

# 设置工作目录
WORK_DIR=$(pwd)

# 编译项目
echo "开始编译项目..."
go build -o tiler main.go map.go task.go tile.go utils.go

# 检查编译是否成功
if [ -f "tiler" ]
then
    echo "编译成功！"
else
    echo "编译失败！"
    exit 1
fi

# 复制必要的文件
echo "复制必要的文件..."
cp -f conf.toml tiler.conf

# 打包
echo "开始打包..."
TAR_FILE="tiler_linux_$(date +%Y%m%d).tar.gz"
tar -czvf $TAR_FILE tiler tiler.conf README.md README-EN.md geojson/

# 检查打包是否成功
if [ -f "$TAR_FILE" ]
then
    echo "打包成功：$TAR_FILE"
else
    echo "打包失败！"
    exit 1
fi

echo "构建完成！"
exit 0