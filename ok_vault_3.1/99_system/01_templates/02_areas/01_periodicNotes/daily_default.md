---
tags:
  - daily
category: daily
created: '{{date:YYYYMMDD}}'
---

## meetings

```dataview
TABLE
FROM #meeting OR #mentoring
WHERE date = "{{date:YYYYMMDD}}"
SORT date asc
```

## tasks
```tasks
not done
(due today) OR (no due date)
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
