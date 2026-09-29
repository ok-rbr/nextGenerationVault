<%*
// Load library
const lib = tp.user.lib;

// Prompt for resource details
const resourceName = await lib.promptText(tp, "Resource name:");
const resourceType = await lib.promptSuggester(
    tp,
    "Resource type:",
    ["Playbook", "Template", "Tool", "Documentation", "Reference"],
    ["playbook", "template", "tool", "documentation", "reference"]
);
const description = await lib.promptText(tp, "Description:");
const tags = await lib.promptText(tp, "Tags (comma-separated, optional):");

// Create slug and use resource builder
const resourceSlug = lib.slugify(resourceName);
const additionalTags = lib.processTags(tags).map(t => lib.slugify(t));
const fm = lib.fmResource({
    title: resourceName,
    extraTags: [`resource/${resourceType}`, ...additionalTags]
});

// Rename and move the file
await lib.renameAndMove(tp, resourceSlug, `03_resources/${resourceSlug}`);
-%>---
title: "<% resourceName %>"
id: "<% fm.id %>"
created: "<% fm.created %>"
lang: "en"
tags: <% JSON.stringify(fm.tags) %>
category: "resource"
status: "active"
related: []
concepts: []
aliases: []
---

# [[<% resourceName %>]]

## Description

<% description %>

## Type

<% resourceType %>

## Usage


## Links & References


## Notes

