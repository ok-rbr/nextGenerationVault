---
id: 20260624_1800
aliases:
  - AI Operating Rules
  - Local AI Rules
tags:
  - system/ai
  - vault/rules
  - workflow/local-ai
category: knowledge
concepts:
  - local-ai
  - obsidian
  - vault-automation
  - security
created: 2026-06-24 18:00
related:
  - 99_system/05_ai/vault_ai_boundaries.md
  - 99_system/05_ai/meeting_ingestion_workflow.md
status: active
title: ai_operating_rules
---

# ai_operating_rules

## purpose

This document defines the operating rules for local AI assistance inside this Obsidian vault.

The goal is to use local AI to support knowledge work, meeting processing, coding workflows, and note maintenance without compromising privacy, structure, or data integrity.

AI assistance must be conservative, transparent, and reviewable.

## core principles

1. **local first**
   - Prefer local tools and local models.
   - Do not send personal vault content to external services unless explicitly approved.

2. **human approval**
   - AI may propose changes.
   - AI must not silently apply destructive changes.
   - Final decisions remain with the vault owner.

3. **append over overwrite**
   - Prefer appending structured analysis sections.
   - Avoid replacing existing note content.
   - If content must be changed, create a backup or diff first.

4. **inbox first**
   - New AI-generated notes start in `00_knowledge/00_inbox/`.
   - Notes are only moved into permanent/project/area/resource folders after review.

5. **traceability**
   - Every AI-generated or AI-assisted note should make clear:
     - what was generated
     - from which source
     - when it was generated
     - what still needs review

6. **minimal authority**
   - AI gets only the context required for the current task.
   - Sensitive folders remain excluded by default.

## ai may do

AI may perform the following actions:

- create new notes in `00_knowledge/00_inbox/`
- create meeting processing drafts in `00_knowledge/00_inbox/meetings/`
- generate summaries from transcripts
- extract action items, decisions, open questions, and risks
- suggest links to existing notes
- suggest candidate atomic notes
- suggest project, area, resource, and knowledge placement
- validate frontmatter against vault conventions
- identify missing metadata
- identify possible duplicate notes
- propose refactorings
- generate Dataview query drafts
- generate templates and workflow documentation
- generate code snippets for local vault automation scripts

## ai may not do

AI must not perform the following actions without explicit approval:

- delete files
- permanently move files
- overwrite existing notes
- modify archive content
- modify personal logs
- modify people/contact notes
- modify daily or weekly notes
- mark tasks as completed
- change project status
- change ownership of tasks
- alter source transcripts
- remove frontmatter fields
- rewrite personal reflections
- expose secrets, credentials, tokens, keys, or private URLs
- send vault content to external APIs

## default write policy

By default, AI may only write to:

```text
00_knowledge/00_inbox/
00_knowledge/00_inbox/meetings/
99_system/05_ai/
````

All other writes require explicit approval.

## default read policy

By default, AI may read from:

```text
00_knowledge/00_index.md
00_knowledge/01_atomic/
00_knowledge/03_permanent/
01_projects/00_index.md
02_areas/00_index.md
03_resources/00_index.md
99_system/01_templates/
99_system/05_ai/
```

Sensitive folders are excluded by default. See:

```text
99_system/05_ai/vault_ai_boundaries.md
```

## note processing statuses

AI-assisted notes should use one of the following statuses:

```text
raw
transcribed
analyzed
review-needed
integrated
archived
```

Meaning:

* `raw`: captured but not processed
* `transcribed`: audio was transcribed
* `analyzed`: AI analysis exists
* `review-needed`: human review required
* `integrated`: processed into the vault
* `archived`: no further action required

## required ai analysis sections

When AI analyzes a meeting, transcript, or raw note, it should use these sections:

```markdown
## ai summary

## decisions

## action items

## open questions

## risks

## link suggestions

## candidate atomic notes

## suggested destination

## processing log
```

## action item format

Action items must be explicit and assignable.

```markdown
- [ ] task description
  - owner:
  - due:
  - related:
  - source:
```

Rules:

* `owner` should be filled if known.
* `due` should be filled if mentioned.
* `related` should link to project, area, resource, or knowledge notes where possible.
* `source` should reference the meeting or transcript note.

## link suggestion format

AI should not create links blindly. It should propose them first.

```markdown
- suggested link: [[note_name]]
  - reason:
  - confidence: low|medium|high
```

## candidate atomic note format

```markdown
- title:
  - core idea:
  - source:
  - suggested tags:
  - suggested links:
  - confidence: low|medium|high
```

## frontmatter validation rules

AI should check for the following standard fields:

```yaml
title:
id:
created:
tags:
category:
status:
related:
concepts:
aliases:
```

Rules:

* file names use lowercase and underscores
* no spaces in file names
* no umlauts in file names
* no special characters in file names
* IDs use `YYYYMMDD` or `YYYYMMDD_HHMM`
* tags use lowercase slugs
* category must match vault conventions

## review checklist

Before integrating AI-generated content, check:

* [ ] Is the source clear?
* [ ] Is the summary accurate?
* [ ] Are action items assigned?
* [ ] Are sensitive details removed if needed?
* [ ] Are links valid?
* [ ] Are suggested notes useful?
* [ ] Is frontmatter complete?
* [ ] Is the target folder correct?
* [ ] Should this remain in inbox?
* [ ] Should this become an atomic/permanent/project/resource note?

## escalation rule

If AI is unsure, it must not modify the vault directly.

It should instead add:

```markdown
## needs human decision

- question:
- options:
- recommendation:
```
