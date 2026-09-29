<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "task title:");

// Rename and move the file
await lib.renameAndMove(tp, title, "01_projects/minas-tirith-pipeline-wacht/doc/" + title);
-%>---
title: <% title %>
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["note", "minas-tirith-pipeline-wacht", "lotr", "middle-earth", "free-peoples", "gondor", "obsidian", "lotr-gondor-07"]
category: "note"
project: "Minas Tirith – Pipeline-Wacht"
status: "active"

---

## description

### progression log

### related
