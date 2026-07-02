# syntax=docker/dockerfile:1
FROM ghcr.io/netbox-community/netbox:v4.6.4@sha256:79a155d9dee2012a5677eca8abb8662022797d7b7690c8db41fd360a89cad32f
RUN --mount=type=cache,target=/root/.cache/uv \
    /usr/local/bin/uv pip install \
    netbox-bgp \
    netbox-topology-views \
    netboxlabs-diode-netbox-plugin
