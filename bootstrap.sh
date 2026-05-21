#!/usr/bin/env bash
# bootstrap.sh — Idempotent MCP stack setup
# Usage: bash bootstrap.sh
set -euo pipefail

BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

log()  { echo -e "${BLUE}[bootstrap]${NC} $1"; }
ok()   { echo -e "${GREEN}[ok]${NC} $1"; }
warn() { echo -e "${YELLOW}[warn]${NC} $1"; }
err()  { echo -e "${RED}[error]${NC} $1"; }

log "Starting MCP stack bootstrap..."

# ── 1. Prerequisites ──────────────────────────────────────────────────────────
for cmd in curl jq; do
  if ! command -v $cmd &>/dev/null; then
    err "Required tool '$cmd' not found. Install it and re-run."
    exit 1
  fi
done
ok "Prerequisites: curl, jq found"

# ── 2. Create .env from example if missing ────────────────────────────────────
if [ ! -f .env ]; then
  cp .env.example .env
  chmod 600 .env
  warn ".env created from .env.example — fill in your tokens before running validate.sh"
else
  ok ".env already exists (skipping creation)"
fi

# ── 3. Validate JSON files ────────────────────────────────────────────────────
log "Validating JSON config files..."
for f in connectors.json tools.json permissions.json; do
  if jq empty "$f" 2>/dev/null; then
    ok "$f is valid JSON"
  else
    err "$f is invalid JSON — fix before proceeding"
    exit 1
  fi
done

# ── 4. Count connector definitions ───────────────────────────────────────────
CONNECTOR_COUNT=$(jq '.connectors | length' connectors.json)
log "Found ${CONNECTOR_COUNT} connector definitions in connectors.json"

# ── 5. Check which tokens are filled in .env ──────────────────────────────────
log "Checking token status in .env..."
ENV_KEYS=(
  GITHUB_TOKEN NOTION_TOKEN STACKONE_API_KEY CLOUDFLARE_API_TOKEN
  FIRECRAWL_API_KEY MAKE_API_KEY GOOGLE_DRIVE_TOKEN ONEDRIVE_TOKEN
  DISCORD_BOT_TOKEN SUPABASE_SERVICE_KEY SENTRY_AUTH_TOKEN
)
MISSING=0
for key in "${ENV_KEYS[@]}"; do
  val=$(grep -E "^${key}=" .env | cut -d= -f2- | tr -d '\n')
  if [[ -z "$val" || "$val" == *"your_"* || "$val" == *"_here" ]]; then
    warn "  ${key}: NOT SET (placeholder)"
    MISSING=$((MISSING+1))
  else
    ok "  ${key}: set"
  fi
done

echo ""
if [ $MISSING -gt 0 ]; then
  warn "${MISSING}/${#ENV_KEYS[@]} tokens still need to be filled in .env"
  warn "Edit .env, then run: bash validate.sh"
else
  ok "All tokens are set. Run: bash validate.sh"
fi

echo ""
log "Bootstrap complete."
log "Next: fill .env tokens, then run 'bash validate.sh'"
