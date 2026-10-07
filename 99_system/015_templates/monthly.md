---
title: "{{ title }}"
aliases:
  - "{{ title }}"
id: "{{ id }}"
created: "{{ created }}"
updated: "{{ created }}"
lang: "en"
category: "monthly"
tags:
  - "monthly"
  - "review"
month: "{{ month }}"
month_start: "{{ month_start }}"
month_end: "{{ month_end }}"
---

# {{ title }}

{{ month_start }} to {{ month_end }} · [[{{ previous }}|previous month]] ·
[[{{ next }}|next month]]

## Month overview

### Weekly reviews

```dataview
LIST
FROM #weekly AND #review
WHERE week_end >= "{{ month_start }}" AND week_start <= "{{ month_end }}"
SORT week ASC
```

### Tasks closed

```dataview
TABLE project, priority
FROM #task
WHERE (status = "done" OR status = "completed")
  AND file.mtime >= date("{{ month_start }}")
  AND file.mtime <= date("{{ month_end }}") + dur(1 day)
SORT project ASC
```

### Knowledge created

```dataview
LIST
FROM "00_knowledge"
WHERE file.ctime >= date("{{ month_start }}")
  AND file.ctime <= date("{{ month_end }}") + dur(1 day)
SORT file.ctime ASC
```

## Reflection

### Highlights

-

### What did not work

-

### Learnings

-

## Areas

### Work

-

### Personal

-

### Health

-

## Next month

1.
2.
3.

## Checklist

- [ ] Weekly reviews of this month read
- [ ] Projects without progress archived or re-planned
- [ ] Goals for next month set
