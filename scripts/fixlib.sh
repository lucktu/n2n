#!/bin/bash

. init_logger.sh
command_exists() {
    command -v "$@" >/dev/null 2>&1
}

if [[ $(/usr/local/sbin/edge -h 2>&1 | grep libcrypto.so.1.0.0) ]]; then
    if command_exists apt-get; then
        apt-get update
        apt-get install libssl1.0.0
        rm -rf /var/lib/apt/lists/*
    elif command_exists apt; then
        apk add --no-cache libssl1.0
    fi
fi

if [[ $(/usr/local/sbin/edge -h 2>&1 | grep /lib/ld-linux.so.3) ]]; then
    find / -name ld-linux*.so* | head -n 1 | xargs -I {} ln -sv {} /lib/ld-linux.so.3
fi
