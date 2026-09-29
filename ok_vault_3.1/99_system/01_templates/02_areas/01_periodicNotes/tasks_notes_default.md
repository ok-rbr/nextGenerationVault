<%*
		if (tp.file.title == "Untitled") {
			var title = await tp.system.prompt("title:")
		} else {
			var title = tp.file.title
		}
    var priority = await tp.system.prompt("priority (low, medium, high):")

    // Rename and move the file
    await tp.file.rename(title)
    await tp.file.move("/02_areas/07_task/" + title)
-%>---
title: <% title %>
created: <% tp.date.now("YYYYMMDD - HH:mm") %>
tags: ["task"]
category: "tasks"
project: "noch auf der suche"
status: active
priority: <% priority %>
---

## related notes/tasks
