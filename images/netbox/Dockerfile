# syntax=docker/dockerfile:1
FROM ghcr.io/netbox-community/netbox:v4.6.7@sha256:1f1f98f1e649f66ff01e2d2751da5a6d4da73a2d47d89ff74d2087e98f823a6d
RUN --mount=type=cache,target=/root/.cache/uv \
    /usr/local/bin/uv pip install \
    netbox-bgp \
    netbox-topology-views \
    netboxlabs-diode-netbox-plugin
