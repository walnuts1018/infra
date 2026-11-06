# syntax=docker/dockerfile:1
FROM ghcr.io/falcondev-oss/actions-runner:2.338.2@sha256:462ebdbc95fabf0bdf264ffe02ff5182665c6d99ac0f870b67d7f649c1ef1746

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
