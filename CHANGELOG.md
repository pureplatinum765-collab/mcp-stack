# Changelog

All notable changes to mcp-stack are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.1.0] - 2026-05-27

### Fixed
- Corrected MCP server URLs for all 11 connectors to use verified/official endpoints
  - Notion: `https://mcp.notion.com/sse`
  - Firecrawl: `https://mcp.firecrawl.dev/sse`
  - Supabase: `https://mcp.supabase.com/sse`
  - Sentry: `https://mcp.sentry.io/sse`
  - StackOne: `https://mcp.stackone.com/sse`
  - Make: `https://mcp.make.com/sse`
  - GitHub: `https://api.githubcopilot.com/mcp/`

### Added
- `connector-status.md` — live tracking table for which connectors are tested vs. placeholder
- `routing.md` — agent decision guide for ambiguous multi-agent tasks
- `.github/workflows/ci.yml` — CI pipeline: JSON validation, secret scanning (Gitleaks), ShellCheck linting
- `CHANGELOG.md` — this file
- `docs` links added to every connector definition in `connectors.json`

## [1.0.0] - 2026-05-21

### Added
- Initial bootstrap: 11 connector definitions (GitHub, Notion, StackOne, Cloudflare, Firecrawl, Make, Google Drive, OneDrive, Discord, Supabase, Sentry)
- `bootstrap.sh` — idempotent setup script
- `validate.sh` — read-only health checks
- `connectors.json`, `tools.json`, `permissions.json`
- `.env.example` — token placeholder template
- `smoke-test-prompt.md` — Perplexity paste-in connector exercise
- `agent-handoff-map.md` — multi-agent task routing reference
