# mcp-stack

Automated MCP connector bootstrap for **Perplexity Enterprise Pro** + 11 connectors.

> Generated and pushed by Perplexity AI (May 2026)

## Connectors Included

| # | Connector | Auth Type |
|---|---|---|
| 1 | GitHub | OAuth / PAT |
| 2 | Notion | OAuth |
| 3 | StackOne | API Key |
| 4 | Cloudflare | API Token |
| 5 | Firecrawl | API Key |
| 6 | Make | API Key |
| 7 | Google Drive | OAuth2 |
| 8 | Microsoft OneDrive | OAuth2 |
| 9 | Discord | Bot Token |
| 10 | Supabase | Service Key |
| 11 | Sentry | Auth Token |

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/pureplatinum765-collab/mcp-stack.git
cd mcp-stack

# 2. Bootstrap (creates .env, validates JSON, checks token status)
bash bootstrap.sh

# 3. Fill in your tokens
nano .env   # or use your preferred editor

# 4. Validate all connectors
bash validate.sh

# 5. Run a specific connector only
bash validate.sh github
```

## File Reference

| File | Purpose |
|---|---|
| `connectors.json` | Connector definitions: auth type, MCP server URL, health endpoint |
| `tools.json` | MCP tool definitions per connector (read + write scoped) |
| `permissions.json` | Minimal-permission policy (read-only bootstrap → write after validation) |
| `.env.example` | Token placeholder template — copy to `.env` and fill in |
| `bootstrap.sh` | Idempotent setup script |
| `validate.sh` | Read-only health checks per connector |
| `smoke-test-prompt.md` | Paste into Perplexity to exercise all 11 connectors |
| `agent-handoff-map.md` | Which AI agent handles which tasks and where each one's limits are |

## Security Notes

- `.env` is in `.gitignore` — never commit real tokens
- Default permissions are **read-only** until `validate.sh` passes
- Recommended: `chmod 600 .env`
- For production: use a secrets manager (AWS Secrets Manager, Doppler, 1Password Secrets Automation)

## Agent Handoff

See [`agent-handoff-map.md`](./agent-handoff-map.md) for the full breakdown of which tasks go to:
- **Perplexity** (orchestration + MCP actions)
- **Google Jules** (async PR automation via Gemini 3.1 Pro)
- **Claude Code** (terminal-level agentic coding)
- **Microsoft Copilot Studio** (enterprise M365 workflows)

## License

MIT
