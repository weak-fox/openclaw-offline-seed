#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
RESOLVER="$SCRIPT_DIR/resolve-seed-release.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_eq() {
  expected=$1
  actual=$2
  message=$3

  if [ "$expected" != "$actual" ]; then
    fail "$message (expected: $expected, actual: $actual)"
  fi
}

get_value() {
  key=$1
  output=$2

  printf '%s\n' "$output" | awk -F= -v key="$key" '$1 == key { print substr($0, length(key) + 2) }' | tail -n1
}

make_repo() {
  repo_dir=$(mktemp -d)

  (
    cd "$repo_dir"
    git init -q
    git config user.name "Test User"
    git config user.email "test@example.com"
    printf '%s\n' "${1:-1.0.0}" > VERSION
    printf 'seed\n' > README.md
    git add VERSION README.md
    git commit -qm "init"
  )

  printf '%s\n' "$repo_dir"
}

cleanup() {
  for dir in "$@"; do
    rm -rf "$dir"
  done
}

repo_a=$(make_repo 1.0.0)
repo_b=$(make_repo 1.0.0)
repo_c=$(make_repo 1.0.0)
repo_d=$(make_repo 1.0.1)
repo_e=$(make_repo 1.0.2)
trap 'cleanup "$repo_a" "$repo_b" "$repo_c" "$repo_d" "$repo_e"' EXIT INT TERM

output_a=$(cd "$repo_a" && sh "$RESOLVER" 2026.3.1)
assert_eq "1.0.0" "$(get_value semver "$output_a")" "uses VERSION as-is for first release"
assert_eq "v1.0.0-oc-2026.3.1" "$(get_value tag "$output_a")" "creates seed tag from initial version"
assert_eq "false" "$(get_value version_changed "$output_a")" "does not rewrite VERSION for first release"
assert_eq "false" "$(get_value target_release_exists "$output_a")" "reports missing release for new OpenClaw version"
assert_eq "1.0.0" "$(tr -d '[:space:]' < "$repo_a/VERSION")" "keeps VERSION unchanged on first release"

(
  cd "$repo_b"
  git tag v1.0.0-oc-2026.3.1
)
output_b=$(cd "$repo_b" && sh "$RESOLVER" 2026.3.1)
assert_eq "1.0.0" "$(get_value semver "$output_b")" "reuses semver when target release tag already exists"
assert_eq "true" "$(get_value target_release_exists "$output_b")" "detects existing release tag for target OpenClaw version"
assert_eq "false" "$(get_value version_changed "$output_b")" "does not bump VERSION when target release already exists"

(
  cd "$repo_c"
  git tag v1.0.0-oc-2026.3.1
)
output_c=$(cd "$repo_c" && sh "$RESOLVER" 2026.3.2)
assert_eq "1.0.1" "$(get_value semver "$output_c")" "bumps patch version for a new OpenClaw release"
assert_eq "v1.0.1-oc-2026.3.2" "$(get_value tag "$output_c")" "creates next seed tag for new OpenClaw release"
assert_eq "true" "$(get_value version_changed "$output_c")" "persists bumped VERSION for a new release"
assert_eq "1.0.1" "$(tr -d '[:space:]' < "$repo_c/VERSION")" "writes bumped version back to VERSION"

output_d=$(cd "$repo_d" && sh "$RESOLVER" 2026.3.3 2.3.4)
assert_eq "2.3.4" "$(get_value semver "$output_d")" "allows manual seed semver override"
assert_eq "v2.3.4-oc-2026.3.3" "$(get_value tag "$output_d")" "uses manual semver in tag"
assert_eq "true" "$(get_value version_changed "$output_d")" "updates VERSION when manual override changes it"
assert_eq "2.3.4" "$(tr -d '[:space:]' < "$repo_d/VERSION")" "persists manual semver override"

(
  cd "$repo_e"
  git tag v1.0.0-oc-2026.3.1
)
output_e=$(cd "$repo_e" && sh "$RESOLVER" 2026.3.1)
assert_eq "1.0.0" "$(get_value semver "$output_e")" "reuses historical semver for an existing older release"
assert_eq "false" "$(get_value version_changed "$output_e")" "does not downgrade VERSION when re-running an older release"
assert_eq "1.0.2" "$(tr -d '[:space:]' < "$repo_e/VERSION")" "keeps VERSION at the latest project semver during old release reruns"

if (
  cd "$repo_d"
  sh "$RESOLVER" 2026.3.4 invalid >/dev/null 2>&1
); then
  fail "rejects invalid manual semver"
fi

echo "All resolve-seed-release tests passed."
