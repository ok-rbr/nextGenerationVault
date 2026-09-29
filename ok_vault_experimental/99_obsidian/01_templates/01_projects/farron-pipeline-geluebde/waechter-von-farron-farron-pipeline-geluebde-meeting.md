<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "meeting name:");
const date = await lib.promptText(tp, "meeting date (YYYYMM-D):");

// Move the file to the appropriate folder
await lib.safeMove(tp, "01_projects/farron-pipeline-geluebde/meetings/" + date + "_" + title);
-%>---
title: "<% title %>"  
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["meeting", "farron-pipeline-geluebde", "dark-souls", "ashen", "farron", "obsidian", "ember", "ds-farron-07"]
category: "meeting"
thema: ""
summary: ""
attendees: [""]  
date: "<% date %>"

---

# [[<% date + "_" + title %>]]

## agenda

-

## log

-

## action items
