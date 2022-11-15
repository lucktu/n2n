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
    if [[ -n "${VERSION_B_S_rC}" ]]; then
        LOG_WARNING "use VERSION_B_S_rC version"
        version_b_s_rc=${VERSION_B_S_rC}
    fi
    if [[ -n "${version_b_s_rc}" ]]; then
        LOG_WARNING "use version_b_s_rc version"
    fi
    if [[ -z "${version_b_s_rc}" && -n "${BIG_VERSION}" && -n "${SMALL_VERSION}" ]]; then
        LOG_WARNING "use env BIG_VERSION... version"
        version_b_s_rc="${BIG_VERSION}_${SMALL_VERSION}${COMMIT:+_r}${COMMIT}"
    fi
    if [[ -z "${version_b_s_rc}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: SCAN_ONE_BUILD - version_b_s_rc - 为空"
    fi
    # e.g. v3_3.1.0-54_r1277
    LOG_INFO "version_b_s_rc: ${version_b_s_rc}"
    # e.g. v3
    build_big_version=${version_b_s_rc%%_*}
    if [[ -z "${build_big_version}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: SCAN_ONE_BUILD: build_big_version - 为空 - ${version_b_s_rc}"
    fi
    LOG_INFO "build_big_version: ${build_big_version}"
    # e.g. 3.1.0-54_r1277
    build_sc_version=${version_b_s_rc##*${build_big_version}}
    build_sc_version=${build_sc_version#*_}

    # e.g. 3.1.0-54
    build_small_version=${build_sc_version%%_*}
    if [[ -z "${build_small_version}" ]]; then
        LOG_ERROR "错误: SCAN_ONE_BUILD: build_small_version - 为空 - ${version_b_s_rc}"
    fi
    LOG_INFO "build_small_version: ${build_small_version}"
    # e.g. 1127
    build_commit=${build_sc_version##*${build_small_version}}
    build_commit=${build_commit#*_}
    build_commit=${build_commit#r}
    if [[ -z "${build_commit}" ]]; then
        LOG_ERROR "请注意: SCAN_ONE_BUILD: build_commit - 为空 - ${version_b_s_rc}"
    fi
    LOG_INFO "build_commit: ${build_commit}"
    build_version_b_s_rc=${build_big_version}${build_small_version:+_}${build_small_version}${build_commit:+_r}${build_commit}
    LOG_INFO "build_version_b_s_rc: ${build_version_b_s_rc}"

    if [[ ${build_version_b_s_rc} != ${version_b_s_rc} ]]; then
        LOG_ERROR_WAIT_EXIT "错误: SCAN_ONE_BUILD: build_version_b_s_rc  ${build_version_b_s_rc} != ${version_b_s_rc}"
    fi
    build_platforms=''
    if [[ -d $BUILD_SRC ]]; then
        rm -r $BUILD_SRC
    fi
    mkdir -p $BUILD_SRC
    need_files=""
    find_path="${PROJECT_ROOT_DIR}/Linux/"
    # if [[ "v2s" == "${version_b_s_rc}" || "v2" == "${version_b_s_rc}" || "v1" == "${version_b_s_rc}" ]]; then
    if [[ -n "$(echo ${version_b_s_rc} | grep -E '^v[0-9]s?$')" ]]; then
        find_path="${PROJECT_ROOT_DIR}/Linux/n2n_${version_b_s_rc}/"
        if [[ ! -d "${find_path}" ]]; then
            if [[ -n "$(ls ${PROJECT_ROOT_DIR}/Linux/ | grep ${version_b_s_rc} | grep x64)" ]]; then
                find_path="${PROJECT_ROOT_DIR}/Linux/"
            else
                LOG_ERROR_WAIT_EXIT "版本未匹配: ${version_b_s_rc}"
            fi
        fi
    fi
    find_files="$(find ${find_path} -name "*${build_big_version}*${build_small_version}*${build_commit}*" | grep -v Professional)"
    for src_file in ${find_files[@]}; do
        GET_FILE_INFOS ${src_file}
        if [[ -d "${src_file}" ]]; then
            LOG_WARNING "跳过: 是文件夹 - ${src_file}"
            continue
        fi
        if [[ -n "$(echo ${version_b_s_rc} | grep -E '^v[0-9]s?$')" ]]; then
            LOG_INFO "匹配文件 releases: ${version_b_s_rc} - ${src_file}"
        elif [[ ${build_big_version} != ${src_big_version} || ${build_small_version} != ${src_small_version} || ${build_commit} != ${src_commit} ]]; then
            LOG_WARNING "版本未匹配: ${version_b_s_rc} - ${src_file}"
            continue
        fi
        if [[ -z $(echo "${src_machine}" | grep -vE '(eb)|(mips)') ]]; then
            LOG_WARNING 不支持的CPU架构类型 - ${src_machine}
            continue
        fi
        if [[ -n "${VERSION_B_S_rC}" || -n "${MANUAL_BUILD}" ]]; then
            # LOG_RUN cp "$src_file" "${BUILD_SRC}/"
            LOG_WARNING 复制文件 "$src_file" "${BUILD_SRC}/"
            cp "$src_file" "${BUILD_SRC}/"
        fi
        LOG_INFO "匹配成功: ${version_b_s_rc} - ${src_file}"
        need_files="${need_files} ${src_file}"
        SEL_PLATFORM ${src_machine}
        if [[ ! ${build_platforms} =~ ${platform} ]]; then
            build_platforms="${build_platforms},${platform}"
        fi
    done
    LOG_WARNING need_files: $need_files
    LOG_INFO $BUILD_SRC: $(ls $BUILD_SRC)
    export REGISTRY="${REGISTRY}"
    export BUILD_PLATFORMS="${build_platforms:1}"
    export BUILD_BIG_VERSION="${build_big_version}"
    export BUILD_SMALL_VERSION="${build_small_version}"
    export BUILD_COMMIT="${build_commit}"
    export BUILD_VERSION_B_S_rC="${build_version_b_s_rc}"
    export BUILD_NEED_FILES="${need_files}"
    LOG_INFO REGISTRY: ${REGISTRY}
    LOG_INFO BUILD_PLATFORMS: ${BUILD_PLATFORMS}
    LOG_INFO BUILD_BIG_VERSION: ${BUILD_BIG_VERSION}
    LOG_INFO BUILD_SMALL_VERSION: ${BUILD_SMALL_VERSION}
    LOG_INFO BUILD_COMMIT: ${BUILD_COMMIT}
    LOG_INFO BUILD_VERSION_B_S_rC: ${BUILD_VERSION_B_S_rC}
    LOG_INFO BUILD_NEED_FILES: ${BUILD_NEED_FILES}
    # docker compose -f docker-compose.build.evn.yaml build --progress plain

    # docker compose -f docker-compose.build.evn.yaml push
    # docker compose -f docker-compose.build.evn.yaml run n2n_evn_BIG_VERSION_SMALL_VERSION_rCOMMIT edge -h >$BUILD_DESC/${BUILD_VERSION_B_S_rC}_edge_help.txt
    # docker compose -f docker-compose.build.evn.yaml run n2n_evn_BIG_VERSION_SMALL_VERSION_rCOMMIT supernode -h >$BUILD_DESC/${BUILD_VERSION_B_S_rC}_supernode_help.txt
    if [[ "${MANUAL_BUILD^^}" == "TRUE" && -n "${BUILD_PLATFORMS}" ]]; then
        build_docker_file='Dockerfile'
        platforms=${BUILD_PLATFORMS}
        l_platforms=(${platforms//,/ })
        for test_platform in ${l_platforms[@]}; do
            LOG_WARNING "Test for platform: ${test_platform}"
            # LOG_RUN docker buildx build --progress plain --platform "'${test_platform}'" -t ${REGISTRY_USERNAME}/n2n-lucktu:test --build-arg VERSION_B_S_rC=${BUILD_VERSION_B_S_rC} -f ../${build_docker_file} --load ../.

            docker_build_command="docker buildx build --progress plain \
                --platform '${test_platform}' \
                --build-arg VERSION_B_S_rC=${BUILD_VERSION_B_S_rC} \
                --build-arg MANUAL_BUILD=${MANUAL_BUILD^^} \
                -f ../${build_docker_file}"

            if [[ -n "${PROXY_SERVER}" ]]; then
                docker_build_command="${docker_build_command} \
                --build-arg http_proxy=${PROXY_SERVER,,} \
                --build-arg https_proxy=${PROXY_SERVER,,}"
            fi

            LOG_RUN "${docker_build_command} \
                -t ${REGISTRY_USERNAME}/n2n-lucktu:test \
                --load ../. "

            edge_result="$(docker run --rm \
                --platform ${test_platform} \
                ${REGISTRY_USERNAME}/n2n-lucktu:test \
                edge -h 2>&1 | xargs -I {} echo {})"
            if [[ -n "$(echo ${edge_result} | grep -E '(libcrypto.so.1.0.0)|(/lib/ld-linux.so.3)')" ]]; then
                LOG_ERROR 出错了: ${edge_result}
                LOG_WARNING 使用 Dockerfile.debian-8 - ${BUILD_VERSION_B_S_rC}
                build_docker_file='Dockerfile.debian-8'
                break
            fi
        done
        # LOG_RUN docker buildx build --progress plain \
        #     --platform "'${BUILD_PLATFORMS}'" \
        #     -t ${REGISTRY}/${REGISTRY_USERNAME}/n2n-lucktu:${BUILD_VERSION_B_S_rC} \
        #     --build-arg VERSION_B_S_rC=${BUILD_VERSION_B_S_rC} \
        #     --build-arg MANUAL_BUILD=${MANUAL_BUILD^^} \
        #     -f ../${build_docker_file} \
        #     ${REGISTRY_CACHE:+--cache-from=type=registry,ref=${REGISTRY}/${REGISTRY_USERNAME}/n2n-lucktu:buildcache --cache-to=type=registry,ref=${REGISTRY}/${REGISTRY_USERNAME}/n2n-lucktu:buildcache} \
        #     ../. --push
        # LOG_RUN docker buildx build --progress plain \
        #     --platform "'${BUILD_PLATFORMS}'" \
        #     -t ${REGISTRY}/${REGISTRY_USERNAME}/n2n-lucktu:v.${BUILD_SMALL_VERSION}${BUILD_COMMIT:+_r}${BUILD_COMMIT} \
        #     --build-arg VERSION_B_S_rC=${BUILD_VERSION_B_S_rC} \
        #     --build-arg MANUAL_BUILD=${MANUAL_BUILD^^} \
        #     -f ../${build_docker_file} \
        #     ${REGISTRY_CACHE:+--cache-from=type=registry,ref=${REGISTRY}/${REGISTRY_USERNAME}/n2n-lucktu:buildcache --cache-to=type=registry,ref=${REGISTRY}/${REGISTRY_USERNAME}/n2n-lucktu:buildcache} \
        #     ../. --push
        # LOG_RUN docker buildx build --progress plain \
        #     --platform "'${BUILD_PLATFORMS}'" \
        #     -t ${REGISTRY}/${REGISTRY_USERNAME}/n2n-lucktu:v.${BUILD_SMALL_VERSION} \
        #     --build-arg VERSION_B_S_rC=${BUILD_VERSION_B_S_rC} \
        #     --build-arg MANUAL_BUILD=${MANUAL_BUILD^^} \
        #     -f ../${build_docker_file} \
        #     ${REGISTRY_CACHE:+--cache-from=type=registry,ref=${REGISTRY}/${REGISTRY_USERNAME}/n2n-lucktu:buildcache --cache-to=type=registry,ref=${REGISTRY}/${REGISTRY_USERNAME}/n2n-lucktu:buildcache} \
        #     ../. --push

        docker_build_command="docker buildx build --progress plain \
                --platform '${BUILD_PLATFORMS}' \
                --build-arg VERSION_B_S_rC=${BUILD_VERSION_B_S_rC} \
                --build-arg MANUAL_BUILD=${MANUAL_BUILD^^} \
                -f ../${build_docker_file}"

        if [[ -n "${PROXY_SERVER}" ]]; then
            docker_build_command="${docker_build_command} \
                --build-arg http_proxy=${PROXY_SERVER,,} \
                --build-arg https_proxy=${PROXY_SERVER,,}"
        fi

        if [[ "${REGISTRY_CACHE^^}"=="TRUE" ]]; then
            docker_build_command="${docker_build_command} \
                --cache-from=type=registry,ref=${REGISTRY}/${REGISTRY_USERNAME}/n2n-lucktu:buildcache \
                --cache-to=type=registry,ref=${REGISTRY}/${REGISTRY_USERNAME}/n2n-lucktu:buildcache"
        fi

        LOG_RUN "${docker_build_command} \
            -t ${REGISTRY}/${REGISTRY_USERNAME}/n2n-lucktu:${BUILD_VERSION_B_S_rC} \
            ../. --push"
        LOG_RUN "${docker_build_command} \
            -t ${REGISTRY}/${REGISTRY_USERNAME}/n2n-lucktu:v.${BUILD_SMALL_VERSION}${BUILD_COMMIT:+_r}${BUILD_COMMIT} \
            ../. --push"
        LOG_RUN "${docker_build_command} \
            -t ${REGISTRY}/${REGISTRY_USERNAME}/n2n-lucktu:v.${BUILD_SMALL_VERSION} \
            --push ../."
    fi

}
