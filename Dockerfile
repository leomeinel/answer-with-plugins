###
# File: Dockerfile
# Author: Leopold Johannes Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2025 Leopold Johannes Meinel & contributors
# SPDX ID: Apache-2.0
# URL: https://www.apache.org/licenses/LICENSE-2.0
###

# Initialize /usr/bin/answer
# INFO: Replace version
FROM docker.io/apache/answer:1.7.0 AS answer-builder
# INFO: Replace version
FROM code.forgejo.org/oci/golang:1.25-alpine3.22 AS golang-builder
COPY --from=answer-builder /usr/bin/answer /usr/bin/answer

# Set build time variables
# INFO: Replace version
ARG PNPM_VERSION=10.20.0
ARG ANSWER_MODULE=github.com/apache/answer@v1.7.0

# Install dependencies
RUN apk --no-cache add \
    build-base git bash nodejs npm go && \
    npm install -g pnpm@${PNPM_VERSION}

# Build /usr/bin/new_answer
COPY scripts/ /scripts
RUN chmod 755 /scripts/*.sh
RUN ["/bin/bash","-c","/scripts/build.sh"]

# Defaults from https://github.com/apache/answer/blob/main/Dockerfile
# INFO: Replace version
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
