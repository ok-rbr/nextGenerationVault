---
id: 20260624_1805
aliases:
  - AI Vault Boundaries
  - Vault Access Rules
tags:
  - system/ai
  - vault/security
  - workflow/local-ai
category: knowledge
concepts:
  - vault-boundaries
  - privacy
  - ai-safety
  - obsidian
created: 2026-06-24 18:05
related:
  - 99_system/05_ai/ai_operating_rules.md
  - 99_system/05_ai/meeting_ingestion_workflow.md
status: active
title: vault_ai_boundaries
---

# vault_ai_boundaries

## purpose

This document defines which areas of the vault local AI tools may read, write, suggest changes for, or must avoid.

The goal is to keep the vault useful for AI-assisted workflows while protecting sensitive, personal, archived, and high-risk content.

## access levels

The vault uses four access levels for AI-assisted workflows:

```text
allowed-read
allowed-write
review-only
blocked
````

## allowed-read

AI may read these paths when needed for context:

```text
00_knowledge/00_index.md
00_knowledge/01_atomic/
00_knowledge/02_literature/
00_knowledge/03_permanent/
01_projects/00_index.md
02_areas/00_index.md
03_resources/00_index.md
99_system/00_index.md
99_system/01_templates/
99_system/05_ai/
```

Rules:

* read only the minimum required context
* prefer indexes before reading full notes
* prefer permanent/atomic knowledge over raw inbox notes
* do not read sensitive folders unless explicitly approved

## allowed-write

AI may write new files only in these paths by default:

```text
00_knowledge/00_inbox/
00_knowledge/00_inbox/meetings/
99_system/05_ai/
```

Rules:

* new notes must follow vault naming conventions
* AI-created notes must include frontmatter
* AI-generated content must be reviewable
* status should usually be `raw`, `analyzed`, or `review-needed`

## review-only

AI may suggest changes for these paths, but must not modify them directly without explicit approval:

```text
00_knowledge/01_atomic/
00_knowledge/02_literature/
00_knowledge/03_permanent/
01_projects/
02_areas/
03_resources/
99_system/01_templates/
```

Allowed actions:

* suggest links
* suggest missing metadata
* suggest refactoring
* suggest candidate moves
* suggest task extraction
* suggest new notes

Not allowed by default:

* overwrite content
* move files
* rename files
* delete files
* mark tasks completed
* change project status

## blocked

AI must not read or write these paths by default:

```text
04_archive/
99_system/04_logs/
02_areas/07_people/
02_areas/08_people/
03_resources/02_people/
```

Also blocked by default:

```text
daily notes
weekly notes
meeting notes with personal/private content
private journals
credential files
environment files
exports containing secrets
attachments with personal data
```

Examples of blocked file patterns:

```text
.env
*.key
*.pem
*.p12
*.pfx
*secret*
*password*
*credential*
*token*
```

## destructive actions

The following actions are always forbidden unless explicitly approved:

```text
delete
rename
move
overwrite
bulk edit
archive
task completion
status change
frontmatter removal
```

If such an action is needed, AI must produce a proposal instead.

## required proposal format for restricted changes

````markdown
## proposed change

- target:
- change type:
- reason:
- risk:
- backup required: yes|no

## diff summary

```diff
- old
+ new
````

## approval required

* [ ] approved by vault owner

````

## backups

Before modifying an existing note outside the allowed-write area:

1. create a backup
2. generate a diff
3. request approval
4. apply only the approved change

Suggested backup path:

```text
99_system/05_ai/backups/
````

Suggested backup naming:

```text
YYYYMMDD_HHMM_original_file_name.md
```

## secrets and credentials

AI must never expose, summarize, copy, or transform secrets.

If a possible secret is detected, AI should replace it with:

```text
[REDACTED_SECRET]
```

And add:

```markdown
## security notice

Potential secret detected and redacted.
```

## people and privacy

People/contact notes are sensitive by default.

AI may extract action owners from meetings, but must not update people profiles automatically.

Allowed:

```markdown
- owner: Raphael
- owner: team
- owner: unknown
```

Not allowed by default:

```text
creating people profiles
updating customer profiles
updating colleague profiles
adding personal details
summarizing private relationships
```

## archive policy

Archive is read-protected and write-protected by default.

AI must not:

* search archive content
* modify archive content
* restore archive content
* use archive content as active context

Exception requires explicit approval.

## meeting content policy

Raw meeting transcripts are considered sensitive until reviewed.

Default location:

```text
00_knowledge/00_inbox/meetings/
```

Allowed processing:

* transcription
* summary
* action item extraction
* decisions
* open questions
* link suggestions

Blocked processing:

* people profiling
* sentiment judgment about people
* private evaluation of individuals
* automatic publishing
* external upload

## coding workflow policy

AI may connect coding notes with vault notes through explicit references.

Allowed references:

```text
repo name
branch name
commit hash
pull request number
issue number
module name
feature name
bug name
```

AI must not store:

```text
access tokens
connection strings
private keys
customer secrets
production credentials
```

## default decision rule

If unsure, AI must choose the safer option:

```text
do not modify
write to inbox
ask for review
create proposal
redact sensitive data
```
