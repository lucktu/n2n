#!/bin/bash

. init_logger.sh
. init_path.sh
. get_file_infos.sh
. scan_all_save.sh
. sel_platform.sh

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
    LOG_INFO "build_big_version: ${build_big_version}"
    # e.g. v3
    build_big_version=${version_b_s_c%%_*}
    if [[ -z "${build_big_version}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: GET_FILE_INFOS: build_big_version - 为空 - ${version_file}"
    fi
    # e.g. 3.1.0-54
    build_small_version=${version_b_s_c##*${build_big_version}_}
    build_small_version=${build_small_version%%_*}
    if [[ -z "${build_small_version}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: GET_FILE_INFOS: build_small_version - 为空 - ${version_file}"
    fi
    LOG_INFO "build_small_version: ${build_small_version}"
    # e.g. 1127
    build_commit=${version_b_s_c##*${build_small_version}}
    build_commit=${build_commit#_}
    if [[ -z "${build_commit}" ]]; then
        LOG_ERROR "请注意: GET_FILE_INFOS: build_commit - 为空 - ${version_file}"
        sleep 3
    fi
    LOG_INFO "build_commit: ${build_commit}"
    build_platforms=''
    rm $BUILD_SRC/*
    for src_file in $(find ${PROJECT_DIR}/Linux -name *${build_big_version}*${build_small_version}*${build_commit}* | grep -v Professional); do
        GET_FILE_INFOS ${src_file}
        if [[ ${build_big_version} != ${src_big_version} || ${build_small_version} != ${src_small_version} || ${build_commit} != ${src_commit} ]]; then
            LOG_WARNING "版本未匹配: ${version_filename} - ${src_file}"
        fi
        cp $src_file $BUILD_SRC/
        SEL_PLATFORM ${src_machine}
        if [[ ! ${build_platforms} =~ ${platform} ]]; then
            build_platforms="${build_platforms}, platform"
        fi
    done
    export REGISTRY='https://registry.aour.zctmdc.cn/'
    export BUILD_PLATFORMS=["${build_platforms}]"
    export BIG_VERSION=${build_big_version}
    export SMALL_VERSION=${build_small_version}
    export COMMIT=${build_big_version}
    export BIG_VERSION=${build_big_version}
    docker compose build
    docker compose push
    docker compose run n2n_evn_BIG_VERSION_SMALL_VERSION_rCOMMIT edge -h >$BUILD_DESC/${version_b_s_c}_edge_help.txt
    docker compose run n2n_evn_BIG_VERSION_SMALL_VERSION_rCOMMIT supernode -h >$BUILD_DESC/${version_b_s_c}_supernode_help.txt
    
done