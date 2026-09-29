---
name: vault-knowledge-retrieval
description: Retrieve and connect knowledge from the vaultK Obsidian system (Knowledge, Projects, Areas, Resources, Archive).
---

# vaultK Knowledge Retrieval

Search and synthesize information from the vaultK system.

## Scope

Search across:

- 00_knowledge/
- 01_projects/
- 02_areas/
- 03_resources/
- 04_archive/

## Instructions

1. Identify:
   - topic
   - type (knowledge, project, area, resource)
   - intent (lookup, connections, overview)

2. Search:
   - filenames
   - frontmatter (tags, category, concepts, related)
   - content + wikilinks

3. Extract:
   - Knowledge → idea / insight / synthesis level
   - Projects → goal / status / blockers
   - Areas → responsibility / domain
   - Resources → summary / source

4. Connect:
   - wikilinks
   - related / concepts fields
   - cross-folder relations

5. Respond:
   - concise summary first
   - then structured results
   - always cite file path

## Rules

- Use ONLY vault content
- No outside knowledge
- Always cite paths: [path/to/file.md]
- Mention if info only exists in Archive
- Highlight gaps (e.g. only inbox, no permanent note)
