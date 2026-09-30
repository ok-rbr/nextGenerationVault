"""Enhanced planning engine with LLM support."""

import random
from dataclasses import asdict, dataclass, field
from datetime import datetime
from pathlib import Path

from voidlink_cli.llm.client import OllamaClient
from voidlink_cli.planning.para import ParaCategory, ParaClassifier


@dataclass
class EnhancedMigrationAction:
    """Migration action with optional LLM enhancement."""

    note_path: str
    source_category: str
    target_category: str
    action_type: str
    reason: str
    confidence: float
    requires_review: bool
    llm_enhanced: bool = False
    extracted_metadata: dict | None = None
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())

    def to_dict(self) -> dict:
        """Convert to dictionary."""
        return asdict(self)


@dataclass
class EnhancedMigrationPlan:
    """Complete plan with optional LLM enhancements."""

    vault_path: str
    total_notes: int
    actions: list[EnhancedMigrationAction]
    category_distribution: dict[str, int]
    llm_used: bool = False
    generated_at: str = field(default_factory=lambda: datetime.now().isoformat())

    def to_dict(self) -> dict:
        """Convert to dictionary."""
        return {
            "vault_path": self.vault_path,
            "total_notes": self.total_notes,
            "generated_at": self.generated_at,
            "category_distribution": self.category_distribution,
            "llm_used": self.llm_used,
            "actions": [a.to_dict() for a in self.actions],
            "action_summary": {
                "total": len(self.actions),
                "requires_review": sum(1 for a in self.actions if a.requires_review),
                "high_confidence": sum(1 for a in self.actions if a.confidence >= 0.8),
                "low_confidence": sum(1 for a in self.actions if a.confidence < 0.6),
                "llm_enhanced": sum(1 for a in self.actions if a.llm_enhanced),
            },
        }


class EnhancedPlanningEngine:
    """Planning engine with optional LLM enhancement."""

    def __init__(self, use_llm: bool = False):
        """Initialize engine."""
        self.classifier = ParaClassifier()
        self.llm = OllamaClient() if use_llm else None

    def generate_plan(
        self,
        notes: list[dict],
        vault_path: str = ".",
        taxonomy: dict | None = None,
        read_content: bool = False,
        sample_size: int | None = None,
        llm_allowed_paths: set[str] | None = None,
    ) -> EnhancedMigrationPlan:
        """Generate enhanced migration plan.

        Args:
            notes: List of note dicts with keys ``path``, ``tags``, ``status``,
                   and ``category``.
            vault_path: Path to vault root (used when reading note content).
            taxonomy: Optional tag taxonomy (currently unused).
            read_content: When True, reads file content for LLM analysis.
            sample_size: Limit LLM processing to a random sample of this size.

        Returns:
            EnhancedMigrationPlan with optional LLM-boosted classifications.
        """
        actions: list[EnhancedMigrationAction] = []
        category_dist: dict[str, int] = {cat.value: 0 for cat in ParaCategory}

        # Determine which notes receive LLM enhancement
        notes_to_enhance: list[dict] = []
        if self.llm and self.llm.available and read_content and sample_size:
            eligible = [
                note
                for note in notes
                if llm_allowed_paths is None or note.get("path") in llm_allowed_paths
            ]
            notes_to_enhance = random.sample(eligible, min(sample_size, len(eligible)))

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

            llm_enhanced = False
            extracted_metadata = None

            if self.llm and self.llm.available and read_content and note in notes_to_enhance:
                try:
                    vault_root = Path(vault_path)
                    full_path = vault_root / path
                    if full_path.exists():
                        with open(full_path, encoding="utf-8", errors="ignore") as f:
                            content = f.read()[:1000]

                        fm_result = self.llm.extract_frontmatter(content)
                        if fm_result.get("success"):
                            extracted_metadata = fm_result.get("metadata")
                            llm_enhanced = True
                            if "tags" in extracted_metadata:
                                tags = extracted_metadata["tags"]

                        llm_para = self.llm.classify_para_with_llm(
                            path, content, result.category.value
                        )
                        if (
                            llm_para.get("used_llm")
                            and llm_para.get("confidence", 0) > result.confidence
                        ):
                            result.category = ParaCategory(llm_para.get("llm_category"))
                            result.confidence = llm_para.get("confidence", 0)
                            result.reasons.append(f"LLM boosted: {llm_para.get('reasoning')}")
                            llm_enhanced = True
                except Exception:
                    pass  # Graceful fallback to heuristic result

            if result.category.value != current_category:
                actions.append(
                    EnhancedMigrationAction(
                        note_path=path,
                        source_category=current_category,
                        target_category=result.category.value,
                        action_type="move",
                        reason="; ".join(result.reasons),
                        confidence=result.confidence,
                        requires_review=result.requires_review,
                        llm_enhanced=llm_enhanced,
                        extracted_metadata=extracted_metadata,
                    )
                )

        return EnhancedMigrationPlan(
            vault_path=vault_path,
            total_notes=len(notes),
            actions=actions,
            category_distribution=category_dist,
            llm_used=self.llm is not None and self.llm.available,
        )
