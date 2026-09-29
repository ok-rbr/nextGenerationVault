<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = "gefaehrten-des-rings-Daily";
const date = tp.file.creation_date("YYYYMMDD");

await lib.renameAndMove(tp, date + "_" + title, "01_projects/minas-tirith-pipeline-wacht/daily/" + date + "_" + title);

-%>---
title: "<% title %>"
created: "<% lib.generateCreatedLegacy(tp) %>"
tags:

- daily
- lotr
- middle-earth
- free-peoples
- gondor
- obsidian
- lotr-gondor-07
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
    dv.pages('#gefaehrten-des-ringsDaily').file.tasks

        .where(t => !t.completed && t.text.includes('#gefaehrten-des-ringsDaily'))
);
```

### things i said today

```dataviewjs
dv.taskList(
    dv.pages('#gefaehrten-des-ringsDaily').file.tasks
        .where(t =>
            t.text.includes('#gefaehrten-des-ringsDaily') &&
             t.text.includes(<% date %>)
        )
);
```
