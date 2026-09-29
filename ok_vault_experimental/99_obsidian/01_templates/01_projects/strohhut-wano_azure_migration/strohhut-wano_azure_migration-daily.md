<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = "strohhut-daily";
const date = tp.file.creation_date("YYYYMMDD");

await lib.renameAndMove(tp, date + "_" + title, "01_projects/strohhut-wano_azure_migration/daily/" + date + "_" + title);

-%>---
title: "Daily: Wano Reise – Azure Pipeline Migration"
mission: "Wano Reise – Azure Pipeline Migration"
crew: "Strohhut-Piraten"
codename: "OP-WANO-01"
tags: ["project", "one-piece", "pirates", "obsidian", "wano", "daily"]
category: daily
attendees:
date: "<% date %>"
aliases: []

---

# [[<% date + "_" + title %>]]

## Agenda

- 
- 
- 

---

## Log

- 
- 
- 

---

### things i want to say

```dataviewjs
dv.taskList(
    dv.pages('#strohhut-daily').file.tasks

        .where(t => !t.completed && t.text.includes('#strohhut-daily'))
);
```

### things i said today

```dataviewjs
dv.taskList(
    dv.pages('#strohhut-daily').file.tasks
        .where(t =>
            t.text.includes('#strohhut-daily') &&
             t.text.includes(<% date %>)
        )
);
```
