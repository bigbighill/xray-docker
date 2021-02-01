# Dockerfile for xray based alpine
# Copyright (C) 2019 - 2020 Teddysun <i@teddysun.com>
# Reference URL:
# https://github.com/XTLS/Xray-core
# https://github.com/v2fly/v2ray-core
# https://github.com/v2fly/geoip
# https://github.com/v2fly/domain-list-community

FROM alpine:latest
LABEL maintainer="Teddysun <i@teddysun.com>"

ARG VERSION="v1.2.4"

WORKDIR /
COPY config.json /etc/xray/config.json
RUN set -ex \
	&& apk add --no-cache tzdata ca-certificates wget unzip \
	&& mkdir -p /var/log/xray /usr/local/share/xray \
	&& chmod +x /wait_for_caddy.sh \
        && wget -O /temp.zip https://github.com/XTLS/Xray-core/releases/download/$VERSION/Xray-linux-64.zip \
        && unzip /temp.zip /usr/bin \
        && rm /temp.zip \
        && chmod +x /usr/bin/xray \
        && setcap 'cap_net_bind_service=+ep' /usr/bin/xray \
        && wget -O /usr/local/share/xray/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat \
	&& wget -O /usr/local/share/xray/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat

VOLUME /etc/xray
ENV TZ=Asia/Shanghai
CMD ["/usr/bin/sh","wait_for_caddy.sh", "/usr/bin/xray", "-config", "/etc/xray/config.json" ]
