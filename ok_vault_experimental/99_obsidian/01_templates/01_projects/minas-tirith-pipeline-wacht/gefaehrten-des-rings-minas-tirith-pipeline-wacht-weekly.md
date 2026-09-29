<%*
// Lade Bibliothek
const lib = tp.user.lib;

const meetingDate = await lib.promptText(tp, "Enter Meeting Date (YYYYMMDD):");
const date = lib.generateDateId(tp);
const title = meetingDate + "_b2csnt-weekly";

await lib.renameAndMove(tp, title, "01_projects/minas-tirith-pipeline-wacht/weekly/" + title);
-%>---
title: "<% title %>"
tags:

- weekly
- b2csnt
- meeting
- lotr
- middle-earth
- free-peoples
- gondor
- obsidian
- lotr-gondor-07
  category: weekly
  attendees:
  summary: ""
  date: "<% meetingDate %>"

---

# [[<% title %>]]

### topics to discuss

```dataviewjs
dv.taskList(dv.pages('#SNT-weekly').file.tasks.where(t => !t.completed))
```
