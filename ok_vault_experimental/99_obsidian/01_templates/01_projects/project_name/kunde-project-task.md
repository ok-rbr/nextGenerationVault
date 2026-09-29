<%\*
// Lade Bibliothek
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "task title:");
const priority = "medium";
const task_Id = await lib.promptText(tp, "task id:");
const related = await lib.promptText(tp, "related notes/tasks (comma-separated):");

// Rename and move the file
await lib.renameAndMove(tp, title, "01_projects/{{project_name}}/task/" + title);

-%>---
title: <% title %>
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["task", "{{project_name}}"]
category: "task"
project: "{{project_name}}"
status: "active"
task_id: <% task_Id %>
priority: <% priority %>
related: <% lib.createYamlArray(related, false) %>

---

## description

### progression log

## related notes/tasks

<% lib.createRelatedLinks(related) %>
