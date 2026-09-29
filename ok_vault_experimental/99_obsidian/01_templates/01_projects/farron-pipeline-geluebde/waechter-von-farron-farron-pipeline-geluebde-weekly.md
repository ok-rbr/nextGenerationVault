<%*
// Lade Bibliothek
const lib = tp.user.lib;

const meetingDate = await lib.promptText(tp, "Enter Meeting Date (YYYYMMDD):");
const date = lib.generateDateId(tp);
const title = meetingDate + "farron-weekly";

await lib.renameAndMove(tp, title, "01_projects/farron-pipeline-geluebde/weekly/" + title);
-%>---
title: "<% title %>"
tags:
- weekly
- b2c
- meeting
- dark-souls
- ashen
- farron
- obsidian
- ember
category: weekly
attendees: Plo Koon, Rumo
summary: ""
date: "<% meetingDate %>"

---

# [[<% title %>]]

### topics to discuss

```dataviewjs
dv.taskList(dv.pages('#waechter-von-farron-weekly').file.tasks.where(t => !t.completed))
```
