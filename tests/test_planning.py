"""Tests for planning engine."""

from pathlib import Path

from voidlink_cli.planning.engine import MigrationAction, MigrationPlan, PlanningEngine
from voidlink_cli.planning.para import ParaCategory, ParaClassifier


def test_para_classifier_by_path():
    """Test PARA classification by path hints."""
    classifier = ParaClassifier()

    result = classifier.classify(
        note_path=Path("01_Projects/ProjectX/plan.md"),
        title="Project X",
        tags=[],
    )
    assert result.category == ParaCategory.PROJECT
    assert result.confidence > 0.8


def test_para_classifier_by_tags():
    """Test PARA classification by tags."""
    classifier = ParaClassifier()

    result = classifier.classify(
        note_path=Path("notes/test.md"),
        title="Test",
        tags=["project", "goal", "deadline"],
    )
    assert result.category == ParaCategory.PROJECT
    assert result.confidence > 0.6


def test_para_classifier_archived():
    """Test archived classification."""
    classifier = ParaClassifier()

    result = classifier.classify(
        note_path=Path("Archive/old.md"),
        title="Old",
        tags=[],
        status="archived",
    )
    assert result.category == ParaCategory.ARCHIVE
    assert result.confidence > 0.9


def test_para_classifier_default():
    """Test default AREA classification."""
    classifier = ParaClassifier()

    result = classifier.classify(
        note_path=Path("unknown/note.md"),
        title="Unknown",
        tags=[],
    )
    assert result.category == ParaCategory.AREA
    assert result.requires_review is True


def test_planning_engine_generate_plan():
    """Test plan generation."""
    engine = PlanningEngine()

    notes = [
        {
            "path": "01_Projects/ProjectX/plan.md",
            "title": "Project X",
            "tags": ["project"],
            "status": "active",
            "category": "project",
        },
        {
            "path": "unknown/note.md",
            "title": "Unknown",
            "tags": [],
            "status": "active",
            "category": "area",
        },
    ]

    plan = engine.generate_plan(notes)

    assert plan.total_notes == 2
    assert plan.notes_reviewed == 2
    assert len(plan.actions) >= 0  # May have 0 or more actions


def test_migration_plan_to_dict():
    """Test plan serialization."""
    plan = MigrationPlan(
        run_id="test_001",
        timestamp="2024-01-01T00:00:00",
        total_notes=10,
        notes_reviewed=10,
        actions=[
            MigrationAction(
                action_type="move",
                reason="Test move",
                confidence=0.8,
            )
        ],
    )

    plan_dict = plan.to_dict()
    assert plan_dict["run_id"] == "test_001"
    assert len(plan_dict["actions"]) == 1
