# Example Template for Testing

This is a demonstration template to test the note-taking workflow fixes.

## Location

Create this file at:
`vault_root/99_system/015_templates/01_projects/demo_project.md`

## Template Content

```markdown
---
title: "{{ title }}"
aliases: ["{{ title }}"]
id: "{{ id }}"
created: "{{ created }}"
lang: "en"
tags: ["project", "{{ tag }}"]
category: "project"
status: "{{ status }}"
client: "{{ client }}"
---

# {{ title }}

## Overview

{{ description }}

## Project Details

- **Client**: {{ client }}
- **Status**: {{ status }}
- **Created**: {{ created }}

## Notes

{{ notes }}

## Next Steps

- [ ] {{ next_step_1 }}
- [ ] {{ next_step_2 }}
- [ ] {{ next_step_3 }}
```

## Expected Behavior

When using this template with `:NoteTemplate`:

1. **First prompt** - Title: `My Demo Project`

- This value will be used in:
- Frontmatter: `title: "My Demo Project"` and `aliases: ["My Demo Project"]`
- First heading: `# My Demo Project`
- Suggested filename: `20251227_1430_my_demo_project`

2. **Other prompts** (each asked only once):

- Tag: `demo`
- Status: `active`
- Client: `Acme Corp`
- Description: `Testing the new workflow`
- Notes: `This is a test note`
- Next Step 1: `Setup repository`
- Next Step 2: `Create documentation`
- Next Step 3: `Deploy to production`

3. **Automatic values** (not prompted):

- `id`: The filename stem you confirm at the prompt, so that `id` and the file
  name never disagree (e.g. `20251227_1430_my_demo_project`)
- `created`: Generated automatically (e.g., `2025-12-27 14:30`)

4. **File creation**:

- Filename prompt shows: `20251227_1430_my_demo_project` (default)
- Location prompt shows: `01_projects/` (default based on template category)
- File created at: `vault_root/01_projects/20251227_1430_my_demo_project.md`
- **NOT** at:
  `vault_root/99_system/015_templates/01_projects/20251227_1430_my_demo_project.md`

## Result

The created file will be:

**Path**: `vault_root/01_projects/20251227_1430_my_demo_project.md`

**Content**:

```markdown
---
title: "My Demo Project"
aliases: ["My Demo Project"]
id: "20251227_1430_my_demo_project"
created: "2025-12-27 14:30"
lang: "en"
tags: ["project", "demo"]
category: "project"
status: "active"
client: "Acme Corp"
---

# My Demo Project

## Overview

Testing the new workflow

## Project Details

- **Client**: Acme Corp
- **Status**: active
- **Created**: 2025-12-27 14:30

## Notes

This is a test note

## Next Steps

- [ ] Setup repository
- [ ] Create documentation
- [ ] Deploy to production
```

## Key Improvements Demonstrated

1. **Title prompted only once** - Used in multiple places (frontmatter, alias,
   heading, filename)
2. **Smart filename suggestion** - Auto-slugified from title, with a timestamp
   prefix so two notes of the same name cannot collide
3. **Correct file location** - Created in vault, not in templates directory
4. **Variable deduplication** - Each variable prompted exactly once
5. **Automatic variables** - `id` and `created` auto-generated
6. **Title in content** - Appears in frontmatter AND as heading
7. **Linkable identity** - `id` equals the filename stem and `aliases` carries
   the title, so `[[` completion finds the note by name and the link it inserts
   points at a file that exists. A template without these two lines produces
   notes that are hard to link to; see the _Note Identity_ section of
   [README.md](./README.md).
