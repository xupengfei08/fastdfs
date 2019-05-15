#!/bin/bash
#set -e

TRACKER_BASE_PATH="/fastdfs/tracker"
STORAGE_BASE_PATH="/fastdfs/storage"
STORAGE_DATA_BASE_PATH="/fastdfs/storage_data"
NGINX_PROXY_CACHE_PATH="/fastdfs/nginx/proxy_cache/tmp"

TRACKER_LOG_FILE="$TRACKER_BASE_PATH/logs/trackerd.log"
STORAGE_LOG_FILE="$STORAGE_BASE_PATH/logs/storaged.log"

CONF_BASE_PATH="/fdfs_conf"
TRACKER_BASE_CONF_FILE="$CONF_BASE_PATH/tracker.conf"
STORAGE_BASE_CONF_FILE="$CONF_BASE_PATH/storage.conf"
MOD_BASE_CONF_FILE="$CONF_BASE_PATH/mod_fastdfs.conf"

TRACKER_CONF_FILE="/etc/fdfs/tracker.conf"
STORAGE_CONF_FILE="/etc/fdfs/storage.conf"
MOD_CONF_FILE="/etc/fdfs/mod_fastdfs.conf"

if [  -f ${TRACKER_LOG_FILE} ]; then
        rm -rf ${TRACKER_LOG_FILE}
fi

if [  -f ${STORAGE_LOG_FILE} ]; then
        rm -rf ${STORAGE_LOG_FILE}
fi

if [ "$1" = 'sh' ]; then
        /bin/bash
fi

if [ "$1" = 'tracker' ]; then
        echo "start $1 ..."

        # 记录日志
        if [ ! -d "${TRACKER_BASE_PATH}/logs" ]; then
                mkdir "${TRACKER_BASE_PATH}/logs"
        fi
        touch  ${TRACKER_LOG_FILE}
        # ln -sf /dev/stdout "$TRACKER_LOG_FILE"

        # 完成配置文件
        mv ${TRACKER_BASE_CONF_FILE} ${TRACKER_CONF_FILE}

        # 启动服务
        fdfs_trackerd ${TRACKER_CONF_FILE}

        # delay wait for pid file
        while [ ! -f "${TRACKER_BASE_PATH}/data/fdfs_trackerd.pid" ]
        do
            sleep 3s
        done

        # tail -F --pid=`cat $TRACKER_BASE_PATH/data/fdfs_trackerd.pid`  $STORAGE_BASE_PATH/logs/trackerd.log
        # wait `cat $TRACKER_BASE_PATH/data/fdfs_trackerd.pid`
        tail -F --pid=`cat ${TRACKER_BASE_PATH}/data/fdfs_trackerd.pid`  /dev/null
fi

if [ "$1" = 'storage' ]; then
        echo "start $1 ..."

        # 记录日志
        if [ ! -d "$STORAGE_BASE_PATH/logs" ]; then
                mkdir "$STORAGE_BASE_PATH/logs"
        fi
        touch  "$STORAGE_LOG_FILE"
        # ln -sf /dev/stdout "$STORAGE_LOG_FILE"

        # 启动服务前配置文件可配置项
        # 指定此storage server所在组(卷)
        if [ ${GROUP_NAME} ]; then
            sed -i "s|^group_name=.*$|group_name=${GROUP_NAME}|g" ${STORAGE_BASE_CONF_FILE}
        fi

        # tracker server列表，有多个时，每个tracker server写一行
        if [ ${TRACKER_SERVER} ]; then
            sed -i "s|^tracker_server=.*$|tracker_server=${TRACKER_SERVER//,/\ntracker_server=}|g" ${STORAGE_BASE_CONF_FILE}
        fi

        # web server的端口
        if [ ${WEB_PORT} ]; then
            sed -i "s|^http.server_port=.*$|http.server_port=${WEB_PORT}|g" ${STORAGE_BASE_CONF_FILE}
        fi

        # 完成配置文件
        mv ${STORAGE_BASE_CONF_FILE} ${STORAGE_CONF_FILE}

        # 启动服务
        fdfs_storaged ${STORAGE_CONF_FILE}

        # 安装Nginx、fastdfs-nginx-module模块
        cd /usr/local/src

        # 解压nginx和fastdfs-nginx-module
        tar -zxvf nginx-1.10.3.tar.gz
        unzip fastdfs-nginx-module-master.zip

        # 进入nginx解压目录进行编译安装, 解压后fastdfs-nginx-module所在的位置
        cd nginx-1.10.3
        ./configure --prefix=/usr/local/nginx --add-module=/usr/local/src/fastdfs-nginx-module-master/src

        # 编译安装
        make && make install

        # 修改mod_fastdfs文件
        # 指定此storage server所在组(卷)
        if [ ${GROUP_NAME} ]; then
            sed -i "s|^group_name=.*$|group_name=${GROUP_NAME}|g" ${MOD_BASE_CONF_FILE}
        fi

        # tracker server列表，有多个时，每个tracker server写一行
        if [ ${TRACKER_SERVER} ]; then
            sed -i "s|^tracker_server=.*$|tracker_server=${TRACKER_SERVER//,/\ntracker_server=}|g" ${MOD_BASE_CONF_FILE}
        fi

        echo -e "\n\
[${GROUP_NAME:-group1}]\n\
group_name=${GROUP_NAME:-group1}\n\
storage_server_port=23000\n\
store_path_count=1\n\
store_path0=/fastdfs/storage_data\n\
        " >> ${MOD_BASE_CONF_FILE}

        # 完成配置文件
        mv ${MOD_BASE_CONF_FILE} ${MOD_CONF_FILE}

        # 复制FastDFS安装目录的部分配置文件到/etc/fdfs目录中
        cd /usr/local/src/fastdfs-5.11/conf
        cp http.conf  mime.types  /etc/fdfs/

        # 创建M00至storage存储目录的符号连接
        ln -s ${STORAGE_DATA_BASE_PATH}/data/ ${STORAGE_DATA_BASE_PATH}/data/M00

        # nginx服务配置
        echo -e "\
worker_processes  1;\n\
events {\n\
    worker_connections  1024;\n\
}\n\
http {\n\
    include       mime.types;\n\
    default_type  application/octet-stream;\n\
    sendfile on;\n\
    keepalive_timeout 65;\n\
    server {\n\
        listen ${WEB_PORT:-8888};\n\
        server_name localhost;\n\
        location ~ /group([0-9])/M00 {\n\
            ngx_fastdfs_module;\n\
        }\n\
    }\n\
}\n\
        " > /usr/local/nginx/conf/nginx.conf

        # 启动nginx服务
        /usr/local/nginx/sbin/nginx

        # delay wait for pid file
        while [ ! -f "${STORAGE_BASE_PATH}/data/fdfs_storaged.pid" ]
        do
            sleep 3s
        done
        # tail -F --pid=`cat $STORAGE_BASE_PATH/data/fdfs_storaged.pid`  $STORAGE_BASE_PATH/logs/storaged.log
        # wait -n `cat $STORAGE_BASE_PATH/data/fdfs_storaged.pid`
        tail -F --pid=`cat ${STORAGE_BASE_PATH}/data/fdfs_storaged.pid`  /dev/null
fi

if [ "$1" = 'nginx' ]; then
        echo "start $1 ..."

        cd /usr/local/src
        tar -zxvf nginx-1.10.3.tar.gz
        tar -zxvf ngx_cache_purge-2.3.tar.gz
        cd nginx-1.10.3
        ./configure --prefix=/usr/local/nginx --add-module=/usr/local/src/ngx_cache_purge-2.3
        make && make install

        # 缓存目录
        if [ ! -d "${NGINX_PROXY_CACHE_PATH}" ]; then
                mkdir -p "${NGINX_PROXY_CACHE_PATH}"
        fi

        # 启动服务
        /usr/local/nginx/sbin/nginx

        tail -F --pid=`cat /usr/local/nginx/logs/nginx.pid`  /dev/null
fi
