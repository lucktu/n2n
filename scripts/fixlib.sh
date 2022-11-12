#!/bin/bash

. init_logger.sh
command_exists() {
    command -v "$@" >/dev/null 2>&1
}

if [[ -n "$(/usr/local/sbin/edge -h 2>&1 | grep /lib/ld-linux.so.3)" ]]; then
    LOG_WARNING 缺少 /lib/ld-linux.so.3 , 正在修复
    find / -name ld-linux*.so* | head -n 1 | xargs -I {} ln -sv {} /lib/ld-linux.so.3
    LOG_WARNING 缺少 /lib/ld-linux.so.3 , 修复完毕
fi

if [[ -n "$(/usr/local/sbin/edge -h 2>&1 | grep libcrypto.so.1.0.0)" ]]; then
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

if [[ -n "$(/usr/local/sbin/edge -h 2>&1 | grep libcrypto.so.1.1)" ]]; then
    LOG_WARNING 缺少 libssl1.1 , 正在修复
    if command_exists apt-get; then
        apt-get update
        apt-get install -y libssl1.1
        rm -rf /var/lib/apt/lists/*
    elif command_exists apt; then
        # 自带 
        apk add --no-cache --upgrade libssl1.1
    fi
    LOG_WARNING 缺少 libssl1.1 , 修复完毕
fi

if [[ -z "$(echo ${edge_result,,} | grep welcome)" ]];then
    LOG_ERROR 出错了: ${edge_result}
    sh -c /tmp/n2n-lucktu/scripts/fixlib.sh 
fi