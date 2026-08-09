#!/usr/bin/env python3
"""Slack cockpit for safe, read-oriented NotebookLM CLI access.

Runs in Slack Socket Mode so it does not need a public web endpoint.
The bot exposes a single /nlm slash command and deliberately permits only
an allowlisted subset of NotebookLM commands.
"""

from __future__ import annotations

import json
import os
import shlex
import subprocess
from dataclasses import dataclass
from typing import Sequence

from slack_bolt import App
from slack_bolt.adapter.socket_mode import SocketModeHandler


BOT_TOKEN = os.environ["SLACK_BOT_TOKEN"]
APP_TOKEN = os.environ["SLACK_APP_TOKEN"]
ALLOWED_CHANNEL = os.getenv("SLACK_ALLOWED_CHANNEL", "").strip()
NLM_BIN = os.getenv("NLM_BIN", "nlm")
COMMAND_TIMEOUT_SECONDS = int(os.getenv("NLM_TIMEOUT_SECONDS", "120"))

app = App(token=BOT_TOKEN)


HELP = """*NotebookLM cockpit*

`/nlm notebooks`
List notebooks.

`/nlm query <notebook-id-or-alias> | <question>`
Ask one notebook a grounded question.

`/nlm cross <id1,id2,...> | <question>`
Ask across selected notebooks.

`/nlm doctor`
Run NotebookLM diagnostics.

`/nlm help`
Show this help.

This bot intentionally starts read/query-only. Source mutation, sharing, deletion, and artifact generation are not exposed through Slack yet.
"""


@dataclass(frozen=True)
class Result:
    returncode: int
    stdout: str
    stderr: str


def run_nlm(args: Sequence[str]) -> Result:
    """Execute nlm without a shell to prevent shell injection."""
    completed = subprocess.run(
        [NLM_BIN, *args],
        capture_output=True,
        text=True,
        timeout=COMMAND_TIMEOUT_SECONDS,
        check=False,
        env=os.environ.copy(),
    )
    return Result(
        returncode=completed.returncode,
        stdout=completed.stdout.strip(),
        stderr=completed.stderr.strip(),
    )


def trim_for_slack(text: str, limit: int = 3800) -> str:
    if len(text) <= limit:
        return text
    return text[: limit - 80] + "\n\n…output truncated. Run the query locally for the full result."


def json_pretty_or_raw(text: str) -> str:
    try:
        return json.dumps(json.loads(text), indent=2, ensure_ascii=False)
    except Exception:
        return text


def split_pipe(text: str) -> tuple[str, str]:
    left, sep, right = text.partition("|")
    if not sep or not left.strip() or not right.strip():
        raise ValueError("Expected: target | question")
    return left.strip(), right.strip()


def allowed(channel_id: str) -> bool:
    return not ALLOWED_CHANNEL or channel_id == ALLOWED_CHANNEL


@app.command("/nlm")
def nlm_command(ack, command, respond):
    ack()

    channel_id = command.get("channel_id", "")
    if not allowed(channel_id):
        respond("This cockpit is restricted to the configured Slack channel.", response_type="ephemeral")
        return

    raw = (command.get("text") or "").strip()
    if not raw or raw == "help":
        respond(HELP, response_type="ephemeral")
        return

    verb, _, rest = raw.partition(" ")
    verb = verb.lower().strip()
    rest = rest.strip()

    try:
        if verb in {"notebooks", "list"}:
            result = run_nlm(["notebook", "list", "--json"])
            title = "Notebook list"
        elif verb == "doctor":
            result = run_nlm(["doctor"])
            title = "NotebookLM doctor"
        elif verb == "query":
            target, question = split_pipe(rest)
            result = run_nlm(["notebook", "query", target, question, "--json"])
            title = f"Notebook query: `{target}`"
        elif verb == "cross":
            targets, question = split_pipe(rest)
            if not all(part.strip() for part in targets.split(",")):
                raise ValueError("Cross query notebook IDs must be comma-separated.")
            result = run_nlm(["cross", "query", question, "--notebooks", targets])
            title = f"Cross-notebook query: `{targets}`"
        else:
            respond(f"Unknown command `{shlex.quote(verb)}`.\n\n{HELP}", response_type="ephemeral")
            return
    except subprocess.TimeoutExpired:
        respond(f"NotebookLM command exceeded {COMMAND_TIMEOUT_SECONDS}s and was stopped.", response_type="ephemeral")
        return
    except ValueError as exc:
        respond(f"{exc}\n\n{HELP}", response_type="ephemeral")
        return
    except Exception as exc:
        respond(f"Cockpit error: `{type(exc).__name__}: {exc}`", response_type="ephemeral")
        return

    if result.returncode != 0:
        detail = result.stderr or result.stdout or "Unknown nlm error"
        respond(f"*{title} failed*\n```{trim_for_slack(detail)}```", response_type="ephemeral")
        return

    output = json_pretty_or_raw(result.stdout) or "Command completed with no output."
    respond(f"*{title}*\n```{trim_for_slack(output)}```")


if __name__ == "__main__":
    SocketModeHandler(app, APP_TOKEN).start()
