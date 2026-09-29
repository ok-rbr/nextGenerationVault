---
title: "strohhut_piraten"
id: "20260227_1632"
created: "2026-02-27 16:32"
tags: ["resource", "client/strohhut_piraten", "one-piece", "pirates", "wano", "topic/cloud", "tool/azure"]
category: "resource"
status: "active"
role: "Piratencrew / Azure-Migration-Auftraggeber"
company: "Strohhut-Piratenbande – Großlinie Wano"
email: "luffy@thousandsunny.wano"
phone: "+0 SUNNY-1337"
location: "Wano-Land, Neues Welt-Meer"
start_date: "20260227"
related: ["[[01_projects/strohhut-wano_azure_migration/index]]"]
concepts: ["azure-migration", "pipeline", "dms", "automatisierung"]
aliases: ["Strohhut-Piraten", "OP-WANO-01", "strohhut-azure-migration"]
---

# Strohhut-Piraten

> *„Ich werde der König der Piraten!" – und bis dahin migrieren wir auf Azure.*

## Profil

| Feld | Wert |
|---|---|
| **Fraktion** | Strohhut-Piraten |
| **Rolle** | Piratencrew / Azure-Migration-Auftraggeber |
| **Heimat** | Wano-Land, Neues Welt-Meer |
| **Codename** | OP-WANO-01 |
| **Kontakt** | luffy@thousandsunny.wano |
| **Status** | active |
| **Projekt-Start** | 2026-02-27 |

## Beschreibung

Die Strohhut-Piraten sind eine legendäre Crew unter Kapitän Monkey D. Luffy. Im Rahmen der *Wano Reise – Azure Pipeline Migration* beauftragen sie die vollständige Modernisierung ihrer digitalen Infrastruktur: Azure-Pipelines, DMS-Integration und Automatisierung aller Deployment-Prozesse – damit die Thousand Sunny auch in der Cloud die schnellste im Meer bleibt.

## Mitglieder (Schlüsselkontakte)

| Name | Rolle im Projekt |
|---|---|
| Monkey D. Luffy | Product Owner / Entscheider |
| Nami | Projektsteuerung / Cloud-Navigation |
| Usopp | Technische Dokumentation |
| Zoro | Pipeline-Architektur |

## Aktive Projekte

- [[01_projects/strohhut-wano_azure_migration/index|Wano Reise – Azure Pipeline Migration]]

## Meeting-Log

```dataview
TABLE date, thema, summary
FROM "01_projects/strohhut-wano_azure_migration/meetings"
SORT date desc
LIMIT 10
```

## Offene Aufgaben

```dataviewjs
dv.taskList(
  dv.pages('"01_projects/strohhut-wano_azure_migration"').file.tasks
    .where(t => !t.completed)
)
```
