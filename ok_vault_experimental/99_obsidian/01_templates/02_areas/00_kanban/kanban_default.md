<%*
// Lade Bibliothek
const lib = tp.user.lib;

try {
    // Prompt for kanban board details
    const title = await lib.promptTitle(tp, "kanban board name:");
    const area = await lib.promptText(tp, "area/project:");

    // Move the file to the appropriate folder
    await lib.renameAndMove(tp, title, `/02_areas/00_kanban/${title}`);
} catch (error) {
    console.error("Error creating kanban board: ", error)
}
-%>---
title: <% title %>
created: <% lib.generateCreatedLegacy(tp) %>
tags:
  - kanban
  - board
category: kanban
area: <% area %>
status: active
---
# [[<% title %>]]

## Backlog

```dataview
TABLE status, priority
FROM #task
WHERE contains(area, "<% area %>") AND contains(status, "backlog")
SORT priority desc, created asc
```

## To Do

```dataview
TABLE status, priority
FROM #task
WHERE contains(area, "<% area %>") AND contains(status, "todo")
SORT priority desc, created asc
```

## In Progress

```dataview
TABLE status, priority
FROM #task
WHERE contains(area, "<% area %>") AND contains(status, "active")
SORT priority desc, created asc
```

## Done

```dataview
TABLE status, completed
FROM #task
WHERE contains(area, "<% area %>") AND contains(status, "done")
SORT completed desc
LIMIT 10
```
