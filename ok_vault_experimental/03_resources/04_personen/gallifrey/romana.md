---
title: "Romana"
id: "20260227_1656"
created: "2026-02-27 16:56"
tags: ["resource", "person", "client/time_lords_von_gallifrey", "doctor-who", "time-lord", "gallifrey", "tool/azure"]
category: "resource"
status: "active"
role: "Projektleitung / Chefarchitektin"
department: "Rat der Time Lords – Citadel of Gallifrey"
email: "romana@citadel.gallifrey"
phone: "+0 TARDIS-0002"
location: "Gallifrey, Kasterborous-Konstellation"
start_date: "20260227"
related: ["[[time_lords_von_gallifrey]]", "[[01_projects/gallifrey-automatisierungs-protokoll/index]]", "[[deployment_protokoll]]", "[[automatisierungs_spezifikation]]"]
concepts: ["projektleitung", "architektur", "azure-devops"]
aliases: ["Romana", "Romanadvoratrelundar"]
---

## Profile Summary

- **Full Name**: Romana
- **Role**: Projektleitung / Chefarchitektin
- **Fraktion**: Time Lords von Gallifrey
- **Location**: Gallifrey, Kasterborous-Konstellation
- **Start Date**: 2026-02-27
- **Contact**:
  - Email: romana@citadel.gallifrey
  - Phone: +0 TARDIS-0002

## Projekte

- [[01_projects/gallifrey-automatisierungs-protokoll/index|Gallifrey – Automatisierungs-Protokoll]] – Projektleitung, Owner von [[deployment_protokoll|T-001]] und [[automatisierungs_spezifikation]]

## Meeting Log

```dataview
TABLE date, thema, summary
FROM "01_projects"
WHERE contains(attendees, "Romana") AND category = "meeting"
SORT date desc
```
