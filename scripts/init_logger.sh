#!/bin/bash
LOG_INFO() {
  echo -e $(caller) "\033[0;32m[INFO] $* \033[0m"
}

LOG_ERROR() {
  echo -e $(caller) "\033[0;31m[ERROR] $* \033[0m"
  if [[ -n "${SLOW_DEBUG}" ]]; then
    sleep 3
  fi
}

LOG_ERROR_WAIT_EXIT() {
  LOG_ALL
  echo -e $(caller) "\033[0;31m[ERROR] $* \033[0m"
  t=60
  while test $t -gt 0; do
    if [ $t -ge 10 ]; then
      echo -e "${t}\b\b\c"
    elif [ $t -eq 9 ]; then
      echo -e "  \b\c"
      echo -e "\b${t}\b\c"
    else
      echo -e "${t}\b\c"
    fi
    sleep 1
    t=$((t - 1))
  done

  exit 1
}

LOG_WARNING() {
  echo -e $(caller) "\033[0;33m[WARNING] $* \033[0m"
  if [[ -n "${SLOW_DEBUG}" ]]; then
    sleep 1
  fi
}

LOG_RUN() {
  echo -e $(caller) "\033[43;34m$@\033[0m"
  # eval $@
  eval "$@"
}

LOG_INPTU() {
  LOG_INFO "input: BIG_VERSION: ${BIG_VERSION}"
  LOG_INFO "input: SMALL_VERSION: ${SMALL_VERSION}"
  LOG_INFO "input: COMMIT: ${COMMIT}"
  LOG_INFO "input: VERSION_B_S_rC: ${VERSION_B_S_rC}"
}

LOG_GET_FILE_INFOS() {
  LOG_INFO "LOG_GET_FILE_INFOS: src_machine: ${src_machine}"
  LOG_INFO "LOG_GET_FILE_INFOS: src_machine_alias: ${src_machine_alias}"
  LOG_INFO "LOG_GET_FILE_INFOS: src_big_version: ${src_big_version}"
  LOG_INFO "LOG_GET_FILE_INFOS: src_small_version: ${src_small_version}"
  LOG_INFO "LOG_GET_FILE_INFOS: src_commit: ${src_commit}"
  LOG_INFO "LOG_GET_FILE_INFOS: src_version_b_s_rc: ${src_version_b_s_rc}"
}
LOG_SCAN_ONE_BUILD() {
  LOG_INFO "SCAN_ONE_BUILD: build_big_version: ${build_big_version}"
  LOG_INFO "SCAN_ONE_BUILD: build_small_version: ${build_small_version}"
  LOG_INFO "SCAN_ONE_BUILD: build_commit: ${build_commit}"
  LOG_INFO "SCAN_ONE_BUILD: build_version_b_s_rc: ${build_version_b_s_rc}"
}
LOG_SEL_PLATFORM() {
  LOG_INFO "SEL_PLATFORM: MY_KERNEL: ${MY_KERNEL}"
  LOG_INFO "SEL_PLATFORM: MY_MACHINE: ${MY_MACHINE}"
  LOG_INFO "SEL_PLATFORM: dn_machine: ${dn_machine}"
  LOG_INFO "SEL_PLATFORM: fn_machine: ${fn_machine}"
  LOG_INFO "SEL_PLATFORM: platform: ${platform}"
}
LOG_ALL() {
  LOG_INPTU
  LOG_GET_FILE_INFOS
  LOG_SCAN_ONE_BUILD
  LOG_SCAN_ONE_BUILD
  LOG_SEL_PLATFORM
}
LOG_INFO "init_logger success - $(caller)"
