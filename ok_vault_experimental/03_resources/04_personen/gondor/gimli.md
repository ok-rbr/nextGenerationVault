---
title: "Gimli"
id: "20260227_1703"
created: "2026-02-27 17:03"
tags: ["resource", "person", "client/gefaehrten_des_rings", "lotr", "middle-earth", "free-peoples", "gondor", "topic/cloud"]
category: "resource"
status: "active"
role: "Infrastruktur & On-Premises"
department: "Gefährten des Rings – Zwerge von Erebor"
email: "gimli@minas-tirith.gondor"
phone: "+0 AXTOR-0005"
location: "Minas Tirith / Erebor"
start_date: "20260227"
related: ["[[gefaehrten_des_rings]]", "[[01_projects/minas-tirith-pipeline-wacht/index]]", "[[wacht_architektur]]"]
concepts: ["infrastruktur", "on-premises", "migration"]
aliases: ["Gimli", "Gimli Sohn des Glóin"]
---

## Profile Summary

- **Full Name**: Gimli
- **Role**: Infrastruktur & On-Premises
- **Fraktion**: Gefährten des Rings – Zwerge von Erebor
- **Location**: Minas Tirith / Erebor
- **Start Date**: 2026-02-27
- **Contact**:
  - Email: gimli@minas-tirith.gondor
  - Phone: +0 AXTOR-0005

> 💡 *Gimli migriert On-Premises-Infrastruktur erst, wenn die Azure Pipeline wie Mithril hält.*

## Projekte

- [[01_projects/minas-tirith-pipeline-wacht/index|Minas Tirith – Pipeline-Wacht]] – On-Premises-Migration, Infrastruktur-Beratung (gemäß [[wacht_architektur]])

## Meeting Log

```dataview
TABLE date, thema, summary
FROM "01_projects"
WHERE contains(attendees, "Gimli") AND category = "meeting"
SORT date desc
```
