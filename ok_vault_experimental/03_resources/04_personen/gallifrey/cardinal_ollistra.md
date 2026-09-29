---
title: "Cardinal Ollistra"
id: "20260227_1658"
created: "2026-02-27 16:58"
tags: ["resource", "person", "client/time_lords_von_gallifrey", "doctor-who", "time-lord", "gallifrey", "tool/azure"]
category: "resource"
status: "active"
role: "Audit & Compliance / Azure Policy"
department: "Rat der Time Lords – War Council"
email: "ollistra@citadel.gallifrey"
phone: "+0 TARDIS-0004"
location: "Gallifrey, Kasterborous-Konstellation"
start_date: "20260227"
related: ["[[time_lords_von_gallifrey]]", "[[01_projects/gallifrey-automatisierungs-protokoll/index]]", "[[automatisierungs_spezifikation]]"]
concepts: ["audit", "compliance", "azure-policy", "log-analytics"]
aliases: ["Cardinal Ollistra", "Ollistra"]
---

## Profile Summary

- **Full Name**: Cardinal Ollistra
- **Role**: Audit & Compliance / Azure Policy
- **Fraktion**: Time Lords von Gallifrey – War Council
- **Location**: Gallifrey, Kasterborous-Konstellation
- **Start Date**: 2026-02-27
- **Contact**:
  - Email: ollistra@citadel.gallifrey
  - Phone: +0 TARDIS-0004

## Projekte

- [[01_projects/gallifrey-automatisierungs-protokoll/index|Gallifrey – Automatisierungs-Protokoll]] – Audit-Log Pflicht, Azure Policy Konfiguration (Anforderung gemäß [[automatisierungs_spezifikation]])

## Meeting Log

```dataview
TABLE date, thema, summary
FROM "01_projects"
WHERE contains(attendees, "Cardinal Ollistra") AND category = "meeting"
SORT date desc
```
