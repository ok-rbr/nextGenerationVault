# AGENTS.md

Working agreement for humans and coding agents in this repository. Tool-specific
adapters (`CLAUDE.md`) point here and restate nothing.

## What this repository is

VoidLink is the system layer of the VoidSystem Obsidian vault: templates,
schemas, workflow scripts and `vault-agent`, the CLI that proposes changes to
notes. **The actual vault content is not in this repository.** The top-level
PARA folders (`00_knowledge/`, `01_projects/`, `02_areas/`, `03_resources/`,
`04_archive/`) are git-ignored; they live in the user's vault and reach the
tools only at run time.

| Path                    | Purpose                                                              |
| ----------------------- | -------------------------------------------------------------------- |
| `src/voidlink_cli/`     | `vault-agent` — scan, plan, review, apply, validate, ingest          |
| `tests/`                | pytest suite for the CLI (`testpaths`)                               |
| `99_system/`            | system area of the vault                                             |
| `99_system/01_templates/` | note templates (Templater / QuickAdd)                              |
| `99_system/015_templates/` | Neovim templates (`lua/notes/` in voidCore, plain `{{ }}` placeholders) |
| `99_system/03_workflow/scripts/` | shell helpers for daily notes and task status               |
| `99_system/05_schemas/` | JSON schemas for frontmatter, suggestions and the AI policy          |
| `99_system/ai_policy.yaml` | paths and actions the AI tooling may and may not touch            |
| `99_system/ai_staging/` | the only location for unconfirmed tool output; git-ignored except `.gitkeep`, and the `no-ai-staging-output` pre-commit hook and `tests/test_staging_not_tracked.py` reject anything else (#43) |
| `.claude/`              | Claude Code settings, guard hook, skills and agents (see `CLAUDE.md`) |
| `99_system/_scripts/`   | the Templater library `lib.js` and `new-yoga-pose.ps1`; the former `voidlink_agent.py` and `vaultops.py` are replaced by `vault-agent` (#44) |

## Rules for anything that writes to the vault

- **Suggest, review, apply.** No tool writes to a note without prior human
  approval. `vault-agent` writes plans and review artefacts; only `apply` after
  review changes notes, and it records a change log and a rollback report.
- **Staging only.** Unconfirmed output — plans, suggestions, reports, AI
  results — goes to `99_system/ai_staging/` and nowhere else.
- **`draft: true` is never changed automatically.** A note with that
  frontmatter is left alone unless the user explicitly asks. The CLI does not
  enforce this yet; any change you make must keep it true. For Claude Code
  sessions `.claude/hooks/guard.py` blocks edits to such notes.
- **Additive and reviewable.** Never delete notes or assets, never mutate
  binary files, never rewrite user-authored content, never run a vault-wide
  rewrite. Preserve existing frontmatter.
- **Frontmatter** is validated against
  `99_system/05_schemas/frontmatter.schema.json`
  (`vault-agent validate frontmatter`; exits 1 on issues).
- **`99_system/ai_policy.yaml`** lists protected, LLM-excluded and sensitive
  paths plus allowed and forbidden actions. Read it before adding a write path.
  Every path must name an existing folder under one of the vault roots;
  `vault-agent plan suggest` and `apply commit` warn about one that does not
  (#32). The schema pins the roots.
- **Local models only.** `--with-llm` talks to Ollama on
  `http://localhost:11434`. No cloud model API, no telemetry.

## Validation

```bash
./scripts/check.sh setup   # uv sync --frozen, once per environment
./scripts/check.sh fmt     # the only verb that edits files
./scripts/check.sh all     # ruff, shellcheck, pytest, vault-agent --help: what CI runs
pre-commit run --all-files
```

CI (`.github/workflows/ci.yml`) runs `./scripts/check.sh all` on every pull
request and push to `main`; run it yourself before you report a change as
done, and say what you ran. A missing `shellcheck` is reported as `SKIP`
locally and fails in CI.

## House standard

`.editorconfig`, `.gitattributes` and `.pre-commit-config.yaml` follow the
original shared standards; adapt them here only with a documented reason.
Run `pre-commit install` once per clone. `.secrets.baseline` lists
reviewed `detect-secrets` findings: update it with
`detect-secrets scan --baseline .secrets.baseline` and review the new entries,
never regenerate it as part of an unrelated change.

## Git

- Default branch `main`; work on a branch and open a pull request.
- Conventional commits with the scope `voidlink`: `feat(voidlink): …`.
- Never commit vault content, `.env`, credentials or anything under the
  git-ignored PARA folders.
- `uv.lock` changes only through `uv`.
- GitHub issues are the source of truth for planned work.

## Definition of done

1. The validation commands above pass.
2. Behaviour you changed has a test.
3. Nothing writes to the vault without review, and `draft: true` is untouched.
4. Documentation (README, this file) describes what the code does now.
