# syntax=docker/dockerfile:1
FROM ghcr.io/netbox-community/netbox:v4.6.7@sha256:7ad3a287d38829c98799c4a03d874d3d309738d1f42987dfd8037ec0e80587ce
RUN --mount=type=cache,target=/root/.cache/uv \
    /usr/local/bin/uv pip install \
    netbox-bgp \
    netbox-topology-views \
    netboxlabs-diode-netbox-plugin
