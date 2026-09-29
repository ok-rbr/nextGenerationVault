---
tags:
  - ObjektKultur
  - daily
note_type: daily
note_author: raphael brand
note_date_creation: "{{date}}"
---

```dataview
TABLE
	FROM #meeting
	WHERE date >= "{{date:YYYYMMDD}}" AND !summary
	SORT date asc
```

```tasks
not done
(due today) OR (no due date)
```

```meta-bind-button
style: primary
label: Vuner
actions:
  - type: templaterCreateNote
    templateFile: "obsidian/templates/VunerT.md"
    folderPath: objektkultur/vuner
    fileName: "{{date:YYYYMMDD}}_Vuner"
```

## Active Tasks

```dataview
table project_name as "project"
WHERE contains(status, "active") AND file.name != "WorkTaskT" AND file.name != "nopCommerceWorkTaskT" AND !contains(tags, "userStory")
```

## Pending Tasks

```dataview
table project_name as "project"
WHERE contains(status, "pending") AND file.name != "WorkTaskT" AND file.name != "nopCommerceWorkTaskT" AND !contains(tags, "userStory")
```

## log

## Next ToDo

- [x] #toDo Thilo das feature zeigen ✅ 2025-11-27
- [ ]
