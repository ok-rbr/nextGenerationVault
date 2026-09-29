<%*
const lib = tp.user.lib || {};

// Prompt for area name
const areaName = await tp.system.prompt("Area name:");
const areaSlug = lib.slugify ? lib.slugify(areaName) : areaName.toLowerCase().replace(/\s+/g, '_');

const title = `area_dashboard_${areaSlug}`;

await tp.file.rename(title);
await tp.file.move(`/02_areas/05_overview/${title}`);
-%>---
title: "area dashboard - <%= areaName %>"
id: "<%= lib.nowId ? lib.nowId() : tp.date.now('YYYYMMDD_HHmm') %>"
created: "<%= lib.nowIso ? lib.nowIso() : tp.date.now('YYYY-MM-DD HH:mm') %>"
lang: "en"
tags:
  - "area"
  - "dashboard"
  - "area/<%= areaSlug %>"
category: "area"
status: "active"
area: "<%= areaName %>"
---

# 🎯 Area Dashboard - <%= areaName %>

**Area**: <%= areaName %>  
**Last Updated**: <%= tp.date.now('YYYY-MM-DD HH:mm') %>

---

## 📊 Area Overview

### Description
> What is this area about?

### Responsibilities
> What am I responsible for in this area?

- 
- 
- 

### Goals & Objectives

#### Current Quarter Goals
1. **Goal 1**: 
   - **Target Date**: 
   - **Progress**: ☐ Not Started ☐ In Progress ☐ Completed
   
2. **Goal 2**: 
   - **Target Date**: 
   - **Progress**: ☐ Not Started ☐ In Progress ☐ Completed

3. **Goal 3**: 
   - **Target Date**: 
   - **Progress**: ☐ Not Started ☐ In Progress ☐ Completed

#### Long-term Vision
> Where do I want this area to be in 1 year?

---

## ✅ Active Tasks

### High Priority

```dataview
TABLE status, priority, due, file.link as "Task"
FROM #task
WHERE contains(tags, "area/<%= areaSlug %>") AND priority = "high" AND status = "active"
SORT due ASC
```

### All Active Tasks

```dataview
TABLE status, priority, due, file.link as "Task"
FROM #task
WHERE contains(tags, "area/<%= areaSlug %>") AND status = "active"
SORT priority DESC, due ASC
LIMIT 20
```

### Blocked/Pending

```dataview
TABLE status, file.link as "Task", related
FROM #task
WHERE contains(tags, "area/<%= areaSlug %>") 
  AND (status = "blocked" OR status = "pending")
SORT file.ctime DESC
```

---

## 📅 Recent Activity

### This Week's Notes

```dataview
TABLE file.ctime as "Created", tags
FROM "02_areas"
WHERE contains(tags, "area/<%= areaSlug %>")
  AND file.ctime >= date(today) - dur(7 days)
  AND file.name != this.file.name
SORT file.ctime DESC
LIMIT 10
```

### Recent Meetings

```dataview
TABLE date, thema, attendees
FROM #meeting
WHERE contains(tags, "area/<%= areaSlug %>")
  OR contains(thema, "<%= areaName %>")
SORT date DESC
LIMIT 10
```

---

## 📋 Projects in This Area

### Active Projects

```dataview
TABLE status, client, due, file.link as "Project"
FROM "01_projects"
WHERE contains(tags, "area/<%= areaSlug %>") 
  AND (status = "active" OR status = "in-progress")
SORT due ASC
```

### Completed Projects (Last 3 Months)

```dataview
TABLE status, file.ctime as "Completed", file.link as "Project"
FROM "01_projects"
WHERE contains(tags, "area/<%= areaSlug %>")
  AND (status = "completed" OR status = "done")
  AND file.mtime >= date(today) - dur(90 days)
SORT file.mtime DESC
LIMIT 5
```

---

## 🧠 Knowledge & Learnings

### Recent Learnings

```dataview
LIST
FROM "00_knowledge"
WHERE contains(tags, "area/<%= areaSlug %>") 
  OR contains(source, "<%= areaName %>")
SORT file.ctime DESC
LIMIT 10
```

### Key Concepts

```dataview
TABLE concepts, status, file.link as "Note"
FROM "00_knowledge"
WHERE contains(tags, "area/<%= areaSlug %>")
  AND status = "completed"
SORT file.mtime DESC
LIMIT 10
```

---

## 👥 People & Relationships

### Key People in This Area

```dataview
TABLE role, company, file.mtime as "Last Updated"
FROM "02_areas/07_people" OR "03_resources/02_people"
WHERE contains(tags, "area/<%= areaSlug %>")
SORT file.mtime DESC
LIMIT 10
```

### 1-on-1 Meetings

```dataview
TABLE date, attendees, thema
FROM #meeting
WHERE contains(tags, "area/<%= areaSlug %>")
  AND (contains(thema, "1:1") OR contains(thema, "1-on-1"))
SORT date DESC
LIMIT 5
```

---

## 📊 Metrics & Progress

### Task Statistics

```dataview
TABLE length(rows) as "Count"
FROM #task
WHERE contains(tags, "area/<%= areaSlug %>")
GROUP BY status
SORT length(rows) DESC
```

### Activity Over Time

**Tasks Created This Month**:
```dataview
TABLE length(rows) as "Count"
FROM #task
WHERE contains(tags, "area/<%= areaSlug %>")
  AND file.ctime >= date(today) - dur(30 days)
GROUP BY date(file.ctime).weekyear + "-W" + string(date(file.ctime).week)
SORT file.ctime DESC
```

---

## 🔄 Routines & Habits

### Daily Routine
> What should I do daily for this area?

- [ ] 
- [ ] 

### Weekly Routine
> What should I do weekly?

- [ ] 
- [ ] 

### Monthly Routine
> What should I do monthly?

- [ ] 
- [ ] 

---

## ⚠️ Attention Required

### Overdue Items

```dataview
TABLE due, priority, file.link as "Task"
FROM #task
WHERE contains(tags, "area/<%= areaSlug %>")
  AND status = "active"
  AND due < date(today)
SORT due ASC
```

### Long-Running Tasks

```dataview
TABLE file.ctime as "Started", status, file.link as "Task"
FROM #task
WHERE contains(tags, "area/<%= areaSlug %>")
  AND status = "active"
  AND file.ctime < date(today) - dur(30 days)
SORT file.ctime ASC
```

### Items to Review

- [ ] Update area goals
- [ ] Review long-running tasks
- [ ] Check if any projects should be archived
- [ ] Update routines if needed

---

## 📚 Resources

### Relevant Tools & Methods

```dataview
TABLE resource_type, rating, last_used
FROM "03_resources"
WHERE contains(tags, "area/<%= areaSlug %>")
SORT rating DESC, last_used DESC
```

### Documentation

- 
- 

---

## 🎯 Current Focus

### This Week
1. 
2. 
3. 

### This Month
1. 
2. 
3. 

### This Quarter
1. 
2. 
3. 

---

## 💡 Ideas & Improvements

### Process Improvements
> Ideas to make this area more efficient

- 
- 

### Future Projects
> Potential projects for this area

- 
- 

### Skills to Develop
> What skills would help in this area?

- 
- 

---

## 🔗 Quick Links

### Core Documents
- [[01_projects/00_index|Projects]]
- [[00_knowledge/00_index|Knowledge Base]]
- [[02_areas/05_overview/dashboard|Main Dashboard]]

### Area-Specific
- 
- 

### Templates
- [[99_obsidian/01_templates/02_areas/meetings_enhanced|New Meeting]]
- [[99_obsidian/01_templates/00_knowledge/knowledge_inbox_default|Capture Idea]]

---

## 📝 Review Checklist

### Weekly Review
- [ ] Review active tasks
- [ ] Update task statuses
- [ ] Check overdue items
- [ ] Review this week's meetings
- [ ] Update current focus

### Monthly Review
- [ ] Review area goals
- [ ] Check progress on quarterly objectives
- [ ] Archive completed items
- [ ] Update metrics
- [ ] Identify improvements

### Quarterly Review
- [ ] Assess goal achievement
- [ ] Set new quarterly goals
- [ ] Review and update routines
- [ ] Archive old projects
- [ ] Update area description

---

## 📈 Health Indicators

**Area Health**: ☐ Thriving ☐ Good ☐ Needs Attention ☐ Critical

**Indicators**:
- **Task Completion Rate**: 
- **Overdue Tasks**: 
- **Active Projects**: 
- **Recent Activity**: 

**Notes**: 

---

**Next Review**: 
**Review Frequency**: ☐ Weekly ☐ Bi-weekly ☐ Monthly

---

**Dashboard Version**: 1.0  
**Created**: <%= tp.date.now('YYYY-MM-DD') %>
