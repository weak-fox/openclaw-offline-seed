#!/bin/sh
set -eu

INPUT_VERSION=${1:-${INPUT_VERSION:-}}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

validate_openclaw_version() {
  value=$1

  if ! printf '%s\n' "$value" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9]+)?$'; then
    fail "Invalid OpenClaw version: $value"
  fi
}

emit_output() {
  key=$1
  value=$2

  printf '%s=%s\n' "$key" "$value"
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    printf '%s=%s\n' "$key" "$value" >> "$GITHUB_OUTPUT"
  fi
}

target=$INPUT_VERSION
if [ -z "$target" ]; then
  target=$(gh api repos/openclaw/openclaw/releases/latest --jq '.tag_name' | sed 's/^v//')
fi

[ -n "$target" ] || fail "Missing OpenClaw version"
validate_openclaw_version "$target"

emit_output version "$target"
echo "Target OpenClaw version: $target" >&2
