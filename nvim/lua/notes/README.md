# Neovim Notes System

A native Lua note-taking system for Neovim that works with Obsidian-compatible
vaults.

## Overview

This notes system provides:

- **Dynamic template system** - reads markdown templates from
  `99_system/015_templates`
- **Runtime variable prompting** - prompts for template variables at note
  creation time
- **Smart input deduplication** - reuses values like title to suggest filenames
- **Fuzzy template search** - find and select templates using Telescope or
  vim.ui.select
- **Obsidian-compatible vault conventions** - shares Markdown, frontmatter and
  wiki-link formats without requiring the Neovim Obsidian plugin
- **PARA directory structure** - Projects, Areas, Resources, Archive
- **Automatic frontmatter** - default fields like `id` and `created` are
  auto-generated

## Two Template Directories

The vault holds **two** template folders and they are not interchangeable:

| Directory                 | Used by                     | Format                                |
| ------------------------- | --------------------------- | ------------------------------------- |
| `99_system/01_templates`  | Obsidian (Templater plugin) | Templater syntax, contains JavaScript |
| `99_system/015_templates` | Neovim (this module)        | Plain `{{ variable }}` placeholders   |

lua/notes/ cannot execute Templater's JavaScript, which is why it reads its own
directory. Putting a Neovim template in `01_templates` means the picker will
never find it. Override the Neovim directory per machine with
`NOTES_TEMPLATES_DIR` in `.env`.

## Important: Template Path Behavior

**Templates are READ from**: `vault_root/99_system/015_templates/...` **Notes
are CREATED at**: `vault_root/<location>/<filename>`

Example:

- Template location: `vault_root/99_system/015_templates/01_projects/example.md`
- Created note: `vault_root/01_projects/client_slug/project_slug/note.md`

The template directory structure (e.g., `01_projects/`, `02_areas/`) is used to:

1. Organize templates by category
2. Suggest default locations for new notes
3. Display category information in the template picker

Project notes use the client-first path `01_projects/client_slug/project_slug/`.
Generated project notes link to the client index in
`03_resources/clients/client_slug/client_index.md` and the project index.

**The templates themselves stay in `99_system/015_templates/` and are never
modified.**

## Quick Start

### Create a Note from Template

Use the fuzzy template picker:

```vim
:NoteTemplate
" or
<leader>nT
```

This opens a fuzzy search interface where you can:

- Browse all available templates from `99_system/015_templates`
- Filter by name or category
- Select a template to create a new note

When the cursor is inside a wiki-link, `:NoteTemplate` and `<leader>nT`
automatically pass its target as `{{ title }}` and use it for the suggested
filename. For example, `[[My Note|Shown Label]]` uses `My Note`.

`:NoteTemplateFromLink` and `<leader>nt` require a wiki-link under the cursor
and show a warning if none is present:

```vim
:NoteTemplateFromLink
" or
<leader>nt
```

The system will:

1. Prompt you for template variables (e.g., `{{ title }}`, `{{ client }}`)

- If the template has a `{{ title }}` variable, you'll be prompted for it first
- The title is automatically used to suggest a filename (slugified)
- Each variable is only prompted once (deduplication)

2. Ask for the filename (with smart default based on title)
3. Ask for the file location (with smart defaults based on template category)
4. Create the note at `vault_root/location/filename` with all variables replaced

For templates whose filename contains `weekly` or `monthly` (recurring meetings
such as `weekly_team_sync.md`), Neovim additionally asks for the meeting date.
It prefixes the filename with that date (for example, `2026-08-26_team_sync.md`)
and supplies the same value to `{{ date }}` and `{{ meeting_date }}` when those
placeholders are present. This prevents recurring meetings with the same title
from colliding.

### Create Daily Note

```vim
:NoteDaily
" or
<leader>nd
```

### Create Weekly and Monthly Review Notes

```vim
:NoteWeekly            " this ISO week,  or :NoteWeekly 2026-W39
:NoteMonthly           " this month,     or :NoteMonthly 2026-09
" or
<leader>nW / <leader>nM
```

Both work like `:NoteDaily`: the note is opened if it exists and created
otherwise, and an existing note is never rewritten. Weeks are ISO 8601 weeks
(Monday to Sunday; 2027-01-01 belongs to `2026-W53`).

In the `allMight` profile, Marksman is not attached to buffers in the daily-note
directory because its indexing can stall those buffers. It remains enabled for
other vault notes and repository Markdown.

| Period  | Folder (`directories.*`)     | File          | Template (at the templates root) |
| ------- | ---------------------------- | ------------- | -------------------------------- |
| daily   | `02_areas/life/logs/daily`   | `20260925.md` | `daily.md`                       |
| weekly  | `02_areas/life/logs/weekly`  | `2026_w39.md` | `weekly.md`                      |
| monthly | `02_areas/life/logs/monthly` | `2026_09.md`  | `monthly.md`                     |

The file name stem is the note's `id`, so `[[2026_w39]]` links to the review of
that week. Without a template the note gets frontmatter and a short built-in
outline. A template receives these placeholders:

- all periods: `{{ title }}`, `{{ id }}`, `{{ created }}`, `{{ previous }}` and
  `{{ next }}` (stems of the neighbouring notes, for `[[{{ previous }}]]`)
- daily: `{{ date }}`, `{{ current_date }}`
- weekly: `{{ week }}` (`2026-W39`), `{{ week_start }}`, `{{ week_end }}`
- monthly: `{{ month }}` (`2026-09`), `{{ month_start }}`, `{{ month_end }}`

The templates for weekly and monthly reviews are versioned in VoidLink under
`99_system/015_templates/`. Periodic templates at the templates root are not
offered by `:NoteTemplate`: through the picker they would get a timestamped name
in the wrong folder.

### Edit Markdown Lists and Tables

In Markdown notes, `Enter` continues a list and keeps its marker or number in
sync. At the end of a list item, `Tab` indents it into a nested list and
`Shift-Tab` dedents it; ordered lists are renumbered automatically. `>` and `<`
in Visual mode indent or dedent selected items while preserving the selection.

Use `<leader>mt` while the cursor is in a pipe-style Markdown table to align all
cells. The command is also available as `:MarkdownTableFormat`; it retains the
table's alignment markers (`:---`, `---:`, `:---:`). Rendered tables use padded
cells for easier reading.

## Template System

### Template Format

Templates are standard markdown files with variable placeholders using `{{ }}`
syntax:

```markdown
---
title: "{{ title }}"
id: "{{ id }}"
created: "{{ created }}"
tags: ["note"]
category: "note"
status: "active"
---

# [[{{ title }}]]

## Content

{{ description }}
```

### Default Variables

These variables are automatically provided:

- `{{ id }}` - Generated in format `YYYYMMDD_HHmm`
- `{{ created }}` - ISO timestamp `YYYY-MM-DD HH:mm`
- `{{ created_date }}` - ISO date `YYYY-MM-DD`
- `{{ current_date }}` - ISO date `YYYY-MM-DD`

### Custom Variables

Any variable in `{{ variable_name }}` format will prompt the user at runtime.

### Template Location

Templates are discovered from: `vault_root/99_system/015_templates/`

The system automatically:

- Scans all subdirectories
- Skips README.md and CHANGELOG.md files
- Skips the `_scripts` directory
- Infers category from directory structure (e.g., `01_projects`, `02_areas`)

**Important**: The subdirectory structure (e.g., `01_projects/`) helps organize
templates and suggest default locations, but notes are created in the vault
root, NOT inside the templates directory.

### Creating Custom Templates

1. Create a markdown file in `vault_root/99_system/015_templates/` or any
   subdirectory
2. Use `{{ variable }}` placeholders for user input
3. Use default variables (`{{ id }}`, `{{ created }}`) for automatic values
4. **Special**: If you use `{{ title }}`, it will be prompted first and used to
   suggest the filename
5. The template will automatically appear in the fuzzy picker

Example template:

```markdown
---
title: "{{ title }}"
id: "{{ id }}"
created: "{{ created }}"
tags: ["{{ tag }}"]
category: "{{ category }}"
---

# {{ title }}

## Description

{{ description }}
```

## Directory Structure

The notes system follows the PARA method:

```text
notebook_root/
├── 00_knowledge/         # Knowledge notes
│   ├── 01_atomic/        # Atomic notes
│   ├── 02_literature/    # Literature notes
│   └── 03_permanent/     # Permanent notes
├── 01_projects/          # Active projects
├── 02_areas/             # Areas of responsibility
│   └── 01_periodicNotes/
│       └── daily/        # Daily notes
├── 03_resources/         # Reference materials
├── 04_archive/           # Archived items
└── 99_system/            # Templates, attachments and configuration
    ├── 01_templates/     # Obsidian templates (Templater, JavaScript)
    ├── 015_templates/    # Neovim templates (this module)
    └── attachments/
        └── imgs/         # Every pasted image, from any tool
```

## Frontmatter Conventions

All notes include YAML frontmatter with:

```yaml
---
title: "Note Title"
id: "20251226_2230_example" # Must equal the filename stem
created: "2025-12-26 22:30" # ISO timestamp
lang: "en" # Language (default: en)
tags: ["tag1", "tag2"] # Tags (lowercase)
category: "project" # Note category
status: "active" # Status (lowercase)
---
```

### Naming Conventions

Following the language policy:

- **Lowercase**: folders, files, slugs, tags, categories, status values
- **Exceptions**: Proper names (e.g., "Microsoft Entra ID"), acronyms (API, SSO)
- **Separators**: Underscores for slugs (e.g., `my_project_name`)
- **Date format**: YYYYMMDD for IDs, YYYY-MM-DD for display

Client and project slugs are not free text. They are validated by
`notes.utils.is_slug()` against `^[a-z0-9]+(_[a-z0-9]+)*$` — the same grammar
`azctx` and `void-work` enforce, because the slug is one identifier shared with
Azure, Taskwarrior and Git rather than a note-local convention. The full rule,
including how to migrate existing notes, is in
[`docs/WORK_TAXONOMY.md`](../../../../docs/WORK_TAXONOMY.md).

## Commands Reference

### Note Creation

- `:NoteTemplate` - Create from template (fuzzy search); uses the
  `[[wiki-link]]` under the cursor as `{{ title }}` when present
- `:NoteTemplateFromLink` - Create from template using the `[[wiki-link]]` under
  the cursor as `{{ title }}`
- `:NoteDaily [date]` - Create/open daily note
- `:NoteWeekly [YYYY-Www]` - Create/open weekly review note
- `:NoteMonthly [YYYY-MM]` - Create/open monthly review note
- `:NoteNew [type]` - Create a note of a given type (`project`, `area`,
  `knowledge`, `task`, `meeting`, `person`, `note`)
- `:NoteProjectCreate` - Create a project with its templates and client index

### Note Operations

- `:NoteArchive` - Archive current note (inbound links are rewritten with it)
- `:NoteRename` - Rename current note (inbound links are rewritten with it)
- `:NoteStatus` - Update note status
- `:NoteTag` - Add tag to current note
- `:NoteDelete` - Delete the current Markdown note
- `:NoteInsertExtLink` - Insert an external `[text](url)` link at the cursor
- `:NoteLink` - Pick a vault note and insert a wiki-link; `:'<,'>NoteLink` uses
  the selection as the label
- `:NoteLinkNew` - Link the selection to a new note titled after it
- `:NoteFollowLink` - Follow the link under the cursor (also `gf` in vault
  notes)
- `:NoteBacklinks` - List the notes that link to the current note
- `:NoteLinks` - List the links in the current note, flagging missing targets
- `:NoteSwitch` - Open a note by title, alias, id or path
- `:NoteSearch` - Full-text search across the vault
- `:NotePasteImage` - Save the clipboard image to the attachment folder and
  embed it
- `:NoteOpenInObsidian` - Open the current note in the Obsidian app

### Queries

- `:NoteQueryTasks` - Query active tasks
- `:NoteQueryTasksPending` - Query pending tasks
- `:NoteQueryTasksClosed` - Query closed tasks
- `:NoteQueryTasksDone` - Query completed tasks
- `:NoteQueryTasksProject [project]` - Query tasks for a specific project
- `:NoteQueryProjects` - Query active projects
- `:NoteQueryProjectsArchived` - Query archived projects
- `:NoteQueryClient [slug]` - Query every note of one client, matching both the
  `client/<slug>` tag and the `client` frontmatter field
- `:NoteQueryMeetings [date]` - Query meetings scheduled for today or later;
  past dates return no results
- `:NoteQueryKnowledge [type]` - Query knowledge notes
- `:NoteQueryPeople` - Query people/contacts
- `:NoteQueryTag [tag]` - Query by tag
- `:NoteQueryRecent [days]` - Query recent notes

Queries exclude all files below the configured templates directory, so template
files never appear as contacts, tasks, projects, meetings, or tag results.

The task queries read note frontmatter (`tags: ["task"]`), which is what a task
note created from `:TaskPick` carries. Tasks themselves live in Taskwarrior —
there is no separate checkbox-scanning query.

### Daily Overview

The dashboard and its sub-modules register these under the same `<leader>n`
prefix:

- `:VoidDash` - Open the VoidDash daily overview, including only today's khal
  events
- `:CalendarPick` - Browse upcoming khal events (Telescope)
- `:CalendarNew` - Create a khal calendar event
- `:TaskPick` - Browse pending Taskwarrior tasks by urgency; `<CR>` opens the
  task's note (creating it from the project's `<project_slug>_task_default`
  template, or the global `task` template, on first use), `<C-d>` completes the
  task
- `:TaskAdd` - Capture a Taskwarrior task using `task add` syntax, then offer to
  create its note
- `:TaskCreateFromTemplate` - Choose a task template and explicitly create its
  linked Taskwarrior task; saving a task note never creates one
- `:HealthPick` - Browse workout notes (Telescope)

Task note sync is disabled by default. When `VOIDCORE_TASK_NOTE_SYNC=1` is set,
only notes with `category: task` and a matching `task_uuid` sync the documented
fields in either direction. See
[dot_config/task/README.md](../../../task/README.md).

Vault links are native Lua (`notes/links.lua`) and replace obsidian.nvim, which
is no longer loaded. Marksman provides Markdown completion on demand with
`<C-Space>`; daily-note buffers remain excluded from Marksman in the `allMight`
profile, so use `<leader>ni` there.

## Note Identity

Every note obeys one rule, and the rest of the linking behaviour follows from
it:

**`id` in the frontmatter is always the filename stem, and `aliases[1]` is
always the human title.**

The native Lua resolver matches `[[wiki-link]]` targets against the frontmatter
`id`, filename stem, vault-relative path, and aliases. Marksman provides link
diagnostics and heading navigation. Keeping `id` equal to the filename stem
makes links unambiguous and interoperable with the Obsidian desktop app.

The human title is mirrored into `aliases`, allowing the native resolver and
link picker to display and match notes by name instead of only by id.

Consequences for everyday use:

- Filenames are unique by construction: `:NoteNew` and the template picker both
  default to `YYYYMMDD_HHmm_<slug>`, daily notes to `YYYYMMDD`. Two notes with
  the same title no longer collapse onto the same name.
- Wiki-links are written as stems, never as vault paths — `[[<stem>|Label]]`. A
  stem resolves from anywhere in the vault and stays stable when a note moves.
- `:NoteRename` and `:NoteArchive` use the native Lua link module to rewrite
  inbound wiki-links and Markdown links before moving the file.
- `lua/notes/` is the only frontmatter writer. The `BufWritePre` hook updates
  `updated` without changing the canonical `id` or aliases.
- marksman reports a link that points at nothing, so a remaining breakage
  surfaces as a diagnostic instead of waiting to be discovered.

### Vault template compatibility

Templates under `99_system/015_templates/` live in the vault and are not changed
by this repository configuration. `{{ id }}` is set to the created filename
stem; `aliases` is optional and can hold alternate names. The native resolver
and picker use the title field. [EXAMPLE_TEMPLATE.md](./EXAMPLE_TEMPLATE.md)
shows the recommended frontmatter shape.

### Linking without leaving the note

Create a link after the cursor with `:NoteLink` or `<leader>ni`. To use existing
text as the label, select it and press `<leader>oi`; choose the target in the
picker. `<leader>oN` on a selection creates a new note from a template, titled
after the selection, and links to it.

Follow a link with `gf`, `:NoteFollowLink` or `<leader>of`. The resolver accepts
ids, filename stems, vault-relative paths and, as a fallback, titles and
aliases; `#Heading`, `#heading-slug` and `#^block` fragments jump to their
target, relative Markdown links open the file and URLs open in the browser.
Following a link to a note that does not exist offers to create it from a
template and repoints the link at the new note's id, so it keeps working in the
Obsidian app and in Marksman. Links inside fenced code blocks are text: they are
neither listed as backlinks nor rewritten on a move.

`<leader>ob` lists backlinks, `<leader>ol` the links of the current note with
missing targets marked. Both use Telescope and fall back to the quickfix list.

## Keymaps

Most note keymaps use `<leader>n`; vault-link actions keep the `<leader>o`
namespace obsidian.nvim used, so the muscle memory still applies:

### Note Creation

- `<leader>nT` - **Template picker (fuzzy search)** - Main way to create notes;
  uses the wiki-link title under the cursor when present
- `<leader>nt` - Create from template using the title in the wiki-link under the
  cursor
- `<leader>nd` - Daily note
- `<leader>nW` - Weekly review note
- `<leader>nM` - Monthly review note

### Note Operations

- `<leader>ni` - Insert a wiki-link using the vault picker
- `<leader>na` - Archive note
- `<leader>nr` - Rename note
- `<leader>nu` - Update status
- `<leader>ng` - Add tag
- `<leader>nx` - Delete note

### Vault Links

- `gf` - Follow the link under the cursor (built-in `gf` elsewhere)
- `<leader>of` - Follow the link under the cursor
- `<leader>oi` - Insert a wiki-link; in Visual mode the selection is the label
- `<leader>oN` - Link the selection to a new note (Visual mode)
- `<leader>ob` - Backlinks
- `<leader>ol` - Links in this note
- `<leader>oq` - Quick switch
- `<leader>os` - Search the vault
- `<leader>ot` - Notes by tag
- `<leader>or` - Rename note (updates links)
- `<leader>op` - Paste clipboard image
- `<leader>oo` - Open in the Obsidian app

### Queries

- `<leader>nqt` - Query tasks
- `<leader>nqP` - Query pending tasks
- `<leader>nqX` - Query closed tasks
- `<leader>nqf` - Query tasks by project (prompt)
- `<leader>nqp` - Query projects
- `<leader>nqC` - Query by client slug (prompt)
- `<leader>nqm` - Query meetings
- `<leader>nqk` - Query knowledge
- `<leader>nqc` - Query contacts
- `<leader>nqr` - Query recent
- `<leader>nqg` - Query by tag

### Daily Overview and Workflows

- `<leader>nD` - VoidDash daily overview
- `<leader>nL` - Insert an external `[text](url)` link (normal and insert mode)
- `<leader>np` - New project
- `<leader>nwc` - Calendar events (khal)
- `<leader>nwC` - New calendar event
- `<leader>nwt` - Taskwarrior tasks and their notes
- `<leader>nwa` - Choose a task template and create a linked Taskwarrior task
- `<leader>nwh` - Workout notes

## Configuration

Customize the notes system in your `init.lua`:

```lua
require("notes.init").setup({
  notebook_root = "~/my-notes",  -- Override notebook location

  directories = {
    projects = "01_projects",     -- Customize directory names
    areas = "02_areas",
    knowledge = "00_knowledge/01_atomic",
    resources = "03_resources",
    archive = "04_archive",
    daily = "02_areas/01_periodicNotes/daily",
  },

  default_lang = "en",             -- Default language
  slug_separator = "_",            -- Slug separator
  date_format = "%Y-%m-%d",       -- Date display format
  task_note_template = "task",     -- Template used for Taskwarrior task notes
})
```

## Layer Ownership

This module is layer 1 of a four-layer split
([ADR-005](../../../../docs/ADR-005-note-taking-layer-ownership.md)). Each
capability has exactly one owner, so nothing is configured twice:

| Layer | Owner                      | Owns                                                                  |
| ----- | -------------------------- | --------------------------------------------------------------------- |
| 1     | `lua/notes/` (this module) | Daily notes, templates, frontmatter, PARA routing, queries, dashboard |
| 2     | marksman                   | Broken-link diagnostics, heading anchors, definition, references      |
| 3     | `lua/notes/links.lua`      | Wiki-link creation, following, alias resolution and rename updates    |
| 4     | render-markdown.nvim       | Headings, checkboxes, tables, concealment                             |

The `obsidian.nvim` Lazy import is disabled but its spec is retained.
`render-markdown.nvim` and Treesitter continue to provide Markdown rendering and
syntax highlighting.

## Integration with Obsidian

This system works with Obsidian-compatible vaults without loading obsidian.nvim:

- Uses YAML frontmatter compatible with Obsidian
- Keeps its own plain-variable template directory next to Obsidian's
  JavaScript-based Templater directory
- Supports wiki-style links and resolves ids, filename stems, paths, and aliases
- Uses native Lua for link insertion, following, and inbound wiki-link updates
- Uses Marksman for Markdown diagnostics and on-demand completion
- Uses `render-markdown.nvim` for in-editor Markdown presentation
- Works with Dataview plugin queries
- Maintains a consistent directory structure

## Design Principles

1. **DRY (Don't Repeat Yourself)**: Templates are files, not code
2. **KISS (Keep It Simple)**: Simple variable replacement
3. **Consistency**: Both editors share frontmatter and vault conventions, with
   templates kept in their supported formats
4. **Flexibility**: User controls filename and location at runtime
5. **Extensibility**: Just add a markdown file to create a new template

## Architecture

```text
notes/
├── init.lua              # Configuration and setup
├── commands.lua          # Note commands and keymaps
├── templates.lua         # Template discovery and creation
├── frontmatter.lua       # Frontmatter parsing and updates
├── vault_index.lua       # Shared, short-lived note index
├── taskwarrior.lua       # Explicit task creation and opt-in sync
├── calendar.lua          # khal integration
├── health.lua            # Workout-note queries
├── dashboard.lua         # VoidDash integration
├── project_generator.lua # Project notes and task templates
└── utils.lua             # Paths, prompts and shared helpers
```

## Examples

### Example 1: Create Note from Template

1. Press `<leader>nT` to open template picker
2. Type to filter templates (e.g., "simple note")
3. Select the template
4. Fill in prompts:

- Title: "My New Note"

5. Enter filename: "my_new_note"
6. Enter location: "02_areas/" (or press Enter for default)
7. File created with all variables replaced

### Example 2: Create Custom Template

Create `/99_system/015_templates/my_custom/task.md`:

```markdown
---
title: "{{ task_title }}"
id: "{{ id }}"
created: "{{ created }}"
tags: ["task", "{{ project }}"]
category: "task"
status: "{{ status }}"
priority: "{{ priority }}"
---

# [[{{ task_title }}]]

## Description

{{ description }}

## Checklist

- [ ] {{ subtask1 }}
- [ ] {{ subtask2 }}
```

Next time you run `:NoteTemplate`, this template will be available!

## Troubleshooting

### Templates not found

- Check that templates exist in `99_system/015_templates/`
- Ensure template files have `.md` extension
- Verify the notebook root is correctly detected

### Notes being created in wrong location

- **Expected behavior**: Notes are created at `vault_root/<location>/<filename>`
- **NOT in**: `vault_root/99_system/015_templates/<location>/<filename>`
- Templates stay in `99_system/015_templates/` (read-only)
- Notes go to vault paths like `01_projects/`, `02_areas/`, etc.

### Variables not being replaced

- Check variable syntax: `{{ variable }}` with spaces allowed
- Ensure all required variables are prompted
- Default variables (`id`, `created`, etc.) are automatic
- Variables with the same name are only prompted once (deduplication)

### Getting prompted for title twice

- **Fixed**: If template has `{{ title }}`, you're now only prompted once
- The title is used both for content and filename suggestion
- You can still override the suggested filename if needed

### Directory not created

- The system creates directories automatically
- Check file permissions on the notebook root
