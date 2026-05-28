# Connector Status

Track which connectors have been live-tested vs. configured as placeholders.
Update this file after each successful `bash validate.sh` run.

| Connector | MCP Server URL | Auth Type | Status | Last Tested | Notes |
|---|---|---|---|---|---|
| GitHub | `https://api.githubcopilot.com/mcp/` | OAuth / PAT | ⬜ Untested | | |
| Notion | `https://mcp.notion.com/sse` | OAuth | ⬜ Untested | | |
| StackOne | `https://mcp.stackone.com/sse` | API Key | ⬜ Untested | | |
| Cloudflare | `https://cloudflare.com/mcp` | API Token | ⬜ Untested | | |
| Firecrawl | `https://mcp.firecrawl.dev/sse` | API Key | ⬜ Untested | | |
| Make | `https://mcp.make.com/sse` | API Key | ⬜ Untested | | Manual health check required |
| Google Drive | `https://mcp.googleapis.com/drive` | OAuth2 | ⬜ Untested | | Browser consent flow required |
| OneDrive | `https://graph.microsoft.com/v1.0/mcp` | OAuth2 | ⬜ Untested | | Browser consent flow required |
| Discord | `https://discord.com/api/v10/mcp` | Bot Token | ⬜ Untested | | |
| Supabase | `https://mcp.supabase.com/sse` | Service Key | ⬜ Untested | | Also requires SUPABASE_URL in .env |
| Sentry | `https://mcp.sentry.io/sse` | Auth Token | ⬜ Untested | | |

## Status Key

- ✅ Working — live-tested, health check passes
- ⬜ Untested — configured but not yet validated
- ❌ Broken — health check fails, needs attention
- 🔑 Needs Token — placeholder in .env, not yet filled in
- 🔐 OAuth Pending — requires browser consent flow
