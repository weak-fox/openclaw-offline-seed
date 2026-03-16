#!/bin/sh
set -eu

SEED_IMAGE=${1:-${SEED_IMAGE:-}}

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

[ -n "$SEED_IMAGE" ] || fail "missing seed image reference"

docker run --rm --entrypoint sh "$SEED_IMAGE" -lc '
set -eu

check_dir() {
  root=$1
  [ -d "$root" ] || return 0

  for entry in "$root"/*; do
    [ -e "$entry" ] || continue
    [ -d "$entry" ] || continue

    if [ ! -r "$entry" ] || [ ! -x "$entry" ]; then
      echo "Unreadable seed directory: $entry" >&2
      stat -c "%A %u:%g %n" "$entry" >&2
      exit 1
    fi
  done
}

check_dir /seed/extensions
check_dir /seed/skills
' || fail "seed image contains unreadable payload directories for runtime user"

echo "All seed image permission tests passed."
