<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "task title:");
const priority = "medium";

// Rename and move the file
await lib.renameAndMove(tp, title, "01_projects/gallifrey-automatisierungs-protokoll/task/" + title);

-%>---
title: <% title %>
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["task", "gallifrey-automatisierungs-protokoll", "doctor-who", "time-lord", "gallifrey", "obsidian", "time-vortex", "dw-gallifrey-07"]
category: "task"
project: "Gallifrey – Automatisierungs-Protokoll"
status: "active"
task_id: <% task_Id %>
priority: <% priority %>
related: <% lib.createYamlArray(related, false) %>

---

## description

### progression log

## related notes/tasks

<% lib.createRelatedLinks(related) %>
