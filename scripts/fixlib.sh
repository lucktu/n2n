#!/bin/bash

. init_logger.sh

flag_retry="$1"

################################
# see: https://get.docker.com/
command_exists() {
    command -v "$@" >/dev/null 2>&1
}
get_distribution() {
    lsb_dist=""
    # Every system that we officially support has /etc/os-release
    if [ -r /etc/os-release ]; then
        lsb_dist="$(. /etc/os-release && echo "$ID")"
    fi
    # Returning an empty string here should be alright since the
    # case statements don't act unless you provide an actual value
    echo "$lsb_dist"
}

get_dist_version() {
    get_distribution >/dev/null 2>&1
    case "$lsb_dist" in

    ubuntu)
        if command_exists lsb_release; then
            dist_version="$(lsb_release --codename | cut -f2)"
        fi
        if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
            dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
        fi
        ;;

    debian | raspbian)
        dist_version="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
        case "$dist_version" in
        12)
            dist_version="bookworm"
            ;;
        11)
            dist_version="bullseye"
            ;;
        10)
            dist_version="buster"
            ;;
        9)
            dist_version="stretch"
            ;;
        8)
            dist_version="jessie"
            ;;
        esac
        ;;

    centos | rhel | sles)
        if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
            dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
        fi
        ;;

    *)
        if command_exists lsb_release; then
            dist_version="$(lsb_release --release | cut -f2)"
        fi
        if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
            dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
        fi
        ;;

    esac
    echo "${dist_version}"
}
################################

get_lsb_dist() {
    lsb_dist=$(get_distribution)
    echo "${lsb_dist,,}"
}

get_lsb_version() {
    lsb_version=$(get_dist_version)
    echo "${lsb_version,,}"
}

get_version_id() {
    version_id=""
    # Every system that we officially support has /etc/os-release
    if [ -r /etc/os-release ]; then
        version_id="$(. /etc/os-release && echo "$VERSION_ID")"
    fi
    # Returning an empty string here should be alright since the
    # case statements don't act unless you provide an actual value
    echo "$version_id"
}

is_debian() {
    echo "$(get_lsb_dist)" | grep debian >/dev/null 2>&1
}

is_debian_8() {
    echo "$(get_lsb_version)" | grep jessie >/dev/null 2>&1
}

is_ubuntu() {
    echo "$(get_lsb_dist)" | grep ubuntu >/dev/null 2>&1
}

is_ubuntu_18_04() {
    echo "$(get_lsb_version)" | grep jessie >/dev/null 2>&1
}

is_alpine() {
    echo $(get_lsb_dist) | grep alpine >/dev/null 2>&1
}

get_alpine_version() {
    echo "$(get_version_id)" | grep -Eo '[0-9]+\.[0-9]+'
}

is_alpine_3_8() {
    echo $(get_alpine_version) | grep '3.8' >/dev/null 2>&1
}

if [[ -n "$(/usr/local/sbin/edge -h 2>&1 | grep /lib/ld-linux.so.3)" ]]; then
    LOG_WARNING 缺少 /lib/ld-linux.so.3 , 正在修复
    find / -name ld-linux*.so* | head -n 1 | xargs -I {} ln -sv {} /lib/ld-linux.so.3
    LOG_WARNING 缺少 /lib/ld-linux.so.3 , 修复完毕
fi

if [[ -n "$(/usr/local/sbin/edge -h 2>&1 | grep libcrypto.so.1.0.0)" ]]; then
    LOG_WARNING 缺少 libssl1.0.0 , 正在修复
    if command_exists apt-get; then

        if is_debian && ! is_debian_8; then
            apt-get update && apt-get install -y gnupg2
            mkdir -p ~/.gnupg/
            chmod og-rwx ~/.gnupg/
            gpg --no-default-keyring --keyring /usr/share/keyrings/9D6D8F6BC857C906-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 9D6D8F6BC857C906
            gpg --no-default-keyring --keyring /usr/share/keyrings/AA8E81B4331F7F50-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys AA8E81B4331F7F50
            echo 'deb [signed-by=/usr/share/keyrings/9D6D8F6BC857C906-archive-keyring.gpg signed-by=/usr/share/keyrings/AA8E81B4331F7F50-archive-keyring.gpg] http://archive.debian.org/debian-security jessie/updates main' >/etc/apt/sources.list.d/debian8.list
        fi
        if is_ubuntu && ! is_ubuntu_18_04; then
            apt-get update && apt-get install -y gnupg2
            mkdir -p ~/.gnupg/
            chmod og-rwx ~/.gnupg/
            gpg --no-default-keyring --keyring /usr/share/keyrings/3B4FE6ACC0B21F32-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3B4FE6ACC0B21F32
            echo 'deb http://security.ubuntu.com/ubuntu/ bionic-security main restricted' >/etc/apt/sources.list.d/ubuntu-18.04.list
            echo 'deb http://security.ubuntu.com/ubuntu/ bionic-security universe' >/etc/apt/sources.list.d/ubuntu-18.04.list
            echo 'deb [signed-by=/usr/share/keyrings/3B4FE6ACC0B21F32-archive-keyring.gpg] http://security.ubuntu.com/ubuntu/ bionic-security multiverse' >/etc/apt/sources.list.d/ubuntu-18.04.list
        fi

        ################################################################
        apt-get update
        apt-get install -y libssl1.0.0
        ################################################################

        if is_debian && ! is_debian_8; then
            rm -f /etc/apt/sources.list.d/debian8.list
            rm -f /usr/share/keyrings/9D6D8F6BC857C906-archive-keyring.gpg
            rm -f /usr/share/keyrings/AA8E81B4331F7F50-archive-keyring.gpg
        fi
        if is_ubuntu && ! is_ubuntu_18_04; then
            rm -f /etc/apt/sources.list.d/ubuntu-18.04.list
            rm -f /usr/share/keyrings/3B4FE6ACC0B21F32-archive-keyring.gpg
        fi
    elif command_exists apk; then
        if is_alpine && ! is_alpine_3_8; then
            sed -i "s/v$(get_alpine_version)/v3.8/g" /etc/apk/repositories
        fi

        ################################################################
        apk add --no-cache --upgrade libssl1.0
        ################################################################

        if is_alpine && ! is_alpine_3_8; then
            sed -i "s/v3.8/v$(get_alpine_version)/g" /etc/apk/repositories
        fi
    fi
    LOG_WARNING 缺少 libssl1.0.0 , 修复完毕
fi

if [[ -n "$(/usr/local/sbin/edge -h 2>&1 | grep libcrypto.so.1.1)" ]]; then
    LOG_WARNING 缺少 libssl1.1 , 正在修复
    if command_exists apt-get; then
        if is_debian_8; then
            echo 'deb http://archive.debian.org/debian-security stretch/updates main' >/etc/apt/sources.list.d/debian9.list
        fi
        if is_ubuntu_18_04; then
            echo 'deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted' >/etc/apt/sources.list.d/ubuntu22.04.list
            echo 'deb http://security.ubuntu.com/ubuntu/ jammy-security universe' >/etc/apt/sources.list.d/ubuntu22.04.list
            echo 'deb http://security.ubuntu.com/ubuntu/ jammy-security multiverse' >/etc/apt/sources.list.d/ubuntu22.04.list
        fi

        ################################################################
        apt-get update
        apt-get install -y libssl1.1
        ################################################################

        if is_debian_8; then
            rm -f /etc/apt/sources.list.d/debian9.list
        fi
        if is_ubuntu_18_04; then
            rm -f /etc/apt/sources.list.d/ubuntu22.04.list
        fi

    elif command_exists apt; then
        if is_alpine_3_8; then
            sed -i "s/v3.8/v3.10/g" /etc/apk/repositories
        fi

        ################################################################
        apk add --no-cache --upgrade libssl1.1
        # 自带
        # LOG_WARNING 'alpine 自带 libssl1.1'
        ################################################################

        if is_alpine_3_8; then
            sed -i "s/v3.10/v3.8/g" /etc/apk/repositories
        fi
    fi
    LOG_WARNING 缺少 libssl1.1 , 修复完毕
fi
edge_result="$(edge -h 2>&1 | xargs -0 --no-run-if-empty -I {} echo {})"

if [[ -z "$(echo ${edge_result,,} | grep welcome)" && -z "${flag_retry}" ]]; then
    LOG_ERROR 出错了: ${edge_result}
    source /tmp/n2n-lucktu/scripts/fixlib.sh retry
else
    if command_exists apt-get; then
        apt-get clean && rm -rf /var/lib/apt/lists/*
    fi
    if command_exists apk; then
        rm -rf /var/cache/apk/* && rm -rf /root/.cache
    fi
    LOG_INFO 修复结束
fi
