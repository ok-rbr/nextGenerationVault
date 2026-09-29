<%*
/**
 * Archive Index Template
 * 
 * Creates an index for a daily archive folder.
 * Only created when something is actually archived.
 * 
 * Path: 04_archive/<YYYYMMDD>/00_index.md
 */

// Load library
const lib = tp.user.lib;

// Get date
const archiveDate = lib.generateDateId(tp);
const year = archiveDate.slice(0, 4);
const month = archiveDate.slice(4, 6);
const day = archiveDate.slice(6, 8);
const displayDate = `${day}.${month}.${year}`;

// Rename and move
await lib.renameAndMove(tp, "00_index", `04_archive/${archiveDate}/00_index`);
-%>---
title: "index - <% archiveDate %>"
id: "<% lib.generateId(tp) %>"
created: "<% lib.generateCreatedTimestamp(tp) %>"
lang: "en"
tags: ["obsidian/index", "archive/day"]
category: "index"
status: "active"
related: []
concepts: []
aliases: []
---

# Index - <% archiveDate %>

## Archived on <% displayDate %>

Archive index for <% displayDate %>.

## Archived Notes

```dataview
TABLE file.link as Item, status, archived_on, archived_from
FROM "04_archive/<% archiveDate %>/notes"
SORT file.name ASC
```

## Archived Projects

```dataview
TABLE file.link as Item, status, archived_on, archived_from
FROM "04_archive/<% archiveDate %>/projects"
SORT file.name ASC
```

## Navigation

- [[04_archive/00_index|Archive Overview]]
