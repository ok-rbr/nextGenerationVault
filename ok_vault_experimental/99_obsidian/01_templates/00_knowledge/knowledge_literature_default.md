<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = await lib.promptText(tp, "literature title:");
const author = await lib.promptText(tp, "author:");
const type = await lib.promptText(tp, "type (e.g., book, article, video):");
const source = await lib.promptText(tp, "source (e.g., link or citation):");
const summary = await lib.promptText(tp, "summary:");

// Rename the file and move it to the correct folder
await lib.renameAndMove(tp, title, `/00_knowledge/02_literature/${title}`);
-%>---
title: "<% title %>"
id: "<% lib.generateId(tp) %>"
created: "<% lib.generateCreatedTimestamp(tp) %>"
tags: ["literature"]
category: "knowledge"
status: "in-progress"
type: "<% type %>"
author: "<% author %>"
source: "<% source %>"
related: []
concepts: []
aliases: []
---
# [[<% title %>]]

## Literature Details
- **Autor**: <% author %>
- **Type**: <% type %>
- **Quelle**: <% source || "Nicht angegeben" %>

## Summary
<% summary || "Keine Zusammenfassung verfügbar" %>

## Key Takeaways


## Action Items
- [ ] Vollständig lesen/studieren
- [ ] Kernkonzepte extrahieren
- [ ] Mit bestehendem Wissen verknüpfen