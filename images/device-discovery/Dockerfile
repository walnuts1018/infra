# syntax=docker/dockerfile:1
FROM python:3.12-slim-bullseye AS builder

ARG ORB_DISCOVERY_REF=develop

WORKDIR /usr/src/app

ADD https://github.com/netboxlabs/orb-discovery/archive/${ORB_DISCOVERY_REF}.tar.gz /tmp/orb-discovery.tar.gz

RUN tar -xzf /tmp/orb-discovery.tar.gz --strip-components=2 -C /usr/src/app orb-discovery-${ORB_DISCOVERY_REF}/device-discovery

RUN python -m venv /opt/venv \
    && . /opt/venv/bin/activate \
    && pip install --no-cache-dir . \
    && deactivate

FROM python:3.12-slim-bullseye

RUN addgroup --system netdev \
    && useradd -m --shell /bin/bash -G netdev appuser \
    && echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY --from=builder /opt/venv /opt/venv

LABEL maintainer="techops@netboxlabs.com"
LABEL org.opencontainers.image.title="Orb Device Discovery"
LABEL org.opencontainers.image.url="https://github.com/netboxlabs/orb-discovery/tree/develop/device-discovery"
LABEL org.opencontainers.image.documentation="https://github.com/netboxlabs/orb-discovery/tree/develop/device-discovery"
LABEL org.opencontainers.image.description="NetBox Labs device-discovery image"
LABEL org.opencontainers.image.vendor="NetBox Labs, Inc"
LABEL org.opencontainers.image.authors="techops@netboxlabs.com"
LABEL org.opencontainers.image.licenses="Apache-2.0"

ENV PATH="/opt/venv/bin:$PATH"

USER appuser

CMD ["device-discovery"]
