FROM debian:stable-slim as downloader

ARG name="n2n-downloader"
ARG summary="Base build image for n2n-lucktu built on-top of debian:stable-slim"
LABEL description="${summary}" \
  maintainer="<zctmdc@outlook.com>" \
  app.kubernetes.io/name="${name}" \
  org.opencontainers.image.title="${name}" \
  org.opencontainers.artifact.description="${summary}" \
  org.opencontainers.image.url="https://hub.docker.com/r/zctmdc/n2n_ntop" \
  org.opencontainers.image.source="https://github.com/zctmdc/docker/tree/alpha/n2n-lucktu" \
  org.opencontainers.image.authors="zctmdc@outlook.com" \
  org.opencontainers.image.description="${summary}" \
  org.opencontainers.image.documentation="https://github.com/zctmdc/docker/tree/alpha/n2n-lucktu/doc/build.md"\
  org.opencontainers.image.licenses="MIT"

ARG DEBIAN_FRONTEND=noninteractive
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN sed -i 's|security.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list
RUN apt-get -qq update

RUN apt-get -qq -y install \
  bash curl wget unzip jq git

# 安装RAR
WORKDIR /tmp/scripts/
COPY ./scripts/init_logger.sh ./scripts/install_rar.sh /tmp/scripts/
RUN chmod +x /tmp/scripts/*.sh
RUN /tmp/scripts/install_rar.sh

ARG KERNEL=linux
# 用于自定义机型编译,未自动识别时请赋值
ARG MACHINE
ARG BIG_VERSION
ARG SMALL_VERSION
ARG COMMIT
ARG VERSION_B_S_rC
# 选择对应版本文件
WORKDIR /tmp/n2n-lucktu/scripts/
# COPY . /tmp/n2n-lucktu/
# RUN chmod +x /tmp/n2n-lucktu/scripts/*.sh
# RUN /tmp/n2n-lucktu/scripts/build-docker.sh

# RUN mkdir -p /tmp/down/ && cp /tmp/n2n-lucktu/result/build_src/* /tmp/down/ && ls /tmp/down/

COPY ./result/build_src/ /tmp/down/
COPY ./scripts/ /tmp/n2n-lucktu/scripts/

# 解压，选择最大的edge文件
RUN /tmp/n2n-lucktu/scripts/extract_n2n.sh
RUN /tmp/n2n-lucktu/scripts/sel_n2n.sh

FROM debian:stable

ARG name="n2n-lucktu"
ARG summary="n2n-lucktu built on-top of ubuntu"
LABEL description="${summary}" \
  maintainer="<zctmdc@outlook.com>" \
  app.kubernetes.io/name="${name}" \
  org.opencontainers.image.title="${name}" \
  org.opencontainers.artifact.description="${summary}" \
  org.opencontainers.image.url="https://hub.docker.com/r/zctmdc/n2n_ntop" \
  org.opencontainers.image.source="https://github.com/zctmdc/docker/tree/alpha/n2n-lucktu" \
  org.opencontainers.image.authors="zctmdc@outlook.com" \
  org.opencontainers.image.description="${summary}" \
  org.opencontainers.image.licenses="MIT"

WORKDIR /usr/local/sbin/
COPY --from=downloader \
  /tmp/desc/supernode \
  /tmp/desc/edge \
  /usr/local/sbin/
RUN ls
