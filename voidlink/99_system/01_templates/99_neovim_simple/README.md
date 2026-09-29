# Simple Neovim Templates

This directory contains simplified templates designed specifically for use with the Neovim note-taking system.

## Template Format

These templates use the `{{ variable }}` placeholder syntax. When you create a note from one of these templates in Neovim:

1. The system extracts all variables from the template
2. Prompts you for each variable value
3. Automatically provides default values for `id`, `created`, `created_date`, and `current_date`
4. Replaces all placeholders with the values you provided
5. Creates the note with the processed content

## Available Templates

### simple_note.md
A basic note template with minimal structure.

**Variables:**
- `title` - The title of your note
- `id` - Auto-generated (YYYYMMDD_HHmm)
- `created` - Auto-generated (YYYY-MM-DD HH:mm)

**Default location:** `02_areas/`

### simple_meeting.md
A meeting notes template with agenda and action items.

**Variables:**
- `title` - The meeting title
- `meeting_date` - The date of the meeting
- `id` - Auto-generated (YYYYMMDD_HHmm)
- `created` - Auto-generated (YYYY-MM-DD HH:mm)

**Default location:** `02_areas/`

### simple_project.md
A project overview template.

**Variables:**
- `project_name` - The name of the project
- `client` - The client or customer name
- `description` - Brief project description
- `id` - Auto-generated (YYYYMMDD_HHmm)
- `created` - Auto-generated (YYYY-MM-DD HH:mm)

**Default location:** `01_projects/`

### security_knowledge.md
Atomic security knowledge template (attack patterns, privesc techniques, concepts).

**Variables:**
- `title` - Suggested slug-style title (e.g. `attack-pattern-file-upload-rce`)
- `primary_tag` - Main tag for frontmatter (e.g. `attack-pattern`, `privesc`, `concept`)
- `inline_tags` - Space-separated inline tags (e.g. `#attack-pattern #web #rce`)
- `related_note_1` - First related note name
- `related_note_2` - Second related note name
- `id` - Auto-generated (YYYYMMDD_HHmm)
- `created` - Auto-generated (YYYY-MM-DD HH:mm)

**Default location:** `00_knowledge/`

### security_htb_machine.md
Project-context template for Hack The Box machines with explicit knowledge extraction.

**Variables:**
- `machine_name` - HTB machine name
- `target_ip` - Target IP
- `os` - OS tag (e.g. linux, windows)
- `difficulty` - Difficulty tag (e.g. easy, medium, hard)
- `inline_tags` - Space-separated inline tags (e.g. `#htb #machine #linux #easy`)
- `extracted_note_1` - First extracted knowledge note
- `extracted_note_2` - Second extracted knowledge note
- `id` - Auto-generated (YYYYMMDD_HHmm)
- `created` - Auto-generated (YYYY-MM-DD HH:mm)

**Default location:** `01_projects/security-lab/htb/`

## Using Templates in Neovim

1. Open Neovim in your notebook
2. Press `<leader>nT` (usually `\nT`) or run `:NoteTemplate`
3. Search for "simple" or "security" to filter these templates
4. Select the template you want
5. Fill in the prompted variables
6. Enter a filename (e.g., `my_note`)
7. Choose a location (or press Enter for default)

## Creating Your Own Templates

To create a custom template:

1. Create a new `.md` file in this directory
2. Use `{{ variable_name }}` for any values you want to prompt for
3. Use `{{ id }}`, `{{ created }}`, `{{ created_date }}`, or `{{ current_date }}` for automatic values
4. Structure your frontmatter and content as desired

Example:

```markdown
---
title: "{{ task_title }}"
id: "{{ id }}"
created: "{{ created }}"
tags: ["task", "{{ priority }}"]
category: "task"
status: "active"
---

# {{ task_title }}

## Description

{{ description }}

## Checklist

- [ ] {{ step1 }}
- [ ] {{ step2 }}
```

The template will automatically appear in the fuzzy picker next time you use `:NoteTemplate`!

## Tips

- Use descriptive variable names (e.g., `project_name` instead of just `name`)
- Always include `id` and `created` in frontmatter for consistency
- Keep templates simple and focused on structure, not content
- Test your template by creating a note from it
