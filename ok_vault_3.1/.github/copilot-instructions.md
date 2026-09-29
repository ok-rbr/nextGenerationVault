# GitHub Copilot Instructions - OK Vault Experimental

This is an Obsidian Vault for personal knowledge management based on the PARA method (Projects, Areas, Resources, Archives) and Zettelkasten principles.

## Blocked Paths

**IMPORTANT**: Do NOT read, access, or suggest modifications to the following paths:

- `99_system/04_logs/**` - Personal activity logs and private data (reserved path)
- `04_archive/**` - Archived content and historical data
- `02_areas/07_people/**` - Personal contact information
- `02_areas/08_people/**` - Sensitive contact details
- `03_resources/02_people/**` - Customer and colleague profiles
- `**/*daily*.md` - Daily notes contain personal information
- `**/*weekly*.md` - Weekly reviews contain personal information
- `**/*meeting*.md` - Meeting notes may contain confidential information
- `.obsidian/**` - Obsidian configuration files
- `.trash/**` - Deleted files

These directories contain sensitive personal information, logs, and private data that should not be analyzed or modified.

## Vault Structure

This vault follows a strict organizational hierarchy based on PARA:

```
00_knowledge/          # Knowledge Management (Zettelkasten)
├── 00_inbox/         # Unprocessed ideas
├── 01_atomic/        # Atomic notes (one idea per note)
├── 02_literature/    # Notes from books/articles
└── 03_permanent/     # Verified, networked knowledge

01_projects/          # Active projects (time-limited, goal-oriented)

02_areas/             # Areas of responsibility (ongoing)

03_resources/         # Reference material and contacts

04_archive/           # Completed/inactive content

99_system/            # System files
├── 01_templates/    # All templates
└── 05_ai/           # AI configuration and workflows
```

**NEVER** create new top-level folders. Use only the existing structure.

## Naming Conventions

### File Names

**STRICT RULES** - Always follow these:

- ✅ **Lowercase only**: `projekt_name.md`
- ✅ **Underscores as separators**: `azure_identity_governance.md`
- ✅ **No special characters**: No umlauts (ä, ö, ü), no spaces, no hyphens
- ✅ **Context from folders**: Not in filename
- ❌ **NEVER**: `Azure Identity & Governance.md`
- ❌ **NEVER**: `Projekt-Name-Meeting.md`

### IDs

- **Format**: `YYYYMMDD` or `YYYYMMDD_HHMM`
- **Example**: `20251110_2157`

### Timestamps

- **Frontmatter**: ISO format `YYYY-MM-DD HH:mm`
- **Regular text**: German formats allowed

## Frontmatter Rules

### Required Fields

**ALL notes MUST include these fields** (no exceptions):

```yaml
---
title: "note_title"
id: "YYYYMMDD_HHMM"
created: "YYYY-MM-DD HH:mm"
tags: ["tag1", "tag2"]
category: "category"
status: "status"
related: []
concepts: []
aliases: []
---
```

### Field Descriptions

- **title**: Note title (string)
- **id**: Unique ID in format YYYYMMDD_HHMM
- **created**: ISO timestamp (YYYY-MM-DD HH:mm)
- **tags**: Array of tags (lowercase)
- **category**: One of the PARA categories or "index"
- **status**: Current status of the note
- **related**: Array of related note links
- **concepts**: Array of concepts/topics
- **aliases**: Array of alternative names

### Allowed Categories

**ONLY these values** are allowed for the `category` field:

- `knowledge` - Knowledge management
- `project` - Projects
- `area` - Areas of responsibility
- `resource` - Resources
- `archive` - Archive
- `index` - Index pages

### Category-Specific Additional Fields

**Projects**:
```yaml
client: "Client Name"
due: "YYYY-MM-DD"
```

**Knowledge (Literature)**:
```yaml
author: "Author Name"
source: "Source/Link"
type: "book|article|video"
```

**Knowledge (Inbox)**:
```yaml
priority: "low|medium|high"
source: "optional source"
```

**Resources (People)**:
```yaml
role: "Role"
company: "Company Name"
email: "email@example.com"
phone: "Phone Number"
location: "Location"
start_date: "YYYYMMDD"
```

### Forbidden

**NEVER**:
- Invent new frontmatter fields not documented here
- Use uppercase in tags
- Duplicate information (e.g., status as both field and tag)
- Use non-standard category values

## Tagging Conventions

### Rules

- **Lowercase only**: `#azure`, NOT `#Azure`
- **Short slugs**: `#tool/azure`, NOT `#tool/microsoft-azure-cloud`
- **No duplicates**: Don't tag status if already in frontmatter
- **Focus on content/context**

### Allowed Patterns

```yaml
# Tool tags
#tool/azure
#tool/entra_id
#tool/powershell

# Topic tags
#topic/identity
#topic/security
#topic/cloud

# Client tags (use sparingly)
#client/kunde_name
#client/acme_gmbh

# Optional nested
#topic/azure/governance
```

## Templates

### Template Location

- **All templates**: `99_system/01_templates/`
- Organized by PARA categories
- **ALWAYS use existing templates** - don't create new ones without necessity

### Template Categories

1. **Knowledge** (`00_knowledge/`):
   - `knowledge_inbox_default.md` - Unprocessed ideas
   - `knowledge_atomic_default.md` - Atomic notes
   - `knowledge_literature_default.md` - Literature notes
   - `knowledge_permanent_default.md` - Permanent knowledge

2. **Projects** (`01_projects/project_name/`):
   - `kunde-project-note.md` - Generic project notes
   - `kunde-project-task.md` - Project tasks
   - `kunde-project-meeting.md` - Project meetings
   - `kunde-project-daily.md` - Daily project updates
   - `kunde-project-weekly.md` - Weekly project reviews

3. **Areas** (`02_areas/`):
   - `daily_default.md` - Daily periodic notes
   - `weekly_default.md` - Weekly periodic notes
   - `meetings_default.md` - General meetings
   - `overview_default.md` - Area overviews
   - `kanban_default.md` - Kanban boards
   - `people_default.md` - People profiles

4. **Resources** (`03_resources/`):
   - `people_customer_default.md` - Customer profiles
   - `people_colleague_default.md` - Colleague profiles
   - `cert_overview.md` - Certification overview
   - `cert_study_note.md` - Study notes
   - `cert_practice_exam.md` - Practice exam results

### Using Templates

- Templates use **Templater plugin** for dynamic prompts
- Templates **automatically rename** and **move** files to correct locations
- **Never modify template structure** without understanding the implications

## Index Pages

### Requirements

- **One per top-level folder**: `00_index.md`
- **Frontmatter**:
  ```yaml
  ---
  title: "index - <folder_name>"
  id: "<YYYYMMDD_HHMM>"
  created: "<YYYY-MM-DD HH:mm>"
  tags: ["obsidian/index"]
  category: "index"
  status: "in-progress"
  related: []
  concepts: []
  aliases: []
  ---
  ```
- **Must include**: Dataview queries for the folder's content

## Dataview Best Practices

### Query Guidelines

- **Keep queries simple** - no over-engineering
- **Always set limits** for performance
- **Use consistent field names**
- **Filter by category** or tags for accuracy

### Example Queries

```dataview
TABLE status, priority, created
FROM #task
WHERE contains(status, "active")
SORT priority desc
LIMIT 20
```

```dataview
LIST
FROM "01_projects"
WHERE category = "project" AND status = "in-progress"
SORT created desc
```

## Quality Rules

### Always Check

1. ✅ **No duplicate fields**: Status not as both field and tag
2. ✅ **IDs/filenames** strictly follow naming conventions
3. ✅ **Use templates** from `99_system/01_templates/`
4. ✅ **Dataview queries** are simple and understandable
5. ✅ **Frontmatter complete** with all required fields

### Best Practices

- **Consistency**: Same field names everywhere
- **Simplicity**: No complex nested structures
- **Maintainability**: Queries must be understandable
- **Performance**: Limits in Dataview queries
- **Context**: Use folder structure instead of verbose filenames

## Workflows & Principles

### PARA Method

- **Projects**: Time-limited with clear goals → `01_projects/`
- **Areas**: Ongoing responsibilities → `02_areas/`
- **Resources**: Reference material → `03_resources/`
- **Archives**: Completed content → `04_archive/`

### Zettelkasten (Knowledge Management)

- **Inbox**: Capture everything → process later
- **Atomic**: One idea per note → highly focused
- **Literature**: Notes from external sources
- **Permanent**: Verified, networked knowledge

### Note Linking

- **Use Wiki links**: `[[note_name]]`
- **Build connections**: Link related notes in `related` field
- **Bi-directional**: Obsidian automatically tracks backlinks

## Plugin Requirements

### Essential

- ✅ **Templater**: Required for all templates
- ✅ **Dataview**: Required for queries and dashboards

### Recommended

- ⭐ **Periodic Notes**: For daily/weekly automation
- ⭐ **Tasks**: Enhanced task management
- ⭐ **Calendar**: Time-based navigation

## Code Suggestions

When suggesting Markdown or YAML:

1. **Always follow naming conventions** (lowercase, underscores)
2. **Include complete frontmatter** with all required fields
3. **Use existing templates** as reference
4. **Suggest appropriate category** and tags
5. **Maintain consistency** with existing notes
6. **Add Dataview queries** where appropriate
7. **Link related notes** using `[[note_name]]` syntax
8. **Respect the PARA structure** - don't create new top-level folders

## Examples

### Good Example - Project Note

```markdown
---
title: "website_relaunch"
id: "20251110_1430"
created: "2025-11-10 14:30"
tags: ["project", "client/acme_gmbh", "topic/web", "tool/azure"]
category: "project"
status: "in-progress"
client: "ACME GmbH"
due: "2025-12-31"
related: []
concepts: []
aliases: []
---

# [[website_relaunch]]

## Project Description
Relaunch of company website using Azure Static Web Apps.

## Goals
- Modernize design
- Improve performance
- SEO optimization

## Tasks
- [ ] Design mockups
- [ ] Azure setup
- [ ] Content migration
```

### Bad Example - Project Note

```markdown
---
title: Website Relaunch        # ❌ Spaces in title
created: 10.11.2025            # ❌ German date format
tags: [Project, ACME]          # ❌ Uppercase tags
category: proj                 # ❌ Invalid category value
status: active                 # ✅ OK
customField: value             # ❌ Invented field
---
```

## Maintenance

### Regular Checks

- Frontmatter field consistency
- Index pages up-to-date
- Dataview queries functional
- Naming conventions followed

### When Making Changes

- Update templates if necessary
- Adjust index pages
- Update documentation
- Test Dataview queries

---

**Version**: 1.0
**Last Updated**: 2026-02-19
**Maintained by**: GitHub Copilot AI Assistant

## Summary

This vault is a structured knowledge management system. When working with it:

1. **RESPECT** the existing structure - don't create new top-level folders
2. **FOLLOW** naming conventions strictly (lowercase, underscores, no special chars)
3. **USE** existing templates - they handle automation and organization
4. **INCLUDE** complete frontmatter in every note
5. **BLOCK** sensitive paths (logs, archives, personal data) from analysis
6. **MAINTAIN** consistency - this is a personal knowledge base with strict conventions

The vault owner values organization, consistency, and privacy. Help maintain these standards in all suggestions.
