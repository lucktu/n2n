#!/bin/bash

. init_logger.sh
. get_file_infos.sh

SAVE_FILE_INFOS() {

    result_version=${src_big_version}_${src_small_version}${src_commit:+_}${src_commit}
    result_file=${RESULT_DIR}/${result_version}.txt
    LOG_INFO result_file: ${result_file}

    # result_str="${src_machine} - ${result_version}"
    # result_str="${src_machine}${src_machine_alias:+\n}${src_machine_alias}"
    result_str="${src_machine}"
    LOG_INFO result_str: ${result_str}
    echo -e ${result_str} >>${result_file}
    echo -e ${result_str} >>${RESULT_DIR}/all.txt
    vmv_dir=${RESULT_DIR}/${src_big_version}/${src_small_version}
    mkdir -p ${vmv_dir}
    l_result_file=${RESULT_DIR}/${src_big_version}/${src_small_version}${src_commit:+/r}${src_commit}.txt
    echo -e ${result_str} >>${l_result_file}
}

LOG_INFO "init SAVE_FILE_INFOS success - $(caller)"
