# syntax=docker/dockerfile:1
FROM ghcr.io/netbox-community/netbox:v4.6.6@sha256:9d89ab99d6c45b6b24f6f18f6a0c0eb173f65b630b16814577858a58d51cdb94
RUN --mount=type=cache,target=/root/.cache/uv \
    /usr/local/bin/uv pip install \
    netbox-bgp \
    netbox-topology-views \
    netboxlabs-diode-netbox-plugin
