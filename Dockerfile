FROM centos:7.4.1708

LABEL maintainer="xupengfei08@163.com"

COPY ./src/* /usr/local/src/

COPY ./conf/* /fdfs_conf/

COPY ./entrypoint.sh /

VOLUME ["/fastdfs"]

WORKDIR /usr/local/src

RUN chmod +x init.sh && ./init.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]