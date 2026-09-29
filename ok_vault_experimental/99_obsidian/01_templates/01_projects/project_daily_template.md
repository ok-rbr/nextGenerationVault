<%*
// Lade Bibliothek
const lib = tp.user.lib;

// Prompt for daily metadata
const projectName = await lib.promptText(tp, "Project Name (e.g., b2csnt):");
const customerName = await lib.promptText(tp, "Customer Name (for display):");

// Create the title with date
const date = tp.file.creation_date("YYYYMMDD");
const title = `${date}_${customerName}-Daily`;

// Rename and move the file
await lib.renameAndMove(tp, title, `01_projects/${projectName}/daily/${title}`);
-%>---
title: "<% customerName %>-Daily"
created: "<% lib.generateCreatedLegacy(tp) %>"
tags: ["daily", "<% projectName %>"]
category: "daily"
project: "<% projectName %>"
attendees: []
date: "<% date %>"
---

# [[<% title %>]]

## Agenda

- 
- 
- 

---

## Log

- 
- 
- 

---

## Things I Want to Say

```dataviewjs
dv.taskList(
    dv.pages('#<% projectName %>').file.tasks
        .where(t => !t.completed && t.text.includes('#<% projectName %>Daily'))
);
```

## Things I Said Today

```dataviewjs
dv.taskList(
    dv.pages('#<% projectName %>').file.tasks
        .where(t => 
            t.text.includes('#<% projectName %>Daily') && 
            t.text.includes('<% date %>')
        )
);
```

## Notes

- 

## Follow-ups

- [ ] 
