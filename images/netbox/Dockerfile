# syntax=docker/dockerfile:1
FROM ghcr.io/netbox-community/netbox:v4.6.8@sha256:1cc0849088b211d8d796bf6f4e910e062e8437cafcb381c4a40e88077cab61a8
RUN --mount=type=cache,target=/root/.cache/uv \
    /usr/local/bin/uv pip install \
    netbox-bgp \
    netbox-topology-views \
    netboxlabs-diode-netbox-plugin
