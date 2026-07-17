# syntax=docker/dockerfile:1
FROM ghcr.io/netbox-community/netbox:v4.6.5@sha256:691ec1a4f569f3dfb9fefd9f086cca1b39689ad59c3eae753712a741447e5e60
RUN --mount=type=cache,target=/root/.cache/uv \
    /usr/local/bin/uv pip install \
    netbox-bgp \
    netbox-topology-views \
    netboxlabs-diode-netbox-plugin
