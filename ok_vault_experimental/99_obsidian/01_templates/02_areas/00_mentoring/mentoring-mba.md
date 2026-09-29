<%*
// Lade Bibliothek
const lib = tp.user.lib;

const mentoringDate = await lib.promptText(tp, "Mentoring Date:");
const title = mentoringDate + "_mentoring";
const PATH = "/02_areas/06_mentoring/"+title;

await lib.renameAndMove(tp, title, PATH);
-%>---
title: <% title %>
created: <% lib.generateCreatedLegacy(tp) %>
tags:
  - mentoring
  - meeting
category: mentoring
mentor: Marvin Baschnagel
mentorig_date: <% mentoringDate %>
summary: ""
---
# Mentoring <% mentoringDate %> 

## agenda

## log

## Open Topics 
```dataviewjs
dv.taskList(dv.pages('#mentoring').file.tasks.where(t => !t.completed))
```

## Next Action
