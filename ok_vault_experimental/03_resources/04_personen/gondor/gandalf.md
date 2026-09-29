---
title: "Gandalf"
id: "20260227_1700"
created: "2026-02-27 17:00"
tags: ["resource", "person", "client/gefaehrten_des_rings", "lotr", "middle-earth", "free-peoples", "gondor", "tool/azure"]
category: "resource"
status: "active"
role: "Technischer Chefarchitekt"
department: "Gefährten des Rings – Istari"
email: "gandalf@minas-tirith.gondor"
phone: "+0 STAFF-0002"
location: "Minas Tirith, Gondor (wechselnder Standort)"
start_date: "20260227"
related: ["[[gefaehrten_des_rings]]", "[[01_projects/minas-tirith-pipeline-wacht/index]]", "[[pipeline_wacht_aufbau]]", "[[wacht_architektur]]"]
concepts: ["chefarchitekt", "azure-devops", "iac", "bicep"]
aliases: ["Gandalf", "Gandalf der Weiße", "Mithrandir"]
---

## Profile Summary

- **Full Name**: Gandalf
- **Role**: Technischer Chefarchitekt
- **Fraktion**: Gefährten des Rings – Istari
- **Location**: Minas Tirith, Gondor
- **Start Date**: 2026-02-27
- **Contact**:
  - Email: gandalf@minas-tirith.gondor
  - Phone: +0 STAFF-0002

## Projekte

- [[01_projects/minas-tirith-pipeline-wacht/index|Minas Tirith – Pipeline-Wacht]] – Technischer Chefarchitekt, Owner von [[pipeline_wacht_aufbau|T-001]] und [[wacht_architektur]], IaC-Review (Bicep)

## Meeting Log

```dataview
TABLE date, thema, summary
FROM "01_projects"
WHERE contains(attendees, "Gandalf") AND category = "meeting"
SORT date desc
```
