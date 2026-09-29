<%*
// Lade Bibliothek
const lib = tp.user.lib;

// Prompt for note metadata
const projectName = await lib.promptText(tp, "Project Name (e.g., b2csnt):");
const noteTitle = await lib.promptText(tp, "Note Title:");
const status = await lib.promptSuggester(
    tp,
    "Select Note Status:",
    ["Active", "Draft", "Completed", "Archived"],
    ["active", "draft", "completed", "archived"]
);

// Rename and move the file
await lib.renameAndMove(tp, noteTitle, `01_projects/${projectName}/doc/${noteTitle}`);
-%>---
title: "<% noteTitle %>"
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["note", "<% projectName %>"]
category: "note"
project: "<% projectName %>"
status: "<% status %>"
---

# [[<% noteTitle %>]]

## Description

## Context

**Project:** [[<% projectName %>]]
**Created:** <% lib.generateCreatedTimestamp(tp) %>

## Content

## Progression Log

### <% tp.date.now("YYYY-MM-DD") %>

- 

## Related

### Related Notes

- 

### Related Tasks

- 

### Related Meetings

- 

## References

- 
