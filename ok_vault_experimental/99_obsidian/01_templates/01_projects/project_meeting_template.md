<%*
// Lade Bibliothek
const lib = tp.user.lib;

// Prompt for meeting metadata
const projectName = await lib.promptText(tp, "Project Name (e.g., b2csnt):");
const meetingTitle = await lib.promptText(tp, "Meeting Name:");
const meetingDate = await lib.promptText(tp, "Meeting Date (YYYYMMDD):");
const attendees = await lib.promptText(tp, "Attendees (comma-separated):");

// Create the full title
const title = `${meetingDate}_${meetingTitle}`;

// Move the file to the appropriate folder
await lib.renameAndMove(tp, title, `01_projects/${projectName}/meetings/${title}`);
-%>---
title: "<% meetingTitle %>"
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["meeting", "<% projectName %>"]
category: "meeting"
project: "<% projectName %>"
thema: ""
summary: ""
attendees: <% lib.createYamlArray(attendees, true) %>
date: "<% meetingDate %>"
---

# [[<% title %>]]

## Meeting Information

**Date:** <% meetingDate %>
**Project:** [[<% projectName %>]]
**Attendees:** <% attendees %>

## Agenda

- 

## Log

- 

## Action Items

- [ ] 

## Decisions Made

- 

## Next Meeting

**Date:**
**Topics:**
