#!/bin/bash

. init_logger.sh
if [[ -z ${PROJECT_DIR} ]]; then
    PROJECT_DIR=$(pwd)
fi
if [[ ! ${PROJECT_DIR} =~ 'n2n-lucktu' ]]; then
    LOG_ERROR_WAIT_EXIT "错误: init_path - PROJECT_DIR - ${PROJECT_DIR}"
fi

PROJECT_DIR="${PROJECT_DIR%%n2n-lucktu*}n2n-lucktu"

SCRIPTS_DIR=$(
    cd $(dirname $0)/
    pwd
)

RESULT_DIR=${PROJECT_DIR}/result

BUILD_SRC=${RESULT_DIR}/build_src
BUILD_DESC=${RESULT_DIR}/build_desc

if [[ ! -d ${BUILD_SRC} ]]; then
    LOG_RUN mkdir -p ${BUILD_SRC}
fi
if [[ ! -d ${BUILD_DESC} ]]; then
    LOG_RUN mkdir -p ${BUILD_DESC}
fi

LOG_INFO PROJECT_DIR: $PROJECT_DIR
LOG_INFO SCRIPTS_DIR: $SCRIPTS_DIR
LOG_INFO RESULT_DIR: $RESULT_DIR
LOG_INFO BUILD_SRC: $BUILD_SRC
