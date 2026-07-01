# syntax=docker/dockerfile:1
FROM ghcr.io/netbox-community/netbox:v4.6.4@sha256:9758cdb571114659c9dbe14c5a51c7f003b4eb4a611152d28314afc569c320f7
RUN --mount=type=cache,target=/root/.cache/uv \
    /usr/local/bin/uv pip install \
    netbox-bgp \
    netbox-topology-views \
    netboxlabs-diode-netbox-plugin
