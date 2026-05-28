# Agent Routing Decision Guide

Use this guide when a task could belong to more than one agent. Pick the first row that matches your task.

## Decision Table

| If your task involves... | Use this agent | Why |
|---|---|---|
| GitHub: creating repos, pushing files, opening PRs, managing issues | **Perplexity** | Has direct GitHub MCP access |
| Notion: reading/writing pages, searching databases | **Perplexity** | Has direct Notion MCP access |
| Web research or connector health queries | **Perplexity** | Built-in search + MCP tools |
| Writing or fixing code across multiple files, no deadline | **Jules** | Async background PRs; runs without you |
| Running bash commands, deep refactors, interactive terminal work | **Claude Code** | Full terminal + subagent delegation |
| Teams, SharePoint, Power Automate, Dynamics 365 workflows | **Copilot Studio** | M365 enterprise integration layer |
| OAuth consent for Google Drive, OneDrive, or GitHub OAuth app | **You (browser)** | Cannot be automated; requires human |
| Filling in .env tokens | **You (terminal)** | Secrets must never leave your machine |
| Running bootstrap.sh or validate.sh | **You (terminal)** | Requires local environment |

## Ambiguous Cases

**Code task but needs research too?**
Start with Perplexity to gather context and specs, then hand off the implementation to Claude Code or Jules.

**Multi-file edit but no terminal available?**
Use Jules (async PR) or ask Perplexity to push files directly via GitHub MCP.

**Connector broken but unsure why?**
1. Run `bash validate.sh <connector_id>` locally
2. If HTTP error, check token expiry and scope
3. If MCP server unreachable, check `connector-status.md` and verify the URL against the connector's official docs link in `connectors.json`

**OAuth token expired?**
Re-run the browser consent flow. Google Drive and OneDrive tokens expire; set up token refresh in your OAuth app config.

## Perplexity Hard Limits
- Cannot run local terminal commands
- Cannot initiate OAuth consent flows
- Cannot access private networks or localhost
- Cannot read/write your local filesystem directly

## Jules Hard Limits
- Async only — no real-time interaction
- Requires jules.google.com account
- 15 concurrent tasks on Pro plan
- Cannot access services not connected to its GitHub integration

## Claude Code Hard Limits
- Requires local terminal with `claude` CLI installed
- Requires active Anthropic subscription (Pro or Max)
- Does not persist state between sessions by default
