"""Planning engine for generating vault migration strategies."""

from dataclasses import asdict, dataclass, field
from datetime import datetime
from pathlib import Path

from voidlink_cli.planning.para import ParaCategory, ParaClassifier


def _default_run_id() -> str:
    return f"plan_{datetime.now().strftime('%Y%m%d_%H%M%S')}"


@dataclass
class MigrationAction:
    """Single migration action to apply to a note."""

    action_type: str
    reason: str
    confidence: float
    note_path: str = ""
    source_category: str = ""
    target_category: str = ""
    requires_review: bool = False
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())

    def to_dict(self) -> dict:
        """Convert to dictionary."""
        return asdict(self)


@dataclass
class MigrationPlan:
    """Complete migration plan for vault."""

    total_notes: int
    notes_reviewed: int
    actions: list[MigrationAction]
    run_id: str = field(default_factory=_default_run_id)
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())
    vault_path: str = "."
    category_distribution: dict[str, int] = field(default_factory=dict)

    def to_dict(self) -> dict:
        """Convert to dictionary."""
        return {
            "run_id": self.run_id,
            "timestamp": self.timestamp,
            "vault_path": self.vault_path,
            "total_notes": self.total_notes,
            "notes_reviewed": self.notes_reviewed,
            "category_distribution": self.category_distribution,
            "actions": [a.to_dict() for a in self.actions],
            "action_summary": {
                "total": len(self.actions),
                "requires_review": sum(1 for a in self.actions if a.requires_review),
                "high_confidence": sum(1 for a in self.actions if a.confidence >= 0.8),
                "low_confidence": sum(1 for a in self.actions if a.confidence < 0.6),
            },
        }


class PlanningEngine:
    """Generate PARA migration plans for vault notes."""

    def __init__(self) -> None:
        """Initialize planning engine."""
        self.classifier = ParaClassifier()

    def generate_plan(
        self,
        notes: list[dict],
        vault_path: str = ".",
        taxonomy: dict | None = None,
    ) -> MigrationPlan:
        """Generate a migration plan for a list of notes.

        Args:
            notes: List of note dicts with keys ``path``, ``tags``, ``status``,
                   and ``category`` (current PARA category).
            vault_path: Absolute or relative path to the vault root.
            taxonomy: Optional tag taxonomy for normalization (currently unused).

        Returns:
            MigrationPlan with classification results and suggested actions.
        """
        actions: list[MigrationAction] = []
        category_dist: dict[str, int] = {cat.value: 0 for cat in ParaCategory}

        for note in notes:
            path = note.get("path", "")
            tags = note.get("tags", [])
            status = note.get("status", "")
            current_category = note.get("category", "area")

            result = self.classifier.classify(
                note_path=Path(path),
                title=Path(path).stem,
                tags=tags,
                status=status,
            )
            category_dist[result.category.value] += 1

            if result.category.value != current_category:
                actions.append(
                    MigrationAction(
                        note_path=path,
                        source_category=current_category,
                        target_category=result.category.value,
                        action_type="move",
                        reason="; ".join(result.reasons),
                        confidence=result.confidence,
                        requires_review=result.requires_review,
                    )
                )

        return MigrationPlan(
            total_notes=len(notes),
            notes_reviewed=len(notes),
            actions=actions,
            vault_path=vault_path,
            category_distribution=category_dist,
        )
