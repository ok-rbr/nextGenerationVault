---
title: "Faramir"
id: "20260227_1701"
created: "2026-02-27 17:01"
tags: ["resource", "person", "client/gefaehrten_des_rings", "lotr", "middle-earth", "free-peoples", "gondor"]
category: "resource"
status: "active"
role: "Projektsteuerung / Staging-Umgebung"
department: "Gefährten des Rings – Ithilien-Ranger"
email: "faramir@minas-tirith.gondor"
phone: "+0 ITHIL-0003"
location: "Ithilien / Minas Tirith"
start_date: "20260227"
related: ["[[gefaehrten_des_rings]]", "[[01_projects/minas-tirith-pipeline-wacht/index]]", "[[dms_migration_gondor]]"]
concepts: ["projektsteuerung", "staging", "dms-migration"]
aliases: ["Faramir", "Hauptmann von Ithilien"]
---

## Profile Summary

- **Full Name**: Faramir
- **Role**: Projektsteuerung / Staging-Umgebung
- **Fraktion**: Gefährten des Rings – Ithilien-Ranger
- **Location**: Ithilien / Minas Tirith
- **Start Date**: 2026-02-27
- **Contact**:
  - Email: faramir@minas-tirith.gondor
  - Phone: +0 ITHIL-0003

## Projekte

- [[01_projects/minas-tirith-pipeline-wacht/index|Minas Tirith – Pipeline-Wacht]] – Projektsteuerung, Verantwortlich für `osgiliath`- & `ithilien`-Environments, plant Kick-off für [[dms_migration_gondor|T-002]]

## Meeting Log

```dataview
TABLE date, thema, summary
FROM "01_projects"
WHERE contains(attendees, "Faramir") AND category = "meeting"
SORT date desc
```
