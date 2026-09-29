<%*
// Lade Bibliothek
const lib = tp.user.lib;

const meetingDate = await lib.promptText(tp, "Enter Meeting Date (YYYYMMDD):");
const date = lib.generateDateId(tp);
const title = meetingDate + "_strohhut-weekly";

await lib.renameAndMove(tp, title, "01_projects/strohhut-wano_azure_migration/weekly/" + title);
-%>---
title: "Weekly: Wano Reise – Azure Pipeline Migration"
mission: "Wano Reise – Azure Pipeline Migration"
crew: "Strohhut-Piraten"
codename: "OP-WANO-01"
created: <% lib.generateCreatedLegacy(tp) %>
updated: <% lib.generateCreatedLegacy(tp) %>
tags: ["project", "one-piece", "pirates", "obsidian", "wano", "weekly"]
category: weekly
theme:
  one_piece: true
  vibe: "pirates"
attendees:
summary: ""
date: "<% meetingDate %>"
aliases: []

---

# [[<% title %>]]

### topics to discuss

```dataviewjs
dv.taskList(dv.pages('#strohhut-weekly').file.tasks.where(t => !t.completed))
```
