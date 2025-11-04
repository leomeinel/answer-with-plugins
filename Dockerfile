###
# File: Dockerfile
# Author: Leopold Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2025 Leopold Meinel & contributors
# SPDX ID: MIT
# URL: https://opensource.org/licenses/MIT
# -----
###

# Initialize /usr/bin/answer
# INFO: Replace VERSION
# FIXME: This should use 1.7.0 after release
FROM docker.io/apache/answer:1.6.0 AS answer-builder
# INFO: Replace VERSION
FROM code.forgejo.org/oci/golang:1.25-alpine3.22 AS golang-builder
COPY --from=answer-builder /usr/bin/answer /usr/bin/answer

# Install dependencies
# INFO: Replace VERSION
ENV PNPM_VERSION="10.20.0"
RUN apk --no-cache add \
    build-base git bash nodejs npm go && \
    npm install -g pnpm@${PNPM_VERSION}

# Build /usr/bin/new_answer
COPY scripts/ /scripts
RUN chmod +x /scripts/*.sh
RUN ["/bin/bash","-c","/scripts/build.sh"]

# Defaults from https://github.com/apache/answer/blob/main/Dockerfile
# INFO: Replace VERSION
FROM code.forgejo.org/oci/alpine:latest
LABEL maintainer="linkinstar@apache.org"

ARG TIMEZONE
ENV TIMEZONE=${TIMEZONE:-"Asia/Shanghai"}

RUN apk update \
    && apk --no-cache add \
        bash \
        ca-certificates \
        curl \
        dumb-init \
        gettext \
        openssh \
        sqlite \
        gnupg \
        tzdata \
    && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone

# Defaults from https://answer.apache.org/docs/plugins/#build-with-plugin-from-answer-base-image
COPY --from=golang-builder /usr/bin/new_answer /usr/bin/answer
COPY --from=answer-builder /data /data
COPY --from=answer-builder /entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

VOLUME /data
ENTRYPOINT ["/entrypoint.sh"]
