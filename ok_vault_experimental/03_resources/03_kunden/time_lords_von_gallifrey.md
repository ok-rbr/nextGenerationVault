---
title: "time_lords_von_gallifrey"
id: "20260227_1634"
created: "2026-02-27 16:34"
tags: ["resource", "client/time_lords_von_gallifrey", "doctor-who", "time-lord", "gallifrey", "time-vortex", "topic/cloud", "tool/azure"]
category: "resource"
status: "active"
role: "Zeitwächter / Automatisierungs-Auftraggeber"
company: "Rat der Time Lords – Citadel of Gallifrey"
email: "council@citadel.gallifrey"
phone: "+0 TARDIS-0042"
location: "Gallifrey, Kasterborous-Konstellation"
start_date: "20260227"
related: ["[[01_projects/gallifrey-automatisierungs-protokoll/index]]"]
concepts: ["azure-automatisierung", "pipeline", "zeitvortex-deployment", "dms"]
aliases: ["Time Lords von Gallifrey", "DW-GALLIFREY-07", "gallifrey-automatisierungs-protokoll"]
---

# Time Lords von Gallifrey

> *„Wir reisen nicht nur durch die Zeit – wir automatisieren sie."*

## Profil

| Feld | Wert |
|---|---|
| **Fraktion** | Time Lords von Gallifrey |
| **Rolle** | Zeitwächter / Automatisierungs-Auftraggeber |
| **Heimat** | Gallifrey, Kasterborous-Konstellation |
| **Codename** | DW-GALLIFREY-07 |
| **Kontakt** | council@citadel.gallifrey |
| **Status** | active |
| **Projekt-Start** | 2026-02-27 |

## Beschreibung

Die Time Lords von Gallifrey überwachen das Kontinuum der Zeit – und neuerdings auch das ihrer Azure-Infrastruktur. Im Rahmen des *Gallifrey – Automatisierungs-Protokolls* beauftragen sie den Aufbau vollautomatisierter Deployment-Pipelines: DMS-Migration mit Zeitstempel-Präzision, lückenlose Pipeline-Überwachung und Automatisierung, die auch einem Dalek-Angriff standhält.

## Schlüsselkontakte

| Name | Rolle im Projekt |
|---|---|
| Der Rassilon | Sponsor / Oberster Entscheider |
| The Doctor | Technischer Berater (extern, manchmal unhilfreich) |
| Romana | Projektleitung / Architektur |
| The Master | Risikomanagement (mit Vorsicht einzusetzen) |

## Aktive Projekte

- [[01_projects/gallifrey-automatisierungs-protokoll/index|Gallifrey – Automatisierungs-Protokoll]]

## Meeting-Log

```dataview
TABLE date, thema, summary
FROM "01_projects/gallifrey-automatisierungs-protokoll/meetings"
SORT date desc
LIMIT 10
```

## Offene Aufgaben

```dataviewjs
dv.taskList(
  dv.pages('"01_projects/gallifrey-automatisierungs-protokoll"').file.tasks
    .where(t => !t.completed)
)
```
