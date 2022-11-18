#!/bin/bash

rm -r ../result/
. init_logger.sh

docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx create --use --name build --node build --driver-opt network=host

export MANUAL_BUILD="True"
export REGISTRY='registry.aour.zctmdc.cn'
export REGISTRY_USERNAME='zctmdc'
export REGISTRY_CACHE='True'
# export PROXY_SERVER="http://host.docker.internal:21089"

sh -c scan_all_save.sh
sh -c scan_all_build.sh

. scan_one_build.sh
build_version_b_s_rcs="v2s,v2,v1"
l_build_version_b_s_rcs=(${build_version_b_s_rcs//,/ })
for build_version_b_s_rc in ${l_build_version_b_s_rcs[@]}; do
    LOG_INFO "version_b_s_rc: ${build_version_b_s_rc}"
    SCAN_ONE_BUILD ${build_version_b_s_rc}
done
