---
title: "Training note schema"
aliases:
  - "Training note schema"
id: "training_schema"
created: "2026-09-26 12:00"
lang: "en"
category: "index"
tags:
  - "training"
  - "docs"
---

# Training note schema

Frontmatter for strength and calisthenics training notes (voidlink#22). Terms,
value ranges and the split between vault and database follow voidCore's
`docs/voidsystem/DOMAIN_MODEL.md`; where this page and that document disagree,
the domain model wins and this page is wrong. The machine-readable version is
the training section of [`frontmatter.schema.json`](frontmatter.schema.json);
`vault-agent validate frontmatter` checks it.

## Four note types

| `type`                | What it is                                                        | Template                                                        | Folder in the vault                     |
| --------------------- | ----------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------------- |
| `exercise`            | A reusable training move: technique, muscle groups, equipment     | `015_templates/02_areas/health/training/exercise.md`            | `02_areas/health/training/exercises/`   |
| `training_routine`    | A reusable, ordered **plan**: exercises with target sets and reps | `015_templates/02_areas/health/training/training_routine.md`    | `02_areas/health/training/routines/`    |
| `workout`             | One **executed** training, with the sets actually done            | `015_templates/02_areas/health/training/workout.md`             | `02_areas/health/training/workouts/`    |
| `training_evaluation` | A look back over a period: volume, frequency, progress            | `015_templates/02_areas/health/training/training_evaluation.md` | `02_areas/health/training/evaluations/` |

A routine is never an execution record and a workout is never a plan. Yoga
postures are `Pose`, not `exercise` (voidlink#23).

## Fields every training note has

The base fields of every vault note (`title`, `id`, `created`, `tags`,
`category`) plus:

| Field      | Rule                                                              |
| ---------- | ----------------------------------------------------------------- |
| `type`     | one of the four types above                                       |
| `category` | `area`                                                            |
| `tags`     | a list that contains `training`; the templates add the type's tag |

## Units and value ranges

| Value                                | Rule                                                                                                               |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| `duration`, `rest`                   | whole **seconds**, everywhere (holds, rest, a workout's length)                                                    |
| `reps`                               | integer count                                                                                                      |
| `weight`                             | number ≥ 0, the **external** load; `0` for bodyweight only. Added weight on a dip belt counts, bodyweight does not |
| `weight_unit`                        | `kg` or `lb`, once per routine or workout; every `weight` in the note uses it                                      |
| `rpe`                                | 1 to 10 in 0.5 steps                                                                                               |
| `rir`                                | integer 0 to 10, reps in reserve                                                                                   |
| `tempo`                              | four characters, eccentric-bottom-concentric-top in seconds, `X` for explosive: `31X0`                             |
| `date`, `period_start`, `period_end` | local date `YYYY-MM-DD`                                                                                            |
| `started_at`                         | ISO 8601 with an explicit offset: `2026-09-26T18:30+02:00`                                                         |
| `*_ref`                              | lowercase slug `pull_up`, `push_day_a`; see below                                                                  |

## Stable references

Workouts and routines name exercises by `exercise_ref`, and workouts name their
routine by `routine_ref`, not by wiki-link. A `*_ref` is minted once when the
exercise or routine note is created and never changes, even when the note is
renamed or moved (DOMAIN*MODEL.md §4), so the history of an exercise survives a
rename. Pick it like a file name: lowercase ASCII, `*` between words, umlauts
transliterated (`ä → ae`). Two exercise notes must not share an `exercise_ref`.

`workout_ref` is the workout's id in voidApi. The vault never mints it; it is
set when a workout is synced, and empty until then.

## `exercise`

| Field                                          | Required | Values                                                          |
| ---------------------------------------------- | -------- | --------------------------------------------------------------- |
| `exercise_ref`                                 | yes      | slug                                                            |
| `exercise_type`                                | yes      | `strength`, `skill`, `conditioning`, `mobility`                 |
| `movement_pattern`                             | yes      | `push`, `pull`, `squat`, `hinge`, `carry`, `core`, `locomotion` |
| `muscle_groups`                                | yes      | list of slugs, at least one: the primary muscles                |
| `equipment`                                    | yes      | list of slugs, empty for bodyweight                             |
| `secondary_muscle_groups`                      | no       | list of slugs                                                   |
| `progression_level`                            | no       | 1 beginner, 2 intermediate, 3 advanced, 4 elite                 |
| `prerequisites`, `regressions`, `progressions` | no       | lists of `exercise_ref`                                         |
| `status`                                       | no       | `active`, `archived`                                            |

## `training_routine`

| Field         | Required | Values                                                                      |
| ------------- | -------- | --------------------------------------------------------------------------- |
| `routine_ref` | yes      | slug                                                                        |
| `goal`        | yes      | `strength`, `hypertrophy`, `skill`, `endurance`, `conditioning`, `mobility` |
| `weight_unit` | yes      | `kg`, `lb`                                                                  |
| `exercises`   | yes      | list of planned exercises; at least one unless `status` is `draft`          |
| `split`       | no       | `full_body`, `upper`, `lower`, `push`, `pull`, `legs`, `skill`              |
| `status`      | no       | `draft`, `active`, `archived`                                               |

A planned exercise has `exercise_ref`, `order` and `sets` (the number of sets),
and `reps` or `duration` or both. Optional: `reps_max` (with `reps` as the lower
bound of a range), `weight`, `rest`, `rpe`, `tempo`, `superset_group`, `notes`.
Any other key is an error, so a typo like `rep:` does not pass silently.

```yaml
exercises:
  - {
      exercise_ref: pull_up,
      order: 1,
      superset_group: a,
      sets: 4,
      reps: 5,
      reps_max: 8,
      rest: 120,
    }
  - {
      exercise_ref: dip,
      order: 2,
      superset_group: a,
      sets: 4,
      reps: 8,
      rest: 120,
    }
  - {
      exercise_ref: hollow_body_hold,
      order: 3,
      sets: 3,
      duration: 30,
      rest: 60,
    }
```

## `workout`

| Field         | Required | Values                                                                 |
| ------------- | -------- | ---------------------------------------------------------------------- |
| `date`        | yes      | local date                                                             |
| `status`      | yes      | `planned`, `in_progress`, `completed`, `cancelled`                     |
| `weight_unit` | yes      | `kg`, `lb`                                                             |
| `entries`     | yes      | list of performed exercises; at least one when `status` is `completed` |
| `routine_ref` | no       | the routine this workout executed; empty for an ad-hoc workout         |
| `workout_ref` | no       | voidApi id, set by sync                                                |
| `started_at`  | no       | ISO 8601 with offset                                                   |
| `duration`    | no       | seconds                                                                |
| `rpe`         | no       | session RPE                                                            |

A performed exercise has `exercise_ref`, `order` and `sets`, here the list of
sets as done, and optionally `superset_group` and `notes`. A set has `reps` or
`duration` (or both), and optionally `weight`, `rest`, `rpe`, `rir`, `notes`
and `status`: `done` (the default when absent) or `skipped`. A skipped set
needs no reps.

```yaml
entries:
  - exercise_ref: pull_up
    order: 1
    superset_group: a
    sets:
      - { reps: 8, weight: 0, rpe: 7.5, rest: 120 }
      - { reps: 5, weight: 0, rpe: 9.5, rir: 0 }
  - exercise_ref: weighted_dip
    order: 2
    superset_group: a
    sets:
      - { reps: 6, weight: 10, rpe: 8 }
      - { status: skipped, notes: "shoulder" }
```

The session statuses are the domain model's lifecycle values. They are
spelled `in_progress` with an underscore; the base schema's `in-progress`
belongs to tasks.

## `training_evaluation`

| Field             | Required | Values                                            |
| ----------------- | -------- | ------------------------------------------------- |
| `period_start`    | yes      | local date                                        |
| `period_end`      | yes      | local date, not before `period_start`             |
| `routine_ref`     | no       | restrict the evaluation to one routine            |
| `focus_exercises` | no       | list of `exercise_ref`; empty means all exercises |

## Superset grouping

Entries with the same `superset_group` value form one superset and are run in
`order`. `order` is unique within a routine or workout; `vault-agent validate
frontmatter` reports a duplicate. The two fields exist so voidApi's superset
grouping (voidApi#36) survives a sync to the vault.

## Derived values are never stored

Training volume, personal bests and frequency are derived from the sets and
computed by Dataview; they are never typed into frontmatter (DOMAIN_MODEL.md
§2). Sets live in frontmatter lists so Dataview can read them without parsing
the note body. Volume of one exercise over all completed workouts:

```dataview
TABLE WITHOUT ID
  key AS Exercise,
  length(rows) AS Sets,
  sum(map(rows, (r) => default(r.s.reps, 0))) AS Reps,
  sum(map(rows, (r) => default(r.s.reps, 0) * default(r.s.weight, 0))) AS Volume
FROM #training AND -"99_system"
WHERE type = "workout" AND status = "completed"
FLATTEN entries AS e
FLATTEN e.sets AS s
WHERE default(s.status, "done") = "done"
GROUP BY e.exercise_ref
```

The exercise, routine and evaluation templates contain the queries for their
own view: an exercise's history, a routine's workouts, and a period's volume
per exercise.

Once voidApi records workouts, it holds the operational truth and a synced
workout note carries its `workout_ref`. The set lists stay the vault's
structured record until that sync exists; how a synced note treats them is
decided with the sync, not here.

## Migrating the calisthenics templates

The older Templater templates `calisthenics_exercise` and
`calisthenics_workout` were removed (voidlink#44); the templates above replace
them. Notes created from them stay as they are and do not validate against
this schema. Nothing converts them automatically: migrate a note by hand, or
through a reviewed `vault-agent` plan, with this mapping. Notes with
`draft: true` stay as they are.

### `calisthenics_exercise` → `exercise`

| Old field                             | New field                                                               |
| ------------------------------------- | ----------------------------------------------------------------------- |
| `type: calisthenics_exercise`         | `type: exercise`, plus `category: area`                                 |
| `name`                                | `title`; add `id` (the file name stem) and `exercise_ref`               |
| `created: {{created}}`                | `created: YYYY-MM-DD HH:mm`                                             |
| `skill: true` / `false`               | `exercise_type: skill` / `strength` (or `conditioning`, `mobility`)     |
| `movement_pattern`                    | unchanged                                                               |
| `primary_muscles`                     | `muscle_groups`, as slugs                                               |
| `secondary_muscles`                   | `secondary_muscle_groups`, as slugs                                     |
| `muscle_load_map`                     | dropped from frontmatter; move it to the body if it matters             |
| `progression_level`                   | unchanged                                                               |
| `prerequisites`                       | unchanged, as `exercise_ref` values                                     |
| `equipment`                           | unchanged, as slugs                                                     |
| regression/progression wiki-links     | optionally also `regressions` / `progressions` as `exercise_ref` values |
| tags `calisthenics, exercise, health` | must include `training`; keep the others if you query them              |
| `status: active`                      | unchanged                                                               |

### `calisthenics_workout` → `workout` (and `training_routine`)

| Old field                                                 | New field                                                                                                 |
| --------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `type: calisthenics_workout`                              | `type: workout`, plus `category: area`                                                                    |
| `name`                                                    | `title`; add `id`                                                                                         |
| `date`                                                    | unchanged                                                                                                 |
| `duration_min`                                            | `duration`, in seconds (× 60)                                                                             |
| `rpe_target`, `intensity_target`                          | targets belong to the routine: `rpe` on its planned exercises                                             |
| actual RPE in the body                                    | `rpe` (session RPE)                                                                                       |
| `goal`, `split`                                           | belong to the routine: `goal`, `split` on a `training_routine`                                            |
| `warmup`, `workout_blocks`, `cooldown` and the set tables | `entries`, one entry per exercise with its sets; blocks become `order` ranges, supersets `superset_group` |
| weight in the table                                       | `weight` per set, and `weight_unit` once per note                                                         |
| `status: completed`                                       | unchanged                                                                                                 |
| "Total volume" in the body                                | dropped; the evaluation template computes it                                                              |

If several old workouts share the same plan, create one `training_routine`
for it and set `routine_ref` in each migrated workout.
