<%\*
// Lade Bibliothek
const lib = tp.user.lib;

const title = "{{kunden_name}}-Daily";
const date = tp.file.creation_date("YYYYMMDD");

await lib.renameAndMove(tp, date + "_" + title, "01_projects/{{project_name}}/daily/" + date + "_" + title);

-%>---
title: "<% title %>"
created: "<% lib.generateCreatedLegacy(tp) %>"
tags:

- daily
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
    dv.pages('#{{kunden_name}}Daily').file.tasks

        .where(t => !t.completed && t.text.includes('#{{kunden_name}}Daily'))
);
```

### things i said today

```dataviewjs
dv.taskList(
    dv.pages('#{{kunden_name}}Daily').file.tasks
        .where(t =>
            t.text.includes('#{{kunden_name}}Daily') &&
             t.text.includes(<% date %>)
        )
);
```
