<%*
// Lade Bibliothek
const lib = tp.user.lib;

try {
    // Prompt for overview details
    const title = await lib.promptTitle(tp, "overview name:");
    const area = await lib.promptText(tp, "area name:");
    const description = await lib.promptText(tp, "area description:");

    // Move the file to the appropriate folder
    await lib.renameAndMove(tp, title, `/02_areas/05_overview/${title}`);
} catch (error) {
    console.error("Error creating overview: ", error)
}
-%>---
title: "<% title %>"
id: "<% lib.generateId(tp) %>"
created: "<% lib.generateCreatedTimestamp(tp) %>"
tags: ["overview", "areas"]
category: "overview"
area: "<% area %>"
status: "in-progress"
related: []
concepts: []
aliases: []
---
# [[<% title %>]] - Overview

## Beschreibung
<% description %>

## Aktive Tasks

```dataview
TABLE status, priority, created
FROM #task
WHERE contains(area, "<% area %>") AND (contains(status, "active") OR contains(status, "pending"))
SORT priority desc, created asc
```

## Neueste Notizen

```dataview
TABLE created, tags
FROM #note
WHERE contains(area, "<% area %>")
SORT created desc
LIMIT 10
```

## Meetings

```dataview
TABLE date, thema, attendees
FROM #meeting
WHERE contains(tags, "<% area %>")
SORT date desc
LIMIT 10
```

## Key Metrics
- Aktive Tasks: 
- Diese Woche abgeschlossen: 
- Anstehende Meetings: 

## Ziele

### Kurzfristige Ziele

### Langfristige Ziele

## Ressourcen & Links
