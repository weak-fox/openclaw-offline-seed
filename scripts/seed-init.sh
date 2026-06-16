#!/bin/sh
set -eu

OPENCLAW_HOME_DIR="${OPENCLAW_HOME_DIR:-/home/node/.openclaw}"
SKILLS_SRC="/seed/skills"
EXT_SRC="/seed/extensions"
NPM_PROJECTS_SRC="/seed/npm/projects"

log() {
  printf '%s %s\n' "[$(date -u +%Y-%m-%dT%H:%M:%SZ)]" "[offline-seed-init] $*"
}

mkdir -p "$OPENCLAW_HOME_DIR/workspace/skills"
mkdir -p "$OPENCLAW_HOME_DIR/extensions"
mkdir -p "$OPENCLAW_HOME_DIR/npm/projects"

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

if [ -d "$NPM_PROJECTS_SRC" ] && [ "$(ls -A "$NPM_PROJECTS_SRC" 2>/dev/null)" ]; then
  log "Syncing npm plugin projects into $OPENCLAW_HOME_DIR/npm/projects"
  for project in "$NPM_PROJECTS_SRC"/*; do
    [ -d "$project" ] || continue
    name="$(basename "$project")"
    rm -rf "$OPENCLAW_HOME_DIR/npm/projects/$name"
    cp -r "$project" "$OPENCLAW_HOME_DIR/npm/projects/$name"
  done
fi

log "Offline seed sync complete"
