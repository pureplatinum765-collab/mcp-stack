# Agent Handoff Map

This document defines which AI agent handles which part of the MCP stack automation, and where each agent's limits are.

## Execution Layers

| Task | Agent | Method | Limit |
|---|---|---|---|
| GitHub repo creation, file push, PR creation, issue management | **Perplexity (me)** | GitHub MCP server | Cannot run local terminal commands |
| Notion page search, create, update | **Perplexity (me)** | Notion MCP server | Cannot trigger OAuth consent flows |
| Web research, connector health queries | **Perplexity (me)** | Built-in search + MCP | Cannot access private networks |
| Async code tasks: write tests, fix bugs, open PRs automatically | **Google Jules** (Gemini 3.1 Pro) | jules.google.com → connect to this repo | Requires jules.google.com account; 15 concurrent tasks on Pro |
| IDE-level agentic coding: file edits, bash, subagent delegation | **Claude Code (Claude Pro/Max)** | `claude` CLI in terminal | Requires Anthropic subscription + local terminal |
| Enterprise M365/Teams/Power Automate workflows | **Microsoft Copilot Studio** | Agent 365 control plane | Requires Microsoft 365 Business/Enterprise |
| OAuth consent flows (Google Drive, OneDrive, GitHub OAuth app) | **You (browser)** | Browser-based OAuth | Cannot be automated without user action |
| Token entry into .env | **You (terminal)** | `nano .env` or editor | Secrets must stay local |
| Run bootstrap.sh / validate.sh | **You (terminal)** | `bash bootstrap.sh` | Requires local machine |

## How to Connect Google Jules

1. Go to https://jules.google.com
2. Sign in with your Google account
3. Click **New Task** > connect repository > `pureplatinum765-collab/mcp-stack`
4. Assign tasks like: *"Write unit tests for bootstrap.sh"* or *"Add a Python wrapper for connectors.json"
5. Jules will create a PR automatically on completion

## How to Connect Claude Code

```bash
# Install Claude Code CLI
npm install -g @anthropic-ai/claude-code

# Run in the repo directory
cd mcp-stack
claude
```

Claude Code can then read all files, run bash commands, edit files, and delegate to subagents — all from your terminal.

## When to Use Which Agent

- **Perplexity**: orchestration, research, Notion/GitHub API actions, connector health queries
- **Jules**: async background PR work, test generation, dependency bumps, scheduled daily agent tasks
- **Claude Code**: deep refactors, multi-file edits, terminal-level automation, complex debugging
- **Copilot Studio**: enterprise workflow automation across Teams, SharePoint, Dynamics 365
