#!/bin/bash

. init_logger.sh

down_url_path=https://www.rarlab.com/rar
filename_unrar_i386=unrar_5.2.5-0.1_i386.deb
filename_unrar_amd64=unrar_5.2.5-0.1_amd64.deb

ucpu="$(uname -m | tr '[A-Z]' '[a-z]')"
mycpu=""
case "${ucpu}" in
*i386* | *i486* | *i586* | *i686* | *bepc* | *i86pc*)
    mycpu="i386"
    ;;
*amd*64* | *x86-64* | *x86_64*)
    case $(getconf LONG_BIT) in
    64)
        mycpu="amd64"
        ;;
    32)
        mycpu="i386"
        ;;
    esac
    ;;
esac
LOG_INFO "ucpu: ${ucpu}, mycpu: ${mycpu}"
if [[ "${mycpu}" == "i386" || "${mycpu}" == "amd64" ]]; then
    case ${mycpu} in
    i386)
        down_url="${down_url_path}/${filename_unrar_i386}"
        ;;
    amd64)
        down_url="${down_url_path}/${filename_unrar_amd64}"
        ;;
    esac
    if [[ -z "${down_url}" ]]; then
        LOG_ERROR_WAIT_EXIT "down_url 获取失败"

    fi
    rar_down_dir="/tmp/rar"
    down_filename="${rar_down_dir}/${down_url##*/}"
    LOG_INFO "Try: 下载 - ${down_url}"
    mkdir "${rar_down_dir}"
    wget --no-check-certificate -q ${down_url} -O "${down_filename}"
    if [[ $? != 0 ]]; then
        LOG_ERROR_WAIT_EXIT "下载失败: ${down_url}"
    fi
    dpkg -i "${down_filename}"
    LOG_INFO "install_rar success"
fi
