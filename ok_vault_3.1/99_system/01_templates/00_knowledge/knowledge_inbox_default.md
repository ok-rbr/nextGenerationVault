<%*

	if (tp.file.title == "Untitled") {
		var title = await tp.system.prompt("Atomic title:")
	} else {
		var title = tp.file.title
	}
    var source = await tp.system.prompt("source (optional):")
    var priority = await tp.system.prompt("priority (low, medium, high):")

    await tp.file.rename(title)
    await tp.file.move("/00_knowledge/00_inbox/" + title)
-%>---
title: "<% title %>"
id: "<% tp.date.now("YYYYMMDD_HHmm") %>"
created: "<% tp.date.now("YYYY-MM-DD HH:mm") %>"
tags: ["inbox"]
category: "knowledge"
status: "unprocessed"
priority: "<% priority || "medium" %>"
source: "<% source || "" %>"
related: []
concepts: []
aliases: []
---

# [[<% title %> ]]



## Idea Summary
- **Title**: <% title %>
- **Source**: <% source || "Not provided" %>
- **Priority**: <% priority || "medium" %>

## Next Steps
- [x] Review this idea [completion:: 20250508]
- [x] Assign to relevant knowledge category [completion:: 20250508]
