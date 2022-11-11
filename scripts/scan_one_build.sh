#!/bin/bash

. init_logger.sh
. sel_platform.sh
. init_path.sh
. get_file_infos.sh

SCAN_ONE_BUILD() {
    # 一个版本
    if [[ -n "$1" ]]; then
        LOG_WARNING "use arg version"
        version_b_s_rc=$1
    fi
    if [[ -n "${version_b_s_rc}" ]]; then
        LOG_WARNING "use version_b_s_rc version_b_s_rc version"
    fi
    if [[ -z "${version_b_s_rc}" && -n "${BIG_VERSION}" && -n "${SMALL_VERSION}" ]]; then
        LOG_WARNING "use env BIG_VERSION... version"
        version_b_s_rc="${BIG_VERSION}_${SMALL_VERSION}${COMMIT:+_r}${COMMIT}"
    fi
    if [[ -z "${version_b_s_rc}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: SCAN_ONE_BUILD - version_b_s_rc - 为空"
    fi

    LOG_INFO "version_b_s_rc: ${version_b_s_rc}"
    # e.g. v3
    build_big_version=${version_b_s_rc%%_*}
    if [[ -z "${build_big_version}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: SCAN_ONE_BUILD: build_big_version - 为空 - ${version_file}"
    fi
    LOG_INFO "build_big_version: ${build_big_version}"
    # e.g. 3.1.0-54
    build_small_version=${version_b_s_rc##*${build_big_version}_}
    build_small_version=${build_small_version%%_*}
    if [[ -z "${build_small_version}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: SCAN_ONE_BUILD: build_small_version - 为空 - ${version_file}"
    fi
    LOG_INFO "build_small_version: ${build_small_version}"
    # e.g. 1127
    build_commit=${version_b_s_rc##*${build_small_version}}
    build_commit=${build_commit#_}
    build_commit=${build_commit#r}
    if [[ -z "${build_commit}" ]]; then
        LOG_ERROR "请注意: SCAN_ONE_BUILD: build_commit - 为空 - ${version_file}"
    fi
    LOG_INFO "build_commit: ${build_commit}"
    build_version_b_s_rc=${build_big_version}${build_small_version:+_}${build_small_version}${build_commit:+_r}${build_commit}
    if [[ ${build_version_b_s_rc} != ${version_b_s_rc} ]]; then
        LOG_ERROR_WAIT_EXIT "错误: SCAN_ONE_BUILD: build_version_b_s_rc  ${build_version_b_s_rc} != ${version_file}"
    fi
    build_platforms=''
    if [[ -d $BUILD_SRC ]]; then
        rm -r $BUILD_SRC
    fi
    mkdir -p $BUILD_SRC
    need_files=""
    for src_file in $(find ${PROJECT_ROOT_DIR}/Linux -name "*${build_big_version}*${build_small_version}*${build_commit}*" | grep -v Professional); do
        GET_FILE_INFOS ${src_file}
        if [[ ${build_big_version} != ${src_big_version} || ${build_small_version} != ${src_small_version} || ${build_commit} != ${src_commit} ]]; then
            LOG_WARNING "版本未匹配: ${version_filename} - ${src_file}"
            continue
        fi
        if [[ -z $(echo "${src_machine}" | grep -vE '(eb)|(mips)') ]]; then
            LOG_WARNING 不支持的CPU架构类型 - ${src_machine}
            continue
        fi
        if [[ -n "${VERSION_B_S_rC}" || -n "${GITHUB_WORKSPACE}" ]]; then
            LOG_RUN cp $src_file ${BUILD_SRC}/
        fi
        LOG_INFO "匹配成功: ${version_filename} - ${src_file}"
        need_files="${need_files} ${src_file}"
        SEL_PLATFORM ${src_machine}
        if [[ ! ${build_platforms} =~ ${platform} ]]; then
            build_platforms="${build_platforms},${platform}"
        fi
    done
    LOG_WARNING need_files: $need_files
    LOG_INFO $BUILD_SRC: $(ls $BUILD_SRC)
    export REGISTRY='registry.aour.zctmdc.cn'
    export BUILD_PLATFORMS="${build_platforms:1}"
    export BUILD_BIG_VERSION=${build_big_version}
    export BUILD_SMALL_VERSION=${build_small_version}
    export BUILD_COMMIT=${build_commit}
    export BUILD_VERSION_B_S_rC=${build_version_b_s_rc}

    LOG_INFO REGISTRY: ${REGISTRY}
    LOG_INFO BUILD_PLATFORMS: ${BUILD_PLATFORMS}
    LOG_INFO BUILD_BIG_VERSION: ${BUILD_BIG_VERSION}
    LOG_INFO BUILD_SMALL_VERSION: ${BUILD_SMALL_VERSION}
    LOG_INFO BUILD_COMMIT: ${BUILD_COMMIT}
    LOG_INFO BUILD_VERSION_B_S_rC: ${BUILD_VERSION_B_S_rC}
    # docker compose -f docker-compose.build.evn.yaml build --no-cache --progress plain

    # docker compose -f docker-compose.build.evn.yaml push
    # docker compose -f docker-compose.build.evn.yaml run n2n_evn_BIG_VERSION_SMALL_VERSION_rCOMMIT edge -h >$BUILD_DESC/${BUILD_VERSION_B_S_rC}_edge_help.txt
    # docker compose -f docker-compose.build.evn.yaml run n2n_evn_BIG_VERSION_SMALL_VERSION_rCOMMIT supernode -h >$BUILD_DESC/${BUILD_VERSION_B_S_rC}_supernode_help.txt
    if [[ -n "${MANUAL_BUILD}" && -n "${BUILD_PLATFORMS}" ]]; then
        LOG_RUN docker buildx build --no-cache --progress plain --platform "'${BUILD_PLATFORMS}'" -t ${REGISTRY}/zctmdc/n2n-lucktu:${BUILD_VERSION_B_S_rC} --build-arg VERSION_B_S_rC=${BUILD_VERSION_B_S_rC} ../. --push
        LOG_RUN docker buildx build --no-cache --progress plain --platform "'${BUILD_PLATFORMS}'" -t ${REGISTRY}/zctmdc/n2n-lucktu:v.${BUILD_SMALL_VERSION}${BUILD_COMMIT:+_r}${BUILD_COMMIT} --build-arg VERSION_B_S_rC=${BUILD_VERSION_B_S_rC} ../. --push
        LOG_RUN docker buildx build --no-cache --progress plain --platform "'${BUILD_PLATFORMS}'" -t ${REGISTRY}/zctmdc/n2n-lucktu:v.${BUILD_SMALL_VERSION} --build-arg VERSION_B_S_rC=${BUILD_VERSION_B_S_rC} ../. --push
    fi

}
