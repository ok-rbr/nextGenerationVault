---
title: "Index: Minas Tirith – Pipeline-Wacht"
mission: "Minas Tirith – Pipeline-Wacht"
crew: "Gefährten des Rings"
codename: "LOTR-GONDOR-07"
created: "2026-02-27"
updated: "2026-02-27"
tags: ["project", "lotr", "middle-earth", "free-peoples", "obsidian", "gondor", "index"]
category: "index"
theme:
  lord_of_the_rings: true
  vibe: "free-peoples"
links:
  index: "./index.md"
status: "active"
aliases: ["LOTR-GONDOR-07", "minas-tirith-pipeline-wacht"]

---

# Minas Tirith – Pipeline-Wacht

> **Gefährten:** Gefährten des Rings · **Codename:** LOTR-GONDOR-07 · **Status:** active

## Projektsteckbrief

| Feld | Wert |
|---|---|
| Mission | Minas Tirith – Pipeline-Wacht |
| Fraktion (Kunde) | Gefährten des Rings |
| Codename | LOTR-GONDOR-07 |
| Thema | Softwareentwicklung, Azure, Pipeline, DMS, Migration, Automatisierung |
| Start | 2026-02-27 |
| Status | active |

## Beschreibung

Aufbau und Wacht über eine Azure-Pipeline-Infrastruktur unter dem Banner der Gefährten. Wie die Wächter von Minas Tirith die weiße Stadt hüten, so bewacht dieses Projekt jeden Schritt der DMS-Migration und Automatisierung – kein Deployment ohne Geleit.

---

## Inhaltsverzeichnis

### 📋 Tasks
```dataviewjs
dv.table(["Titel", "Status", "Priorität", "ID"],
  dv.pages('"01_projects/minas-tirith-pipeline-wacht/task"')
    .sort(f => f.priority)
    .map(f => [f.file.link, f.status, f.priority, f.task_id])
)
```

### 📝 Notes / Dokumentation
```dataviewjs
dv.list(
  dv.pages('"01_projects/minas-tirith-pipeline-wacht/doc"')
    .sort(f => f.file.mtime, 'desc')
    .file.link
)
```

### 🗓️ Meetings
```dataviewjs
dv.table(["Datum", "Titel", "Thema", "Summary"],
  dv.pages('"01_projects/minas-tirith-pipeline-wacht/meetings"')
    .sort(f => f.date, 'desc')
    .map(f => [f.date, f.file.link, f.thema, f.summary])
)
```

### 📅 Dailies
```dataviewjs
dv.list(
  dv.pages('"01_projects/minas-tirith-pipeline-wacht/daily"')
    .sort(f => f.date, 'desc')
    .file.link
)
```

### 📆 Weeklies
```dataviewjs
dv.list(
  dv.pages('"01_projects/minas-tirith-pipeline-wacht/weekly"')
    .sort(f => f.date, 'desc')
    .file.link
)
```

---

## Offene Tasks

```dataviewjs
dv.taskList(
  dv.pages('"01_projects/minas-tirith-pipeline-wacht"').file.tasks
    .where(t => !t.completed)
)
```
