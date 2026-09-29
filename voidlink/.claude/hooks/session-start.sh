#!/usr/bin/env bash
# SessionStart hook: install the locked environment so the validation commands
# in AGENTS.md run in a fresh Claude Code on the web container. Local sessions
# keep their own setup.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd -- "${CLAUDE_PROJECT_DIR:-$(dirname -- "$0")/../..}"
uv sync --frozen
