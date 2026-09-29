---
title: "waechter_von_farron"
id: "20260227_1633"
created: "2026-02-27 16:33"
tags: ["resource", "client/waechter_von_farron", "dark-souls", "ashen", "farron", "ember", "topic/cloud", "tool/azure"]
category: "resource"
status: "active"
role: "Hüter der Asche / Pipeline-Auftraggeber"
company: "Wacht von Farron – Untotes Asyl"
email: "watch@farron-keep.abyss"
phone: "+0 FARRON-0707"
location: "Farron Keep, Verfluchter Sumpf"
start_date: "20260227"
related: ["[[01_projects/farron-pipeline-geluebde/index]]"]
concepts: ["azure-pipeline", "dms-migration", "automatisierung", "ashen-one"]
aliases: ["Wächter von Farron", "DS-FARRON-07", "farron-pipeline-geluebde"]
---

# Wächter von Farron

> *„Das Feuer darf nicht erlöschen – und das Pipeline-Deployment auch nicht."*

## Profil

| Feld | Wert |
|---|---|
| **Fraktion** | Wächter von Farron |
| **Rolle** | Hüter der Asche / Pipeline-Auftraggeber |
| **Heimat** | Farron Keep, Verfluchter Sumpf |
| **Codename** | DS-FARRON-07 |
| **Kontakt** | watch@farron-keep.abyss |
| **Status** | active |
| **Projekt-Start** | 2026-02-27 |

## Beschreibung

Die Wächter von Farron hüten seit Äonen die Grenze zwischen Licht und Abyss. Im Rahmen des *Farron – Pipeline-Gelübdes* beauftragen sie den Aufbau einer robusten Azure-Pipeline-Infrastruktur: DMS-Stabilisierung, automatisierte Deployments und lückenlose Migrationspfade – denn keine Untote Schlange soll je wieder ein Pipeline-Build zum Erlöschen bringen.

## Schlüsselkontakte

| Name | Rolle im Projekt |
|---|---|
| Watchdog of Farron | Product Owner / Hüter des Budgets |
| The Abyss Watchers | Technische Architektur |
| Old Wolf of Farron | Anforderungsmanagement |

## Aktive Projekte

- [[01_projects/farron-pipeline-geluebde/index|Farron – Pipeline-Gelübde]]

## Meeting-Log

```dataview
TABLE date, thema, summary
FROM "01_projects/farron-pipeline-geluebde/meetings"
SORT date desc
LIMIT 10
```

## Offene Aufgaben

```dataviewjs
dv.taskList(
  dv.pages('"01_projects/farron-pipeline-geluebde"').file.tasks
    .where(t => !t.completed)
)
```
