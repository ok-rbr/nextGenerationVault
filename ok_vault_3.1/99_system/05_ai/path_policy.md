---
title: "path_policy"
id: "20260625_2154"
created: "2026-06-25 21:54"
tags: ["ai", "security", "vault"]
category: "knowledge"
status: "active"
related: ["ingest_rules", "knowledge_lifecycle", "vault_ai_boundaries"]
concepts: ["path_policy", "blocked_paths", "safe_writes"]
aliases: []
---

# Path Policy

> For the full access-level model (allowed-read, allowed-write, review-only, blocked), see [[vault_ai_boundaries]].

## Allowed read paths

AI-assisted tooling may read:

- `00_knowledge/`
- `01_projects/`
- `02_areas/`
- `03_resources/`
- `99_system/01_templates/`
- `99_system/05_ai/`

## Allowed write paths (default)

By default, AI-assisted tooling may only write to:

- `00_knowledge/00_inbox/`
- `00_knowledge/00_inbox/meetings/`
- `99_system/05_ai/`

All other write operations require explicit user approval. See [[vault_ai_boundaries]] for the review-only proposal workflow.

## Restricted paths

AI-assisted tooling must not modify without explicit user instruction:

- `04_archive/`
- `99_system/04_logs/`
- people/contact folders
- daily notes
- weekly notes
- meeting notes with personal data

## Raw file rule

Audio files and binary source files must not be edited by AI tooling.

## Update rule

Existing notes are append-only by default.

Do not delete or replace existing content unless explicitly requested.
