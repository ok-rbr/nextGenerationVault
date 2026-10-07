---
tags:
  - daily
category: daily
created: "{{date:YYYYMMDD}}"
---

## meetings

```dataview
TABLE
FROM #meeting
WHERE date = "{{date:YYYYMMDD}}" AND !contains(tags, "#daily")
SORT date asc
```

## tasks

```tasks
not done
(due today) OR (no due date)
```

### scheduled

```dataviewjs
let d = dv.date("today").toFormat("yyyyMMdd");
dv.taskList(
dv.pages().file.tasks.where(t => !t.completed && (t.text.includes(d) || t.text.includes(`${d.slice(0,4)}-${d.slice(4,6)}-${d.slice(6)}`))))

```

### active Tasks

```dataview
table project as "project"
FROM #task
WHERE contains(status, "active") AND file.name != "WorkTaskT" AND file.name != "nopCommerceWorkTaskT" AND !contains(tags, "userStory")
Sort project ASC, file.name ASC
```

### Pending Tasks

```dataview
table project as "project"
FROM #task
WHERE contains(status, "pending") AND file.name != "WorkTaskT" AND file.name != "nopCommerceWorkTaskT" AND !contains(tags, "userStory")
Sort project ASC, file.name ASC
```

## log
