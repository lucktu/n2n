#!/bin/bash
. init_logger.sh

SEL_PLATFORM() {
    sel_machine=$1
    platform=''
    dn_machine=''
    fn_machine=''

    if [[ -z "${sel_machine}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: SEL_PLATFORM - sel_machine - 为空"
    fi

    case ${sel_machine} in
    x64 | amd64)
        dn_machine="x64"
        fn_machine="x64"
        platform="linux/amd64"
        ;;
    x86 | 386)
        dn_machine="x86"
        fn_machine="x86"
        platform="linux/386"
        ;;
    arm64 | aarch64 | arm64/v8)
        dn_machine="arm64"
        fn_machine="arm64"
        platform="linux/arm64/v8"
        ;;
    arm64eb | aarch64eb)
        dn_machine="arm64eb"
        fn_machine="arm64eb"
        platform=${sel_machine}
        ;;
    arm | arm/v7)
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
