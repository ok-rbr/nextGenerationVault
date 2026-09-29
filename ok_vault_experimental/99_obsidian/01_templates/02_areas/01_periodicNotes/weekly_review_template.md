<%*
const lib = tp.user.lib || {};

// Calculate week dates
const today = new Date();
const weekNum = Math.ceil((today - new Date(today.getFullYear(), 0, 1)) / (7 * 24 * 60 * 60 * 1000));
const year = today.getFullYear();
const weekId = `${year}-W${String(weekNum).padStart(2, '0')}`;

// Week start and end (Monday to Sunday)
const dayOfWeek = today.getDay() || 7; // Convert Sunday (0) to 7
const monday = new Date(today);
monday.setDate(today.getDate() - dayOfWeek + 1);
const sunday = new Date(monday);
sunday.setDate(monday.getDate() + 6);

const formatDate = (d) => d.toISOString().split('T')[0];
const weekStart = formatDate(monday);
const weekEnd = formatDate(sunday);

const title = `weekly_review_${weekId.toLowerCase().replace('-', '_')}`;

await tp.file.rename(title);
await tp.file.move(`/02_areas/03_weekly/${title}`);
-%>---
title: "weekly review - <%= weekId %>"
id: "<%= lib.nowId ? lib.nowId() : tp.date.now('YYYYMMDD_HHmm') %>"
created: "<%= lib.nowIso ? lib.nowIso() : tp.date.now('YYYY-MM-DD HH:mm') %>"
lang: "en"
tags:
  - "weekly"
  - "review"
  - "periodic"
category: "weekly"
status: "active"
week: "<%= weekId %>"
week_start: "<%= weekStart %>"
week_end: "<%= weekEnd %>"
---

# Weekly Review - <%= weekId %>

**Week**: <%= weekStart %> to <%= weekEnd %>

---

## 📊 Week Overview

### Meetings This Week

```dataview
TABLE thema as "Topic", attendees as "Attendees", date as "Date"
FROM #meeting
WHERE date >= "<%= weekStart.replace(/-/g, '') %>" AND date <= "<%= weekEnd.replace(/-/g, '') %>"
SORT date ASC
```

### Tasks Completed

```dataview
TABLE project as "Project", priority as "Priority", file.link as "Task"
FROM #task
WHERE status = "completed" OR status = "done"
  AND file.ctime >= date("<%= weekStart %>")
  AND file.ctime <= date("<%= weekEnd %>")
SORT priority DESC, file.ctime DESC
```

### Active Projects Status

```dataview
TABLE status, client, due
FROM "01_projects"
WHERE category = "project" AND status != "archived"
SORT status ASC, due ASC
```

---

## 🎯 Week Reflection

### Achievements
> What did I accomplish this week?

- 
- 
- 

### Challenges
> What obstacles did I face?

- 
- 

### Learnings
> What did I learn this week?

- 
- 

**Knowledge Transfer**: 
- [ ] Create permanent notes for key learnings in [[00_knowledge/00_index|Knowledge Base]]

---

## 📝 Areas Review

### Work

**Key Activities**:
- 

**Progress**:
- 

**Blockers**:
- 

### Personal

**Highlights**:
- 

**Growth**:
- 

---

## 🔄 Task Management

### Overdue Tasks

```dataview
TABLE project, priority, due
FROM #task
WHERE status = "active" AND due < "<%= weekStart %>"
SORT priority DESC, due ASC
```

### Pending Tasks

```dataview
TABLE project, priority, related
FROM #task
WHERE status = "pending"
SORT priority DESC
LIMIT 10
```

### Action Items

- [ ] Review and prioritize overdue tasks
- [ ] Close completed tasks
- [ ] Archive old projects
- [ ] Update project statuses

---

## 🎯 Next Week Goals

### Week <%= weekNum + 1 %> Priorities

1. **Priority 1**: 
2. **Priority 2**: 
3. **Priority 3**: 

### Tasks to Schedule

- [ ] 
- [ ] 
- [ ] 

### Meetings to Prepare

- [ ] 
- [ ] 

---

## 📊 Metrics & Stats

### Task Completion Rate

```dataview
TABLE length(rows) as "Count"
FROM #task
WHERE file.ctime >= date("<%= weekStart %>") AND file.ctime <= date("<%= weekEnd %>")
GROUP BY status
```

### Meeting Count

**Total meetings this week**: (See table above)

### Knowledge Created

```dataview
LIST
FROM "00_knowledge"
WHERE file.ctime >= date("<%= weekStart %>") AND file.ctime <= date("<%= weekEnd %>")
LIMIT 10
```

---

## 💡 Insights & Actions

### Process Improvements
> What can I optimize next week?

- 

### Focus Areas
> What needs more attention?

- 

### Procrastination Check
> What am I avoiding? Why?

- 

**Action**: 
- [ ] Address procrastination items

---

## 📋 Checklist

- [ ] Reviewed all meetings from this week
- [ ] Updated task statuses
- [ ] Identified key learnings
- [ ] Set goals for next week
- [ ] Archived completed items
- [ ] Reviewed procrastination items

---

## Quick Links

- [[02_areas/05_overview/dashboard|Main Dashboard]]
- [[01_projects/00_index|Projects Index]]
- [[00_knowledge/00_index|Knowledge Base]]
- Previous week: [[weekly_review_<%= year %>_w<%= String(weekNum - 1).padStart(2, '0') %>]]
- Next week: [[weekly_review_<%= year %>_w<%= String(weekNum + 1).padStart(2, '0') %>]]
