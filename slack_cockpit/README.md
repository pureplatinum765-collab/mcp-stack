# Slack NotebookLM Cockpit

A small Slack Bolt app that turns the `#ai-cockpit` channel into a safe front door for the local `nlm` CLI.

It uses Slack Socket Mode, so the process can run locally without exposing a public HTTP endpoint.

## What it exposes

The first version is intentionally read/query-only:

```text
/nlm help
/nlm notebooks
/nlm doctor
/nlm query <notebook-id-or-alias> | <question>
/nlm cross <id1,id2,...> | <question>
```

It does **not** expose source deletion, notebook deletion, sharing, artifact generation, or arbitrary shell execution.

## Prerequisites

1. Install and authenticate the NotebookLM CLI:

```bash
bash ../notebooklm/install.sh
nlm login
nlm doctor
```

2. Create a Slack app from `slack-app-manifest.yaml`.

3. Enable Socket Mode and create an app-level token with `connections:write`.

4. Install the app to the workspace and keep the bot `commands` scope from the manifest.

5. Copy the resulting bot token (`xoxb-...`) and app-level token (`xapp-...`).

Slack's current developer documentation notes that Socket Mode uses an app-level `connections:write` token, and slash commands use the bot `commands` scope. A Request URL is not required when using Socket Mode.

Official references:

- https://docs.slack.dev/reference/scopes/connections.write/
- https://docs.slack.dev/reference/scopes/commands/
- https://docs.slack.dev/tools/java-slack-sdk/guides/slash-commands/

## Configure

```bash
cd slack_cockpit
cp .env.example .env
```

Fill in only the local `.env` file:

```dotenv
SLACK_BOT_TOKEN=xoxb-...
SLACK_APP_TOKEN=xapp-...
SLACK_ALLOWED_CHANNEL=C0BNJECTHMM
```

Never commit `.env`.

## Run

```bash
cd slack_cockpit
uv run python app.py
```

The process stays connected to Slack over Socket Mode. Test in `#ai-cockpit`:

```text
/nlm notebooks
```

Then query a notebook:

```text
/nlm query NOTEBOOK_ID | Build a factual timeline from these sources and separate direct evidence from inference.
```

Or query selected notebooks together:

```text
/nlm cross NOTEBOOK_ID_1,NOTEBOOK_ID_2 | What claims are supported across both notebooks, and where do they conflict?
```

## Safety model

- `subprocess.run` receives an argument array, not a shell string.
- Only hard-coded command patterns are accepted.
- The Slack channel can be restricted with `SLACK_ALLOWED_CHANNEL`.
- Slack responses are length-limited.
- Destructive NotebookLM commands are excluded from this first version.
- Credentials and NotebookLM browser auth remain local.

## Architecture

```text
Slack #ai-cockpit
      |
      v
Slack Bolt / Socket Mode
      |
      v
allowlisted nlm CLI commands
      |
      v
Gemini Notebook / NotebookLM

GitHub = code, prompts, issues, version history
Slack  = requests, decisions, outputs, handoffs
NLM    = source-grounded research and synthesis
```
