<%*
    var title = {Enter Name}
    var date = await tp.system.prompt("Enter Meeting Date (YYYYMMDD):", tp.date.now("YYYYMMDD"))

    // Set file name and move to appropriate folder
    await tp.file.rename(date + "_" + project + "_Weekly")
    await tp.file.move("01_projects/" + project + "/weekly/" + date + "_" + project + "_Weekly")
-%>---
title: "<% project %> Weekly"
created: "<% tp.date.now('YYYYMMDD - HHmm') %>"
tags:
  - weekly
  - meeting
  - project/<% project.toLowerCase().replace(" ", "-") %>
category: [weekly](weekly.md)
attendees:
  -
thema: "Weekly Update"
summary: ""                 # Add key decisions or highlights here
date: "<% date %>"
---
# [[<% date + "_" + project + "_Weekly" %>]]

## Agenda
- Review last week's tasks
- Updates from team members
- Upcoming deadlines and goals
- Challenges or blockers
- Next steps

---

## Log
### Key Updates
- [x] Summary of key updates discussed during the meeting. [completion:: 20250508]

---

## topics

```dataviewjs
dv.taskList(dv.pages('#weekly').file.tasks.where(t => !t.completed))
```
