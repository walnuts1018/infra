# syntax=docker/dockerfile:1
FROM ghcr.io/netbox-community/netbox:v4.6.8@sha256:1abb7a50280cde87aca7e1a7391cde620f18c617333b24692adb1c077e58ecda
RUN --mount=type=cache,target=/root/.cache/uv \
    /usr/local/bin/uv pip install \
    netbox-bgp \
    netbox-topology-views \
    netboxlabs-diode-netbox-plugin
