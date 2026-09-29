<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "task title:");
const priority = "medium";
const task_Id = await lib.promptText(tp, "task id:");
const related = await lib.promptText(tp, "related notes/tasks (comma-separated):");

// Rename and move the file
await lib.renameAndMove(tp, title, "01_projects/farron-pipeline-geluebde/task/" + title);

-%>---
title: <% title %>
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["task", "farron-pipeline-geluebde", "dark-souls", "ashen", "farron", "obsidian", "ember", "ds-farron-07"]
category: "task"
project: "Farron – Pipeline-Gelübde"
status: "active"
task_id: <% task_Id %>
priority: <% priority %>
related: <% lib.createYamlArray(related, false) %>

---

## description

### progression log

## related notes/tasks

<% lib.createRelatedLinks(related) %>
