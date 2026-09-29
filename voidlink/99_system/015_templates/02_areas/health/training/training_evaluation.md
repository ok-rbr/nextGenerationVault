---
title: "{{ title }}"
aliases:
  - "{{ title }}"
id: "{{ id }}"
created: "{{ created }}"
lang: "en"
category: "area"
type: "training_evaluation"
location: "02_areas/health/training/evaluations"
tags:
  - "training"
  - "evaluation"
period_start: "{{ period_start }}"
period_end: "{{ period_end }}"
routine_ref: "" # optional: evaluate one routine
focus_exercises: [] # exercise_ref values this evaluation looks at
---

# {{ title }}

{{ period_start }} to {{ period_end }}. Volume, frequency and bests are computed
by the queries below from the workouts' `entries`; they are never typed into
frontmatter.

## Workouts

```dataview
TABLE WITHOUT ID
  file.link AS Workout,
  date AS Date,
  routine_ref AS Routine,
  round(duration / 60) AS "Minutes",
  rpe AS RPE
FROM #training AND -"99_system"
WHERE type = "workout" AND status = "completed"
  AND date >= this.period_start AND date <= this.period_end
  AND (!this.routine_ref OR routine_ref = this.routine_ref)
SORT date ASC
```

## Volume per exercise

Sets and reps count done sets only. Volume is reps × external load, so it stays
0 for pure bodyweight work; compare reps and holds there.

```dataview
TABLE WITHOUT ID
  key AS Exercise,
  length(rows) AS Sets,
  sum(map(rows, (r) => default(r.s.reps, 0))) AS Reps,
  sum(map(rows, (r) => default(r.s.duration, 0))) AS "Hold (s)",
  max(map(rows, (r) => default(r.s.weight, 0))) AS "Top load",
  sum(map(rows, (r) => default(r.s.reps, 0) * default(r.s.weight, 0))) AS Volume
FROM #training AND -"99_system"
WHERE type = "workout" AND status = "completed"
  AND date >= this.period_start AND date <= this.period_end
  AND (!this.routine_ref OR routine_ref = this.routine_ref)
FLATTEN entries AS e
FLATTEN e.sets AS s
WHERE default(s.status, "done") = "done"
  AND (!this.focus_exercises OR contains(this.focus_exercises, e.exercise_ref))
GROUP BY e.exercise_ref
SORT key ASC
```

## Progress

-

## Adjustments for the next period

- [ ]
