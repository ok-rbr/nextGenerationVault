<%*
// Lade Bibliothek
const lib = tp.user.lib;

try {
    // Initialisierung: Titel setzen
    const title = await lib.promptTitle(tp, "Atomic title:");

    // Key concepts abfragen
    const concepts = await lib.promptText(tp, "Key concepts (comma-separated):");

    // Related notes abfragen
    const related = await lib.promptText(tp, "Related notes (comma-separated):");

    // Datei umbenennen und verschieben
    await lib.renameAndMove(tp, title, `/00_knowledge/01_atomic/${title}`);

} catch (error) {
    console.error("Error creating atomic note template: ", error)
}
-%>---
title: "<% title %>"
id: "<% lib.generateId(tp) %>"
created: "<% lib.generateCreatedTimestamp(tp) %>"
tags: ["atomic"]
category: "knowledge"
status: "in-progress"
related: []
concepts: []
aliases: []
---
# [[<% title %>]]

## Key Concepts
<% concepts || "N/A" %>

## Related Notes
<% lib.createRelatedLinks(related) %>
