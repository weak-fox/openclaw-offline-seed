#!/bin/sh
set -eu

TARGET_VERSION=${1:-${TARGET_VERSION:-}}
INPUT_SEMVER=${2:-${INPUT_SEMVER:-}}
VERSION_FILE=${VERSION_FILE:-VERSION}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

validate_semver() {
  value=$1

  if ! printf '%s\n' "$value" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    fail "Invalid semver: $value"
  fi
}

validate_openclaw_version() {
  value=$1

  if ! printf '%s\n' "$value" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    fail "Invalid OpenClaw version: $value"
  fi
}

bump_patch() {
  version=$1
  major=$(printf '%s' "$version" | cut -d. -f1)
  minor=$(printf '%s' "$version" | cut -d. -f2)
  patch=$(printf '%s' "$version" | cut -d. -f3)

  printf '%s.%s.%s\n' "$major" "$minor" "$((patch + 1))"
}

emit_output() {
  key=$1
  value=$2

  printf '%s=%s\n' "$key" "$value"
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    printf '%s=%s\n' "$key" "$value" >> "$GITHUB_OUTPUT"
  fi
}

select_highest_semver() {
  target_version=$1

  git tag -l "v*-oc-$target_version" \
    | sed -n 's/^v\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)-oc-.*$/\1/p' \
    | sort -t. -k1,1n -k2,2n -k3,3n \
    | tail -n1
}

[ -n "$TARGET_VERSION" ] || fail "Missing target OpenClaw version"
validate_openclaw_version "$TARGET_VERSION"

[ -f "$VERSION_FILE" ] || fail "Missing version file: $VERSION_FILE"
current_version=$(tr -d '[:space:]' < "$VERSION_FILE")
[ -n "$current_version" ] || fail "Empty version file: $VERSION_FILE"
validate_semver "$current_version"

selected_semver=
should_persist_version=false
if [ -n "$INPUT_SEMVER" ]; then
  validate_semver "$INPUT_SEMVER"
  selected_semver=$INPUT_SEMVER
  should_persist_version=true
else
  target_semver=$(select_highest_semver "$TARGET_VERSION")
  if [ -n "$target_semver" ]; then
    selected_semver=$target_semver
  elif git tag -l 'v*-oc-*' | grep . >/dev/null 2>&1; then
    selected_semver=$(bump_patch "$current_version")
    should_persist_version=true
  else
    selected_semver=$current_version
  fi
fi

validate_semver "$selected_semver"
seed_tag="v${selected_semver}-oc-${TARGET_VERSION}"
version_changed=false

if [ "$should_persist_version" = "true" ] && [ "$selected_semver" != "$current_version" ]; then
  printf '%s\n' "$selected_semver" > "$VERSION_FILE"
  version_changed=true
fi

target_release_exists=false
if git rev-parse -q --verify "refs/tags/$seed_tag" >/dev/null 2>&1; then
  target_release_exists=true
fi

emit_output semver "$selected_semver"
emit_output tag "$seed_tag"
emit_output version_changed "$version_changed"
emit_output target_release_exists "$target_release_exists"
