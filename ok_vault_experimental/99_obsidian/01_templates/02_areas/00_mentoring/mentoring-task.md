<%*
// Lade Bibliothek
const lib = tp.user.lib;

try {
    const title = await lib.promptText(tp, "title:");
    const status = "active";
    const priority = await lib.promptSuggester(tp, "Select priority:", ["Low", "Medium", "High"], ["low", "medium", "high"]);
    const related = await lib.promptText(tp, "related notes/tasks (comma-separated):");

    // Rename and move the file
    await lib.renameAndMove(tp, title, `/02_areas/06_mentoring/${title}`);
} catch (error) {
    console.error("Error creating task note template: ", error)
}
-%>---
title: <% title %>
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["task", "mentoring"]
category: "mentoring"
project: "mentoring"
status: <% status %>
priority: <% priority %>
related: <% lib.createYamlArray(related, false) %>
---
## description


## related notes/tasks
<% lib.createRelatedLinks(related) %>