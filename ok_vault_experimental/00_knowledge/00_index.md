---
title: "index - knowledge"
id: "20251110_2157"
created: "2025-11-10 21:57"
tags: ["obsidian/index"]
category: "index"
status: "in-progress"
related: []
concepts: []
aliases: []
---

# Knowledge Management

Dieser Bereich dient der systematischen Wissenserfassung nach dem Zettelkasten-Prinzip. Wissen durchläuft mehrere Stufen: von der initialen Erfassung (Inbox) über atomare Notizen bis hin zu permanentem, vernetztem Wissen.

## Struktur

- **00_inbox/**: Unverarbeitete Ideen und Informationen
- **01_atomic/**: Kleine, fokussierte Wissenseinheiten
- **02_literature/**: Notizen aus Büchern, Artikeln und anderen Quellen
- **03_permanent/**: Verifiziertes, dauerhaft relevantes Wissen

## Aktuelle Atomic Notes

```dataview
table file.link as Note, file.mtime as Updated
from "00_knowledge/01_atomic"
sort file.mtime desc
limit 15
```

## Literatur-Notizen

```dataview
table file.link as Literature, created, status
from "00_knowledge/02_literature"
sort created desc
limit 15
```

## Permanente Notizen

```dataview
table file.link as Permanent, tags
from "00_knowledge/03_permanent"
sort file.name asc
```
