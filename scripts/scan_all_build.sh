#!/bin/bash

. init_logger.sh
. init_path.sh
. scan_one_build.sh

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
    # e.g. v3_3.1.0-54_1127
    version_b_s_c=${version_file##*/}
    version_b_s_c=${version_b_s_c%%.txt}
    LOG_INFO "version_b_s_c: ${version_b_s_c}"
    SCAN_ONE_BUILD ${version_b_s_c}
done
