---
name: add-note-type
description: Add or extend a vault note type — frontmatter schema, cross-field validation, Neovim template, rendering test and README entry — the way the training types were added. Use for schema issues such as yoga and meditation, habits, contacts, calendar or media notes.
---

# Add a note type

The training types from raxovile/voidlink#41 are the worked example. Read the
diff of that PR, or the files below, before starting.

1. **Terms first.** Take field names, status values and units from
   `docs/voidsystem/DOMAIN_MODEL.md` in raxovile/voidCore. Write the
   human-facing field list next to the schema, as
   `99_system/05_schemas/<domain>_schema.md` (see `training_schema.md`).
2. **Schema.** Add a definition per `type` to
   `99_system/05_schemas/frontmatter.schema.json`. Required fields,
   enumerations and patterns go there, not in Python.
3. **Cross-field rules.** Only what JSON Schema cannot express goes into
   `src/voidlink_cli/validation/frontmatter.py`, for example unique `order`
   values (`TRAINING_LIST_TYPES`) or date ordering.
4. **Template.** Put the Neovim template under
   `99_system/015_templates/<PARA path>/<type>.md`, with plain `{{ }}`
   placeholders that voidCore's `lua/notes/templates.lua` fills. A Templater
   variant under `01_templates/` only if the issue asks for one.
5. **Tests.**
   - Valid and invalid examples in `tests/test_frontmatter_validation.py` or
     `tests/test_<domain>_schema.py`.
   - Render the template the way `tests/test_neovim_templates.py` does, and
     validate the result.
   - Synthetic fixtures only; never a real note.
6. **Docs.** A row in the README's template table.
7. **Prove it.** Run the validation from `AGENTS.md`:

   ```bash
   uv run ruff format --check . && uv run ruff check . && uv run pytest
   ```

   Then ask the `schema-reviewer` agent to review the diff.
