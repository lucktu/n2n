#!/bin/bash

. init_logger.sh

flag_retry="$1"
command_exists() {
    command -v "$@" >/dev/null 2>&1
}
get_distribution() {
    lsb_dist=""
    # Every system that we officially support has /etc/os-release
    if [ -r /etc/os-release ]; then
        lsb_dist="$(. /etc/os-release && echo "$ID")"
    fi
    # Returning an empty string here should be alright since the
    # case statements don't act unless you provide an actual value
    echo "$lsb_dist"
}

get_lsb_dist() {
    lsb_dist=$(get_distribution)
    lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
    echo "${lsb_dist}"
}
is_debian() {
    echo $(get_lsb_dist) | grep debian >/dev/null 2>&1
}

is_debian8() {
    cat /etc/os-release | grep jessie >/dev/null 2>&1
}
if [[ -n "$(/usr/local/sbin/edge -h 2>&1 | grep /lib/ld-linux.so.3)" ]]; then
    LOG_WARNING 缺少 /lib/ld-linux.so.3 , 正在修复
    find / -name ld-linux*.so* | head -n 1 | xargs -I {} ln -sv {} /lib/ld-linux.so.3
    LOG_WARNING 缺少 /lib/ld-linux.so.3 , 修复完毕
fi

if [[ -n "$(/usr/local/sbin/edge -h 2>&1 | grep libcrypto.so.1.0.0)" ]]; then
    LOG_WARNING 缺少 libssl1.0.0 , 正在修复
    if command_exists apt-get; then
        if is_debian && ! is_debian8; then
            echo 'deb http://security.debian.org/debian-security jessie/updates main' >/etc/apt/sources.list.d/debian8.list
        fi
        apt-get update
        apt-get install -y libssl1.0.0
        if is_debian && ! is_debian8; then
            rm -f /etc/apt/sources.list.d/debian8.list
        fi
    elif command_exists apt; then
        apk add --no-cache --upgrade libssl1.0
    fi
    LOG_WARNING 缺少 libssl1.0.0 , 修复完毕
fi

if [[ -n "$(/usr/local/sbin/edge -h 2>&1 | grep libcrypto.so.1.1)" ]]; then
    LOG_WARNING 缺少 libssl1.1 , 正在修复
    if command_exists apt-get; then
        if is_debian8; then
            echo 'deb http://security.debian.org/debian-security stretch/updates main' >/etc/apt/sources.list.d/debian9.list
        fi
        apt-get update
        apt-get install -y libssl1.1
        if is_debian8; then
            rm -f /etc/apt/sources.list.d/debian9.list
        fi

    elif command_exists apt; then
        # 自带
        apk add --no-cache --upgrade libssl1.1
    fi
    LOG_WARNING 缺少 libssl1.1 , 修复完毕
fi
edge_result="$(edge -h 2>&1 | xargs -I {} echo {})"

if [[ -z "$(echo ${edge_result,,} | grep welcome)" && -z "${flag_retry}" ]]; then
    LOG_ERROR 出错了: ${edge_result}
    . /tmp/n2n-lucktu/scripts/fixlib.sh retry
else
    apt-get clean && rm -rf /var/lib/apt/lists/*
    LOG_INFO 修复结束
fi
