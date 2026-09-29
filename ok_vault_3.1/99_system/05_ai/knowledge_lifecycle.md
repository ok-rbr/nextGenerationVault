---
title: "knowledge_lifecycle"
id: "20260625_2154"
created: "2026-06-25 21:54"
tags: ["ai", "knowledge", "lifecycle"]
category: "knowledge"
status: "in-progress"
related: ["ingest_rules"]
concepts: ["inbox", "atomic_notes", "literature_notes", "permanent_notes"]
aliases: []
---

# Knowledge Lifecycle

## 00_inbox

Use for raw, unprocessed material.

Examples:

- transcripts
- copied notes
- rough thoughts
- web clippings
- PDFs

Rule:

- no raw inbox item is considered reliable knowledge
- inbox items require processing before reuse

## 01_atomic

Use for one focused idea.

Criteria:

- one concept
- one clear claim
- short and reusable
- may still be improved later

## 02_literature

Use for source-based notes.

Criteria:

- derived from article, book, transcript, PDF, documentation, talk, or meeting
- keeps source context
- may contain summary and key takeaways
- does not need to be fully generalized

## 03_permanent

Use for stable, reusable knowledge.

Criteria:

- independent of one single source
- written in the user's own structure
- linked to related concepts
- usable for future reasoning and project work

## Promotion rules

### Inbox to Atomic

Use when raw material contains one clear concept worth preserving.

### Inbox to Literature

Use when raw material is mainly source-bound.

### Literature to Permanent

Use when a source produces durable insight that should stand independently.

### Project to Knowledge

Use when project-specific notes contain reusable technical or conceptual knowledge.

### Knowledge to Area

Use when a concept becomes a long-term responsibility or domain.

## Default rule

If unsure, keep the item closer to the source:

`inbox -> literature -> permanent`

Do not prematurely create permanent notes.
