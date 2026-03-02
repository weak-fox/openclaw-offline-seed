#!/bin/sh
set -eu

IMAGE="${IMAGE:-REGISTRY/openclaw-offline-seed:v1}"
OPENCLAW_IMAGE="${OPENCLAW_IMAGE:-ghcr.io/openclaw/openclaw:2026.3.1}"
CONFIG_PATH="${CONFIG_PATH:-config/seed-config.json}"

if [ ! -f "$CONFIG_PATH" ]; then
  echo "ERROR: CONFIG_PATH not found: $CONFIG_PATH" >&2
  exit 1
fi

echo "Building $IMAGE"
echo "  OPENCLAW_IMAGE=$OPENCLAW_IMAGE"
echo "  CONFIG_PATH=$CONFIG_PATH"

docker build \
  --build-arg OPENCLAW_IMAGE="$OPENCLAW_IMAGE" \
  --build-arg SEED_CONFIG="$CONFIG_PATH" \
  -t "$IMAGE" \
  -f Dockerfile \
  .
