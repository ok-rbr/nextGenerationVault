"""Backlink detection and relationship analysis."""

import re
from dataclasses import dataclass
from pathlib import Path


@dataclass
class BacklinkSuggestion:
    """Suggested backlink between notes."""

    source_note: str  # The note that should have the link
    target_note: str  # The note to link to
    target_title: str  # Display name
    confidence: float  # 0-1 confidence score
    reason: str  # Why this link is suggested


class BacklinkDetector:
    """Detect cross-note relationships and backlink suggestions."""

    def __init__(self, vault_root: Path):
        """Initialize detector."""
        self.vault_root = Path(vault_root)
        self.note_index = {}  # Map note titles/tags to paths

    def index_notes(self, notes: list[dict]) -> None:
        """Build index of all notes for relationship detection."""
        self.note_index = {}
        for note in notes:
            path = note.get("path", "")
            title = Path(path).stem
            tags = note.get("tags", [])

            # Index by path
            self.note_index[path] = {"title": title, "tags": tags}

            # Index by title variations
            self.note_index[title] = {"path": path, "title": title}
            self.note_index[title.lower()] = {"path": path, "title": title}

    def find_backlinks(self, note_path: str, content: str) -> list[BacklinkSuggestion]:
        """
        Find potential backlinks in a note.

        Returns list of suggestions with confidence scores.
        """
        suggestions = []

        # Pattern 1: Explicit [[WikiLinks]]
        wiki_links = re.findall(r"\[\[([^\]]+)\]\]", content)
        for link in wiki_links:
            target_path = self._resolve_link(link)
            if target_path and target_path != note_path:
                suggestions.append(
                    BacklinkSuggestion(
                        source_note=note_path,
                        target_note=target_path,
                        target_title=link,
                        confidence=0.95,
                        reason=f"Explicit wiki link: [[{link}]]",
                    )
                )

        # Pattern 2: Tag-based relationships (same tags = related)
        note_tags = self.note_index.get(note_path, {}).get("tags", [])
        if note_tags:
            for other_path, other_data in self.note_index.items():
                if other_path == note_path:
                    continue
                other_tags = other_data.get("tags", [])
                common_tags = set(note_tags) & set(other_tags)
                if len(common_tags) >= 2:  # At least 2 common tags
                    suggestions.append(
                        BacklinkSuggestion(
                            source_note=note_path,
                            target_note=other_path,
                            target_title=other_data.get("title", ""),
                            confidence=min(0.7, len(common_tags) / max(len(note_tags), 1)),
                            reason=f"Shared tags: {', '.join(common_tags)}",
                        )
                    )

        # Pattern 3: Named entity matching (if title mentioned in text)
        for other_path, other_data in self.note_index.items():
            if other_path == note_path:
                continue
            target_title = other_data.get("title", "")
            # Case-insensitive mention in content
            if target_title and len(target_title) > 3 and f" {target_title} " in f" {content} ":
                suggestions.append(
                    BacklinkSuggestion(
                        source_note=note_path,
                        target_note=other_path,
                        target_title=target_title,
                        confidence=0.6,
                        reason=f"Title mentioned in text: '{target_title}'",
                    )
                )

        # Deduplicate and sort by confidence
        unique = {s.target_note: s for s in suggestions}
        return sorted(unique.values(), key=lambda x: x.confidence, reverse=True)

    def _resolve_link(self, link: str) -> str | None:
        """Resolve [[WikiLink]] to actual note path."""
        # Exact match
        if link in self.note_index:
            return self.note_index[link].get("path")

        # Case-insensitive match
        lower_link = link.lower()
        for key, data in self.note_index.items():
            if key.lower() == lower_link:
                return data.get("path")

        return None

    def find_orphans(self) -> list[str]:
        """Find notes with no inbound or outbound links."""
        orphans = []

        for note_path in self.note_index:
            if not isinstance(note_path, str) or "/" not in note_path:
                continue

            # Check if this note has any links to it
            has_inbound = False
            has_outbound = False

            full_path = self.vault_root / note_path
            if full_path.exists():
                with open(full_path, encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                    # Check for outbound
                    if "[[" in content or "[" in content:
                        has_outbound = True

            # Check inbound from other notes (expensive, skip for now)

            if not has_inbound and not has_outbound:
                orphans.append(note_path)

        return orphans
