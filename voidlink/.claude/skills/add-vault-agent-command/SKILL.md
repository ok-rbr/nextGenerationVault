---
name: add-vault-agent-command
description: Add a vault-agent CLI command (validate, plan, ingest, review, report) that only writes to 99_system/ai_staging/ and changes notes only through reviewed apply. Use for issues such as "implement vault-agent ingest hevy" or new validation reports.
---

# Add a vault-agent command

1. **Place it.** Command groups are registered in `src/voidlink_cli/cli.py`
   from `voidlink_cli.commands` (`validate`, `ingest`, `plan`, `review`,
   `apply`). Add the command to the matching group and keep the logic in its
   package (`validation/`, `ingest/`, `planning/`, …), not in the Typer
   function.
2. **Output goes to staging.** Write through `Config.get_staging_path()` and a
   run manifest (`run_logging.create_run_manifest`). Never write to a note.
3. **Changes to notes** are expressed as a plan or suggestions that validate
   against `99_system/05_schemas/suggestion.schema.json`. They reach the vault
   only through `vault-agent review approve` and `vault-agent apply commit`.
4. **Respect the policy.** Check each target path against
   `99_system/ai_policy.yaml` through `voidlink_cli.policy`. Skip notes with
   `draft: true` and report them as skipped.
5. **Exit codes.** Return 0 when clean and 1 when issues are found (like
   `validate frontmatter`), so the command can gate a hook or a timer.
6. **Tests** with a fixture vault built in `tmp_path`, covering:
   - output lands in staging only, and no note file changes (compare mtimes or
     hashes)
   - `draft: true` notes are skipped
   - the exit code
   - Typer's `CliRunner` for the CLI surface (see `tests/test_cli.py`)
7. **Docs.** Add a README section in the style of the existing
   `vault-agent …` sections.
8. **Prove it.** Run the validation from `AGENTS.md`, then ask the
   `privacy-reviewer` agent to review the diff. Never run the command against
   the real vault from an agent session.
