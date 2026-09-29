---
title: "ingest_rules"
id: "20260625_2154"
created: "2026-06-25 21:54"
tags: ["ai", "ingest", "vault"]
category: "knowledge"
status: "in-progress"
related: []
concepts: ["inbox", "knowledge_lifecycle", "ai_assisted_vault"]
aliases: []
---

# Ingest Rules

## Purpose

This document defines how raw material enters the vault and when it is considered processed.

## Input folders

- `00_knowledge/00_inbox/transcripts/`
  - Meeting transcripts
  - Whisper transcripts
  - Audio-derived text

- `00_knowledge/00_inbox/clippings/`
  - Web Clipper exports
  - Articles
  - Documentation snippets

- `00_knowledge/00_inbox/notes/`
  - Free-form notes
  - Quick dumps
  - Manual thoughts

- `00_knowledge/00_inbox/pdfs/`
  - PDFs waiting for extraction or review

- `00_knowledge/00_inbox/ai_review/`
  - AI-generated drafts that require manual review

- `00_knowledge/00_inbox/processed/`
  - Raw files that were already processed

## Raw input requirements

Every raw Markdown input should contain frontmatter:

```yaml
---
title: "raw_title"
id: "YYYYMMDD_HHMM"
created: "YYYY-MM-DD HH:mm"
tags: ["raw"]
category: "knowledge"
status: "raw"
related: []
concepts: []
aliases: []
source: ""
input_type: "transcript|clipping|note|pdf"
processed: false
---
```

## Processing rule

Raw input is never treated as permanent knowledge directly.

Processing must create or update one of:

- `00_knowledge/01_atomic/`
- `00_knowledge/02_literature/`
- `00_knowledge/03_permanent/`
- `01_projects/`
- `02_areas/`
- `03_resources/`

## Processed rule

After successful processing:

1. create or update target note
2. preserve source reference
3. move raw file to `00_knowledge/00_inbox/processed/`
4. do not delete raw text by default

## Safety rule

If the correct target is unclear, move generated output to:

`00_knowledge/00_inbox/ai_review/`

Do not write uncertain content directly into permanent notes.
