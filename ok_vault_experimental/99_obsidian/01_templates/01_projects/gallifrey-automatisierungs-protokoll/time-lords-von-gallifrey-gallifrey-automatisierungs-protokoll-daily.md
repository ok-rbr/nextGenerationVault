<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = "time-lords-von-gallifrey-Daily";
const date = tp.file.creation_date("YYYYMMDD");

await lib.renameAndMove(tp, date + "_" + title, "01_projects/gallifrey-automatisierungs-protokoll/daily/" + date + "_" + title);

-%>---
title: "<% title %>"
created: "<% lib.generateCreatedLegacy(tp) %>"
tags:

- daily
- doctor-who
- time-lord
- gallifrey
- obsidian
- time-vortex
- dw-gallifrey-07
  category: daily
  attendees:
  date: "<% date %>"

---

# [[<% date + "_" + title %>]]

## Agenda


---

## Log



---

### things i want to say

```dataviewjs
dv.taskList(
    dv.pages('#time-lords-von-gallifreyDaily').file.tasks

        .where(t => !t.completed && t.text.includes('#time-lords-von-gallifreyDaily'))
);
```

### things i said today

```dataviewjs
dv.taskList(
    dv.pages('#time-lords-von-gallifreyDaily').file.tasks
        .where(t =>
            t.text.includes('#time-lords-von-gallifreyDaily') &&
             t.text.includes(<% date %>)
        )
);
```
