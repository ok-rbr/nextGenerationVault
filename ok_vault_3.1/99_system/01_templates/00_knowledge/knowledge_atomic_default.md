<%*
try {
    // Initialisierung: Titel setzen
		if (tp.file.title == "Untitled") {
			var title = await tp.system.prompt("Atomic title:")
		} else {
			var title = tp.file.title
		}

    // Key concepts abfragen
    var concepts = await tp.system.prompt("Key concepts (comma-separated):")
    concepts = concepts || "None" // Fallback, wenn leer

    // Related notes abfragen
    var related = await tp.system.prompt("Related notes (comma-separated):")
    related = related || "None" // Fallback, wenn leer

    // Datei umbenennen und verschieben
    await tp.file.rename(title)
    await tp.file.move("/00_knowledge/01_atomic/" + title)

} catch (error) {
    console.error("Error creating atomic note template: ", error)
}
-%>---
title: "<% title %>"
id: "<% tp.date.now("YYYYMMDD_HHmm") %>"
created: "<% tp.date.now("YYYY-MM-DD HH:mm") %>"
tags: ["atomic"]
category: "knowledge"
status: "completed"
related:
  - <% related !== "None" ? related.split(",").map(note => note.trim()).join("\n  - ") : "" %>
concepts:
  - <% concepts !== "None" ? concepts.split(",").map(concept => concept.trim()).join("\n  - ") : "" %>
aliases: []
---
# [[<% title %>]]

## Related Notes
<%*
if (related !== "None") {
    related.split(",").forEach((note) => {
        tR += "- [[" + note.trim() + "]]\n";
    });
}
-%>
