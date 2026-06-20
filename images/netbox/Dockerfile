# syntax=docker/dockerfile:1
FROM ghcr.io/netbox-community/netbox:v4.6.3@sha256:7fc399e59ceaac1c58adfdc0c0f28cf22453f06f784c6118576deb399957c478
RUN --mount=type=cache,target=/root/.cache/pip \
    /opt/netbox/venv/bin/pip install --no-warn-script-location \
    netbox-bgp \
    netbox-topology-views
