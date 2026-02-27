#!/bin/sh
set -eu

CONFIG_FILE="${1:-/seed-config/seed-config.json}"

log() {
  printf '%s %s\n' "[$(date -u +%Y-%m-%dT%H:%M:%SZ)]" "[offline-seed-build] $*"
}

if [ ! -f "$CONFIG_FILE" ]; then
  log "ERROR: config file not found: $CONFIG_FILE"
  exit 1
fi

# Validate JSON format early.
node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));' "$CONFIG_FILE"

mkdir -p /seed/skills
mkdir -p /seed/extensions
mkdir -p /tmp/openclaw-home/.openclaw/workspace/skills

log "Using config: $CONFIG_FILE"

install_plugins_from_config() {
  node -e '
    const fs = require("fs");
    const cfg = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    const plugins = Array.isArray(cfg.plugins) ? cfg.plugins : [];
    for (const p of plugins) {
      if (!p) continue;
      if (typeof p === "string") {
        if (p.trim()) console.log(p.trim());
        continue;
      }
      if (typeof p === "object") {
        if (p.enabled === false) continue;
        const spec = typeof p.spec === "string" ? p.spec.trim() : "";
        if (spec) console.log(spec);
      }
    }
  ' "$CONFIG_FILE" | while IFS= read -r spec; do
    [ -z "$spec" ] && continue
    log "Installing plugin spec: $spec"
    echo '{}' > /tmp/openclaw.plugins-install.json
    if ! OPENCLAW_CONFIG_PATH=/tmp/openclaw.plugins-install.json \
      node /app/openclaw.mjs plugins install "$spec"; then
      log "WARNING: failed to install plugin: $spec"
    fi
  done
}

install_skills_from_config() {
  node -e '
    const fs = require("fs");
    const cfg = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    const skills = Array.isArray(cfg.skills) ? cfg.skills : [];
    for (const s of skills) {
      if (!s) continue;
      if (typeof s === "string") {
        if (s.trim()) console.log(s.trim());
        continue;
      }
      if (typeof s === "object") {
        if (s.enabled === false) continue;
        const slug = typeof s.slug === "string" ? s.slug.trim() : "";
        if (slug) console.log(slug);
      }
    }
  ' "$CONFIG_FILE" | while IFS= read -r slug; do
    [ -z "$slug" ] && continue
    log "Installing skill: $slug"
    cd /tmp/openclaw-home/.openclaw/workspace
    if ! npx -y clawhub install "$slug" --no-input; then
      log "WARNING: failed to install skill: $slug"
    fi
  done
}

install_plugins_from_config
install_skills_from_config

# Export installed extensions and skills from build-time OPENCLAW_HOME.
if [ -d /tmp/openclaw-home/.openclaw/extensions ]; then
  cp -a /tmp/openclaw-home/.openclaw/extensions/. /seed/extensions/
fi
if [ -d /tmp/openclaw-home/.openclaw/workspace/skills ]; then
  cp -a /tmp/openclaw-home/.openclaw/workspace/skills/. /seed/skills/
fi

# Merge vendored local content (useful for fully offline builds).
if [ -d /seed-local/plugins ] && [ "$(ls -A /seed-local/plugins 2>/dev/null)" ]; then
  log "Copying vendored local plugins from /seed-local/plugins"
  cp -a /seed-local/plugins/. /seed/extensions/
fi
if [ -d /seed-local/skills ] && [ "$(ls -A /seed-local/skills 2>/dev/null)" ]; then
  log "Copying vendored local skills from /seed-local/skills"
  cp -a /seed-local/skills/. /seed/skills/
fi

log "Seed image payload ready at /seed"
