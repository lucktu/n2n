#!/bin/bash
. init_logger.sh
. init_path.sh

n2n_edge_biggest=$(find ${DOWN_DIR} -type f | grep edge | grep -v upx | xargs -I {} du -h {} | sort -rh | head -n 1 | awk '{print$2}')
if [[ -z "${n2n_edge_biggest}" ]]; then
    LOG_ERROR_WAIT_EXIT "n2n_edge_biggest 获取失败"
fi
chmod +x ${n2n_edge_biggest}
down_version="$(${n2n_edge_biggest} -h | grep Welcome | grep -Eo 'v\.[0-9]\.[0-9]\.[0-9]' | grep -Eo '[0-9]\.[0-9]\.[0-9]')"
define_version="$(echo ${SMALL_VERSION} | grep -Eo '[0-9]\.[0-9]\.[0-9]')"
if [[ "${define_version}" != "${down_version}" || -z "${down_version}" ]]; then
    LOG_ERROR "下载版本不匹配: ${define_version} != ${down_version}"
    LOG_ERROR "$(${n2n_edge_biggest} -h)"
    # exit 1
fi

n2n_src_dir=${n2n_edge_biggest%/*}
if [[ -z "${n2n_src_dir}" ]]; then
    LOG_ERROR_WAIT_EXIT "n2n_src_dir 获取失败"
fi

n2n_desc_dir="/tmp/desc"
mkdir -p "${n2n_desc_dir}"
LOG_INFO "n2n_src_dir: ${n2n_src_dir}"
cp -r ${n2n_src_dir}/* ${n2n_desc_dir}
chmod +x ${n2n_desc_dir}/*

ls -l ${n2n_desc_dir}

if [[ ! -f "${n2n_desc_dir}/edge" ]]; then
    edge_file_src="$(ls ${n2n_desc_dir}/edge* | grep -v upx)"
    if [[ -z "${edge_file_src}" ]]; then
        LOG_ERROR_WAIT_EXIT "复制文件错误: edge_file_src- 为空"
    fi
    LOG_WARNING "使用${edge_file_src}"
    cp "${edge_file_src}" "${n2n_desc_dir}/edge"
fi
if [[ ! -f "${n2n_desc_dir}/supernode" ]]; then
    supernode_file_src="$(ls ${n2n_desc_dir}/supernode* | grep -v upx)"
    if [[ -z "${supernode_file_src}" ]]; then
        LOG_ERROR_WAIT_EXIT "复制文件错误: supernode_file_src- 为空"
    fi
    LOG_WARNING "使用${supernode_file_src}"
    cp "${supernode_file_src}" "${n2n_desc_dir}/supernode"
fi
LOG_INFO ls ${n2n_desc_dir}
