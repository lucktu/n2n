#!/bin/bash

. init_logger.sh

. scan_one_build.sh
if [[ ! -z "${VERSION_B_S_rC}" ]]; then
    version_b_s_rc="${VERSION_B_S_rC}"
else
    version_b_s_rc="${BIG_VERSION}${SMALL_VERSION:+_}${SMALL_VERSION}${COMMIT:+_r}${COMMIT}"
fi
LOG_WARNING "Try Build: version_b_s_rc - ${version_b_s_rc}"

if [[ "${version_b_s_rc}" == "v2s" || "${version_b_s_rc}" == "v2" || "${version_b_s_rc}" == "v1" ]]; then
    LOG_WARNING "BUILD BIG VERSION"
    . init_path.sh
    cp ${PROJECT_ROOT_DIR}/Linux/n2n_${BIG_VERSION}/* $RESULT_DIR
    return 0
fi

version_b_s_rc="${BIG_VERSION}_${SMALL_VERSION}${COMMIT:+_r}${COMMIT}"

SCAN_ONE_BUILD ${version_b_s_rc}
