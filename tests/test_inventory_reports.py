"""Tests for inventory report generation."""

import json

from voidlink_cli.scanning.inventory_reports import generate_inventory_reports


def test_generate_inventory_reports_writes_expected_artifacts(tmp_path):
    """Report generator should produce the full artifact set."""
    scan_results = {
        "vault_root": str(tmp_path),
        "scope": "all",
        "notes": [
            {
                "path": "01_projects/p1.md",
                "has_frontmatter": True,
                "frontmatter_keys": ["title", "id", "created", "tags"],
                "tags": ["project/x", "topic/a"],
                "parse_errors": [],
                "wikilinks": ["missing-note"],
                "markdown_links": ["https://example.com"],
            },
            {
                "path": "03_resources/r1.md",
                "has_frontmatter": False,
                "frontmatter_keys": [],
                "tags": ["topic/a"],
                "parse_errors": [],
                "wikilinks": [],
                "markdown_links": [],
            },
        ],
        "media": [],
        "assets": [],
        "stats": {"total_files": 2},
    }

    output_dir = tmp_path / "inventory"
    paths = generate_inventory_reports(scan_results, output_dir, required_fields=["title", "tags"])

    expected = {
        "vault_summary.md",
        "missing_metadata.md",
        "duplicate_tags.md",
        "orphan_notes.md",
        "broken_links.md",
        "frontmatter_keys.md",
        "parser_errors.md",
        "known_context.json",
    }
    assert expected == set(paths)
    for file_path in paths.values():
        assert file_path.exists()

    known_context = json.loads((output_dir / "known_context.json").read_text(encoding="utf-8"))
    assert "known_tags" in known_context
    assert "folder_patterns" in known_context
