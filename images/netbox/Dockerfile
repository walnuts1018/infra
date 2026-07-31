# syntax=docker/dockerfile:1
FROM ghcr.io/netbox-community/netbox:v4.6.7@sha256:575bdf20e89e0ee0cc40daac55ff9835c7c74686bccd8a5db36ec4ba8db0f440
RUN --mount=type=cache,target=/root/.cache/uv \
    /usr/local/bin/uv pip install \
    netbox-bgp \
    netbox-topology-views \
    netboxlabs-diode-netbox-plugin
