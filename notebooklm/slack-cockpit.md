# Slack AI Cockpit

Slack is the front door for this stack. The goal is to make the system feel like one workspace instead of a collection of tools.

## Core channel

Use one primary channel: `#ai-cockpit`.

Post four kinds of things there:

1. **ASK** — a research or synthesis request
2. **BUILD** — an implementation request that should become GitHub/ClickUp work
3. **DECISION** — a conclusion worth preserving
4. **DROP** — a file, URL, transcript, note, or source that should be routed somewhere

Suggested message prefixes:

```text
ASK: Compare the strongest evidence for X across my family and research notebooks.
BUILD: Turn this synthesis into a source-indexed timeline generator.
DECISION: Keep Family Narrative and Clinical Research as separate notebooks.
DROP: Add this PDF to the Clinical Research notebook and tell me what it changes.
```

## Routing rules

- If the request needs grounded synthesis from user-provided sources, route to Gemini Notebook.
- If it changes code, configuration, prompts, tests, or automation logic, route to GitHub.
- If it has an owner, next action, status, or due date, mirror it into ClickUp.
- If it is merely a thought, question, discussion, or result, keep it in Slack.
- Do not turn every Slack message into a ClickUp task.

## Slack Canvas

The channel canvas should contain:

- System map
- Current build status
- Quick commands
- Notebook registry
- GitHub repository link
- ClickUp project link
- Human-only setup steps

## Automation target

A future Slack bot/agent can read a message, classify it as ASK / BUILD / DECISION / DROP, invoke the correct MCP toolchain, then reply in-thread with:

- what it did
- source links or notebook references
- resulting GitHub issue/PR if any
- resulting ClickUp task if any
- the next human action only when required

Slack remains the conversational surface even when the actual work happens elsewhere.
