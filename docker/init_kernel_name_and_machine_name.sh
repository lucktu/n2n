#!/bin/bash
. init_logger.sh
. sel_platform.sh
### 自动识别系统类型
sel_os() {
    uos=$(uname -s | tr '[A-Z]' '[a-z]')
    case $uos in
    *linux*)
        myos="linux"
        ;;
    *)
        LOG_ERROR_WAIT_EXIT "识别失败的系统 - $uos"
        ;;
    esac
    LOG_INFO "识别成功的系统 - $myos"
}

### 自动识别CPU架构
sel_cpu() {
    ucpu=$(uname -m | tr '[A-Z]' '[a-z]')
    case $ucpu in
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
    *mips*)
        case $ucpu in
        mips | mipsel | mips64 | mips64el)
            mycpu=$ucpu
            ;;
        *)
            LOG_ERROR_WAIT_EXIT "分析失败的CPU架构类型 - 未知的 MIPS : $ucpu"
            ;;
        esac
        ;;
    *armv6l* | *armv7l*)
        mycpu="arm"
        ;;
    *aarch64*)
        mycpu="aarch64"
        ;;
    *riscv64*)
        mycpu="riscv64"
        ;;
    *)
        LOG_ERROR_WAIT_EXIT "分析失败的CPU架构类型 - $ucpu"
        ;;
    esac
    LOG_INFO "分析成功的CPU架构类型 - $mycpu"
}
myos=""
mycpu=""
sel_os
sel_cpu

if [[ -z ${KERNEL} ]]; then
    case ${myos} in
    linux)
        KERNEL="linux"
        ;;
    macosx)
        KERNEL="darwin"
        ;;
    windows)
        KERNEL="windows"
        ;;
    *)
        LOG_ERROR_WAIT_EXIT "不支持的系统 - ${myos}"
        ;;
    esac
    LOG_INFO "受支持的系统 - ${myos} -> ${KERNEL}"
fi

if [[ -z ${MACHINE} ]]; then
    case ${mycpu} in
    i386)
        MACHINE="x86"
        ;;
    amd64)
        MACHINE="x64"
        ;;
    arm)
        MACHINE="arm"
        ;;
    arm64 | aarch64)
        MACHINE="arm64"
        ;;
    armeb | mips | mips64 | mips64el | mipsel)
        MACHINE=$mycpu
        ;;
    *)
        LOG_ERROR_WAIT_EXIT "不支持的CPU架构类型 - ${mycpu}"
        ;;
    esac
    LOG_INFO "受支持的CPU架构类型 - ${mycpu} -> ${MACHINE}"
fi

SEL_PLATFORM $MACHINE
