#!/bin/bash

. init_logger.sh

. scan_one_build.sh

ARG BIG_VERSION
ARG SMALL_VERSION
ARG COMMIT
if [[ ("${BIG_VERSION}" == "v2s" || "${BIG_VERSION}" == "v2" || "${BIG_VERSION}" == "v1") && -z "${SMALL_VERSION}" && -z "${COMMIT}" ]]; then
    LOG_WARNING BUILD BIG VERSION
    . init_path.sh
    cp ${PROJECT_ROOT_DIR}/Linux/n2n_${BIG_VERSION}/* $RESULT_DIR
    return 0
fi

version_b_s_rc="${BIG_VERSION}_${SMALL_VERSION}${COMMIT:+_r}${COMMIT}"

SCAN_ONE_BUILD ${version_b_s_rc}
