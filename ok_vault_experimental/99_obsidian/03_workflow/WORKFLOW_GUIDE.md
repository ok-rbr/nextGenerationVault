# Vault Workflow Guide

Complete guide for using the OK Vault workflows, automation scripts, and templates to maintain an efficient PARA + Zettelkasten system.

---

## 📋 Table of Contents

1. [Daily Workflow](#daily-workflow)
2. [Weekly Workflow](#weekly-workflow)
3. [Monthly Workflow](#monthly-workflow)
4. [Project Workflows](#project-workflows)
5. [Knowledge Management Workflow](#knowledge-management-workflow)
6. [Meeting Management](#meeting-management)
7. [Task Management](#task-management)
8. [Automation & Scripts](#automation--scripts)
9. [Best Practices](#best-practices)

---

## 🌅 Daily Workflow

### Morning Routine (10-15 minutes)

**1. Create/Open Daily Note**

Using automation:
```bash
cd /path/to/vault
./99_obsidian/03_workflow/scripts/create_daily_note.sh
```

Or use Obsidian template:
- Open template: `02_areas/01_periodicNotes/daily_default.md`
- Templater will auto-create with today's date

**2. Review Dashboard**

Open: [[02_areas/05_overview/dashboard|Main Dashboard]]

Check:
- ✅ Priority tasks for today
- 📅 Scheduled meetings
- ⚠️ Overdue items
- 🔔 Alerts and reminders

**3. Set Daily Priorities**

In your daily note:
```markdown
### Morning Priorities
1. [Most important task]
2. [Second priority]
3. [Third priority]
```

**4. Review Active Projects**

Quick scan of:
```dataview
TABLE status, due
FROM "01_projects"
WHERE status = "active"
SORT due ASC
LIMIT 5
```

---

### During the Day

**Capture Ideas Immediately**

When inspiration strikes:
1. Create inbox note: Use template `00_knowledge/knowledge_inbox_default.md`
2. Quick capture with minimal structure
3. Add `priority: high/medium/low`
4. Process during weekly review

**Update Task Statuses**

As you complete tasks:
- Update status in task file
- Add progression log entry
- Mark in daily note

**Take Meeting Notes**

Use enhanced meeting template:
- `02_areas/meetings_enhanced.md`
- Document decisions and action items
- Link to related projects/areas

---

### Evening Routine (5-10 minutes)

**1. Update Daily Note**

Add to your daily note:
```markdown
### Achievements
- [What you accomplished]

### Learnings
- [What you learned]

### Tomorrow
- [ ] [First priority for tomorrow]
```

**2. Close Completed Tasks**

```bash
# For bulk updates (optional)
./99_obsidian/03_workflow/scripts/update_task_status.sh \
  01_projects/my_project active completed
```

**3. Prepare Tomorrow**

- Check tomorrow's meetings
- Set 3 priorities for tomorrow
- Move unfinished items to tomorrow's list

---

## 📊 Weekly Workflow

### Friday Afternoon or Sunday Evening (30-45 minutes)

**1. Create Weekly Review**

Use template: `02_areas/01_periodicNotes/weekly_review_template.md`

This template automatically aggregates:
- ✅ Completed tasks this week
- 📅 All meetings
- 📊 Task statistics
- 🧠 New knowledge notes

**2. Review Section by Section**

**Meetings**:
- Review all meeting notes from the week
- Ensure all action items are captured as tasks
- Follow up on pending decisions

**Tasks**:
- Mark completed tasks as done
- Review overdue tasks (reschedule or delegate)
- Update priorities for next week

**Projects**:
- Check project statuses
- Identify blockers
- Update project documentation

**Learnings**:
- Identify 2-3 key learnings from the week
- Create permanent notes for important insights
- Link to existing knowledge

**3. Archive Completed Items**

Preview what can be archived:
```bash
./99_obsidian/03_workflow/scripts/archive_inactive.sh --dry-run --older-than 60
```

If satisfied, execute:
```bash
./99_obsidian/03_workflow/scripts/archive_inactive.sh --older-than 60
```

**4. Set Next Week Goals**

In weekly review:
```markdown
### Week X Priorities
1. [Priority 1]
2. [Priority 2]
3. [Priority 3]
```

**5. Plan Monday Morning**

- Schedule important meetings
- Block time for priority tasks
- Prepare materials needed

---

## 📅 Monthly Workflow

### Last Day of Month (1-2 hours)

**1. Review All Areas**

For each area (Work, Personal, Health, etc.):
- Open area dashboard
- Review goals and progress
- Update metrics
- Identify improvements

**2. Project Portfolio Review**

Check all projects:
```dataview
TABLE status, client, due
FROM "01_projects"
WHERE status != "archived"
SORT status ASC, due ASC
```

Actions:
- Archive completed projects (>30 days old)
- Review stuck projects (no activity >14 days)
- Update project scopes if needed
- Reprioritize project list

**3. Knowledge Base Maintenance**

**Process Inbox**:
- Goal: Empty or nearly empty inbox
- Convert high-priority items to permanent notes
- Archive or delete low-value items

**Consolidate Notes**:
- Find related atomic notes
- Combine into permanent notes
- Update links and references

**4. Clean Up**

Run comprehensive archive:
```bash
# Archive completed items older than 90 days
./99_obsidian/03_workflow/scripts/archive_inactive.sh --older-than 90

# Archive done items
./99_obsidian/03_workflow/scripts/archive_inactive.sh --status "done" --older-than 60
```

**5. Review Metrics**

Check dashboard statistics:
- Task completion rate
- Project velocity
- Knowledge creation rate
- Meeting frequency

**6. Set Next Month Goals**

Update area dashboards with:
- Monthly objectives
- Key results
- Focus areas

---

## 🎯 Project Workflows

### Starting a New Project

**1. Create Project Folder Structure**

```
01_projects/
└── project_name/
    ├── daily/
    ├── weekly/
    ├── meetings/
    ├── tasks/
    ├── notes/
    └── 00_index.md
```

**2. Create Project Overview**

Use template: `01_projects/project_template.md`

Fill out:
- Project description
- Goals and objectives
- Timeline and milestones
- Stakeholders
- Success criteria

**3. Create Initial Tasks**

Use template: `01_projects/project_name/kunde-project-task.md`

For each major deliverable:
- Create task with clear scope
- Set priority and due date
- Link to project overview

**4. Create Kanban Board** (Optional)

Use template: `02_areas/00_kanban/kanban_default.md`

Set area to project name for automatic filtering

---

### During Project Execution

**Daily**:
- Update task statuses
- Add project daily notes if significant progress
- Document blockers immediately

**Weekly**:
- Create project weekly note
- Review all project tasks
- Update project overview with progress

**Meetings**:
- Use enhanced meeting template
- Link meeting to project
- Create tasks from action items

---

### Completing a Project

**1. Mark All Tasks Complete**

Bulk update:
```bash
./99_obsidian/03_workflow/scripts/update_task_status.sh \
  01_projects/project_name active completed
```

**2. Extract Learnings**

Use template: `01_projects/project_learning_extraction.md`

Document:
- ✅ What worked well
- ❌ What didn't work
- 💡 Key insights
- 📚 Knowledge to extract
- ⚠️ Mistakes to avoid

**3. Create Permanent Notes**

From learning extraction, create notes in:
- `00_knowledge/03_permanent/` - for established insights
- `00_knowledge/02_atomic/` - for specific concepts

**4. Update Resources**

If new tools/methods were used:
- Create resource entries using `03_resources/resource_database_template.md`
- Document ratings and use cases
- Link to project

**5. Archive Project**

After 30-60 days:
- Use archive template or script
- Move to `04_archive/<YYYYMMDD>/projects/`
- Ensure all learnings are extracted

---

## 🧠 Knowledge Management Workflow

### Capture Phase (Inbox)

**When to Capture**:
- New ideas while working
- Insights from meetings
- Concepts from reading
- Questions to explore

**How to Capture**:

Use template: `00_knowledge/knowledge_inbox_default.md`

Minimal structure:
```markdown
---
priority: high
source: meeting/article/project
status: unprocessed
---

# Quick summary of idea

- Key points
- Why interesting
- Related to: [[other notes]]
```

**Frequency**: Immediately when idea occurs

---

### Process Phase (Atomic Notes)

**When to Process**: Weekly review or dedicated time

**Steps**:

1. Open inbox note
2. Create atomic note: `00_knowledge/knowledge_atomic_default.md`
3. Write in your own words
4. One concept per note
5. Link to related notes
6. Add tags and metadata

**Quality Checklist**:
- [ ] Single, focused concept
- [ ] Written in my own words
- [ ] Linked to related notes
- [ ] Clear and understandable
- [ ] Properly tagged

---

### Connect Phase (Permanent Notes)

**When to Create**: When pattern emerges from multiple atomic notes

**Steps**:

1. Identify related atomic notes
2. Create permanent note: `00_knowledge/knowledge_permanent_default.md`
3. Synthesize information
4. Create structure
5. Link extensively
6. Mark as completed

**Structure**:
```markdown
## Summary
[High-level overview]

## Key Concepts
- Concept 1
- Concept 2

## Details
[In-depth explanation]

## Related Notes
- [[Note 1]]
- [[Note 2]]

## Applications
[Where/how to use this knowledge]
```

---

### Literature Notes

**For Books/Articles**:

Use template: `00_knowledge/knowledge_literature_default.md`

**During Reading**:
- Capture key quotes
- Add page numbers
- Note your reactions
- Link to existing knowledge

**After Reading**:
- Create atomic notes for key concepts
- Update permanent notes with new information
- File literature note as reference

---

## 🤝 Meeting Management

### Before Meeting

**1. Prepare Agenda**

Create meeting note in advance:
- Use template: `02_areas/meetings_enhanced.md`
- Fill out agenda section
- Share with participants

**2. Review Context**

- Previous meetings with same people
- Related project status
- Open action items

**3. Prepare Materials**

- Link relevant documents
- Prepare questions
- Set clear objectives

---

### During Meeting

**1. Take Structured Notes**

Follow template sections:
- Opening and context
- Discussion per topic
- Key insights per topic
- Decisions made
- Action items

**2. Capture Action Items**

For each action:
```markdown
- [ ] **[Action]**
  - **Owner**: [[person]]
  - **Due**: YYYY-MM-DD
  - **Related Task**: [[task_note]]
```

**3. Note Key Decisions**

Use decision table:
| Decision | Rationale | Impact | Owner |
|----------|-----------|--------|-------|
| ... | ... | ... | ... |

---

### After Meeting

**1. Complete Meeting Notes** (Within 24 hours)

- Fill in all sections
- Add any missing context
- Clean up log entries

**2. Create Tasks from Action Items**

For each action item:
- Create task note if needed
- Link to meeting note
- Set status and priority

**3. Distribute Notes**

- [ ] Share with participants
- [ ] Update project status
- [ ] Inform stakeholders

**4. Extract Learnings** (if applicable)

- Identify insights worth capturing
- Create inbox notes for complex topics
- Link to knowledge base

---

## ✅ Task Management

### Task Lifecycle

```
inbox → active → done
           ↓
        pending (waiting for input)
           ↓
        blocked (cannot proceed)
```

### Creating Tasks

**From Templates**:
- Project tasks: `01_projects/project_name/kunde-project-task.md`
- Area tasks: Create with `category: "task"` and area tags

**Essential Fields**:
```yaml
---
category: "task"
status: "active"
priority: "high/medium/low"
due: "YYYY-MM-DD"
project: "project_name"
related: []
---
```

---

### Managing Tasks

**Daily**:
- Review priority tasks in dashboard
- Update status as work progresses
- Add progression log entries

**Weekly**:
- Review all active tasks
- Reschedule or close overdue tasks
- Update priorities

**Bulk Operations**:
```bash
# Complete all active tasks in project
./99_obsidian/03_workflow/scripts/update_task_status.sh \
  01_projects/my_project active completed

# Unblock pending tasks
./99_obsidian/03_workflow/scripts/update_task_status.sh \
  01_projects/my_project pending active
```

---

### Progression Logs

Add to task notes:
```markdown
## Progression Log

**YYYY-MM-DD HH:mm**: Started task, researching approach
**YYYY-MM-DD HH:mm**: Completed design phase
**YYYY-MM-DD HH:mm**: Blocked by external dependency
**YYYY-MM-DD HH:mm**: Unblocked, continuing implementation
**YYYY-MM-DD HH:mm**: Completed and ready for review
```

---

## 🤖 Automation & Scripts

### Daily Automation

**Morning Script**:
```bash
#!/bin/bash
# morning_routine.sh

cd /path/to/vault

# Create daily note
./99_obsidian/03_workflow/scripts/create_daily_note.sh

# Open dashboard (if using Obsidian CLI)
obsidian "obsidian://open?vault=VaultName&file=02_areas/05_overview/dashboard"
```

**Add to crontab** (optional):
```cron
# Run at 8 AM on weekdays
0 8 * * 1-5 /path/to/vault/morning_routine.sh
```

---

### Weekly Automation

**Weekly Archive Script**:
```bash
#!/bin/bash
# weekly_archive.sh

cd /path/to/vault

echo "Preview of items to archive:"
./99_obsidian/03_workflow/scripts/archive_inactive.sh --dry-run --older-than 60

read -p "Proceed with archive? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./99_obsidian/03_workflow/scripts/archive_inactive.sh --older-than 60
    echo "Archive complete!"
fi
```

---

### Integration with Git

**Auto-commit Script** (optional):
```bash
#!/bin/bash
# auto_commit.sh

cd /path/to/vault

# Add all changes
git add .

# Commit with timestamp
git commit -m "Auto-commit: $(date '+%Y-%m-%d %H:%M')"

# Push to remote (optional)
git push
```

---

## 💡 Best Practices

### General Principles

**1. Incremental Improvement**
- Start simple, add complexity gradually
- Don't try to be perfect from day 1
- Adjust workflows based on what works

**2. Consistent Routines**
- Daily review (morning)
- Weekly review (Friday/Sunday)
- Monthly cleanup
- Quarterly planning

**3. Capture Everything**
- Better to over-capture than forget
- Process during reviews
- Delete low-value items guilt-free

**4. Link Generously**
- Connect related notes
- Build knowledge network
- Use Dataview queries to find connections

---

### PARA Method Application

**Projects** (01_projects/):
- Has clear end date
- Has specific deliverable
- Active work happening

**Areas** (02_areas/):
- Ongoing responsibilities
- No end date
- Standards to maintain

**Resources** (03_resources/):
- Reference material
- Tools and methods
- Reusable templates

**Archive** (04_archive/):
- Completed projects (after cooling off period)
- Inactive notes
- Historical reference

---

### Zettelkasten Principles

**1. One Idea Per Note**
- Atomic notes contain single concept
- Easier to link and reuse
- Clearer thinking

**2. Write in Your Own Words**
- Ensures understanding
- Makes it easier to recall
- Develops your voice

**3. Link Extensively**
- Create connections
- Build knowledge network
- Enable serendipitous discoveries

**4. Progressive Summarization**
- Inbox → Atomic → Permanent
- Each stage adds structure
- Knowledge compounds

---

### Meeting Best Practices

**Before**:
- [ ] Clear agenda prepared
- [ ] Context reviewed
- [ ] Objectives defined

**During**:
- [ ] Structured notes
- [ ] Capture decisions
- [ ] Note action items

**After**:
- [ ] Complete notes within 24h
- [ ] Create tasks
- [ ] Distribute to participants
- [ ] Extract learnings

---

### Task Management Best Practices

**Prioritization**:
- Use Eisenhower Matrix (urgent/important)
- Limit active tasks (3-5 per day)
- Focus on project impact

**Status Updates**:
- Update daily
- Be honest about blocks
- Document progression

**Bulk Operations**:
- Use scripts for efficiency
- Always dry-run first
- Verify results

---

### Knowledge Management Best Practices

**Capture**:
- Do it immediately
- Minimal structure
- Include source

**Process**:
- Weekly minimum
- Write in own words
- One concept per note

**Connect**:
- Link to related notes
- Update existing notes
- Build knowledge graph

**Review**:
- Monthly cleanup
- Consolidate related notes
- Archive outdated information

---

## 🔗 Quick Reference

### Essential Templates

| Template | Use Case | Location |
|----------|----------|----------|
| Daily Note | Start of day | `02_areas/01_periodicNotes/daily_default.md` |
| Weekly Review | End of week | `02_areas/01_periodicNotes/weekly_review_template.md` |
| Meeting | Before meeting | `02_areas/meetings_enhanced.md` |
| Project | New project | `01_projects/project_template.md` |
| Task | New task | `01_projects/project_name/kunde-project-task.md` |
| Learning | After project | `01_projects/project_learning_extraction.md` |
| Resource | New tool/method | `03_resources/resource_database_template.md` |
| Dashboard | Daily overview | `02_areas/05_overview/dashboard_template.md` |

### Essential Scripts

| Script | Use Case | Command |
|--------|----------|---------|
| Daily Note | Create daily note | `./create_daily_note.sh` |
| Archive | Bulk archive | `./archive_inactive.sh --dry-run` |
| Task Update | Bulk status change | `./update_task_status.sh <project> <old> <new>` |

### Essential Queries

**Today's Tasks**:
```dataview
TABLE status, priority, project
FROM #task
WHERE due = date(today)
SORT priority DESC
```

**Active Projects**:
```dataview
TABLE status, due, client
FROM "01_projects"
WHERE status = "active"
SORT due ASC
```

**Unprocessed Inbox**:
```dataview
TABLE priority, source, file.ctime
FROM "00_knowledge/00_inbox"
WHERE status = "unprocessed"
SORT priority DESC, file.ctime ASC
```

---

## 📚 Further Reading

- [[README|Main README]]
- [[99_obsidian/02_config/INDEX|Template Index]]
- [[OVERVIEW|Detailed Overview]]
- [[99_obsidian/03_workflow/scripts/README|Scripts Documentation]]
- [[99_obsidian/01_templates/_scripts/README|Library Documentation]]

---

**Version**: 1.0  
**Last Updated**: 2025-11-11  
**Maintained by**: Vault Workflow Team
