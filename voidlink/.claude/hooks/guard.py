#!/usr/bin/env python3
"""PreToolUse guard for Claude Code in voidlink.

Enforces the vault rules of AGENTS.md at the tool boundary:

* personal vault content (the PARA folders) is neither read nor written, at
  the repository root or below a vault named by VOIDLINK_VAULT__ROOT;
* a note whose frontmatter says ``draft: true`` is never edited;
* staging output under 99_system/ai_staging/ is never committed (#43);
* destructive Git commands and .env/key material are off limits.

Contract (Claude Code hooks): the tool call arrives as JSON on stdin; exit 2
blocks it and shows stderr to the model, exit 0 allows it. An unparseable
payload is allowed, because .claude/settings.json still carries the deny list.
"""

from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path

PARA = ("00_knowledge", "01_projects", "02_areas", "03_resources", "04_archive")

BASH_DENY = [
    (r"\bgit\s+add\b[^\n]*ai_staging", "staging output is never committed (#43)"),
    (
        r"\brm\s+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)\b",
        "notes and assets are never deleted",
    ),
    (r"\bgit\s+push\b[^\n]*(--force|\s-f\b)", "force pushing rewrites published history"),
    (r"\bgit\s+reset\b[^\n]*--hard", "git reset --hard discards work"),
    (r"\bgit\s+clean\b", "git clean deletes untracked files"),
    (
        r"\b(cat|less|more|head|tail|bat|xxd|strings|grep)\b[^\n]*(?<![\w-])\.env(?![\w.-])",
        "the real .env holds configuration secrets",
    ),
    (
        r"\b(cat|less|more|head|tail|bat|grep|find|ls|rg|sed|awk)\b[^\n]*(^|[\s'\"=])(\./)?"
        r"(00_knowledge|01_projects|02_areas|03_resources|04_archive)/",
        "personal vault content is not read from a session; use fixtures",
    ),
]

PATH_DENY = [
    (r"(^|/)\.env(\.[^/]+)?$", "an environment file"),
    (r"\.(key|pem|p12|pfx)$", "private key material"),
    (r"(^|/)\.git/", "the Git database"),
]

HEREDOC_RE = re.compile(r"<<-?\s*['\"]?([A-Za-z_][A-Za-z0-9_]*)['\"]?")
FRONTMATTER_RE = re.compile(r"\A---\s*\n(.*?)\n---\s*(\n|\Z)", re.DOTALL)
DRAFT_RE = re.compile(r"^draft\s*:\s*['\"]?true['\"]?\s*$", re.IGNORECASE | re.MULTILINE)


def strip_heredoc_bodies(cmd: str) -> str:
    """Drop cat/tee heredoc bodies: documenting a command is not running it."""
    lines = cmd.splitlines()
    out: list[str] = []
    i = 0
    while i < len(lines):
        line = lines[i]
        out.append(line)
        match = HEREDOC_RE.search(line)
        if match and re.match(r"\s*(cat|tee)\b", line):
            delimiter = match.group(1)
            i += 1
            while i < len(lines) and lines[i].strip() != delimiter:
                i += 1
        i += 1
    return "\n".join(out)


def vault_roots() -> list[Path]:
    """The repository root and, if configured, the real vault."""
    roots = [Path(os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd())]
    configured = os.environ.get("VOIDLINK_VAULT__ROOT")
    if configured:
        roots.append(Path(configured))
    return [root.resolve() for root in roots]


def in_para(path: str) -> bool:
    """True when path lies in a PARA folder directly below a vault root.

    Templates such as 99_system/015_templates/02_areas/ are system files and
    stay editable: only the top-level PARA folders hold personal notes.
    """
    target = Path(path)
    for root in vault_roots():
        candidate = target if target.is_absolute() else root / target
        try:
            relative = candidate.resolve().relative_to(root)
        except ValueError:
            continue
        if relative.parts and relative.parts[0] in PARA:
            return True
    return False


def is_draft(path: str) -> bool:
    try:
        text = Path(path).read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return False
    match = FRONTMATTER_RE.match(text)
    return bool(match and DRAFT_RE.search(match.group(1)))


def verdict(event: dict) -> str | None:
    """Return the reason to block, or None to allow."""
    tool = event.get("tool_name", "")
    args = event.get("tool_input") or {}
    if tool == "Bash":
        cmd = strip_heredoc_bodies(args.get("command", "") or "")
        for pattern, reason in BASH_DENY:
            if re.search(pattern, cmd, re.IGNORECASE | re.MULTILINE):
                return reason
    if tool in ("Read", "Write", "Edit", "MultiEdit", "NotebookEdit"):
        path = args.get("file_path") or args.get("notebook_path") or ""
        for pattern, reason in PATH_DENY:
            if re.search(pattern, path):
                return f"{path} is {reason}"
        if path and in_para(path):
            return f"{path} is personal vault content; work on fixtures under tests/"
        if tool != "Read" and path.endswith(".md") and is_draft(path):
            return f"{path} has draft: true and is never changed without explicit instruction"
    return None


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0
    reason = verdict(event)
    if reason:
        sys.stderr.write(f"blocked by .claude/hooks/guard.py: {reason}. See AGENTS.md.\n")
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
