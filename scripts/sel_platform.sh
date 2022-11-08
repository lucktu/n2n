#!/bin/bash
. init_logger.sh

SEL_PLATFORM() {
    sel_machine=$1
    platform=''
    if [[ -z "${sel_machine}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: SEL_PLATFORM - sel_machine - 为空"
    fi

    case ${sel_machine} in
    x64)
        dn_machine="x64"
        fn_machine="x64"
        platform="linux/amd64"
        ;;
    x86)
        dn_machine="x86"
        fn_machine="x86"
        platform="linux/386"
        ;;
    arm64 | aarch64)
        dn_machine="arm64"
        fn_machine="arm64(aarch64)"
        platform="linux/arm64/v8"
        ;;
    arm64eb | aarch64eb)
        dn_machine="arm64eb"
        fn_machine="arm64eb(aarch64eb)"
        platform=
        ;;
    arm)
        dn_machine="arm"
        fn_machine="arm"
        platform="linux/arm/v7"
        ;;
    *)
        LOG_ERROR "不支持的CPU架构类型 - ${sel_machine}"
        dn_machine=${sel_machine}
        fn_machine=${sel_machine}
        ;;
    esac

    LOG_INFO "dn_machine: ${dn_machine}, fn_machine: ${fn_machine}, platform: ${platform}"
}
