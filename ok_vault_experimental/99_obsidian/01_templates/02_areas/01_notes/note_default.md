<%*
// Lade Bibliothek
const lib = tp.user.lib;

try {
    // Prompt for note details
    const title = await lib.promptTitle(tp, "note title:");
    const area = await lib.promptText(tp, "area/topic:");
    const tags_input = await lib.promptText(tp, "additional tags (comma-separated):");
    
    // Move the file to the appropriate folder
    await lib.renameAndMove(tp, title, `/02_areas/01_notes/${title}`);
} catch (error) {
    console.error("Error creating note: ", error)
}
-%>---
title: <% title %>
created: <% lib.generateCreatedLegacy(tp) %>
tags:
  - note
  - areas
<% lib.createYamlList(tags_input, 2) %>
category: note
area: <% area %>
status: active
---
# [[<% title %>]]

## summary

## content

## related notes

```dataview
LIST
FROM #note
WHERE contains(area, "<% area %>") AND file.name != "<% title %>"
SORT created desc
LIMIT 5
```

## tasks

```tasks
not done
description includes <% title %>
```
