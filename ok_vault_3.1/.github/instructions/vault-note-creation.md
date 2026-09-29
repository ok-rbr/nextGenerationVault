---
name: vault-note-creation
description: Create notes in vaultK following PARA + Knowledge structure, templates, naming and frontmatter rules.
---

# vaultK Note Creation

Create new notes consistent with vaultK conventions.

## Structure

- 00_knowledge/ (inbox, atomic, literature, permanent)
- 01_projects/
- 02_areas/
- 03_resources/
- 04_archive/
- Templates: 99_system/01_templates/

## Conventions

- lowercase filenames
- underscores only
- no special chars
- ISO timestamps

### Frontmatter

---
title: "note_title"
id: "YYYYMMDD_HHMM"
created: "YYYY-MM-DD HH:mm"
tags: []
category: "knowledge|project|area|resource"
status: "in-progress"
related: []
concepts: []
aliases: []
---

## Workflow

1. Scan vault:
   - search all folders
   - detect duplicates
   - find related notes

2. Classify:
   - Knowledge (default for concepts)
   - Project (goal-driven)
   - Area (long-term domain)
   - Resource (external/reference)

3. Knowledge subtype:
   - inbox → raw
   - atomic → focused idea
   - literature → source-based
   - permanent → distilled

4. Use template:
   - 99_system/01_templates/

5. Create note:
   - correct folder
   - correct naming
   - correct frontmatter

6. Link:
   - related / concepts
   - wikilinks when appropriate

## Rules

- NEVER create duplicates
- Prefer correct placement over speed
- Keep notes minimal but structured
- Do not invent content
- Respect blocked/sensitive paths
