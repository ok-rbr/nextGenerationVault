<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "meeting name:");
const date = await lib.promptText(tp, "meeting date (YYYYMM-D):");

// Move the file to the appropriate folder
await lib.safeMove(tp, "01_projects/minas-tirith-pipeline-wacht/meetings/" + date + "_" + title);
-%>---
title: "<% title %>"  
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["meeting", "minas-tirith-pipeline-wacht", "lotr", "middle-earth", "free-peoples", "gondor", "obsidian", "lotr-gondor-07"]
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
