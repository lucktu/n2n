#!/bin/bash
. init_logger.sh

EXTRACT() {
    extract_file="$1"
    extract_path="$2"
    extract_every="$3"
    LOG_INFO "Try: 解压文件 ${extract_file} - ${extract_path}"
    if [[ -z "${extract_file}" ]]; then
        LOG_ERROR_WAIT_EXIT "解压文件错误: extract_file - 为空"
    fi
    if [[ -d "${extract_file}" ]]; then
        LOG_ERROR_WAIT_EXIT "解压文件错误: 文件夹 - ${extract_file}"
    fi
    if [[ ! -f "${extract_file}" ]]; then
        LOG_ERROR_WAIT_EXIT "解压文件错误: 不存在 - ${extract_file}"
    fi
    extract_filename=${extract_file##*/}
    extract_filename_suffix=${extract_filename##*_}
    extract_filename_suffix=${extract_filename_suffix#*.}
    if [[ -z "${extract_path}" ]]; then
        extract_path=${extract_file%.${extract_filename_suffix}}
    fi
    LOG_INFO "解压文件 ${extract_file} - ${extract_path}"
    if [[ ! -d "${extract_path}" ]]; then
        mkdir -p "${extract_path}"
    fi
    fn_suffixs=${extract_filename_suffix}
    if [[ ! -z "${extract_every}" ]]; then
        fn_suffixs="tar,ar.gz,zip,rar,${extract_filename_suffix}"
    fi
    l_fn_suffixs=(${fn_suffixs//,/ })
    for fn_suffix in ${l_fn_suffixs[@]}; do
        case "${fn_suffix}" in
        tar)
            LOG_INFO 'try use tar'
            tar -xvf $extract_file -C ${extract_path}
            ;;
        tar.gz)
            LOG_INFO 'try use tar.gz'
            tar -zxvf $extract_file -C ${extract_path}
            ;;
        zip)
            LOG_INFO 'try use zip'
            unzip -o $extract_file -d ${extract_path}
            ;;
        rar)
            LOG_INFO 'try use rar'
            unrar x $extract_file ${extract_path}
            ;;
        *)
            LOG_ERROR "不支持文件类型 - ${extract_filename_suffix}"
            ;;
        esac
        if [[ -z "$(ls ${extract_path})" && -z "${extract_every}" ]]; then
            LOG_ERROR "解压失败 - ${extract_file}"
            # EXTRACT_EVERY
            EXTRACT ${extract_file} ${extract_path} 'true'
        fi
        if [[ ! -z "$(ls ${extract_path})" ]]; then
            LOG_WARNING "The real: ${fn_suffix} - ${extract_file}"
            break
        fi
    done
}

EXTRACT_ALL() {
    extract_file="$1"
    LOG_INFO "Try: 解压全部文件: ${extract_file}"
    if [[ -z "${extract_file}" ]]; then
        LOG_ERROR_WAIT_EXIT "解压全部错误: extract_file- 为空"
    fi
    if [[ ! -e "${extract_file}" ]]; then
        LOG_ERROR_WAIT_EXIT "解压全部错误: 不存在 - ${extract_file}"
    fi
    if [[ -f "${extract_file}" ]]; then
        EXTRACT "${extract_file}"
        # rm "${extract_file}"
        EXTRACT_ALL "${extract_path}"
    elif [[ -d "${extract_file}" ]]; then
        for extract_file in $(find ${extract_file} -type f | grep -E '(tar)|(rar)|(zip)'); do
            EXTRACT_ALL "${extract_file}"
        done
    fi
}

LOG_INFO "init_extract success"
