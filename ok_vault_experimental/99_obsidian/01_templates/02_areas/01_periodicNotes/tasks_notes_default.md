<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "Atomic title:");
const priority = await lib.promptSuggester(tp, "Select priority:", ["Low", "Medium", "High"], ["low", "medium", "high"]);
const related = await lib.promptText(tp, "related notes/tasks (comma-separated):");

// Rename and move the file
await lib.renameAndMove(tp, title, `/02_areas/07_task/${title}`);
-%>---
title: <% title %>
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["task"]
category: "tasks"
project: "noch auf der suche"
status: active
priority: <% priority %>
related: <% lib.createYamlArray(related, false) %>
---

## related notes/tasks
<% lib.createRelatedLinks(related) %>
