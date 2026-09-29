<%*
// Lade Bibliothek
const lib = tp.user.lib;

// Prompt for weekly metadata
const projectName = await lib.promptText(tp, "Project Name (e.g., b2csnt):");
const customerName = await lib.promptText(tp, "Customer Name (for display):");
const meetingDate = await lib.promptText(tp, "Meeting Date (YYYYMMDD):");
const attendees = await lib.promptText(tp, "Attendees (comma-separated, optional):");

// Create the title
const title = `${meetingDate}_${customerName}-weekly`;

// Rename and move the file
await lib.renameAndMove(tp, title, `01_projects/${projectName}/weekly/${title}`);
-%>---
title: "<% title %>"
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["weekly", "<% projectName %>", "meeting"]
category: "weekly"
project: "<% projectName %>"
attendees: <% lib.createYamlArray(attendees, true) %>
summary: ""
date: "<% meetingDate %>"
---

# [[<% title %>]]

## Meeting Information

**Date:** <% meetingDate %>
**Project:** [[<% projectName %>]]
**Attendees:** <% attendees || "TBD" %>

## Topics to Discuss

```dataviewjs
dv.taskList(
    dv.pages('#<% projectName %>-weekly').file.tasks
        .where(t => !t.completed)
);
```

## Weekly Highlights

### Completed This Week

- 

### In Progress

- 

### Planned for Next Week

- 

## Blockers & Issues

- 

## Key Decisions

- 

## Action Items

- [ ] 

## Metrics & KPIs

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
|        |       |        |        |

## Notes

- 
