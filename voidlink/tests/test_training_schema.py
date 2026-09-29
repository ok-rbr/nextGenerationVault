"""Tests for the training note types in the frontmatter schema (voidlink#22)."""

import re
from pathlib import Path

import pytest
import yaml

from voidlink_cli.validation.frontmatter import (
    load_frontmatter_validator,
    parse_frontmatter,
    validate_note_text,
)

ROOT = Path(__file__).parents[1]
SCHEMA = ROOT / "99_system" / "05_schemas" / "frontmatter.schema.json"
REFERENCE = ROOT / "99_system" / "05_schemas" / "training_schema.md"

BASE = {"title": "Note", "created": "2026-09-26 18:00", "category": "area"}
NOTES = {
    "exercise": {
        "tags": ["training", "exercise"],
        "exercise_ref": "pull_up",
        "exercise_type": "strength",
        "movement_pattern": "pull",
        "muscle_groups": ["lats"],
        "secondary_muscle_groups": ["biceps"],
        "equipment": ["pull_up_bar"],
        "progression_level": 2,
        "regressions": ["negative_pull_up"],
        "status": "active",
    },
    "training_routine": {
        "tags": ["training", "routine"],
        "routine_ref": "pull_day_a",
        "goal": "strength",
        "split": "pull",
        "weight_unit": "kg",
        "status": "active",
        "exercises": [
            {"exercise_ref": "pull_up", "order": 1, "superset_group": "a", "sets": 4, "reps": 5,
             "reps_max": 8, "weight": 0, "rest": 120, "rpe": 8, "tempo": "31X0"},
            {"exercise_ref": "hollow_body_hold", "order": 2, "sets": 3, "duration": 30},
        ],
    },
    "workout": {
        "tags": ["training", "workout"],
        "date": "2026-09-26",
        "status": "completed",
        "routine_ref": "pull_day_a",
        "workout_ref": "",
        "started_at": "2026-09-26T18:30+02:00",
        "duration": 3600,
        "rpe": 8.5,
        "weight_unit": "kg",
        "entries": [
            {"exercise_ref": "pull_up", "order": 1, "superset_group": "a", "sets": [
                {"reps": 8, "weight": 12.5, "rpe": 7.5, "rest": 120},
                {"reps": 5, "weight": 12.5, "rpe": 9.5, "rir": 0, "status": "done"},
            ]},
            {"exercise_ref": "hollow_body_hold", "order": 2, "sets": [
                {"duration": 30},
                {"status": "skipped", "notes": "lower back"},
            ]},
        ],
    },
    "training_evaluation": {
        "tags": ["training", "evaluation"],
        "period_start": "2026-09-01",
        "period_end": "2026-09-30",
        "routine_ref": "",
        "focus_exercises": ["pull_up"],
    },
}  # fmt: skip


@pytest.fixture(scope="module")
def validator():
    return load_frontmatter_validator(SCHEMA)


def note(note_type: str, **changes) -> str:
    data = {**BASE, "id": note_type, "type": note_type, **NOTES[note_type], **changes}
    data = {key: value for key, value in data.items() if value is not None}
    return f"---\n{yaml.safe_dump(data, sort_keys=False)}---\n"


def problems(validator, text: str, note_type: str = "note") -> set[tuple[str, str]]:
    stem = parse_frontmatter(text).get("id", note_type)
    return {(i.field, i.message) for i in validate_note_text(text, validator, f"{stem}.md")}


def fields(validator, text: str) -> set[str]:
    return {field for field, _ in problems(validator, text)}


@pytest.mark.parametrize("note_type", NOTES)
def test_complete_training_notes_are_valid(validator, note_type):
    assert problems(validator, note(note_type)) == set()


@pytest.mark.parametrize("note_type", NOTES)
def test_training_notes_are_area_notes_tagged_training(validator, note_type):
    text = note(note_type, category="knowledge", tags=["exercise"])
    assert fields(validator, text) == {"category", "tags"}


@pytest.mark.parametrize(
    ("note_type", "required"),
    [
        (
            "exercise",
            {"exercise_ref", "exercise_type", "movement_pattern", "muscle_groups", "equipment"},
        ),
        ("training_routine", {"routine_ref", "goal", "weight_unit", "exercises"}),
        ("workout", {"date", "status", "weight_unit", "entries"}),
        ("training_evaluation", {"period_start", "period_end"}),
    ],
)
def test_each_type_has_its_required_fields(validator, note_type, required):
    text = note(note_type, **dict.fromkeys(required))
    messages = {message for _, message in problems(validator, text)}
    assert messages == {f"'{name}' is a required property" for name in required}


@pytest.mark.parametrize(
    ("note_type", "changes", "field"),
    [
        ("exercise", {"exercise_type": "cardio"}, "exercise_type"),
        ("exercise", {"movement_pattern": "Pull"}, "movement_pattern"),
        ("exercise", {"muscle_groups": []}, "muscle_groups"),
        ("exercise", {"exercise_ref": "Pull-Up"}, "exercise_ref"),
        ("exercise", {"progression_level": 5}, "progression_level"),
        ("training_routine", {"goal": "fun"}, "goal"),
        ("training_routine", {"weight_unit": "kgs"}, "weight_unit"),
        ("workout", {"status": "in-progress"}, "status"),
        ("workout", {"status": "done"}, "status"),
        ("workout", {"duration": 60.5}, "duration"),
        ("workout", {"rpe": 7.3}, "rpe"),
        ("workout", {"rpe": 11}, "rpe"),
        ("workout", {"started_at": "2026-09-26 18:30"}, "started_at"),
        ("workout", {"routine_ref": "Pull Day"}, "routine_ref"),
        ("training_evaluation", {"period_end": "30.09.2026"}, "period_end"),
    ],
)
def test_values_outside_the_range_are_reported(validator, note_type, changes, field):
    assert fields(validator, note(note_type, **changes)) == {field}


def test_empty_routine_is_allowed_only_as_draft(validator):
    assert fields(validator, note("training_routine", exercises=[])) == {"exercises"}
    assert problems(validator, note("training_routine", exercises=[], status="draft")) == set()


def test_completed_workout_needs_an_entry(validator):
    assert fields(validator, note("workout", entries=[])) == {"entries"}
    assert problems(validator, note("workout", entries=[], status="in_progress")) == set()


@pytest.mark.parametrize(
    "entry",
    [
        {"exercise_ref": "pull_up", "order": 1, "sets": 3, "rep": 5},  # typo
        {"exercise_ref": "pull_up", "order": 1, "sets": 3},  # neither reps nor duration
        {"exercise_ref": "pull_up", "order": 0, "sets": 3, "reps": 5},
        {"exercise_ref": "pull_up", "order": 1, "sets": 3, "reps": 5, "tempo": "3-1-1"},
        {"exercise_ref": "pull_up", "order": 1, "sets": 3, "reps": 5, "superset_group": "A"},
    ],
)
def test_planned_exercises_are_unambiguous(validator, entry):
    assert {
        f.split("/")[0] for f in fields(validator, note("training_routine", exercises=[entry]))
    } == {"exercises"}


@pytest.mark.parametrize(
    "performed_set",
    [
        {"weight": 20},  # load without reps or duration
        {"reps": 5, "weight": -5},
        {"reps": 5, "load": 20},  # unknown key
        {"reps": 5, "status": "failed"},
        {"reps": 5, "rir": 11},
    ],
)
def test_performed_sets_are_unambiguous(validator, performed_set):
    entries = [{"exercise_ref": "pull_up", "order": 1, "sets": [performed_set]}]
    assert {f.split("/")[0] for f in fields(validator, note("workout", entries=entries))} == {
        "entries"
    }


@pytest.mark.parametrize(
    ("note_type", "list_field"), [("training_routine", "exercises"), ("workout", "entries")]
)
def test_order_is_unique_within_a_note(validator, note_type, list_field):
    entries = NOTES[note_type][list_field]
    duplicate = [entries[0], {**entries[1], "order": entries[0]["order"]}]

    assert problems(validator, note(note_type, **{list_field: duplicate})) == {
        (f"{list_field}/1/order", "order 1 is used twice")
    }


def test_order_is_not_checked_outside_training_lists(validator):
    text = note("training_evaluation", entries=[{"order": 1}, {"order": 1}])
    assert problems(validator, text) == set()


def test_evaluation_period_must_not_end_before_it_starts(validator):
    text = note("training_evaluation", period_start="2026-09-30", period_end="2026-09-01")
    assert problems(validator, text) == {
        ("period_end", "'2026-09-01' is before period_start '2026-09-30'")
    }


def test_non_string_type_does_not_break_the_training_checks(validator):
    text = (
        "---\ntitle: x\nid: x\ncreated: 2026-09-26 18:00\ntags: []\ncategory: area\n"
        "type: [a]\n---\n"
    )
    assert fields(validator, text) == {"type"}


def test_other_note_types_keep_their_status_values(validator):
    text = (
        "---\ntitle: Task\nid: task\ncreated: 2026-09-26 18:00\ntags: [task]\n"
        "category: task\nstatus: in-progress\n---\n"
    )
    assert problems(validator, text) == set()


def test_reference_page_is_a_valid_note(validator):
    text = REFERENCE.read_text(encoding="utf-8")
    assert validate_note_text(text, validator, "99_system/05_schemas/training_schema.md") == []


@pytest.mark.parametrize(
    "example",
    re.findall(r"```yaml\n(.*?)```", REFERENCE.read_text(encoding="utf-8"), re.DOTALL),
)
def test_reference_page_examples_are_valid(validator, example):
    data = yaml.safe_load(example)
    note_type = "training_routine" if "exercises" in data else "workout"
    assert problems(validator, note(note_type, **data)) == set()
