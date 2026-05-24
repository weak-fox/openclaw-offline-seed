#!/bin/sh
set -eu

OPENCLAW_HOME_DIR="${OPENCLAW_HOME_DIR:-/home/node/.openclaw}"
SKILLS_SRC="/seed/skills"
EXT_SRC="/seed/extensions"
PLUGIN_SKILLS_SRC="/seed/plugin-skills"

log() {
  printf '%s %s\n' "[$(date -u +%Y-%m-%dT%H:%M:%SZ)]" "[offline-seed-init] $*"
}

mkdir -p "$OPENCLAW_HOME_DIR/workspace/skills"
mkdir -p "$OPENCLAW_HOME_DIR/extensions"
mkdir -p "$OPENCLAW_HOME_DIR/plugin-skills"

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

if [ -d "$PLUGIN_SKILLS_SRC" ] && [ "$(ls -A "$PLUGIN_SKILLS_SRC" 2>/dev/null)" ]; then
  log "Syncing plugin skills into $OPENCLAW_HOME_DIR/plugin-skills"
  for skill in "$PLUGIN_SKILLS_SRC"/*; do
    [ -d "$skill" ] || continue
    name="$(basename "$skill")"
    rm -rf "$OPENCLAW_HOME_DIR/plugin-skills/$name"
    cp -r "$skill" "$OPENCLAW_HOME_DIR/plugin-skills/$name"
  done
fi

log "Offline seed sync complete"
