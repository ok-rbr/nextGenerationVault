<%*
// Lade Bibliothek
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "meeting name:");
const date = await lib.promptText(tp, "meeting date (YYYYMM-D):");

// Move the file to the appropriate folder
await lib.safeMove(tp, "01_projects/strohhut-wano_azure_migration/meetings/" + date + "_" + title);
-%>---
title: "Meeting: Wano Reise – Azure Pipeline Migration"
mission: "Wano Reise – Azure Pipeline Migration"
crew: "Strohhut-Piraten"
codename: "OP-WANO-01"
tags: ["project", "one-piece", "pirates", "obsidian", "wano", "meeting"]
category: "meeting"
thema: ""
summary: ""
attendees: [""]
date: "<% date %>"
aliases: []

---

# [[<% date + "_" + title %>]]

## agenda

-

## log

-

## action items
