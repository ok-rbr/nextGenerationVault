---
title: "{{ title }}"
aliases:
  - "{{ title }}"
id: "{{ id }}"
created: "{{ created }}"
updated: "{{ created }}"
lang: "en"
category: "weekly"
tags:
  - "weekly"
  - "review"
week: "{{ week }}"
week_start: "{{ week_start }}"
week_end: "{{ week_end }}"
---

# {{ title }}

{{ week_start }} to {{ week_end }} · [[{{ previous }}|previous week]] ·
[[{{ next }}|next week]]

## Week overview

### Daily notes

```dataview
LIST
FROM "02_areas/life/logs/daily"
WHERE date >= "{{ week_start }}" AND date <= "{{ week_end }}"
SORT date ASC
```

### Tasks closed

```dataview
TABLE project, priority
FROM #task
WHERE (status = "done" OR status = "completed")
  AND file.mtime >= date("{{ week_start }}")
  AND file.mtime <= date("{{ week_end }}") + dur(1 day)
SORT priority DESC
```

### Knowledge created

```dataview
LIST
FROM "00_knowledge"
WHERE file.ctime >= date("{{ week_start }}")
  AND file.ctime <= date("{{ week_end }}") + dur(1 day)
SORT file.ctime ASC
```

## Reflection

### Achievements

-

### Challenges

-

### Learnings

-

- [ ] Turn key learnings into permanent notes

## Next week

1.
2.
3.

## Checklist

- [ ] Task statuses updated
- [ ] Overdue tasks rescheduled or dropped
- [ ] Next week's meetings prepared
- [ ] Vault dashboard reviewed: orphans, untagged notes, stale tasks
