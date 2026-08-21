#!/usr/bin/env bash
# validate.sh — Read-only health checks for all MCP connectors
# Usage: bash validate.sh [connector_id]
# Example: bash validate.sh github
set -euo pipefail

load_env() {
  local env_file="$1" line key value
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    [[ -z "$line" || "$line" == \#* ]] && continue
    [[ "$line" == export\ * ]] && line="${line#export }"
    if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      value="${BASH_REMATCH[2]}"
      if [[ "$value" =~ ^\"(.*)\"$ || "$value" =~ ^\'(.*)\'$ ]]; then
        value="${value:1:-1}"
      fi
      export "$key=$value"
    else
      echo "[error] Invalid .env entry: $line" >&2
      return 1
    fi
  done < "$env_file"
}

if [[ ! -f .env ]] || ! load_env .env; then
  echo "[error] .env not found or invalid. Run bootstrap.sh first." >&2
  exit 1
fi

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
      if [[ -n "${GITHUB_TOKEN:-}" && "${GITHUB_TOKEN}" != *"your_"* ]]; then
        check_url "GitHub" "https://api.github.com/user" "$GITHUB_TOKEN" "Authorization: token"
      else
        warn "GitHub — token not set"
      fi
      ;;
    notion)
      if [[ -n "${NOTION_TOKEN:-}" && "${NOTION_TOKEN}" != *"your_"* ]]; then
        check_url "Notion" "https://api.notion.com/v1/users/me" "$NOTION_TOKEN" "Authorization: Bearer"
      else
        warn "Notion — token not set"
      fi
      ;;
    cloudflare)
      if [[ -n "${CLOUDFLARE_API_TOKEN:-}" && "${CLOUDFLARE_API_TOKEN}" != *"your_"* ]]; then
        check_url "Cloudflare" "https://api.cloudflare.com/client/v4/user" "$CLOUDFLARE_API_TOKEN" "Authorization: Bearer"
      else
        warn "Cloudflare — token not set"
      fi
      ;;
    firecrawl)
      if [[ -n "${FIRECRAWL_API_KEY:-}" && "${FIRECRAWL_API_KEY}" != *"your_"* ]]; then
        check_url "Firecrawl" "https://api.firecrawl.dev/v1/scrape" "$FIRECRAWL_API_KEY" "Authorization: Bearer"
      else
        warn "Firecrawl — token not set"
      fi
      ;;
    supabase)
      if [[ -n "${SUPABASE_SERVICE_KEY:-}" && "${SUPABASE_SERVICE_KEY}" != *"your_"* && -n "${SUPABASE_URL:-}" ]]; then
        check_url "Supabase" "${SUPABASE_URL}/rest/v1/" "$SUPABASE_SERVICE_KEY" "apikey"
      else
        warn "Supabase — token or URL not set"
      fi
      ;;
    sentry)
      if [[ -n "${SENTRY_AUTH_TOKEN:-}" && "${SENTRY_AUTH_TOKEN}" != *"your_"* ]]; then
        check_url "Sentry" "https://sentry.io/api/0/organizations/" "$SENTRY_AUTH_TOKEN" "Authorization: Bearer"
      else
        warn "Sentry — token not set"
      fi
      ;;
    discord)
      if [[ -n "${DISCORD_BOT_TOKEN:-}" && "${DISCORD_BOT_TOKEN}" != *"your_"* ]]; then
        check_url "Discord" "https://discord.com/api/v10/users/@me" "$DISCORD_BOT_TOKEN" "Authorization: Bot"
      else
        warn "Discord — token not set"
      fi
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
