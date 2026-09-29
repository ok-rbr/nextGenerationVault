<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = "waechter-von-farron-Daily";
const date = tp.file.creation_date("YYYYMMDD");

await lib.renameAndMove(tp, date + "_" + title, "01_projects/farron-pipeline-geluebde/daily/" + date + "_" + title);

-%>---
title: "<% title %>"
created: "<% lib.generateCreatedLegacy(tp) %>"
tags:
- daily
- dark-souls
- ashen
- farron
- obsidian
- ember
- ds-farron-07
category: daily
attendees: Plo Koon, Rumo
date: "<% date %>"
---

# [[<% date + "_" + title %>]]

## Agenda

- Plo Koon
- Rumo
- rapha

---

## Log

- Plo Koon
- Rumo
- Raphael

---

### things i want to say

```dataviewjs
dv.taskList(
    dv.pages('#waechter-von-farronDaily').file.tasks

        .where(t => !t.completed && t.text.includes('#waechter-von-farronDaily'))
);
```

### things i said today

```dataviewjs
dv.taskList(
    dv.pages('#waechter-von-farronDaily').file.tasks
        .where(t =>
            t.text.includes('#waechter-von-farronDaily') &&
             t.text.includes(<% date %>)
        )
);
```
