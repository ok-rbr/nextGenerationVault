# VoidLink - Personal Knowledge & Life Management System

An Obsidian-compatible vault experiment for systematic knowledge management and life organization. Built on the PARA method (Projects, Areas, Resources, Archive) enhanced with Zettelkasten principles for networked thinking and permanent knowledge building.

## 📋 Table of Contents

- [Overview](#overview)
- [Mindset & Goals](#mindset--goals)
- [Vault Structure](#vault-structure)
- [Template System](#template-system)
- [Quick Start](#quick-start)
- [Naming Conventions](#naming-conventions--frontmatter)
- [Philosophy & Methods](#structure-philosophy)
- [Vault Automation Scripts](#vault-automation-scripts)
- [vault-agent CLI](#vault-agent-cli)
- [Statistics](#vault-statistics)

## Overview

VoidLink is an experimental personal knowledge management (PKM) system designed for systematic information capture, project management, and personal development tracking. It combines proven methodologies with a pragmatic, developer-friendly approach.

### Core Features

- ✅ **PARA Organization**: Clear separation of Projects, Areas, Resources, and Archive
- 📝 **Template System**: 26+ specialized templates for various use cases
- 🧠 **Zettelkasten Knowledge Base**: Structured knowledge progression from inbox to permanent notes
- 🔗 **Networked Thinking**: Automatic linking and relationship management
- 📊 **Dataview Queries**: Dynamic dashboards and filtered views
- ⏰ **Periodic Notes**: Daily and weekly templates for habit tracking
- 🎯 **Project Tracking**: Dedicated structures for active projects (gaming, personal development, life goals)
- 🏋️ **Health & Fitness**: Specialized templates for workouts, nutrition, yoga, and meditation

### What Makes It Different

- **Developer-first**: Clean structure, consistent naming, version-controlled
- **Flexible but structured**: Templates provide structure without rigid constraints
- **Multi-domain**: Handles professional projects, personal development, health, and knowledge work
- **Obsidian-compatible**: Uses standard markdown with optional Obsidian plugins
- **Evolution-friendly**: Archives old content, maintains history, allows experimentation

## Mindset & Goals

### Core Principles

**Progressive Knowledge Building**: Information flows from quick capture (inbox) → atomic notes → literature notes → permanent knowledge. This prevents information loss while maintaining quality.

**Action-oriented Organization**: Projects are time-bound with clear outcomes. Areas are ongoing responsibilities. Resources are reference material. This distinction drives better prioritization.

**Minimal Friction**: Templates automate structure. Naming conventions reduce cognitive load. Dataview queries provide instant overviews. The system should enable thinking, not obstruct it.

**Clean Code Philosophy**: The vault applies software engineering principles—DRY (Don't Repeat Yourself), KISS (Keep It Simple), SRP (Single Responsibility Principle). Templates are modular. File names are predictable. Metadata is consistent.

### Goals

1. **Capture Everything, Process Thoughtfully**: Lower the barrier to capture ideas while maintaining quality through progressive refinement
2. **Bridge Life Domains**: Connect professional projects, personal development, health goals, and knowledge work in one system
3. **Long-term Knowledge Compound**: Build permanent notes that compound in value over time through connections and refinements
4. **Learn in Public (Private Edition)**: Document experiments, track progress, learn from failures in a personal lab
5. **Optimize for Retrieval**: Structure for future-self—easy to find, easy to understand, easy to extend

### Current Focus Areas

- **Life RPG**: Gamifying personal development with stat tracking (inspired by Dark Souls/Skyrim mechanics)
- **Knowledge Work**: Building a technical knowledge base for development topics
- **Health Optimization**: Systematic tracking of fitness routines, nutrition, and wellness practices
- **Project Documentation**: Transparent logs of active projects with progress tracking

## Vault Structure

```
voidlink/
│
├── 00_knowledge/              # Zettelkasten-inspired knowledge management
│   ├── 00_inbox/             # Quick capture, unprocessed ideas
│   ├── 01_atomic/            # Small, focused knowledge units
│   ├── 02_literature/        # Notes from books, articles, courses
│   ├── 03_permanent/         # Verified, networked permanent notes
│   └── 00_index.md           # Knowledge overview dashboard
│
├── 01_projects/               # Time-bound initiatives with clear outcomes
│   ├── elden_ring/           # Game progress tracking
│   ├── lifeRPG/              # Personal development gamification
│   ├── newPC/                # Hardware specifications and planning
│   ├── raphasPartei/         # Political party questionnaire project
│   └── 00_index.md           # Active projects dashboard
│
├── 02_areas/                  # Ongoing responsibilities and life domains
│   ├── botanic/              # Plant care and gardening
│   ├── health/               # Fitness, nutrition, wellness tracking
│   ├── ideas/                # Project ideas and concepts
│   ├── life/                 # Daily logs, reflections, planning
│   ├── safehouse/            # Home management and systems
│   └── 00_index.md           # Areas overview dashboard
│
├── 03_resources/              # Reference material and assets
│   ├── img/                  # Images and visual assets
│   ├── libary_of_raxovile/   # Collected reference documents
│   ├── people/               # Contact profiles and relationship notes
│   └── 00_index.md           # Resources index
│
├── 04_archive/                # Completed/deprecated content
│   ├── Geschäftsideen/       # Old business ideas
│   ├── studium/              # University-related archives
│   ├── vaultAIExperiment/    # Previous vault experiments
│   └── vaultMigration/       # Migration history
│
└── 99_system/                 # Vault configuration and templates
    ├── 01_templates/         # 26+ templates organized by category
    │   ├── 00_knowledge/    # Knowledge management templates
    │   ├── 01_projects/     # Project tracking templates
    │   └── 02_areas/        # Area-specific templates
    ├── 02_config/            # Configuration files
    ├── 03_workflow/          # Workflow documentation
    ├── 04_logs/              # System logs and changelogs
    └── 00_index.md           # System documentation hub
```

### Organization Principles

The vault implements a **layered information architecture**:

1. **Knowledge (00_)**: Permanent, domain-independent insights that compound over time
2. **Projects (01_)**: Temporary initiatives with deadlines and deliverables
3. **Areas (02_)**: Ongoing responsibilities requiring maintenance
4. **Resources (03_)**: Reference material, people, and assets
5. **Archive (04_)**: Historical context, completed projects, deprecated content
6. **System (99_)**: Meta-level—templates, configs, and tooling

Each top-level directory contains an `00_index.md` file with Dataview queries for dynamic overviews.

## Template System

The vault includes **26+ specialized templates** organized by use case and domain. Templates use Templater for dynamic content generation and automatic file organization.

### 🧠 Knowledge Templates (4)

For systematic knowledge capture and progression:

- **Inbox Note**: Quick capture template for raw ideas
- **Atomic Note**: Single-concept notes following Zettelkasten principles
- **Literature Note**: Book/article summaries with source attribution
- **Permanent Note**: Refined, networked knowledge pieces

### 📁 Project Templates (3)

For project tracking and documentation:

- **Project README**: Project overview and structure
- **Daily/Weekly Logs**: Time-stamped progress tracking
- **Task/Note Templates**: Context-specific templates per project

### 🎯 Area Templates (16+)

Domain-specific templates for life areas:

**Health & Fitness:**
- Training: exercises, routines, workouts and evaluations (see [Training Templates](#training-templates))
- Yoga session/pose documentation
- Meditation session logs
- Stretching routine templates
- Nutrition: Recipe and meal logging

**Life Management:**
- Daily notes (habit tracking, reflection)
- Weekly notes (review and planning)
- Weekly review template (deep reflection)
- Task notes (GTD-style)

**General:**
- Default note template
- Meeting notes
- Contact/people profiles

### 📚 Resource Templates (3)

For relationship and asset management:

- **Customer Profiles**: Client relationship tracking
- **Colleague Profiles**: Team member documentation
- **Generic People Template**: Contact information structure

### Neovim Periodic Templates

`99_system/015_templates/` holds the templates the Neovim note-taking layer
(`lua/notes/` in voidCore) reads. They use plain `{{ variable }}` placeholders,
not Templater, because Neovim cannot run Templater's JavaScript.

- `weekly.md` — weekly review, created by `:NoteWeekly [YYYY-Www]` as
  `02_areas/life/logs/weekly/2026_w39.md`
- `monthly.md` — monthly review, created by `:NoteMonthly [YYYY-MM]` as
  `02_areas/life/logs/monthly/2026_09.md`

The Dataview blocks in them carry the period's dates as literals, so the same
note works in Obsidian without Templater. The placeholders are listed in
voidCore's `dot_config/nvim/lua/notes/README.md`.

### Vault Dashboard

`99_system/015_templates/00_knowledge/vault_dashboard.md` is a Dataview note
showing the vault's health: notes per PARA folder and per area, orphan notes
(no incoming links), notes without frontmatter `tags`, open tasks (checkboxes in
`01_projects/` and `task` notes that are not finished) and the ten most recently
edited notes. It is versioned here as a template because the PARA folders are
not in this repository. Create the note once in Neovim:

1. `:NoteTemplate` → *Vault Dashboard*, title `Vault Dashboard`
2. At the filename prompt, replace the timestamped default with
   `vault_dashboard`: the dashboard exists once and `[[vault_dashboard]]` should
   stay stable.

The `location:` line puts it at `00_knowledge/vault_dashboard.md`. Neovim does
not render Dataview; the note lists the `:NoteQuery*` commands that answer the
same questions there. The weekly review template has a checklist item for it.

The dashboard and `vault-agent validate inventory` overlap on purpose, with a
split: the dashboard is the **live view** in Obsidian, the inventory reports are
the **history and gate**, written to `99_system/ai_staging/inventory/` and
comparable from run to run. They define an orphan differently: the dashboard
lists notes without incoming links, the inventory report notes with neither
incoming nor outgoing links.

### Training Templates

`99_system/015_templates/02_areas/health/training/` holds four Neovim templates
for strength and calisthenics training, one per note type:

| Template                 | `type`                | Created in                              |
| ------------------------ | --------------------- | --------------------------------------- |
| `exercise.md`            | `exercise`            | `02_areas/health/training/exercises/`   |
| `training_routine.md`    | `training_routine`    | `02_areas/health/training/routines/`    |
| `workout.md`             | `workout`             | `02_areas/health/training/workouts/`    |
| `training_evaluation.md` | `training_evaluation` | `02_areas/health/training/evaluations/` |

A routine is the plan, a workout what was actually done, an evaluation a look
back over a period. Workouts and routines name exercises by a stable
`exercise_ref`, and a workout logs every set (reps, hold in seconds, load, RPE)
as a list in its frontmatter, so Dataview computes volume and progress without
reading the note body. The fields, units and allowed values are in
[`99_system/05_schemas/training_schema.md`](99_system/05_schemas/training_schema.md),
together with how to migrate notes made from the removed calisthenics templates;
`vault-agent validate frontmatter` checks them.

### Template Features

- **Dynamic Prompts**: Templater asks for context (title, tags, dates)
- **Auto-organization**: Files move to correct folders automatically
- **Consistent Metadata**: Standardized frontmatter across all notes
- **Dataview-ready**: Templates generate queryable metadata
- **Language Support**: English default with German umlaut handling in slugs

## Quick Start

### Prerequisites

- **[Obsidian](https://obsidian.md/)** installed (v1.0+)
- **Required Plugins**:
  - **Templater**: Dynamic template processing (essential)
  - **Dataview**: Query language for notes (essential)
- **Recommended Plugins**:
  - **Periodic Notes**: Automated daily/weekly notes
  - **Tasks**: Enhanced task management
  - **Calendar**: Visual date navigation

### Initial Setup

1. **Clone or Download**: Get the vault to your local machine
2. **Open in Obsidian**: File → Open folder as vault → Select `voidlink/`
3. **Enable Core Plugins**: Settings → Core plugins → Enable Templates, Daily notes
4. **Install Community Plugins**: Settings → Community plugins → Install Templater and Dataview
5. **Configure Templater**: Point template folder to `99_system/01_templates/`

### Using Templates

Templates are located in `99_system/01_templates/` organized by category.

**Method 1: Templater Command (Recommended)**
1. Create new note or open existing note
2. Press `Cmd/Ctrl + P` → Search "Templater: Insert Template"
3. Navigate through category folders
4. Select template
5. Answer prompts (title, tags, etc.)
6. Template auto-populates with metadata and moves file to correct location

**Method 2: Manual Copy**
1. Navigate to `99_system/01_templates/[category]/`
2. Copy template content
3. Paste into new note
4. Manually fill in frontmatter fields

### Example Workflow: Daily Note

```markdown
1. Open Templater: Cmd/Ctrl + P → "Templater: Insert"
2. Navigate to: 02_areas/life/log/daily_default.md
3. Template prompts:
   - Date: (auto-filled with today)
   - Focus areas: (enter your priorities)
4. Note is created in: 02_areas/life/logs/daily/YYYYMMDD_daily.md
5. Start writing your daily log
```

### Example Workflow: New Project

```markdown
1. Create folder: 01_projects/my_project/
2. Use template: 01_templates/01_projects/README.md
3. Fill in project metadata:
   - Title, client, due date, status
4. Template creates project structure:
   - README.md (overview)
   - notes/ (general notes)
   - log/ (daily logs)
   - tasks/ (task tracking)
```

## Naming Conventions & Frontmatter

### File Naming Standards

**Format**: `lowercase_with_underscores.md`

**Rules**:
- All lowercase characters
- Underscores (`_`) as word separators
- No spaces, umlauts, or special characters
- Date prefixes when relevant: `YYYYMMDD_HHMM-description.md`
- Context from folder structure, not filename

**Examples**:
```
✅ Good: 20251227_1430-project_review.md
✅ Good: dark_souls_stats.md
✅ Good: weekly_review_template.md

❌ Bad: Project Review.md
❌ Bad: DarkSouls-Stats.md
❌ Bad: Weekly Review Ü.md
```

### Standard Frontmatter

The conventions are owned by voidCore, which writes the notes
([`docs/VAULT_STRUCTURE.md`](https://github.com/raxovile/voidCore/blob/experiment626/docs/VAULT_STRUCTURE.md),
ADR-005, `docs/WORK_TAXONOMY.md`).
[`99_system/05_schemas/frontmatter.schema.json`](99_system/05_schemas/frontmatter.schema.json)
mirrors them, and `vault-agent validate frontmatter` checks every note against it.

```yaml
---
title: "Note Title"
aliases: ["Note Title"]
id: "20260921_1030_note_title"
created: "YYYY-MM-DD HH:mm"
updated: "YYYY-MM-DD HH:mm"
lang: "en"
category: "project"
status: "active"
tags: ["project", "client/acme_gmbh"]
related: []
concepts: []
---
```

**Required**:
- `title`: human-readable title
- `id`: the file name stem, i.e. the wiki-link target (`20260921_1030_note_title`,
  `20260921` for a daily note, `acme_client_index`). Lowercase alphanumerics
  separated by `_`; it must equal the file name without `.md`
- `created`: `YYYY-MM-DD HH:mm`
- `tags`: array of lowercase tags, segments separated by `/`, `_` or `-`
- `category`: `project`, `area`, `resource`, `knowledge`, `index`, `task`,
  `meeting`, `person`, `client`, `daily` or `weekly`
- `status`: only for `project`, `task` and `client` notes — `active`,
  `in-progress`, `waiting`, `review`, `draft`, `done`, `completed`, `archived`
  or `deleted`. Other notes may carry it with the same values

**Optional, checked when present**:
- `aliases` (the first one is the human title obsidian.nvim shows),
  `related`, `concepts`, `participants`: arrays of strings
- `updated`, `archived`: `YYYY-MM-DD HH:mm`; `date`: `YYYY-MM-DD`;
  `due`, `wait_until`: `YYYY-MM-DD` or empty
- `client`, `project`: a slug (`^[a-z0-9]+(_[a-z0-9]+)*$`) or empty
- `lang`: `en` or `de`
- `schemaVersion`, `source`, `confidence`

Other fields are allowed (`type`, `priority`, `task_uuid`, `email`, `role`, …).

### Tagging Conventions

**Format**: Lowercase, short, hierarchical

**Patterns**:
- `#topic/subtopic` - Knowledge domains (`#dev/rust`, `#health/nutrition`)
- `#type/kind` - Note types (`#note/permanent`, `#log/daily`)
- `#status/state` - Workflow states (`#status/draft`, `#status/review`)
- `#project/name` - Project associations (`#project/liferpg`)

**Anti-patterns**:
- No duplicate information with category/status fields
- No uppercase (except acronyms in proper nouns)
- No special characters or spaces
- No overly generic tags like `#note` or `#important`

## Structure Philosophy

VoidLink synthesizes proven knowledge management and productivity methodologies:

### PARA Method (Tiago Forte)

**Projects → Areas → Resources → Archive**

- **Projects**: Time-bound, goal-oriented work with clear completion criteria
- **Areas**: Ongoing responsibilities requiring maintenance (health, relationships, skills)
- **Resources**: Topic-based reference material independent of projects/areas
- **Archive**: Completed or inactive content for historical reference

This creates **actionability-based organization**. When you open the vault, projects demand attention first, areas are monitored, resources are referenced as needed.

### Zettelkasten Principles (Niklas Luhmann)

**Atomic Notes → Connections → Emergent Structure**

The `00_knowledge/` hierarchy implements progressive note refinement:
1. **Inbox** (00): Quick capture, minimal processing
2. **Atomic** (01): Single-concept notes, self-contained
3. **Literature** (02): Source-attributed summaries and extracts
4. **Permanent** (03): Refined insights with bi-directional links

This prevents "collector's fallacy"—capturing without processing. Notes must earn their place in permanent knowledge through refinement and connection.

### Getting Things Done (David Allen)

**Capture → Clarify → Organize → Reflect → Engage**

Templates embody GTD principles:
- Quick capture via inbox templates (low friction)
- Metadata fields force clarification (what, when, why)
- Auto-organization via Templater (reduce decision fatigue)
- Index pages enable reflection (dashboards and queries)
- Tags and statuses guide engagement (what needs attention)

### Software Engineering Principles

**DRY, KISS, SRP applied to PKM**

- **DRY** (Don't Repeat Yourself): Templates prevent manual structure creation. Library functions (lib.js) centralize common operations.
- **KISS** (Keep It Simple): Markdown files, flat hierarchies where possible, convention over configuration.
- **SRP** (Single Responsibility): Each note has one purpose. Each folder has one domain. Each template has one use case.

### Continuous Improvement

The vault is an **experiment**, not a final system. Features to explore:

- **Spaced Repetition**: Integrate Anki or Obsidian plugins for memory retention
- **Graph Analysis**: Mine the knowledge graph for unexpected connections
- **Automation**: Scripts for archiving old projects, generating reports
- **Integration**: Link to external tools (Notion, Todoist, calendar apps)
- **Metrics**: Track vault health (note count, connection density, orphaned notes)

## Vault Automation Scripts

`vault-agent` (below) is the one tool for vault automation. The two standalone
scripts that used to live in `99_system/_scripts/` were removed (#44):

| removed | use instead |
|---------|-------------|
| `vaultops.py lint` | `vault-agent validate frontmatter` |
| `voidlink_agent.py` (`POST /suggest`, FastAPI + Ollama) | `vault-agent plan` and `vault-agent ingest`, which propose metadata into `99_system/ai_staging/` for review |

AI features beyond metadata suggestions — embeddings, semantic search — belong
to VoidSentinel ([voidSentinel#8](https://github.com/raxovile/voidSentinel/issues/8)).
`99_system/_scripts/` keeps the Templater library `lib.js` and the
`new-yoga-pose.ps1` helper.

## vault-agent CLI

`vault-agent` is the Python command-line tool that powers AI-assisted vault management. It lives in `src/voidlink_cli/` and is installed as a standalone tool via `pip install -e .` (or `uv sync`).

### Installation

```bash
# From the repository root
pip install -e .

# or with uv
uv sync
```

After installation the `vault-agent` command is available on your `PATH`.

### Quick Start

```bash
# Initialise vault-agent in the current directory
vault-agent init

# Check configuration and connectivity
vault-agent health

# Scan the vault and validate its structure
vault-agent validate schemas

# Validate every note's frontmatter against the JSON schema
vault-agent validate frontmatter

# Generate a PARA placement plan
vault-agent plan para --scope all --output plan.json

# Ingest a specific folder (with LLM enhancement)
vault-agent ingest folder --path 02_areas/health --with-llm
```

### Configuration

vault-agent reads configuration from a `vault-agent.yml` file in the vault root and from environment variables (prefix `VOIDLINK_`, delimiter `__`).

| Variable | Default | Description |
|---|---|---|
| `VOIDLINK_VAULT__ROOT` | current directory | Absolute path to vault root |
| `VOIDLINK_VAULT__STAGING_DIR` | `99_system/ai_staging` | Staging directory for run artefacts |
| `VOIDLINK_VAULT__SCHEMAS_DIR` | `99_system/05_schemas` | Path to JSON schemas |
| `VOIDLINK_LOG_LEVEL` | `INFO` | Logging level |
| `VOIDLINK_PROFILE` | `default` | Configuration profile name |

Ollama must be running locally on `http://localhost:11434` with a `qwen3` model available for `--with-llm` features.

### Commands

#### `vault-agent init`

Initialise vault configuration and create required directories.

```bash
vault-agent init [--vault-root PATH]
```

#### `vault-agent health`

Verify configuration, directory access, and report vault root details.

#### `vault-agent validate schemas`

Scan the vault and report note counts, media files, and directory statistics.

```bash
vault-agent validate schemas [--scope all|PATTERN] [--output FILE]
```

#### `vault-agent validate frontmatter`

Validate the frontmatter of every note against
`99_system/05_schemas/frontmatter.schema.json`: required fields, types, enums
and patterns. Read-only — notes are never changed.

```bash
vault-agent validate frontmatter [PATH ...] \
  [--scope all|PATTERN] \
  [--include-system] \
  [--output-dir DIR] \
  [--no-report]
```

- Frontmatter is read as YAML 1.2 core, the way Obsidian reads it: unquoted
  `id: 20240101_1200`, `created: 2024-01-01 12:00` or `yes` stay strings.
- Skipped by default: `99_system/` (templates with `{{ id }}` placeholders and
  system docs) and `README.md`, `AGENTS.md`, `CLAUDE.md` at the root.
  `--include-system` checks them too. `99_system/ai_staging/` is never checked.
- One line per issue on stdout (`path: field: message`); the report goes to
  `99_system/ai_staging/validation/frontmatter_validation.{md,json}` unless
  `--no-report` is given.
- Exit codes: `0` = all notes valid, `1` = issues found, `2` = schema missing.

As a pre-commit hook in the vault repository:

```yaml
- repo: local
  hooks:
    - id: vault-frontmatter
      name: vault frontmatter
      entry: vault-agent validate frontmatter --no-report
      language: system
      files: \.md$
```

#### `vault-agent ingest folder`

Run the full ingestion pipeline on a folder: metadata extraction (optional LLM), backlink detection, media extraction, and git commit.

```bash
vault-agent ingest folder \
  --path 02_areas/health \
  [--with-llm] \
  [--read-content] \
  [--extract-media] \
  [--no-interactive] \
  [--output report.json]
```

#### `vault-agent ingest hevy`

Placeholder for future Hevy training-data ingestion.

#### `vault-agent plan para`

Classify all vault notes according to the PARA framework and generate a migration plan.

```bash
vault-agent plan para \
  [--scope all|PATTERN] \
  [--with-llm] \
  [--read-content] \
  [--output plan.json]
```

Each action in the output JSON contains:
- `note_path` – relative path inside the vault
- `source_category` / `target_category` – current and suggested PARA category
- `action_type` – always `move` for reclassification
- `confidence` – float 0–1; actions with `requires_review: true` have confidence < 0.75
- `llm_enhanced` – whether the LLM boosted the heuristic result

#### `vault-agent plan suggest`

Generate suggest-only artifacts (`*.json` + `*.review.md`) and persist pending suggestions to the local SQLite index.
Artifacts include similar-note context and skip policy-sensitive paths.

```bash
vault-agent plan suggest [--scope all|PATTERN] [--output-dir PATH]
```

#### `vault-agent review pending`

List all suggestions with status `pending`.

#### `vault-agent review show`

Show a specific suggestion payload:

```bash
vault-agent review show <suggestion_id>
```

#### `vault-agent review approve`

Approve a suggestion and persist reviewer metadata:

```bash
vault-agent review approve <suggestion_id> [--by local-user]
```

#### `vault-agent review reject`

Reject a suggestion:

```bash
vault-agent review reject <suggestion_id> [--by local-user]
```

#### `vault-agent review sync`

Sync checked review markdown files (`- [x] approve`) back into SQLite:

```bash
vault-agent review sync [--by local-user]
```

#### `vault-agent apply commit`

Apply approved suggestions (`status=approved`) with staleness checks, policy gates, and audit updates.

```bash
vault-agent apply commit --approved-only
```

This command also writes:
- `99_system/ai_staging/reports/change_log.jsonl`
- `99_system/ai_staging/reports/rollback.md`

#### `vault-agent apply preview`

Preview approved suggestion counts before apply:

```bash
vault-agent apply preview
```

### Architecture

```
src/voidlink_cli/
├── cli.py              # Typer app, init & health commands
├── config.py           # Pydantic settings (VaultConfig, Config)
├── run_logging.py      # Run ID generation, manifest creation
├── commands/           # Command sub-groups (one Typer per group)
│   └── __init__.py     # validate, ingest, plan, review, apply apps
├── indexing/
│   └── db.py           # SQLite schema init for audit/suggestions
├── policy/
│   └── loader.py       # ai_policy loader and rule helpers
├── scanning/
│   ├── vault_scanner.py   # Recursive vault discovery + metadata extraction
│   └── inventory_reports.py  # Standardized inventory artifacts
├── validation/
│   └── frontmatter.py  # Full JSON Schema validation of note frontmatter
├── planning/
│   ├── para.py         # ParaClassifier, ParaCategory, ClassificationResult
│   ├── engine.py       # PlanningEngine, MigrationPlan, MigrationAction
│   └── suggestions.py  # Suggest-only artifacts + SQLite persistence
├── llm/
│   ├── client.py       # OllamaClient (HTTP wrapper for Ollama)
│   └── enhanced_engine.py  # EnhancedPlanningEngine (LLM-boosted planning)
├── extraction/
│   ├── extractor.py    # ContentExtractor, ExtractionResult
│   └── sidecar.py      # SidecarWrapper (.extracted.txt files)
├── ingest/
│   ├── backlinks.py    # BacklinkDetector
│   ├── interactive.py  # InteractiveReview (terminal prompts)
│   └── folder_ingester.py  # FolderIngester (full pipeline orchestrator)
└── media/
    ├── models.py       # MediaEntry, MediaType, MediaTemplate
    └── rating.py       # MediaRatingEngine, RatingAnalysis
```

---



**Current State** (as of 2025-12-27):

```
Content Distribution:
├── 03_resources/     ~72 MB  (images, library, reference documents)
├── 04_archive/       ~5.3 MB (historical projects and migrations)
├── 02_areas/         ~2.4 MB (health, ideas, life tracking)
├── 00_knowledge/     ~444 KB (inbox, atomic, literature, permanent notes)
├── 99_system/        ~352 KB (templates, configs, docs)
└── 01_projects/      ~68 KB  (active projects)

Total Files: ~1,449 markdown files
Templates: 26+ specialized templates
Active Projects: 4 (elden_ring, lifeRPG, newPC, raphasPartei)
Life Areas: 5 (botanic, health, ideas, life, safehouse)
```

**Template Library Changelog**: See `99_system/01_templates/CHANGELOG.md` for version history and feature documentation.

## Technologies & Tools

- **[Obsidian](https://obsidian.md/)**: Core knowledge base application
- **[Templater Plugin](https://github.com/SilentVoid13/Templater)**: Dynamic template processing with JavaScript
- **[Dataview Plugin](https://github.com/blacksmithgu/obsidian-dataview)**: SQL-like query language for notes
- **Markdown**: Plain text format for longevity and portability
- **YAML Frontmatter**: Structured metadata for querying
- **Git**: Version control for vault history (optional)

## Contributing & Experimentation

This is a **personal vault experiment**, but the structure and templates can inspire your own system.

**Feel free to**:
- Fork and adapt templates for your use case
- Suggest improvements via issues or discussions
- Share your own PARA/Zettelkasten implementations
- Report bugs in templates or documentation

**Guidelines**:
- Keep templates simple and focused (single purpose)
- Maintain consistent naming and metadata conventions
- Document new features in template headers
- Test templates with Templater before committing

### Development

```bash
uv sync --frozen            # or ./scripts/check.sh setup
./scripts/check.sh all      # ruff, shellcheck, pytest and a vault-agent --help smoke test
./scripts/check.sh fmt      # format; the only verb that edits files
```

CI runs the same `./scripts/check.sh all` on every pull request. The tests
build fixture vaults in temporary directories; nothing reads a real vault,
Ollama or a user configuration.

### House standard

`.editorconfig`, `.gitattributes` and the core of `.pre-commit-config.yaml`
follow the VoidSystem house standard
([raxovile/voidCore#275](https://github.com/raxovile/voidCore/issues/275)) and
are identical in every VoidSystem repository. Change the standard in voidCore
first, then here; a local deviation needs a justification as a comment in the file itself. Run
`pre-commit install` once per clone so the hooks run before every commit.
`.secrets.baseline` lists reviewed `detect-secrets` findings: update it with
`detect-secrets scan --baseline .secrets.baseline` and review the new entries,
never regenerate it as part of an unrelated change.

## License

This vault is shared for educational and experimental purposes. Templates and structure are free to use and adapt. Personal content in notes is private and not for redistribution.

---

**Version**: 2.0 (Experimental)  
**Last Updated**: 2025-12-27  
**Maintainer**: [@raxovile](https://github.com/raxovile)  
**Repository**: [voidlink](https://github.com/raxovile/voidlink)
