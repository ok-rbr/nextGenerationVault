<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "task title:");
const priority = "medium";
const task_Id = await lib.promptText(tp, "task id:");
const related = await lib.promptText(tp, "related notes/tasks (comma-separated):");

// Rename and move the file
await lib.renameAndMove(tp, title, "01_projects/strohhut-wano_azure_migration/task/" + title);

-%>---
title: "Task: Wano Reise – Azure Pipeline Migration"
mission: "Wano Reise – Azure Pipeline Migration"
crew: "Strohhut-Piraten"
codename: "OP-WANO-01"
tags: ["project", "one-piece", "pirates", "obsidian", "wano", "task"]
category: "task"
project: "wano_azure_migration"
status: "active"
task_id: <% task_Id %>
priority: <% priority %>
related: <% lib.createYamlArray(related, false) %>
aliases: []

---

## description

### progression log

## related notes/tasks

<% lib.createRelatedLinks(related) %>
