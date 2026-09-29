<%*

	if (tp.file.title == "Untitled") {
		var title = await tp.system.prompt("Atomic title:")
	} else {
		var title = tp.file.title
	}
    var concepts = await tp.system.prompt("key concepts (comma-separated):")
    var related = await tp.system.prompt("related notes (comma-separated):")

    // Rename the file and move it to the correct folder
    await tp.file.rename(title)
    await tp.file.move("/00_knowledge/03_permanent/" + title)
-%>---
title: <% title %>
created: <% tp.date.now("YYYYMMDD - HHmm") %>
tags: ["permanent"]
category: "knowledge"
status: "completed"
related:
  - <% related.split(",").map(note => note.trim()).join("\n  - ") || "None" %>
concepts:
  - <% concepts.split(",").map(concept => concept.trim()).join("\n  - ") || "None" %>
---
## Summary
- **Title**: <% title %>
- **Key Concepts**:
	- <% concepts.split(",").map(concept => "- " + concept.trim()).join("\n") || "None provided" %>


# [[<% title %> ]]



### realted notes
<%*
if (related.trim() !== "") {
    related.split(",").forEach((note) => {
        tR += "- [[" + note.trim() + "]]\n";
    });
}
-%>
