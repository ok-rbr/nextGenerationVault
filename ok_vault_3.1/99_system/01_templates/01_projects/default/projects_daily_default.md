<%*
try {
    var title = #AddTitle
	var date = tp.file.creation_date("YYYYMMDD")

    await tp.file.rename(date + "_" + title)
    await tp.file.move("01_project/{ProjectName}/daily/" + date + "_" + title)
} catch (error) {
    console.error("Error creating Daily Template:", error)
}
-%>---
title: "<% title %>"
created: "<% tp.date.now('YYYYMMDD - HHmm') %>"
tags:
  - meeting
  - daily
category: daily
attendees:
  -
date: "<% date %>"
---
# [[<% date + "_" + title %>]]

## Agenda

---

## Log

---

### tasks
```dataview
TABLE task AS "Task", due_date AS "Due Date"
FROM #manDaily
WHERE !completed AND contains(tags, "daily")
SORT due_date ASC
````
