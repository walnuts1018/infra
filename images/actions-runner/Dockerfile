# syntax=docker/dockerfile:1
FROM ghcr.io/falcondev-oss/actions-runner:2.338.1@sha256:6d8e4376dbff85372f11589f2087d719292452bc95124d2e4da1bd5b913d12d1

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libatomic1 \
    pkg-config \
    sudo \
    zstd \
    && rm -rf /var/lib/apt/lists/*

USER runner
