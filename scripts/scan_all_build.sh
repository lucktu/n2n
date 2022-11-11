#!/bin/bash

. init_logger.sh
. init_path.sh
. scan_one_build.sh
build_version_b_s_rcs=''
for version_filename in $(ls ${RESULT_DIR}); do
    version_file=${RESULT_DIR}/${version_filename}

    if [[ -d ${version_file} ]]; then
        LOG_WARNING "跳过: 是文件夹 - ${version_file}"
        continue
    fi
    if [[ ${version_filename} == 'all.txt' ]]; then
        LOG_WARNING "跳过: 汇总文件 - ${version_file}"
        continue
    fi
    LOG_INFO "version_file: ${version_file}"
    if [[ -z "$(cat ${version_file} | grep -vE '(eb)|(mips)')" ]]; then
        LOG_WARNING "跳过:  不支持的CPU架构类型 - ${version_file} $(cat ${version_file})"
        continue
    fi
    # e.g. v3_3.1.0-54_1127
    version_b_s_rc=${version_file##*/}
    version_b_s_rc=${version_b_s_rc%%.txt}
    LOG_INFO "version_b_s_rc: ${version_b_s_rc}"
    SCAN_ONE_BUILD ${version_b_s_rc}
    if [[ -n "${BUILD_PLATFORMS}" ]]; then
        build_version_b_s_rcs="${build_version_b_s_rcs},${BUILD_VERSION_B_S_rC}"
    fi
done
build_version_b_s_rcs=${build_version_b_s_rcs:1}
