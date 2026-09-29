<%*
const lib = tp.user.lib || {};
const title = "dashboard";

await tp.file.rename(title);
await tp.file.move(`/02_areas/05_overview/${title}`);
-%>---
title: "vault dashboard"
id: "<%= lib.nowId ? lib.nowId() : tp.date.now('YYYYMMDD_HHmm') %>"
created: "<%= lib.nowIso ? lib.nowIso() : tp.date.now('YYYY-MM-DD HH:mm') %>"
lang: "en"
tags:
  - "obsidian/dashboard"
  - "overview"
category: "dashboard"
status: "active"
---

# 🏠 Vault Dashboard

**Last Updated**: <%= tp.date.now('YYYY-MM-DD HH:mm') %>

---

## 🎯 Today's Focus

### Priority Tasks

```dataview
TABLE status, priority, project, due
FROM #task
WHERE status = "active" AND (due = date(today) OR priority = "critical" OR priority = "high")
SORT priority DESC, due ASC
LIMIT 10
```

### Today's Meetings

```dataview
TABLE thema as "Topic", attendees, time
FROM #meeting
WHERE date = date(today).year + "" + string(date(today).month, "00") + "" + string(date(today).day, "00")
SORT file.ctime ASC
```

---

## 📊 Projects Overview

### Active Projects

```dataview
TABLE status, client, due, file.link as "Project"
FROM "01_projects"
WHERE category = "project" AND status = "active"
SORT due ASC
LIMIT 15
```

### Projects Needing Attention

```dataview
TABLE status, due, file.link as "Project"
FROM "01_projects"
WHERE category = "project" 
  AND (status = "blocked" OR status = "pending" OR due < date(today))
SORT status ASC, due ASC
```

### Recently Completed

```dataview
TABLE status, file.ctime as "Completed", file.link as "Project"
FROM "01_projects"
WHERE category = "project" AND (status = "completed" OR status = "done")
SORT file.mtime DESC
LIMIT 5
```

---

## ✅ Task Management

### Active Tasks (All Projects)

```dataview
TABLE status, priority, project, due
FROM #task
WHERE status = "active"
SORT priority DESC, due ASC
LIMIT 20
```

### Blocked/Pending Tasks

```dataview
TABLE status, project, priority, file.link as "Task"
FROM #task
WHERE status = "blocked" OR status = "pending"
SORT priority DESC
LIMIT 10
```

### Overdue Tasks

```dataview
TABLE project, priority, due, file.link as "Task"
FROM #task
WHERE status = "active" AND due < date(today)
SORT due ASC
```

---

## 📅 Recent Activity

### This Week's Meetings

```dataview
TABLE thema as "Topic", date, attendees
FROM #meeting
WHERE date >= date(today).week.start.year + "" + string(date(today).week.start.month, "00") + "" + string(date(today).week.start.day, "00")
SORT date DESC
LIMIT 10
```

### Recent Notes

```dataview
TABLE category, tags, file.ctime as "Created"
FROM ""
WHERE file.ctime >= date(today) - dur(7 days)
  AND file.name != "dashboard"
  AND !contains(file.path, "01_templates")
SORT file.ctime DESC
LIMIT 15
```

---

## 🧠 Knowledge Management

### Inbox Items

```dataview
TABLE priority, status, file.ctime as "Added"
FROM "00_knowledge/00_inbox"
WHERE status = "unprocessed"
SORT priority DESC, file.ctime DESC
LIMIT 10
```

**Action Required**: 
- [ ] Process inbox items regularly
- [ ] Convert to atomic/permanent notes

### Recent Knowledge Notes

```dataview
TABLE category, concepts, file.ctime as "Created"
FROM "00_knowledge"
WHERE file.ctime >= date(today) - dur(14 days)
  AND file.name != "00_index"
SORT file.ctime DESC
LIMIT 10
```

---

## 📖 Learnings & Insights

### Recent Learnings

```dataview
LIST
FROM ""
WHERE contains(file.outlinks, "knowledge") 
  OR contains(tags, "learning")
  OR contains(file.name, "learning")
SORT file.mtime DESC
LIMIT 10
```

### Key Concepts

```dataview
TABLE length(rows.file.link) as "References"
FROM #permanent OR #atomic
GROUP BY concepts
SORT length(rows.file.link) DESC
LIMIT 10
```

---

## 👥 People & Relationships

### Recent Contacts

```dataview
TABLE role, company, file.mtime as "Last Updated"
FROM "02_areas/07_people" OR "03_resources/02_people"
WHERE category = "people"
SORT file.mtime DESC
LIMIT 10
```

### Upcoming 1-on-1s

```dataview
TABLE attendees, date, thema
FROM #meeting
WHERE contains(thema, "1:1") OR contains(thema, "1-on-1")
  AND date >= date(today).year + "" + string(date(today).month, "00") + "" + string(date(today).day, "00")
SORT date ASC
```

---

## 📈 Statistics & Metrics

### Task Distribution by Status

```dataview
TABLE length(rows) as "Count"
FROM #task
GROUP BY status
SORT length(rows) DESC
```

### Projects by Status

```dataview
TABLE length(rows) as "Count"
FROM "01_projects"
WHERE category = "project"
GROUP BY status
SORT length(rows) DESC
```

### Notes Created This Week

```dataview
TABLE length(rows) as "Count"
FROM ""
WHERE file.ctime >= date(today).week.start
  AND !contains(file.path, "01_templates")
GROUP BY category
SORT length(rows) DESC
```

---

## 🔔 Alerts & Reminders

### Items Needing Review

- **Overdue Tasks**: See section above
- **Blocked Items**: Identify and resolve blockers
- **Unprocessed Inbox**: <%= (await dv.query('LIST FROM "00_knowledge/00_inbox" WHERE status = "unprocessed"')).value.values.length %> items waiting

### Weekly Review

```dataview
LIST
FROM "02_areas/03_weekly"
SORT file.ctime DESC
LIMIT 1
```

**Action**:
- [ ] Schedule this week's review if not done yet

---

## 🚀 Quick Actions

### Daily Routine
- [ ] Review today's priority tasks
- [ ] Check scheduled meetings
- [ ] Process 3-5 inbox items
- [ ] Update task statuses

### Weekly Routine  
- [ ] Complete weekly review
- [ ] Archive completed projects/tasks
- [ ] Update area overviews
- [ ] Plan next week

### Monthly Routine
- [ ] Review all projects
- [ ] Clean up knowledge base
- [ ] Update people profiles
- [ ] Analyze metrics

---

## 🔗 Quick Links

### Core Areas
- [[01_projects/00_index|📁 Projects]]
- [[02_areas/00_index|🎯 Areas]]
- [[00_knowledge/00_index|🧠 Knowledge]]
- [[03_resources/00_index|📚 Resources]]
- [[04_archive/00_index|📦 Archive]]

### Templates
- [[99_obsidian/01_templates/01_projects/project_template|New Project]]
- [[99_obsidian/01_templates/02_areas/01_periodicNotes/weekly_review_template|Weekly Review]]
- [[99_obsidian/01_templates/02_areas/meetings_default|Meeting Notes]]
- [[99_obsidian/01_templates/00_knowledge/knowledge_inbox_default|Capture Idea]]

### Utilities
- [[99_obsidian/01_templates/04_archive/archive_note|Archive Note]]
- [[99_obsidian/01_templates/04_archive/archive_project|Archive Project]]

---

## 💡 Tips & Best Practices

1. **Start your day** by reviewing this dashboard
2. **Update task statuses** as you work
3. **Capture ideas** immediately to inbox
4. **Weekly reviews** are essential for staying on track
5. **Archive regularly** to keep vault clean
6. **Link generously** to build knowledge network

---

**Dashboard Version**: 1.0  
**Created**: <%= tp.date.now('YYYY-MM-DD') %>
