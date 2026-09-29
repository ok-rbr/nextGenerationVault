---
title: waechter-von-farron-Daily
created: 20260305 - 0942
tags:
  - daily
  - dark-souls
  - ashen
  - farron
  - obsidian
  - ember
  - ds-farron-07
category: daily
attendees: Plo Koon, Rumo
date: "20260305"
---

# [[20260305_waechter-von-farron-Daily]]

## Agenda

- Plo Koon
- Rumo
- rapha

---

## Log

- Plo Koon
- Rumo
- Raphael

---

### things i want to say

```dataviewjs
dv.taskList(
    dv.pages('#waechter-von-farronDaily').file.tasks

        .where(t => !t.completed && t.text.includes('#waechter-von-farronDaily'))
);
```

### things i said today

```dataviewjs
dv.taskList(
    dv.pages('#waechter-von-farronDaily').file.tasks
        .where(t =>
            t.text.includes('#waechter-von-farronDaily') &&
             t.text.includes(20260305)
        )
);
```
