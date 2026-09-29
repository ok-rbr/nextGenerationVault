<%\*
// Lade Bibliothek
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "task title:");

// Rename and move the file
await lib.renameAndMove(tp, title, "01_projects/{{project_name}}/doc/" + title);
-%>---
title: <% title %>
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["note", "{{project_name}}"]
category: "note"
project: "{{project_name}}"
status: "active"

---

## description

### progression log

### related
