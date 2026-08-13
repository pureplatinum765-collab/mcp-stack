#!/usr/bin/env bash
set -euo pipefail

# Gemini Notebook / NotebookLM local MCP bootstrap.
# This project uses the unofficial notebooklm-mcp-cli package.

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required. Install it first from https://docs.astral.sh/uv/"
  exit 1
fi

echo "Installing/upgrading notebooklm-mcp-cli..."
if uv tool list | grep -q '^notebooklm-mcp-cli '; then
  uv tool upgrade notebooklm-mcp-cli
else
  uv tool install notebooklm-mcp-cli
fi

echo
nlm doctor || true

echo
cat <<'EOF'
Next steps requiring you at the computer:
  1. Authenticate: nlm login
  2. Register the MCP with the agent(s) you actually use:
       nlm setup add github-copilot
       nlm setup add cursor
       nlm setup add claude-code
       nlm setup add gemini
     Or generate generic JSON:
       nlm setup add json
  3. Optional Codex skill:
       nlm skill install codex
  4. Verify:
       nlm notebook list
       nlm doctor

Do not commit browser cookies, exported auth state, tokens, or local MCP configs containing secrets.
EOF
