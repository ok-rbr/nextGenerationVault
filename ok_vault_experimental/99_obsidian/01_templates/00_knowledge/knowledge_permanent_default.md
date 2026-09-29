<%*
// Load library
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "Note title:");
const concepts = await lib.promptText(tp, "Key concepts (comma-separated):");
const related = await lib.promptText(tp, "Related notes (comma-separated):");

// Create slug and use knowledge builder
const titleSlug = lib.slugify(title);
const fm = lib.fmKnowledge({
    title: title,
    type: "permanent",
    extraTags: []
});

// Parse concepts and related items
const conceptsList = lib.processTags(concepts);
const relatedList = lib.parseRelatedItems(related);
fm.concepts = conceptsList;
fm.related = relatedList;

// Rename the file and move it to the correct folder
await lib.renameAndMove(tp, titleSlug, `/00_knowledge/03_permanent/${titleSlug}`);
-%>---
title: "<% title %>"
id: "<% fm.id %>"
created: "<% fm.created %>"
lang: "en"
tags: <% JSON.stringify(fm.tags) %>
category: "knowledge"
status: "completed"
related: <% JSON.stringify(fm.related) %>
concepts: <% JSON.stringify(fm.concepts) %>
aliases: []
---
# [[<% title %>]]

## Summary


## Key Concepts
<% concepts || "N/A" %>

## Related Notes
<% lib.createRelatedLinks(related) %>