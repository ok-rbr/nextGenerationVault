<%*
const lib = tp.user.lib || {};

// Prompt for meeting details
const meetingTitle = await tp.system.prompt("Meeting title/topic:");
const meetingSlug = lib.slugify ? lib.slugify(meetingTitle) : meetingTitle.toLowerCase().replace(/\s+/g, '_');

// Get date
const dateId = tp.date.now("YYYYMMDD");
const dateDisplay = tp.date.now("YYYY-MM-DD");

// Prompt for participants
const participants = await tp.system.prompt("Participants (comma-separated):");
const participantsList = participants.split(',').map(p => p.trim());

// Prompt for project/area
const projectArea = await tp.system.prompt("Related Project/Area (optional):");

const filename = `${dateId}_${meetingSlug}`;

await tp.file.rename(filename);
await tp.file.move(`/02_areas/04_meetings/${filename}`);
-%>---
title: "meeting - <%= meetingTitle %>"
id: "<%= lib.nowId ? lib.nowId() : tp.date.now('YYYYMMDD_HHmm') %>"
created: "<%= lib.nowIso ? lib.nowIso() : tp.date.now('YYYY-MM-DD HH:mm') %>"
lang: "en"
tags:
  - "meeting"
<%_ if (projectArea) { -%>
  - "project/<%= lib.slugify ? lib.slugify(projectArea) : projectArea.toLowerCase().replace(/\s+/g, '_') %>"
<%_ } -%>
category: "meeting"
status: "active"
date: "<%= dateId %>"
thema: "<%= meetingTitle %>"
attendees:
<%_ for (const participant of participantsList) { -%>
  - "<%= participant %>"
<%_ } -%>
<%_ if (projectArea) { -%>
project: "<%= projectArea %>"
<%_ } -%>
meeting_type: ""
duration: ""
---

# 🤝 Meeting - <%= meetingTitle %>

**Date**: <%= dateDisplay %>  
**Time**: 
**Duration**: 
**Type**: ☐ Planning ☐ Review ☐ Sync ☐ Decision ☐ Brainstorming ☐ 1-on-1  
<%_ if (projectArea) { -%>
**Project/Area**: [[<%= projectArea %>]]
<%_ } -%>

---

## 👥 Participants

<%_ for (const participant of participantsList) { -%>
- [[<%= participant %>]]
<%_ } -%>

**Role Distribution**:
- **Facilitator**: 
- **Note-taker**: 
- **Timekeeper**: 
- **Decision maker**: 

---

## 📋 Meeting Context

### Purpose
> Why are we meeting?

### Expected Outcomes
> What should we achieve by the end?

1. 
2. 
3. 

---

## 📝 Agenda

### Pre-Meeting Preparation
- [ ] Agenda shared with participants
- [ ] Background materials sent
- [ ] Previous action items reviewed

### Discussion Topics

#### 1. [Topic 1]
**Time Allocated**: [X minutes]  
**Owner**: 

**Key Points**:
- 
- 

**Questions to Address**:
- 
- 

---

#### 2. [Topic 2]
**Time Allocated**: [X minutes]  
**Owner**: 

**Key Points**:
- 
- 

**Questions to Address**:
- 
- 

---

#### 3. [Topic 3]
**Time Allocated**: [X minutes]  
**Owner**: 

**Key Points**:
- 
- 

---

## 🗣️ Discussion Log

### Opening (X:XX)
- 

### Topic 1 Discussion (X:XX)
- 
- 
- 

**Key Insights**:
- 

**Decisions Made**:
- 

---

### Topic 2 Discussion (X:XX)
- 
- 

**Key Insights**:
- 

**Decisions Made**:
- 

---

### Topic 3 Discussion (X:XX)
- 
- 

**Key Insights**:
- 

---

### Open Discussion (X:XX)
> Any other business or topics that came up

- 

---

## 💡 Key Takeaways

### Main Insights
1. 
2. 
3. 

### Decisions Made

| Decision | Rationale | Impact | Owner |
|----------|-----------|--------|-------|
| | | | |
| | | | |

### Blockers Identified
- **Blocker**: 
  - **Impact**: 
  - **Action**: 

---

## ✅ Action Items

### Immediate Actions (This Week)

- [ ] **[Action 1]** 
  - **Owner**: [[person]]
  - **Due**: <%= tp.date.now("YYYY-MM-DD", 7) %>
  - **Related Task**: 

- [ ] **[Action 2]** 
  - **Owner**: [[person]]
  - **Due**: <%= tp.date.now("YYYY-MM-DD", 7) %>
  - **Related Task**: 

### Short-term Actions (This Month)

- [ ] **[Action 3]** 
  - **Owner**: [[person]]
  - **Due**: 
  - **Related Task**: 

### Long-term Actions (This Quarter)

- [ ] **[Action 4]** 
  - **Owner**: [[person]]
  - **Due**: 
  - **Related Task**: 

---

## 🔄 Follow-Up Requirements

### Next Meeting
- **Date**: 
- **Purpose**: 
- **Prepare**: 

### Communication Needed
- [ ] Share meeting notes with participants
- [ ] Update project status
- [ ] Inform stakeholders
- [ ] Create tasks from action items

### Documentation
- [ ] Update project documentation
- [ ] Update [[03_resources/]] with decisions
- [ ] Create knowledge notes if applicable

---

## 📊 Meeting Effectiveness

### Outcomes Achieved
- ☐ All agenda items covered
- ☐ Clear decisions made
- ☐ Action items assigned
- ☐ Next steps defined

### Meeting Quality
**Rating**: ☐ Excellent ☐ Good ☐ Average ☐ Poor

**What Worked Well**:
- 

**What Could Improve**:
- 

### Time Management
**Planned Duration**: 
**Actual Duration**: 
**On Time**: ☐ Yes ☐ No

---

## 🔗 Related Information

### Related Meetings
> Previous or upcoming related meetings

```dataview
LIST
FROM #meeting
WHERE contains(thema, "<%= meetingTitle %>") OR contains(project, "<%= projectArea %>")
  AND file.name != this.file.name
SORT date DESC
LIMIT 5
```

### Related Tasks
> Tasks created or discussed in this meeting

```dataview
LIST
FROM #task
WHERE contains(file.outlinks, this.file.link)
SORT created DESC
```

### Related Documents
- 
- 

---

## 💬 Participant Notes

### [Participant 1] Notes
> Their specific perspective or concerns

### [Participant 2] Notes
> Their specific perspective or concerns

---

## 📎 Attachments & References

### Materials Shared
- 
- 

### External Links
- 
- 

---

## 🎯 Success Criteria

**Meeting was successful if**:
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

**Status**: ☐ Success ☐ Partial Success ☐ Needs Follow-up

---

## 📝 Post-Meeting Actions

- [ ] Notes distributed to all participants
- [ ] Action items created as tasks
- [ ] Calendar updated with next meeting
- [ ] Stakeholders informed of decisions
- [ ] Documentation updated
- [ ] Meeting recorded in [[02_areas/05_overview/dashboard|Dashboard]]

---

## 💡 Learnings to Extract

**Knowledge to capture**:
- [ ] Best practices identified
- [ ] Process improvements
- [ ] Technical insights
- [ ] Communication patterns

**Target location**: [[00_knowledge/00_inbox/]]

---

**Meeting Status**: ☐ Scheduled ☐ Completed ☐ Cancelled ☐ Rescheduled  
**Notes Completed**: ☐ Yes ☐ Partial ☐ No  
**Follow-up Required**: ☐ Yes ☐ No
