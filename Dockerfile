# Dockerfile for xray based alpine
# Reference URL:
# https://github.com/XTLS/Xray-core
# https://github.com/v2fly/v2ray-core
# https://github.com/v2fly/geoip
# https://github.com/v2fly/domain-list-community

FROM golang:alpine AS builder

ARG VERSION="v1.4.2"

WORKDIR /

RUN set -ex \ 
	&& apk add --no-cache  git && mkdir /release  \
	&& git clone --branch=$VERSION  https://github.com/XTLS/Xray-core.git  \
	&& cd \Xray-core \
	&& env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -v -trimpath -ldflags "-s -w" -o /release/xray ./main  \
	&& rm /Xray-core -rf 


FROM alpine:latest

WORKDIR /
COPY config.json /etc/xray/config.json
COPY wait_for_caddy.sh /wait_for_caddy.sh
COPY --from=builder /release /usr/bin/
RUN set -ex \
	&& apk add --no-cache tzdata ca-certificates wget unzip libcap \
	&& mkdir -p /var/log/xray /usr/local/share/xray \
	&& chmod +x /wait_for_caddy.sh \
        && chmod +x /usr/bin/xray \
        && setcap 'cap_net_bind_service=+ep' /usr/bin/xray \
        && wget -O /usr/local/share/xray/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat \
	&& wget -O /usr/local/share/xray/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat

VOLUME /etc/xray
ENV TZ=Asia/Shanghai
CMD ["/bin/sh","wait_for_caddy.sh", "/usr/bin/xray", "-config", "/etc/xray/config.json" ]
