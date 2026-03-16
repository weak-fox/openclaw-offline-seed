#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
RESOLVER="$SCRIPT_DIR/resolve-openclaw-version.sh"

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

make_fake_gh() {
  bin_dir=$(mktemp -d)

  cat > "$bin_dir/gh" <<'EOF'
#!/bin/sh
set -eu
printf '%s\n' "${FAKE_GH_TAG:-}"
EOF
  chmod +x "$bin_dir/gh"

  printf '%s\n' "$bin_dir"
}

cleanup() {
  for dir in "$@"; do
    rm -rf "$dir"
  done
}

[ -f "$RESOLVER" ] || fail "missing resolver script: $RESOLVER"

gh_bin=$(make_fake_gh)
trap 'cleanup "$gh_bin"' EXIT INT TERM

output_a=$(PATH="$gh_bin:$PATH" FAKE_GH_TAG="v2026.3.13-1" sh "$RESOLVER")
assert_eq "version=2026.3.13-1" "$output_a" "reads latest release tags with revision suffixes"

output_b=$(sh "$RESOLVER" 2026.3.13-1)
assert_eq "version=2026.3.13-1" "$output_b" "accepts explicit OpenClaw versions with revision suffixes"

if sh "$RESOLVER" invalid >/dev/null 2>&1; then
  fail "rejects invalid OpenClaw versions"
fi

echo "All resolve-openclaw-version tests passed."
