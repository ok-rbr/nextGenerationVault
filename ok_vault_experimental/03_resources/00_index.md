---
title: "index - resources"
id: "20251110_2157"
created: "2025-11-10 21:57"
tags: ["obsidian/index"]
category: "index"
status: "in-progress"
related: []
concepts: []
aliases: []
---

# Resources

Dieser Bereich sammelt Referenzen, Playbooks, Templates und Tools. Resources sind Materialien, die bei Bedarf nachgeschlagen werden können.

## Zweck

- Technische Dokumentation und Playbooks
- Templates und Vorlagen
- Tools und Ressourcen
- Kontakte und Beziehungen

## Alle Resources

```dataview
table file.link as Resource, tags
where category = "resource"
sort file.name asc
```

## Kunden & Fraktionen

```dataview
TABLE role, company, location, file.link as Profil
FROM "03_resources/03_kunden"
WHERE category = "resource"
SORT file.name ASC
```

## Personen (nach Fraktion)

```dataview
TABLE role, department, file.link as Profil
FROM "03_resources/04_personen"
WHERE category = "resource"
SORT department ASC, file.name ASC
```
