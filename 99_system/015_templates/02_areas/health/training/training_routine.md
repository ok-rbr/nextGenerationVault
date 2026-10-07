---
title: "{{ title }}"
aliases:
  - "{{ title }}"
id: "{{ id }}"
created: "{{ created }}"
lang: "en"
category: "area"
type: "training_routine"
location: "02_areas/health/training/routines"
tags:
  - "training"
  - "routine"
# Stable handle that workouts use; never change it once set.
routine_ref: "{{ routine_ref }}"
goal: "strength" # strength | hypertrophy | skill | endurance | conditioning | mobility
split: "full_body" # full_body | upper | lower | push | pull | legs | skill
weight_unit: "kg" # kg | lb
status: "draft" # draft | active | archived; active needs at least one exercise
exercises: []
---

# {{ title }}

A reusable plan. What was actually done goes into `workout` notes that name
this routine in `routine_ref`.

## Plan

List the exercises in `exercises` in the frontmatter, one entry each. Durations
are seconds; exercises sharing a `superset_group` are one superset, run in
`order`:

```yaml
exercises:
  - exercise_ref: pull_up
    order: 1
    superset_group: a
    sets: 4
    reps: 5
    reps_max: 8
    weight: 0
    rest: 120
    rpe: 8
    tempo: "31X0"
  - exercise_ref: dip
    order: 2
    superset_group: a
    sets: 4
    reps: 8
    rest: 120
  - exercise_ref: hollow_body_hold
    order: 3
    sets: 3
    duration: 30
    rest: 60
```

```dataview
TABLE WITHOUT ID
  e.order AS "#",
  e.superset_group AS Superset,
  e.exercise_ref AS Exercise,
  e.sets AS Sets,
  choice(e.reps_max, e.reps + "-" + e.reps_max, e.reps) AS Reps,
  e.duration AS "Hold (s)",
  e.weight AS Load,
  e.rest AS "Rest (s)",
  e.rpe AS RPE
FROM #training AND -"99_system"
WHERE file.path = this.file.path
FLATTEN exercises AS e
SORT e.order ASC
```

## Notes

-

## Workouts

```dataview
TABLE WITHOUT ID file.link AS Workout, date AS Date, status AS Status, rpe AS RPE
FROM #training AND -"99_system"
WHERE type = "workout" AND routine_ref = this.routine_ref
SORT date DESC
```
