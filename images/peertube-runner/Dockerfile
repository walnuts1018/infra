# syntax=docker/dockerfile:1

FROM docker.io/node:22-trixie-slim@sha256:c5849ff9c9ebcd66615412f0b548ca5b8ecaef84003dc9ac2e077ebe46aaa3f6

ARG DEBIAN_FRONTEND=noninteractive

ENV HOME=/home/peertube \
    NODE_ENV=production \
    NPM_CONFIG_AUDIT=false \
    NPM_CONFIG_FUND=false \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    PATH=/opt/peertube-runner/node_modules/.bin:${PATH}

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install --no-install-recommends --yes \
    ca-certificates \
    ffmpeg

RUN groupadd --system --gid 999 peertube \
    && useradd --system --create-home --home-dir /home/peertube --uid 999 --gid 999 --shell /usr/sbin/nologin peertube \
    && install --directory --owner 999 --group 999 /opt/peertube-runner

WORKDIR /opt/peertube-runner

COPY package.json package-lock.json ./

RUN --mount=type=cache,target=/root/.npm,sharing=locked \
    npm ci --ignore-scripts --omit=dev

COPY --chown=999:999 bootstrap.mjs ./

USER 999:999

CMD ["peertube-runner", "server"]
