#!/bin/bash
rm -r ../result/
. init_logger.sh

# docker buildx create --use
docker run --privileged --rm tonistiigi/binfmt --install all

export MANUAL_BUILD=true
export REGISTRY='registry.aour.zctmdc.cn'
export REGISTRY_USERNAME='zctmdc'
export REGISTRY_CACHE='true'

. scan_all_save.sh
. scan_all_build.sh

. scan_one_build.sh
build_version_b_s_rcs="v2s,v2,v1"
l_build_version_b_s_rcs=(${build_version_b_s_rcs//,/ })
for build_version_b_s_rc in ${l_build_version_b_s_rcs[@]}; do
    LOG_INFO "version_b_s_rc: ${build_version_b_s_rc}"
    SCAN_ONE_BUILD ${build_version_b_s_rc}
done
