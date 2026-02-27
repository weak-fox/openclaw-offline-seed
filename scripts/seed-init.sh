#!/bin/sh
set -eu

OPENCLAW_HOME_DIR="${OPENCLAW_HOME_DIR:-/home/node/.openclaw}"
SKILLS_SRC="/seed/skills"
EXT_SRC="/seed/extensions"

log() {
  printf '%s %s\n' "[$(date -u +%Y-%m-%dT%H:%M:%SZ)]" "[offline-seed-init] $*"
}

mkdir -p "$OPENCLAW_HOME_DIR/workspace/skills"
mkdir -p "$OPENCLAW_HOME_DIR/extensions"

if [ -d "$SKILLS_SRC" ] && [ "$(ls -A "$SKILLS_SRC" 2>/dev/null)" ]; then
  log "Copying skills into $OPENCLAW_HOME_DIR/workspace/skills"
  cp -r "$SKILLS_SRC"/. "$OPENCLAW_HOME_DIR/workspace/skills/"
fi

if [ -d "$EXT_SRC" ] && [ "$(ls -A "$EXT_SRC" 2>/dev/null)" ]; then
  log "Syncing extensions into $OPENCLAW_HOME_DIR/extensions"
  for ext in "$EXT_SRC"/*; do
    [ -d "$ext" ] || continue
    name="$(basename "$ext")"
    rm -rf "$OPENCLAW_HOME_DIR/extensions/$name"
    cp -r "$ext" "$OPENCLAW_HOME_DIR/extensions/$name"
  done
fi

log "Offline seed sync complete"
