---
title: "index - archive"
id: "20251110_2157"
created: "2025-11-10 21:57"
tags: ["obsidian/index"]
category: "index"
status: "in-progress"
related: []
concepts: []
aliases: []
---

# Archive

Dieser Bereich dient der Ablage abgeschlossener oder nicht mehr aktiver Inhalte. Archivierte Elemente bleiben durchsuchbar, sind aber aus den aktiven Bereichen ausgelagert.

## Zweck

- Abgeschlossene Projekte
- Nicht mehr aktive Areas
- Veraltete Informationen (zur Referenz)

## Archivierte Elemente

### Kürzlich archiviert (alle Typen)

```dataview
TABLE 
  file.link as Item,
  category as Type,
  archived_from as "Original Location",
  archived_on as "Archived On"
FROM "04_archive"
WHERE status = "archived"
SORT archived_on desc
LIMIT 25
```

### Archivierte Projekte

```dataview
TABLE 
  file.link as Project,
  client as Client,
  project_outcome as Outcome,
  archived_on as "Archived On"
FROM "04_archive"
WHERE status = "archived" AND category = "project"
SORT archived_on desc
LIMIT 15
```

### Archivierte Notizen

```dataview
TABLE 
  file.link as Note,
  archived_from as "Original Location",
  archive_reason as Reason,
  archived_on as "Archived On"
FROM "04_archive"
WHERE status = "archived" AND category = "note"
SORT archived_on desc
LIMIT 15
```

## Archiv-Tage

```dataview
TABLE 
  file.link as "Tagesindex",
  length(list(rows.file.link)) as "Items"
FROM "04_archive"
WHERE file.name = "00_index"
GROUP BY file.folder
SORT file.folder desc
LIMIT 10
```
