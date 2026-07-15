# syntax=docker/dockerfile:1
FROM ghcr.io/netbox-community/netbox:v4.6.5@sha256:980b4cba2c53bf806762b890e0d683eb23413330aa1f94f0c06f0cad31603f39
RUN --mount=type=cache,target=/root/.cache/uv \
    /usr/local/bin/uv pip install \
    netbox-bgp \
    netbox-topology-views \
    netboxlabs-diode-netbox-plugin
