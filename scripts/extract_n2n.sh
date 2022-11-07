#!/bin/bash

. init_logger.sh
. init_path.sh
. init_kernel_name_and_machine_name.sh
. init_extract.sh

for src_file in $(find ${DOWN_DIR} -name *${fn_machine}*); do
    LOG_INFO "Try: 解压 - ${src_file}"
    EXTRACT_ALL "${src_file}"
done
LOG_WARNING "解压结果：\n$(find ${DOWN_DIR} -type f | grep edge | grep -v upx | xargs -I {} du -h {} | sort -rh)"
