---
title: "index - projects"
id: "20251110_2157"
created: "2025-11-10 21:57"
tags: ["obsidian/index"]
category: "index"
status: "in-progress"
related: []
concepts: []
aliases: []
---

# Projects

Dieser Bereich verwaltet aktive Kunden- und Eigenprojekte. Projekte sind zeitlich begrenzte Vorhaben mit einem klaren Ziel und Abschlusskriterium.

## Zweck

- Verwaltung von Kundenprojekten (Consulting, Implementation)
- Eigenprojekte und Initiativen
- Zeitlich begrenzte Vorhaben mit definiertem Ziel

## Aktive Projekte

```dataview
table file.link as Project, client, status, due
where category = "project" and status != "archived"
sort due asc
```

## Projekte nach Kunde

```dataview
table file.link as ByClient, client, status
where category = "project" and status != "archived"
group by client
```
