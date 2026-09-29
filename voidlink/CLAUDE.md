# CLAUDE.md

Claude Code adapter. The project rules — what the repository contains, the
suggest-review-apply rule for the vault, staging, validation and the Definition
of Done — live in [`AGENTS.md`](AGENTS.md). Read it first; this file only adds
how to work here with Claude Code.

## Before changing anything

- The vault content is not in this repository. Never go looking for it outside
  the working tree, and never read personal notes to "test" a change.
- `99_system/ai_policy.yaml` is a backstop, not a safety net: it only protects
  the folders it names. vault-agent warns when a named folder does not exist
  (#32).

## Validate

```bash
./scripts/check.sh setup   # uv sync --frozen, once per environment
./scripts/check.sh fmt     # the only verb that edits files
./scripts/check.sh all     # ruff, shellcheck, pytest, vault-agent --help: what CI runs
pre-commit run --all-files
```

If a command cannot run here, name it and the reason; never report it as
passing.

## Do not

- write outside `99_system/ai_staging/` from a tool, or change a note that has
  `draft: true`
- delete notes or assets, or rewrite user-authored content
- read or print `.env`, tokens or credentials
- `git push --force`, `git reset --hard`, `git clean`
- commit or push unless the task asks for it

## Enforcement

The rules above are enforced by `.claude/settings.json` and
`.claude/hooks/guard.py`, not only by this text. The guard blocks:

- reading or writing the PARA folders (`00_knowledge/` … `04_archive/`) at the
  repository root, or below `VOIDLINK_VAULT__ROOT` if that is set. System files
  such as `99_system/015_templates/02_areas/` stay editable
- editing any note whose frontmatter says `draft: true`
- `git add` of anything under `99_system/ai_staging/` (#43)
- `rm -rf`, force push, `reset --hard`, `clean`, and `.env` or key material

`vault-agent apply` and `ingest` ask before they run.
`hooks/session-start.sh` runs `uv sync --frozen` in Claude Code on the web.
`tests/test_claude_config.py` pins all of it. If the guard blocks you, that is
the answer: work on a fixture vault in `tmp_path` instead.

## Skills and agents

| skill (`.claude/skills/`) | use it for |
| --- | --- |
| `add-note-type` | schema + validation + template + test for a note type |
| `add-vault-agent-command` | a CLI command that writes to staging only |
| `review-vault-change` | turning a request to change notes into a reviewable plan |

Agents: `schema-reviewer` (domain model, the four places a type touches,
backward compatibility) and `privacy-reviewer` (no vault data in a diff,
staging only, `draft: true`, policy coverage, local only).
