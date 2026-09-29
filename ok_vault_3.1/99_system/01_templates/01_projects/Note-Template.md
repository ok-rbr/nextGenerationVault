<%*
	if (tp.file.title == "Untitled") {
		var title = await tp.system.prompt("note title:")
	} else {
		var title = tp.file.title
	}
    // Rename and move the file
    await tp.file.rename(title)
    await tp.file.move("/02_areas/01_notes/" + title)
-%>---
title: <% title %>
created: <% tp.date.now("YYYYMMDD - HH:mm") %>
tags: ["note"]
category: "note"
status: "active"
---
## description



### related
