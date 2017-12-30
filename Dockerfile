
#
# Dockerfile for shadowsocks-libev
#

FROM alpine:3.6

ENV SS_VER 3.1.2
ENV SS_URL https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$SS_VER/shadowsocks-libev-$SS_VER.tar.gz
ENV SS_DIR shadowsocks-libev-$SS_VER
ENV KCP_VER 20171201
ENV KCP_URL https://github.com/xtaci/kcptun/releases/download/v$KCP_VER/kcptun-linux-amd64-$KCP_VER.tar.gz

RUN set -ex \
    && apk add --no-cache --virtual .run-deps \
        pcre \
        libev \
        c-ares \
        libsodium \
        mbedtls \
    && apk add --no-cache --virtual .build-deps \
        curl \
        autoconf \
        build-base \
        libtool \
        linux-headers \
        libressl-dev \
        zlib-dev \
        asciidoc \
        xmlto \
        pcre-dev \
        automake \
        mbedtls-dev \
        libsodium-dev \
        c-ares-dev \
        libev-dev \
        rng-tools \
    && curl -sSL $SS_URL | tar xz \
    && cd $SS_DIR \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf $SS_DIR \
    && mkdir -p /opt/kcptun \
    && cd /opt/kcptun \
    && curl -sSL $KCP_URL | tar xz \
    && rm client_linux_amd64 \
    && cd ~ \
    && apk del .build-deps \
    && apk add --no-cache supervisor \
    && rm -rf /var/cache/apk

COPY supervisord.conf /etc/supervisord.conf

ENV SS_ADDR     0.0.0.0
ENV SS_PORT     8399
ENV SS_PASSWORD 860328
ENV SS_METHOD   aes-256-cfb
ENV SS_TIMEOUT  300

ENV KCP_PORT    30000
ENV KCP_KEY     860328
ENV KCP_CRYPT   aes-128
ENV KCP_MODE    fast
ENV KCP_MTU         1350
ENV KCP_SNDWND      1024
ENV KCP_RCVWND      1024
ENV KCP_DATASHARED   10
ENV KCP_PARITYSHARED 3
ENV KCP_DSCP        0

EXPOSE $SS_PORT/tcp
EXPOSE $SS_PORT/udp
EXPOSE $KCP_PORT/udp

ENTRYPOINT ["/usr/bin/supervisord"]
