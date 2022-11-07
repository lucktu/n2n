#!/bin/bash

. init_logger.sh
. sel_platform.sh
. init_path.sh
. get_file_infos.sh

SCAN_ONE_BUILD() {
    # 一个版本
    version_b_s_rc=$1
    if [[ -z "${version_b_s_rc}" || ! -z "${BIG_VERSION}" || ! -z "${SMALL_VERSION}" ]]; then
        LOG_WARNING "use env version"
        version_b_s_rc="${BIG_VERSION}_${SMALL_VERSION}${COMMIT:+_r}${COMMIT}"
    fi
    if [[ -z "${version_b_s_rc}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: SCAN_ONE_BUILD - version_b_s_rc - 为空"
    fi

    LOG_INFO "version_b_s_rc: ${version_b_s_rc}"
    # e.g. v3
    build_big_version=${version_b_s_rc%%_*}
    if [[ -z "${build_big_version}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: GET_FILE_INFOS: build_big_version - 为空 - ${version_file}"
    fi
    LOG_INFO "build_big_version: ${build_big_version}"
    # e.g. 3.1.0-54
    build_small_version=${version_b_s_rc##*${build_big_version}_}
    build_small_version=${build_small_version%%_*}
    if [[ -z "${build_small_version}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: GET_FILE_INFOS: build_small_version - 为空 - ${version_file}"
    fi
    LOG_INFO "build_small_version: ${build_small_version}"
    # e.g. 1127
    build_commit=${version_b_s_rc##*${build_small_version}}
    build_commit=${build_commit#_}
    build_commit=${build_commit#r}
    if [[ -z "${build_commit}" ]]; then
        LOG_ERROR "请注意: GET_FILE_INFOS: build_commit - 为空 - ${version_file}"
        sleep 3
    fi
    LOG_INFO "build_commit: ${build_commit}"
    build_platforms=''
    if [[ -d $BUILD_SRC ]]; then
        rm -r $BUILD_SRC
    fi
    mkdir -p $BUILD_SRC
    need_files=''
    for src_file in $(find ${PROJECT_ROOT_DIR}/Linux -name *${build_big_version}*${build_small_version}*${build_commit}* | grep -v Professional); do
        GET_FILE_INFOS ${src_file}
        if [[ ${build_big_version} != ${src_big_version} || ${build_small_version} != ${src_small_version} || ${build_commit} != ${src_commit} ]]; then
            LOG_WARNING "版本未匹配: ${version_filename} - ${src_file}"
            continue
        fi
        if [[ ! 'x64 x86 arm64(aarch64) arm' =~ ${src_machine} ]]; then
            LOG_WARNING 不支持的CPU架构类型 - ${src_machine}
            continue
        fi
        cp $src_file $BUILD_SRC/
        need_files="$src_file $need_files"
        SEL_PLATFORM ${src_machine}
        if [[ ! ${build_platforms} =~ ${platform} ]]; then
            build_platforms="${build_platforms}, ${platform}"
        fi
    done
    LOG_WARNING cp $need_files $BUILD_SRC/
    LOG_INFO $BUILD_SRC: $(ls $BUILD_SRC)
    export REGISTRY='registry.aour.zctmdc.cn'
    export BUILD_PLATFORMS="${build_platforms:1}"
    export BIG_VERSION=${build_big_version}
    export SMALL_VERSION=${build_small_version}
    export COMMIT=${build_commit}

    LOG_INFO REGISTRY: ${REGISTRY}
    LOG_INFO BUILD_PLATFORMS: ${BUILD_PLATFORMS}
    LOG_INFO BIG_VERSION: ${BIG_VERSION}
    LOG_INFO SMALL_VERSION: ${SMALL_VERSION}
    LOG_INFO COMMIT: ${COMMIT}
    # docker compose -f docker-compose.build.evn.yaml build --progress plain

    # docker compose -f docker-compose.build.evn.yaml push
    # docker compose -f docker-compose.build.evn.yaml run n2n_evn_BIG_VERSION_SMALL_VERSION_rCOMMIT edge -h >$BUILD_DESC/${version_b_s_rc}_edge_help.txt
    # docker compose -f docker-compose.build.evn.yaml run n2n_evn_BIG_VERSION_SMALL_VERSION_rCOMMIT supernode -h >$BUILD_DESC/${version_b_s_rc}_supernode_help.txt
    if [[ ${MANUAL_BUILD} ]]; then
        LOG_RUN docker buildx build --platform linux/arm64,linux/amd64 -t ${REGISTRY}/zctmdc/n2n-lucktu:${version_b_s_rc} --build-arg VERSION_B_S_rC=${version_b_s_rc} ../. --push
        LOG_RUN docker buildx build --platform linux/arm64,linux/amd64 -t ${REGISTRY}/zctmdc/n2n-lucktu:v.${SMALL_VERSION}${COMMIT:+_r}${COMMIT} --build-arg VERSION_B_S_rC=${version_b_s_rc} ../. --push
        LOG_RUN docker buildx build --platform linux/arm64,linux/amd64 -t ${REGISTRY}/zctmdc/n2n-lucktu:v.${SMALL_VERSION} --build-arg VERSION_B_S_rC=${version_b_s_rc} ../. --push
    fi

}
