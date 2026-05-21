#!/usr/bin/env bash
# validate.sh — Read-only health checks for all MCP connectors
# Usage: bash validate.sh [connector_id]
# Example: bash validate.sh github
set -euo pipefail

[ -f .env ] && source .env || { echo "[error] .env not found. Run bootstrap.sh first."; exit 1; }

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }
warn() { echo -e "${YELLOW}[SKIP]${NC} $1"; }
log()  { echo -e "${BLUE}[validate]${NC} $1"; }

check_url() {
  local name="$1" url="$2" token="$3" header="$4"
  local http_code
  http_code=$(curl -s -o /dev/null -w "%{http_code}" -H "${header}: ${token}" "$url" 2>/dev/null)
  if [[ "$http_code" == "200" || "$http_code" == "201" ]]; then
    ok "${name} (HTTP ${http_code})"
  else
    fail "${name} (HTTP ${http_code}) — check token and permissions"
  fi
}

FILTER="${1:-all}"

run_check() {
  local id="$1"
  [[ "$FILTER" != "all" && "$FILTER" != "$id" ]] && return
  case $id in
    github)
      [[ -n "${GITHUB_TOKEN:-}" && "${GITHUB_TOKEN}" != *"your_"* ]] \
        && check_url "GitHub" "https://api.github.com/user" "$GITHUB_TOKEN" "Authorization: token" \
        || warn "GitHub — token not set"
      ;;
    notion)
      [[ -n "${NOTION_TOKEN:-}" && "${NOTION_TOKEN}" != *"your_"* ]] \
        && check_url "Notion" "https://api.notion.com/v1/users/me" "$NOTION_TOKEN" "Authorization: Bearer" \
        || warn "Notion — token not set"
      ;;
    cloudflare)
      [[ -n "${CLOUDFLARE_API_TOKEN:-}" && "${CLOUDFLARE_API_TOKEN}" != *"your_"* ]] \
        && check_url "Cloudflare" "https://api.cloudflare.com/client/v4/user" "$CLOUDFLARE_API_TOKEN" "Authorization: Bearer" \
        || warn "Cloudflare — token not set"
      ;;
    firecrawl)
      [[ -n "${FIRECRAWL_API_KEY:-}" && "${FIRECRAWL_API_KEY}" != *"your_"* ]] \
        && check_url "Firecrawl" "https://api.firecrawl.dev/v1/scrape" "$FIRECRAWL_API_KEY" "Authorization: Bearer" \
        || warn "Firecrawl — token not set"
      ;;
    supabase)
      [[ -n "${SUPABASE_SERVICE_KEY:-}" && "${SUPABASE_SERVICE_KEY}" != *"your_"* && -n "${SUPABASE_URL:-}" ]] \
        && check_url "Supabase" "${SUPABASE_URL}/rest/v1/" "$SUPABASE_SERVICE_KEY" "apikey" \
        || warn "Supabase — token or URL not set"
      ;;
    sentry)
      [[ -n "${SENTRY_AUTH_TOKEN:-}" && "${SENTRY_AUTH_TOKEN}" != *"your_"* ]] \
        && check_url "Sentry" "https://sentry.io/api/0/organizations/" "$SENTRY_AUTH_TOKEN" "Authorization: Bearer" \
        || warn "Sentry — token not set"
      ;;
    discord)
      [[ -n "${DISCORD_BOT_TOKEN:-}" && "${DISCORD_BOT_TOKEN}" != *"your_"* ]] \
        && check_url "Discord" "https://discord.com/api/v10/users/@me" "$DISCORD_BOT_TOKEN" "Authorization: Bot" \
        || warn "Discord — token not set"
      ;;
    make)
      warn "Make — health check requires team ID; validate manually at https://www.make.com/api/v2/users/me"
      ;;
    google_drive|onedrive|stackone)
      warn "${id} — OAuth token validation requires browser flow; see README.md"
      ;;
  esac
}

log "Running connector health checks (filter: ${FILTER})..."
echo ""
for id in github notion cloudflare firecrawl supabase sentry discord make google_drive onedrive stackone; do
  run_check "$id"
done
echo ""
log "Validation complete. Fix any FAIL entries, then enable write scopes in permissions.json."
