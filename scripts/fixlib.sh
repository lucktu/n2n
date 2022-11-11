#!/bin/bash

. init_logger.sh
command_exists() {
    command -v "$@" >/dev/null 2>&1
}

if [[ $(/usr/local/sbin/edge -h 2>&1 | grep libcrypto.so.1.0.0) ]]; then
    LOG_WARNING 缺少 libssl1.0.0 , 正在修复
    if command_exists apt-get; then
        apt-get update
        apt-get install -y libssl1.0.0
        rm -rf /var/lib/apt/lists/*
    elif command_exists apt; then
        apk add --no-cache --upgrade libssl1.0
    fi
    LOG_WARNING 缺少 libssl1.0.0 , 修复完毕
fi

if [[ $(/usr/local/sbin/edge -h 2>&1 | grep /lib/ld-linux.so.3) ]]; then
    LOG_WARNING 缺少 /lib/ld-linux.so.3 , 正在修复
    find / -name ld-linux*.so* | head -n 1 | xargs -I {} ln -sv {} /lib/ld-linux.so.3
    LOG_WARNING 缺少 /lib/ld-linux.so.3 , 修复完毕
fi
