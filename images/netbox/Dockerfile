# syntax=docker/dockerfile:1
FROM ghcr.io/netbox-community/netbox:v4.6.8@sha256:3a105e0cc585aa823f327e1034dc5fb7a6e1cea6d210c5bf61badd68d784650d
RUN --mount=type=cache,target=/root/.cache/uv \
    /usr/local/bin/uv pip install \
    netbox-bgp \
    netbox-topology-views \
    netboxlabs-diode-netbox-plugin
