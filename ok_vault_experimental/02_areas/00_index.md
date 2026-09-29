---
title: "index - areas"
id: "20251110_2157"
created: "2025-11-10 21:57"
tags: ["obsidian/index"]
category: "index"
status: "in-progress"
related: []
concepts: []
aliases: []
---

# Areas

Dieser Bereich organisiert laufende Verantwortungsbereiche ohne festes Enddatum. Areas sind langfristige Themengebiete, die kontinuierliche Aufmerksamkeit erfordern.

## Zweck

- Azure-Themen und Technologien
- Identity & Access Management (IAM)
- Security-Themen
- Persönliche und berufliche Entwicklung

## Aktive Areas

```dataview
table file.link as Area, status, tags
where category = "area" and status != "archived"
sort file.name asc
```
