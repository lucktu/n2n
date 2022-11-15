#!/bin/bash

# 扫描`Linux`目录下所有文件
# 解析版本信息保存至 `result` 文件夹下

. init_logger.sh
. init_path.sh
. save_file_infos.sh


# scan_dirs="Linux Linux/n2n_v1 Linux/n2n_v2 Linux/n2n_v2s"
# for old_dir in $(ls ${PROJECT_ROOT_DIR}/Linux/Old); do
#     scan_dirs="${scan_dirs} Linux/Old/${old_dir}"
# done

scan_dirs="Linux"
for big_version_dir in $(ls ${PROJECT_ROOT_DIR}/Linux/); do
    scan_dir="${PROJECT_ROOT_DIR}/Linux/${big_version_dir}"
    if [[ ! -d "${scan_dir}" ]]; then
        LOG_WARNING "跳过: 不是文件夹 - ${scan_dir}"
        continue
    fi
    if [[ -z "$(echo ${scan_dir#*${PROJECT_ROOT_DIR}/Linux/} | grep -E '^n2n_v[0-9]s?$')" ]]; then
        LOG_WARNING "跳过: 未匹配 - ${scan_dir}"
        continue
    fi
    scan_dirs="${scan_dirs} Linux/${big_version_dir}"
done
for old_dir in $(ls ${PROJECT_ROOT_DIR}/Linux/Old); do
    scan_dir="${PROJECT_ROOT_DIR}/Linux/Old/${old_dir}"
    if [[ ! -d "${scan_dir}" ]]; then
        LOG_WARNING "SKIP: 不是文件夹 - ${scan_dir}"
        continue
    fi
    scan_dirs="${scan_dirs} Linux/Old/${old_dir}"
done

LOG_INFO scan_dirs: ${scan_dirs}

for scan_dir in ${scan_dirs[@]}; do
    s_dir=${PROJECT_ROOT_DIR}/${scan_dir}
    LOG_INFO s_dir: ${s_dir}

    if [[ ! -d ${s_dir} ]]; then
        LOG_WARNING "跳过: 不是文件夹 - ${s_dir}"
        continue
    fi

    for src_file in $(ls ${s_dir}); do
        s_file=${s_dir}/${src_file}
        if [[ -d ${s_file} ]]; then
            LOG_WARNING "跳过: 是文件夹 - ${s_file}"
            continue
        fi
        LOG_INFO s_file: ${s_file}
        LOG_INFO "当前文件: ${s_file}"
        GET_FILE_INFOS ${s_file}
        SAVE_FILE_INFOS ${s_file}
    done
done
