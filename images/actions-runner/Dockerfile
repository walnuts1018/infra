# syntax=docker/dockerfile:1
FROM ghcr.io/actions/actions-runner:2.336.0

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
    && rm -rf /var/lib/apt/lists/*

USER runner
