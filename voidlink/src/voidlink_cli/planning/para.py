"""PARA classifier for deterministic note categorization."""

from dataclasses import dataclass, field
from enum import StrEnum
from pathlib import Path


class ParaCategory(StrEnum):
    """PARA framework categories."""

    PROJECT = "projects"
    AREA = "areas"
    RESOURCE = "resources"
    ARCHIVE = "archive"


@dataclass
class ClassificationResult:
    """Result of PARA classification."""

    category: ParaCategory
    confidence: float
    reasons: list[str] = field(default_factory=list)
    requires_review: bool = False


class ParaClassifier:
    """Deterministic PARA classifier based on path and metadata."""

    # Priority 1: Strong path prefixes (high-confidence signals)
    PATH_PROJECT_STRONG = {"01_projects"}
    PATH_AREA_STRONG = {"02_areas"}
    PATH_RESOURCE_STRONG = {"03_resources"}
    PATH_ARCHIVE_STRONG = {"archive", "04_archive", "99_archive"}

    # Priority 1b: Weaker path hints
    PATH_PROJECT_WEAK = {"project", "active_project", "current", "in_progress"}
    PATH_AREA_WEAK = {"area", "practice", "ongoing", "skills"}
    PATH_RESOURCE_WEAK = {"resource", "reference", "collection", "library"}
    PATH_ARCHIVE_WEAK = {"archived", "draft", "done"}

    # Priority 2: Tags
    TAG_PROJECT = {"wip", "active", "in-progress", "current", "project", "goal", "deadline"}
    TAG_AREA = {"evergreen", "ongoing", "practice", "skill"}
    TAG_RESOURCE = {"reference", "collection", "template"}
    TAG_ARCHIVE = {"archived", "complete", "done", "obsolete"}

    # Confidence threshold below which requires_review is set
    REVIEW_THRESHOLD = 0.75

    def classify(
        self,
        note_path: Path | str,
        title: str = "",
        tags: list[str] | None = None,
        status: str | None = None,
    ) -> ClassificationResult:
        """Classify a note into a PARA category.

        Args:
            note_path: Relative path of the note inside the vault.
            title: Note title (used as supplementary signal).
            tags: List of frontmatter tags.
            status: Frontmatter status value.

        Returns:
            ClassificationResult with category, confidence, reasons, and
            requires_review flag.
        """
        reasons: list[str] = []
        scores: dict[ParaCategory, float] = {cat: 0.0 for cat in ParaCategory}

        path_lower = str(note_path).lower()

        # --- Path scoring ---
        for keyword in self.PATH_PROJECT_STRONG:
            if keyword in path_lower:
                scores[ParaCategory.PROJECT] += 0.9
                reasons.append(f"path prefix matches project folder: {keyword}")
                break
        else:
            for keyword in self.PATH_PROJECT_WEAK:
                if keyword in path_lower:
                    scores[ParaCategory.PROJECT] += 0.5
                    reasons.append(f"path contains project hint: {keyword}")
                    break

        for keyword in self.PATH_AREA_STRONG:
            if keyword in path_lower:
                scores[ParaCategory.AREA] += 0.8
                reasons.append(f"path prefix matches area folder: {keyword}")
                break
        else:
            for keyword in self.PATH_AREA_WEAK:
                if keyword in path_lower:
                    scores[ParaCategory.AREA] += 0.5
                    reasons.append(f"path contains area hint: {keyword}")
                    break

        for keyword in self.PATH_RESOURCE_STRONG:
            if keyword in path_lower:
                scores[ParaCategory.RESOURCE] += 0.8
                reasons.append(f"path prefix matches resource folder: {keyword}")
                break
        else:
            for keyword in self.PATH_RESOURCE_WEAK:
                if keyword in path_lower:
                    scores[ParaCategory.RESOURCE] += 0.5
                    reasons.append(f"path contains resource hint: {keyword}")
                    break

        for keyword in self.PATH_ARCHIVE_STRONG:
            if keyword in path_lower:
                scores[ParaCategory.ARCHIVE] += 0.7
                reasons.append(f"path contains archive keyword: {keyword}")
                break
        else:
            for keyword in self.PATH_ARCHIVE_WEAK:
                if keyword in path_lower:
                    scores[ParaCategory.ARCHIVE] += 0.4
                    reasons.append(f"path contains archive hint: {keyword}")
                    break

        # --- Tag scoring ---
        if tags:
            tags_lower = [t.lower() for t in tags]
            for tag in tags_lower:
                if tag in self.TAG_PROJECT:
                    scores[ParaCategory.PROJECT] += 0.3
                    reasons.append(f"tag indicates project: {tag}")
                if tag in self.TAG_AREA:
                    scores[ParaCategory.AREA] += 0.3
                    reasons.append(f"tag indicates area: {tag}")
                if tag in self.TAG_RESOURCE:
                    scores[ParaCategory.RESOURCE] += 0.3
                    reasons.append(f"tag indicates resource: {tag}")
                if tag in self.TAG_ARCHIVE:
                    scores[ParaCategory.ARCHIVE] += 0.4
                    reasons.append(f"tag indicates archive: {tag}")

        # --- Status scoring ---
        if status:
            status_lower = status.lower()
            if status_lower == "archived":
                scores[ParaCategory.ARCHIVE] += 0.3
                reasons.append("status is archived")
            elif status_lower in {"active", "in_progress"}:
                scores[ParaCategory.PROJECT] += 0.15
                reasons.append("status is active/in-progress")
            elif status_lower == "evergreen":
                scores[ParaCategory.AREA] += 0.15
                reasons.append("status is evergreen")

        # --- Default fallback ---
        max_score = max(scores.values())
        if max_score == 0.0:
            scores[ParaCategory.AREA] = 0.5
            reasons.append("no classification signals; defaulting to area")

        best_category = max(scores, key=scores.__getitem__)
        confidence = min(scores[best_category], 1.0)
        requires_review = confidence < self.REVIEW_THRESHOLD

        return ClassificationResult(
            category=best_category,
            confidence=confidence,
            reasons=reasons,
            requires_review=requires_review,
        )
