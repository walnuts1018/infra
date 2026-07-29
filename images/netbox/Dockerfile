# syntax=docker/dockerfile:1
FROM ghcr.io/netbox-community/netbox:v4.6.6@sha256:974fb6ee8613fd75e236422f62e0ede82cd98cf5ac9f214a53dc889150cb39ec
RUN --mount=type=cache,target=/root/.cache/uv \
    /usr/local/bin/uv pip install \
    netbox-bgp \
    netbox-topology-views \
    netboxlabs-diode-netbox-plugin
