#!/bin/sh
set -eu

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

extract_default_version() {
  awk -F: '/^ARG OPENCLAW_IMAGE=ghcr\.io\/openclaw\/openclaw:/ {print $NF; exit}' Dockerfile
}

assert_contains() {
  file=$1
  expected=$2

  if ! grep -Fqx "$expected" "$file"; then
    fail "$file is missing expected line: $expected"
  fi
}

default_version=$(extract_default_version)
[ -n "$default_version" ] || fail "failed to read default OpenClaw version from Dockerfile"

assert_contains README.md "OPENCLAW_IMAGE=REGISTRY/openclaw:${default_version} \\"
assert_contains README.md "  REGISTRY/openclaw:${default_version} \\"
assert_contains CONTRIBUTING.md "OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:${default_version} \\"
assert_contains examples/docker-compose.yaml "    image: REGISTRY/openclaw:${default_version}"
assert_contains examples/kubernetes-init-container.yaml "          image: REGISTRY/openclaw:${default_version}"

echo "All OpenClaw version doc tests passed."
