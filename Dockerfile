FROM alpine:latest AS builder
LABEL maintainer="V2Fly Community <dev@v2fly.org>"

WORKDIR /tmp
ARG TARGETPLATFORM
ARG TAG
COPY v2ray.sh "${WORKDIR}"/v2ray.sh

RUN set -ex \
    && apk add --no-cache ca-certificates \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/v2ray/access.log \
    && ln -sf /dev/stderr /var/log/v2ray/error.log \
    && chmod +x "${WORKDIR}"/v2ray.sh \
    && "${WORKDIR}"/v2ray.sh "${TARGETPLATFORM}" "${TAG}"

COPY config.json /etc/v2ray/config.json
COPY v2ray.cer /etc/v2ray/v2ray.cer
COPY v2ray.key /etc/v2ray/v2ray.key

EXPOSE 443

ENTRYPOINT ["/usr/bin/v2ray"]
