---
title: "{{ title }}"
aliases:
  - "{{ title }}"
id: "{{ id }}"
created: "{{ created }}"
lang: "en"
category: "area"
type: "exercise"
location: "02_areas/health/training/exercises"
tags:
  - "training"
  - "exercise"
# Stable handle that routines and workouts use; never change it once set.
exercise_ref: "{{ exercise_ref }}"
exercise_type: "strength" # strength | skill | conditioning | mobility
movement_pattern: "{{ movement_pattern }}" # push | pull | squat | hinge | carry | core | locomotion
muscle_groups:
  - "{{ primary_muscle_group }}"
secondary_muscle_groups: []
equipment: [] # empty for bodyweight
progression_level: 1 # 1 beginner | 2 intermediate | 3 advanced | 4 elite
prerequisites: []
regressions: []
progressions: []
status: "active"
---

# {{ title }}

## Description

What the exercise trains and why it is in the plan.

## Setup

-

## Execution

1.

## Cues

-

## Common mistakes

-

## History

Every completed set of this exercise, newest first.

```dataview
TABLE WITHOUT ID
  file.link AS Workout,
  date AS Date,
  s.reps AS Reps,
  s.duration AS "Hold (s)",
  s.weight AS Load,
  weight_unit AS Unit,
  s.rpe AS RPE
FROM #training AND -"99_system"
WHERE type = "workout" AND status = "completed"
FLATTEN entries AS e
WHERE e.exercise_ref = this.exercise_ref
FLATTEN e.sets AS s
WHERE default(s.status, "done") = "done"
SORT date DESC
LIMIT 30
```

## Routines using it

```dataview
LIST goal
FROM #training AND -"99_system"
WHERE type = "training_routine"
  AND contains(exercises.exercise_ref, this.exercise_ref)
```
