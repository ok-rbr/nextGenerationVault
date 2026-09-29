<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "task title:");

// Rename and move the file
await lib.renameAndMove(tp, title, "01_projects/farron-pipeline-geluebde/doc/" + title);
-%>---
title: <% title %>
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["note", "farron-pipeline-geluebde", "dark-souls", "ashen", "farron", "obsidian", "ember", "ds-farron-07"]
category: "note"
project: "Farron – Pipeline-Gelübde"
status: "active"

---

## description

### progression log

### related
