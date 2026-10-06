# syntax=docker/dockerfile:1
FROM ghcr.io/falcondev-oss/actions-runner:2.337.0@sha256:32a63e960641cde7df61ee56e18576d9781d3980f3e6461d379308b88ec5c036

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
