---
title: "{{ title }}"
aliases:
  - "{{ title }}"
id: "{{ id }}"
created: "{{ created }}"
lang: "en"
category: "area"
type: "workout"
location: "02_areas/health/training/workouts"
tags:
  - "training"
  - "workout"
date: "{{ current_date }}"
status: "in_progress" # planned | in_progress | completed | cancelled
routine_ref: "{{ routine_ref }}" # empty for an ad-hoc workout
# Add when the workout is over:
# duration: 3600 # seconds
# rpe: 7.5 # session RPE, 1-10 in 0.5 steps
weight_unit: "kg" # kg | lb
entries: []
---

# {{ title }}

## Sets

Log every set in `entries` in the frontmatter. `weight` is the external load in
`weight_unit` (0 for bodyweight), `duration` and `rest` are seconds, a set
without `status` counts as done. A completed workout needs at least one entry.

```yaml
entries:
  - exercise_ref: pull_up
    order: 1
    superset_group: a
    sets:
      - { reps: 8, weight: 0, rpe: 7.5, rest: 120 }
      - { reps: 7, weight: 0, rpe: 8.5, rest: 120 }
      - { reps: 5, weight: 0, rpe: 9.5, rir: 0 }
  - exercise_ref: hollow_body_hold
    order: 2
    sets:
      - { duration: 30 }
      - { status: skipped, notes: "lower back" }
```

```dataview
TABLE WITHOUT ID
  e.order AS "#",
  e.superset_group AS Superset,
  e.exercise_ref AS Exercise,
  length(e.sets) AS Sets,
  map(e.sets, (s) => default(s.reps, s.duration + "s")) AS "Reps / hold",
  sum(map(e.sets, (s) => default(s.reps, 0) * default(s.weight, 0))) AS Volume
FROM #training AND -"99_system"
WHERE file.path = this.file.path
FLATTEN entries AS e
SORT e.order ASC
```

## How it went

-

## Next time

-
