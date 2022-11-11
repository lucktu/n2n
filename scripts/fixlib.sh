#!/bin/bash

. init_logger.sh

if [[ $(/usr/local/sbin/edge -h 2>&1 | grep libcrypto.so.1.0.0) ]]; then
    apt-get update
    apt-get install libssl1.0.0
    rm -rf /var/lib/apt/lists/*
fi

if [[ $(/usr/local/sbin/edge -h 2>&1 | grep /lib/ld-linux.so.3) ]]; then
    find / -name ld-linux*.so* | head -n 1 | xargs -I {} ln -sv {} /lib/ld-linux.so.3
fi
