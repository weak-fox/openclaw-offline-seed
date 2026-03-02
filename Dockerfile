ARG OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:2026.3.1
ARG SEED_CONFIG=config/seed-config.json

FROM ${OPENCLAW_IMAGE} AS builder

ARG SEED_CONFIG
USER root
ENV HOME=/tmp
ENV NPM_CONFIG_CACHE=/tmp/.npm
ENV OPENCLAW_HOME=/tmp/openclaw-home

COPY --chmod=755 scripts/build-seed.sh /usr/local/bin/build-seed.sh
COPY skills/ /seed-local/skills/
COPY plugins/ /seed-local/plugins/
COPY ${SEED_CONFIG} /seed-config/seed-config.json

RUN /usr/local/bin/build-seed.sh /seed-config/seed-config.json

FROM alpine:3.20

RUN addgroup -g 1000 -S node \
    && adduser -u 1000 -S node -G node

COPY --from=builder /seed /seed
COPY --chmod=755 scripts/seed-init.sh /usr/local/bin/seed-init.sh

USER 1000:1000
ENTRYPOINT ["/usr/local/bin/seed-init.sh"]
