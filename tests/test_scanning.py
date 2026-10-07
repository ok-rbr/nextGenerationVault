"""Tests for vault scanning and markdown metadata extraction."""

from pathlib import Path

from voidlink_cli.scanning.vault_scanner import VaultScanner


def test_scan_extracts_markdown_metadata(tmp_path):
    """Scanner should extract frontmatter keys, tags, links, and content metrics."""
    note = tmp_path / "note.md"
    note.write_text(
        """---
title: "Example"
tags:
  - topic/ai
  - project/voidlink
status: active
---

# Heading
Inline tag #topic/ml
Link to [[Related Note]] and [GitHub](https://github.com).
""",
        encoding="utf-8",
    )

    scanner = VaultScanner(tmp_path)
    result = scanner.scan_vault()
    assert len(result["notes"]) == 1

    entry = result["notes"][0]
    assert entry["has_frontmatter"] is True
    assert "title" in entry["frontmatter_keys"]
    assert set(entry["tags"]) == {"project/voidlink", "topic/ai"}
    assert entry["sha256"]
    assert entry["wikilinks"] == ["Related Note"]
    assert entry["markdown_links"] == ["https://github.com"]
    assert entry["line_count"] > 0
    assert entry["word_count"] > 0


def test_scan_falls_back_to_inline_tags_without_frontmatter(tmp_path):
    """Scanner should expose inline tags as tags when frontmatter tags are absent."""
    note = tmp_path / "note.md"
    note.write_text("No FM but #topic/test and #Area/MixedCase tags.", encoding="utf-8")

    scanner = VaultScanner(tmp_path)
    result = scanner.scan_vault()
    entry = result["notes"][0]

    assert entry["has_frontmatter"] is False
    assert set(entry["inline_tags"]) == {"area/mixedcase", "topic/test"}
    assert set(entry["tags"]) == {"area/mixedcase", "topic/test"}


def test_scan_excludes_repository_tooling_and_symlinks(tmp_path):
    for directory in ("nvim", "src", "tests", "scripts", "ok_vault_experimental"):
        path = tmp_path / directory
        path.mkdir()
        (path / "README.md").write_text("# Not a vault note", encoding="utf-8")

    notes = tmp_path / "00_knowledge"
    notes.mkdir()
    (notes / "example.md").write_text("# Example", encoding="utf-8")
    outside = tmp_path.parent / f"{tmp_path.name}_external_note.md"
    outside.write_text("# Outside", encoding="utf-8")
    (notes / "linked.md").symlink_to(outside)

    result = VaultScanner(tmp_path).scan_vault()
    assert [note["path"] for note in result["notes"]] == [str(Path("00_knowledge/example.md"))]
