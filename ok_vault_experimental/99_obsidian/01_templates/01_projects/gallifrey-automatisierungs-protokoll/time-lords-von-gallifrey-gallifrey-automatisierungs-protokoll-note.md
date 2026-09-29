<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "task title:");

// Rename and move the file
await lib.renameAndMove(tp, title, "01_projects/gallifrey-automatisierungs-protokoll/doc/" + title);
-%>---
title: <% title %>
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["note", "gallifrey-automatisierungs-protokoll", "doctor-who", "time-lord", "gallifrey", "obsidian", "time-vortex", "dw-gallifrey-07"]
category: "note"
project: "Gallifrey – Automatisierungs-Protokoll"
status: "active"

---

## description

### progression log

### related
