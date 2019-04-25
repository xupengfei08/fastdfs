#!/bin/bash
# set -e

# 安装依赖包
yum -y install unzip make net-tools wget gcc perl-devel openssl-devel pcre-devel zlib-devel

# 编译安装 libfastcommon
cd /usr/local/src
unzip libfastcommon-1.0.36.zip
cd libfastcommon-1.0.36
./make.sh
./make.sh install

# 编译安装 fastdfs
cd /usr/local/src
unzip fastdfs-5.11.zip
cd fastdfs-5.11
./make.sh
./make.sh install

# 软连接 libfastcommon、libfdfsclient
ln -s /usr/lib64/libfastcommon.so /usr/local/lib/libfastcommon.so
ln -s /usr/lib64/libfdfsclient.so /usr/local/lib/libfdfsclient.so

# 初始化数据存储目录
mkdir -p /fastdfs/tracker && mkdir -p /fastdfs/storage && mkdir -p /fastdfs/storage_data
