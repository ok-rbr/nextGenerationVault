---
title: "Index: Wano Reise – Azure Pipeline Migration"
mission: "Wano Reise – Azure Pipeline Migration"
crew: "Strohhut-Piraten"
codename: "OP-WANO-01"
created: "2026-02-27"
updated: "2026-02-27"
tags: ["project", "one-piece", "pirates", "obsidian", "wano", "index"]
category: "index"
theme:
  one_piece: true
  vibe: "pirates"
links:
  index: "./index.md"
status: "active"
aliases: ["OP-WANO-01", "strohhut-azure-migration"]

---


# Wano Reise – Azure Pipeline Migration

> **Crew:** Strohhut-Piraten · **Codename:** OP-WANO-01 · **Status:** active

## Projektsteckbrief

| Feld | Wert |
|---|---|
| Mission | Wano Reise – Azure Pipeline Migration |
| Crew | Strohhut-Piraten |
| Codename | OP-WANO-01 |
| Thema | Softwareentwicklung, Azure, Pipeline, DMS, Migration, Automatisierung |
| Start | 2026-02-27 |
| Status | active |

## Beschreibung

Modernisierung und Migration einer bestehenden Softwarelandschaft auf Azure-basierte Pipelines inkl. DMS-Integration und Automatisierung von Deployments.

---

## Inhaltsverzeichnis

### 📋 Tasks
```dataviewjs
dv.table(["Titel", "Status", "Priorität", "ID"],
  dv.pages('"01_projects/strohhut-wano_azure_migration/task"')
    .sort(f => f.priority)
    .map(f => [f.file.link, f.status, f.priority, f.task_id])
)
```

### 📝 Notes / Dokumentation
```dataviewjs
dv.list(
  dv.pages('"01_projects/strohhut-wano_azure_migration/doc"')
    .sort(f => f.file.mtime, 'desc')
    .file.link
)
```

### 🗓️ Meetings
```dataviewjs
dv.table(["Datum", "Titel", "Thema", "Summary"],
  dv.pages('"01_projects/strohhut-wano_azure_migration/meetings"')
    .sort(f => f.date, 'desc')
    .map(f => [f.date, f.file.link, f.thema, f.summary])
)
```

### 📅 Dailies
```dataviewjs
dv.list(
  dv.pages('"01_projects/strohhut-wano_azure_migration/daily"')
    .sort(f => f.date, 'desc')
    .file.link
)
```

### 📆 Weeklies
```dataviewjs
dv.list(
  dv.pages('"01_projects/strohhut-wano_azure_migration/weekly"')
    .sort(f => f.date, 'desc')
    .file.link
)
```

---

## Offene Tasks

```dataviewjs
dv.taskList(
  dv.pages('"01_projects/strohhut-wano_azure_migration"').file.tasks
    .where(t => !t.completed)
)
```
