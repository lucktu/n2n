#!/bin/bash

. init_logger.sh

GET_FILE_INFOS() {
    s_file="$1"
    if [[ -z "${s_file}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: SAVE_FILE_INFOS - s_file - 为空"
    fi

    if [[ -d ${s_file} ]]; then
        LOG_WARNING "跳过: 是文件夹 - ${s_file}"
        return 1
    fi
    filename_suffix=${s_file##*.}
    if [[ -z ${filename_suffix} ]]; then
        LOG_ERROR_WAIT_EXIT "错误: 获取后缀失败 - ${s_file}"
        return 1
    fi
    if [[ ! 'rar zip tar.gz gz' =~ ${filename_suffix} ]]; then
        LOG_WARNING "跳过: 不是压缩文件 - ${s_file}"
        return 1
    fi

    src_machine=''
    src_machine_alias=''
    src_big_version=''
    src_small_version=''
    src_commit=''

    # e.g. n2n_v3_linux_x64_v3.1.1-16_r1200_all_by_heiye.rar
    s_file=${s_file##*/}
    LOG_INFO "s_file: ${s_file}"

    filename_no_suffix=${s_file%%.rar}
    filename_no_suffix=${filename_no_suffix%%.zip}
    filename_no_suffix=${filename_no_suffix%%.gz}
    filename_no_suffix=${filename_no_suffix%%.tar}

    # e.g. arm64 x64
    src_machine=${filename_no_suffix##*_linux_}
    src_machine=${src_machine%%_*}
    src_machine=${src_machine%%(*}
    if [[ -z "${src_machine}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: GET_FILE_INFOS: src_machine - 为空 - ${s_file}"
    fi
    LOG_INFO "src_machine: ${src_machine}"
    # e.g. v3
    src_big_version=${filename_no_suffix#*n2n_}
    src_big_version=${src_big_version%%_*}
    if [[ -z "${src_big_version}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: GET_FILE_INFOS: src_big_version - 为空 - ${s_file}"
    fi
    LOG_INFO "src_big_version: ${src_big_version}"

    # e.g. 3.1.1-16
    src_small_version=${filename_no_suffix##*_v}
    src_small_version=${src_small_version%%_*}
    if [[ -z "${src_small_version}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: GET_FILE_INFOS: src_small_version - 为空 - ${s_file}"
    fi
    LOG_INFO "src_small_version: ${src_small_version}"

    # e.g. 1200
    src_commit=${filename_no_suffix##*${src_small_version}}
    src_commit=${src_commit#*_}
    src_commit=${src_commit#*r}
    src_commit=${src_commit%%_*}
    if [[ -z "${src_commit}" ]]; then
        LOG_ERROR "请注意: GET_FILE_INFOS: src_commit - 为空 - ${s_file}"
        sleep 3
    fi
    LOG_INFO "src_commit: ${src_commit}"
    # e.g. aarch64
    src_machine_alias=${filename_no_suffix##*${src_machine}}
    src_machine_alias=${src_machine_alias%%_v${src_small_version}*}
    src_machine_alias=${src_machine_alias##*(}
    src_machine_alias=${src_machine_alias%%)*}
    if [[  $src_machine_alias ]];then
        LOG_ERROR src_machine_alias: $src_machine_alias
    fi

}

LOG_INFO "init GET_FILE_INFOS success - $(caller)"
