"""Vault scanning and discovery."""

import hashlib
import re
from pathlib import Path


class VaultScanner:
    """Scan vault for all notes, assets, media."""

    # Files to ignore
    IGNORE_PATTERNS = {".obsidian", ".git", ".venv", "__pycache__", "node_modules"}
    MARKDOWN_EXTENSIONS = {".md"}
    MEDIA_EXTENSIONS = {".pdf", ".jpg", ".jpeg", ".png", ".docx", ".xlsx", ".pptx"}
    INLINE_TAG_PATTERN = re.compile(r"(?<!\w)#([A-Za-z0-9][A-Za-z0-9_/-]*)")
    WIKILINK_PATTERN = re.compile(r"\[\[([^\]]+)\]\]")
    MARKDOWN_LINK_PATTERN = re.compile(r"\[[^\]]+\]\(([^)]+)\)")

    def __init__(self, vault_root: Path):
        """Initialize scanner."""
        self.vault_root = Path(vault_root)

    def should_ignore(self, path: Path) -> bool:
        """Check if path should be ignored."""
        return any(part in self.IGNORE_PATTERNS or part.startswith(".") for part in path.parts)

    def scan_vault(self, scope: str = "all") -> dict:
        """
        Scan vault for all items.

        Args:
            scope: "all", folder pattern like "*/02_Areas/*", or specific path

        Returns:
            Dict with notes, media, and metadata
        """
        results = {
            "vault_root": str(self.vault_root),
            "scope": scope,
            "notes": [],
            "media": [],
            "assets": [],
            "stats": {"total_files": 0, "total_size_bytes": 0},
        }

        # Walk vault
        for file_path in self.vault_root.rglob("*"):
            if not file_path.is_file():
                continue

            if self.should_ignore(file_path):
                continue

            rel_path = file_path.relative_to(self.vault_root)

            # Check scope filter
            if scope != "all" and not self._matches_scope(rel_path, scope):
                continue

            file_size = file_path.stat().st_size
            results["stats"]["total_files"] += 1
            results["stats"]["total_size_bytes"] += file_size

            # Categorize by extension
            if file_path.suffix.lower() in self.MARKDOWN_EXTENSIONS:
                markdown_meta = self._extract_markdown_metadata(file_path)
                results["notes"].append(
                    {
                        "path": str(rel_path),
                        "size_bytes": file_size,
                        "modified": file_path.stat().st_mtime,
                        **markdown_meta,
                    }
                )
            elif file_path.suffix.lower() in self.MEDIA_EXTENSIONS:
                results["media"].append(
                    {
                        "path": str(rel_path),
                        "type": file_path.suffix.lower(),
                        "size_bytes": file_size,
                        "modified": file_path.stat().st_mtime,
                    }
                )
            else:
                results["assets"].append(
                    {
                        "path": str(rel_path),
                        "type": file_path.suffix.lower(),
                        "size_bytes": file_size,
                    }
                )

        return results

    def _matches_scope(self, file_path: Path, scope: str) -> bool:
        """Check if file matches scope pattern."""
        import fnmatch

        path_str = str(file_path).replace("\\", "/")
        return fnmatch.fnmatch(path_str, scope)

    def _extract_markdown_metadata(self, file_path: Path) -> dict:
        """Extract markdown metadata used by inventory and planning phases."""
        metadata = {
            "sha256": "",
            "has_frontmatter": False,
            "frontmatter_keys": [],
            "inline_tags": [],
            "tags": [],
            "wikilinks": [],
            "markdown_links": [],
            "line_count": 0,
            "word_count": 0,
            "char_count": 0,
            "parse_errors": [],
        }

        try:
            raw = file_path.read_bytes()
            text = raw.decode("utf-8", errors="ignore")
            metadata["sha256"] = hashlib.sha256(raw).hexdigest()
            metadata["line_count"] = len(text.splitlines())
            metadata["word_count"] = len(text.split())
            metadata["char_count"] = len(text)
        except Exception as exc:
            metadata["parse_errors"].append(f"read_error: {exc}")
            return metadata

        body = text
        if text.startswith("---\n"):
            parts = text.split("\n---\n", 1)
            if len(parts) == 2:
                metadata["has_frontmatter"] = True
                frontmatter = parts[0].replace("---\n", "", 1)
                body = parts[1]
                metadata["frontmatter_keys"] = self._extract_frontmatter_keys(frontmatter)
                metadata["tags"] = self._extract_frontmatter_tags(frontmatter)
            else:
                metadata["parse_errors"].append("frontmatter_not_closed")

        inline_tags = sorted({m.group(1).lower() for m in self.INLINE_TAG_PATTERN.finditer(body)})
        wikilinks = sorted({m.group(1).strip() for m in self.WIKILINK_PATTERN.finditer(body)})
        markdown_links = sorted(
            {m.group(1).strip() for m in self.MARKDOWN_LINK_PATTERN.finditer(body)}
        )

        metadata["inline_tags"] = inline_tags
        if not metadata["tags"]:
            metadata["tags"] = inline_tags
        metadata["wikilinks"] = wikilinks
        metadata["markdown_links"] = markdown_links
        return metadata

    @staticmethod
    def _extract_frontmatter_keys(frontmatter: str) -> list[str]:
        """Extract top-level frontmatter keys with lightweight parsing."""
        keys: list[str] = []
        for line in frontmatter.splitlines():
            stripped = line.strip()
            if not stripped or stripped.startswith("#"):
                continue
            if ":" in stripped and not stripped.startswith("-"):
                key = stripped.split(":", 1)[0].strip()
                if key:
                    keys.append(key)
        return sorted(set(keys))

    @staticmethod
    def _extract_frontmatter_tags(frontmatter: str) -> list[str]:
        """Extract a normalized tags list from a frontmatter block."""
        tags: list[str] = []
        lines = frontmatter.splitlines()
        in_tags_block = False

        for line in lines:
            stripped = line.strip()
            if stripped.startswith("tags:"):
                value = stripped.split(":", 1)[1].strip()
                if value.startswith("[") and value.endswith("]"):
                    raw_items = value[1:-1].split(",")
                    tags.extend(
                        item.strip().strip("'\"").lstrip("#") for item in raw_items if item.strip()
                    )
                    in_tags_block = False
                else:
                    in_tags_block = True
                continue

            if in_tags_block:
                if stripped.startswith("-"):
                    tag = stripped.lstrip("-").strip().strip("'\"").lstrip("#")
                    if tag:
                        tags.append(tag)
                elif stripped and ":" in stripped:
                    in_tags_block = False
                elif not stripped:
                    continue

        normalized = [t.lower() for t in tags if t]
        return sorted(set(normalized))

    def get_scan_summary(self, results: dict) -> str:
        """Generate human-readable summary."""
        stats = results["stats"]
        notes_count = len(results["notes"])
        media_count = len(results["media"])
        size_mb = stats["total_size_bytes"] / (1024 * 1024)

        summary = f"""
Vault Scan Summary:
  Scope: {results["scope"]}
  Total Files: {stats["total_files"]}
  Notes (*.md): {notes_count}
  Media Files: {media_count}
  Other Assets: {len(results["assets"])}
  Total Size: {size_mb:.2f} MB
"""
        return summary
