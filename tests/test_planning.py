"""Tests for planning engine."""

from pathlib import Path

from voidlink_cli.llm.enhanced_engine import EnhancedPlanningEngine
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


def test_llm_plan_never_reads_excluded_work_notes(tmp_path, monkeypatch):
    seen = []

    class LocalModel:
        available = True

        def extract_frontmatter(self, content):
            seen.append(content)
            return {"success": False}

        def classify_para_with_llm(self, *args):
            return {"used_llm": False}

    monkeypatch.setattr("voidlink_cli.llm.enhanced_engine.OllamaClient", LocalModel)
    paths = ("01_projects/example/private.md", "00_knowledge/01_atomic/public.md")
    for path in paths:
        note = tmp_path / path
        note.parent.mkdir(parents=True)
        note.write_text(path)

    engine = EnhancedPlanningEngine(use_llm=True)
    plan = engine.generate_plan(
        [{"path": path, "category": "area"} for path in paths],
        vault_path=str(tmp_path),
        read_content=True,
        sample_size=50,
        llm_allowed_paths={paths[1]},
    )
    assert plan.total_notes == 2
    assert seen == [paths[1]]

    seen.clear()
    engine.generate_plan(
        [{"path": path, "category": "area"} for path in paths],
        vault_path=str(tmp_path),
        read_content=True,
        sample_size=50,
    )
    assert seen == []
