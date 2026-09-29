<%*
// Lade Bibliothek
const lib = tp.user.lib;

// Prompt for task metadata
const projectName = await lib.promptText(tp, "Project Name (e.g., b2csnt):");
const taskTitle = await lib.promptText(tp, "Task Title:");
const taskId = await lib.promptText(tp, "Task ID (e.g., PROJ-123):");
const priority = await lib.promptPriority(tp);
const status = await lib.promptSuggester(
    tp,
    "Select Task Status:",
    ["Active", "In Progress", "Blocked", "Completed", "Cancelled"],
    ["active", "in-progress", "blocked", "completed", "cancelled"]
);
const related = await lib.promptText(tp, "Related notes/tasks (comma-separated, optional):");

// Rename and move the file
await lib.renameAndMove(tp, taskTitle, `01_projects/${projectName}/task/${taskTitle}`);
-%>---
title: "<% taskTitle %>"
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["task", "<% projectName %>"]
category: "task"
project: "<% projectName %>"
status: "<% status %>"
task_id: "<% taskId %>"
priority: "<% priority %>"
due_date: ""
assigned_to: ""
related: <% lib.createYamlArray(related, true) %>
---

# [[<% taskTitle %>]]

## Task Information

**Task ID:** <% taskId %>
**Project:** [[<% projectName %>]]
**Status:** <% status %>
**Priority:** <% priority %>
**Created:** <% lib.generateCreatedTimestamp(tp) %>

## Description

## Acceptance Criteria

- [ ] 
- [ ] 
- [ ] 

## Progression Log

### <% tp.date.now("YYYY-MM-DD") %>

- 

## Related Notes/Tasks

<% lib.createRelatedLinks(related) %>

## Notes

- 

## Blockers

- 
