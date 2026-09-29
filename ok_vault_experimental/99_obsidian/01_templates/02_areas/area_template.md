<%*
// Load library
const lib = tp.user.lib;

// Prompt for area details
const areaName = await lib.promptText(tp, "Area name:");
const description = await lib.promptText(tp, "Area description:");
const topics = await lib.promptText(tp, "Topics (comma-separated):");

// Create area slug and topic tags
const areaSlug = lib.slugify(areaName);
const topicTags = lib.processTags(topics).map(t => `topic/${lib.slugify(t)}`);

// Use area builder with language policy
const fm = lib.fmArea({
    name: areaName,
    extraTags: topicTags
});

// Rename and move the file
await lib.renameAndMove(tp, areaSlug, `02_areas/${areaSlug}`);
-%>---
title: "<% areaName %>"
id: "<% fm.id %>"
created: "<% fm.created %>"
lang: "en"
tags: <% JSON.stringify(fm.tags) %>
category: "area"
status: "in-progress"
related: []
concepts: []
aliases: []
---

# [[<% areaName %>]]

## Description

<% description %>

## Responsibilities


## Goals


## Current Tasks

```dataview
TABLE status, priority, created
FROM #task
WHERE contains(tags, "<% areaSlug %>") AND status != "done"
SORT priority DESC, created ASC
```

## Notes

```dataview
TABLE created, tags
FROM #note
WHERE contains(area, "<% areaSlug %>")
SORT created DESC
LIMIT 10
```

## Resources & Links

