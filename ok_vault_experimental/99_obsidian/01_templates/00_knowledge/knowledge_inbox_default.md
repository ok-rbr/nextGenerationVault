<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "Atomic title:");
const source = await lib.promptText(tp, "source (optional):");
const priority = await lib.promptSuggester(
    tp,
    "Select priority:",
    ["Low", "Medium", "High"],
    ["low", "medium", "high"]
);

await lib.renameAndMove(tp, title, `/00_knowledge/00_inbox/${title}`);
-%>---
title: "<% title %>"
id: "<% lib.generateId(tp) %>"
created: "<% lib.generateCreatedTimestamp(tp) %>"
tags: ["inbox"]
category: "knowledge"
status: "unprocessed"
priority: "<% priority || "medium" %>"
source: "<% source || "N/A" %>"
related: []
concepts: []
aliases: []
---

# [[<% title %>]]

## Idea Summary
- **Quelle**: <% source || "Nicht angegeben" %>
- **Priorität**: <% priority || "medium" %>

## Notizen


## Next Steps
- [ ] Idee reviewen
- [ ] Zu relevanter Wissenskategorie zuordnen
- [ ] In Atomic oder Permanent Note überführen

