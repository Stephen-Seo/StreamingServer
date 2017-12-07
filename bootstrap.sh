#!/bin/bash

if ! type gcc &>/dev/null; then
    sudo apt-get update
    sudo apt-get -y install \
        build-essential \
        libpcre3 \
        libpcre3-dev \
        libssl-dev \
        zlib1g-dev
fi

if [ ! -d /usr/local/nginx ]; then
    pushd /nginx

    ./configure --with-http_ssl_module --add-module=../nginx-rtmp-module
    make
    sudo make install

    popd
fi

if pgrep nginx &>/dev/null; then
    /usr/local/nginx/sbin/nginx -s stop
fi

(cat - > /usr/local/nginx/conf/nginx.conf) <<EOF
worker_processes 1;
events {
    worker_connections 1024;
}
rtmp {
    server {
        listen 1935;
        chunk_size 4096;

        application live {
            live on;
            record off;

            allow publish 192.168.5.0/24;
            deny publish all;
        }
    }
}
EOF

sudo /usr/local/nginx/sbin/nginx

