---
title: "Index: Farron – Pipeline-Gelübde"
mission: "Farron – Pipeline-Gelübde"
crew: "Wächter von Farron"
codename: "DS-FARRON-07"
created: "2026-02-27"
updated: "2026-02-27"
tags: ["project", "dark-souls", "ashen", "obsidian", "farron", "ember", "index"]
category: "index"
theme:
  dark_souls: true
  vibe: "ashen"
links:
  index: "./index.md"
status: "active"
aliases: ["DS-FARRON-07", "farron-pipeline-geluebde"]

---

# Farron – Pipeline-Gelübde

> **Wächter:** Wächter von Farron · **Codename:** DS-FARRON-07 · **Status:** active

## Projektsteckbrief

| Feld | Wert |
|---|---|
| Mission | Farron – Pipeline-Gelübde |
| Wächter (Kunde) | Wächter von Farron |
| Codename | DS-FARRON-07 |
| Thema | Softwareentwicklung, Azure, Pipeline, DMS, Migration, Automatisierung |
| Start | 2026-02-27 |
| Status | active |

## Beschreibung

Modernisierung und Migration einer bestehenden Softwarelandschaft auf Azure-basierte Pipelines – vollzogen im Geiste von Farron: stetige Wacht, beharrliche Automatisierung, kein Erloschen des Feuers.

---

## Inhaltsverzeichnis

### 📋 Tasks
```dataviewjs
dv.table(["Titel", "Status", "Priorität", "ID"],
  dv.pages('"01_projects/farron-pipeline-geluebde/task"')
    .sort(f => f.priority)
    .map(f => [f.file.link, f.status, f.priority, f.task_id])
)
```

### 📝 Notes / Dokumentation
```dataviewjs
dv.list(
  dv.pages('"01_projects/farron-pipeline-geluebde/doc"')
    .sort(f => f.file.mtime, 'desc')
    .file.link
)
```

### 🗓️ Meetings
```dataviewjs
dv.table(["Datum", "Titel", "Thema", "Summary"],
  dv.pages('"01_projects/farron-pipeline-geluebde/meetings"')
    .sort(f => f.date, 'desc')
    .map(f => [f.date, f.file.link, f.thema, f.summary])
)
```

### 📅 Dailies
```dataviewjs
dv.list(
  dv.pages('"01_projects/farron-pipeline-geluebde/daily"')
    .sort(f => f.date, 'desc')
    .file.link
)
```

### 📆 Weeklies
```dataviewjs
dv.list(
  dv.pages('"01_projects/farron-pipeline-geluebde/weekly"')
    .sort(f => f.date, 'desc')
    .file.link
)
```

---

## Offene Tasks

```dataviewjs
dv.taskList(
  dv.pages('"01_projects/farron-pipeline-geluebde"').file.tasks
    .where(t => !t.completed)
)
```
