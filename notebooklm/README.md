# Gemini Notebook MCP integration

This folder adds Gemini Notebook / NotebookLM as the research and synthesis layer in `mcp-stack`.

## Role in the stack

- **Slack** = human cockpit: prompts, decisions, requests, outputs, links, status
- **Gemini Notebook** = source-grounded research and synthesis
- **GitHub** = code, configuration, versioned prompts, automation logic, issues

ClickUp is intentionally not part of the default architecture. GitHub Issues already cover executable work without introducing a second task system.

## Local install

```bash
bash notebooklm/install.sh
nlm login
nlm doctor
```

Then register the MCP with the agent you use:

```bash
nlm setup add github-copilot
nlm setup add cursor
nlm setup add claude-code
nlm setup add gemini
```

Generic MCP JSON can be generated with:

```bash
nlm setup add json
```

Optional Codex skill:

```bash
nlm skill install codex
```

## Working model

1. Put durable source files in their canonical storage location.
2. Add those sources to the relevant Gemini Notebook.
3. Ask grounded questions inside the notebook rather than across an unstructured pile of files.
4. Post the request, result, and important decision back to Slack.
5. If the result creates implementation work, track it in GitHub Issues or a PR.

## Recommended notebook boundaries

Use multiple focused notebooks instead of one giant notebook. Suggested starting groups:

- Family narrative and timeline
- Clinical and scientific research
- Creative writing and music
- Consumer/legal evidence
- Product and technical research

Cross-notebook queries can be used when synthesis is needed across domains.

## Slack cockpit

The `slack_cockpit/` folder contains a Socket Mode Slack bot that exposes an allowlisted, read/query-first subset of the `nlm` CLI through `/nlm`.

The initial commands are:

```text
/nlm notebooks
/nlm doctor
/nlm query <notebook-id-or-alias> | <question>
/nlm cross <id1,id2,...> | <question>
```

See `slack_cockpit/README.md` for setup.

## Security

`notebooklm-mcp-cli` is unofficial and uses internal Google APIs plus browser-derived authentication. Treat it as a personal/experimental integration. Never commit cookies, auth state, tokens, `.env` files, or local MCP configs containing credentials.
