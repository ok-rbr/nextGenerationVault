<%*
  var title = await tp.system.prompt("literature title :")
  var author = await tp.system.prompt("author:")
  var type = await tp.system.prompt("type (e.g., book, article, video):")
  var source = await tp.system.prompt("source (e.g., link or citation):")
  var summary = await tp.system.prompt("summary:")

  // Rename the file and move it to the correct folder
  await tp.file.rename(title)
  await tp.file.move("/00_knowledge/01_literature/" + title)
-%>---
title: <% title %>
created: <% tp.date.now("YYYYMMDD - HHmm") %>
tags: ["literature"]
category: "knowledge"
type: <% type %>
author: <% author %>
source: <% source %>
summary: <% summary %>
status: "in-progress"
---
## Literature Details
- **Title**: <% title %>
- **Author**: <% author %>
- **Type**: <% type %>
- **Source**: <% source || "Not provided" %>
- **Summary**: <% summary || "No summary available" %>

## Action Items
- [x] Continue reading/studying [completion:: 20250508]
- [x] Extract key concepts [completion:: 20250508]

# [[<% title %> ]]
