"""Tests for suggest-only planning workflow."""

import json
import sqlite3

from voidlink_cli.planning.suggestions import generate_suggestions
from voidlink_cli.policy.loader import AIPolicy


def test_generate_suggestions_writes_artifacts_and_db(tmp_path):
    """Suggestion engine should emit JSON/review files and persist DB entries."""
    scan_results = {
        "notes": [
            {
                "path": "notes/example.md",
                "sha256": "abc123",
                "modified": 123.0,
                "size_bytes": 42,
                "frontmatter_keys": ["title"],
                "tags": ["Project/Test", "topic/AI"],
            },
            {
                "path": "notes/related.md",
                "sha256": "def456",
                "modified": 124.0,
                "size_bytes": 30,
                "frontmatter_keys": ["title"],
                "tags": ["topic/ai"],
            },
        ]
    }
    policy = AIPolicy(
        protected_paths=tuple(),
        llm_excluded_paths=tuple(),
        forbidden_actions=("delete_note", "rewrite_content"),
        allowed_actions=tuple(),
    )

    output_dir = tmp_path / "suggestions"
    db_path = tmp_path / "vault.db"
    result = generate_suggestions(
        scan_results=scan_results,
        required_fields=["title", "tags", "status"],
        policy=policy,
        output_dir=output_dir,
        db_path=db_path,
    )

    assert result["count"] >= 1
    json_files = list(output_dir.glob("*.json"))
    review_files = list(output_dir.glob("*.review.md"))
    assert len(json_files) >= 1
    assert len(review_files) >= 1

    payloads = [json.loads(path.read_text(encoding="utf-8")) for path in json_files]
    assert all(payload["status"] == "pending" for payload in payloads)
    assert "abc123" in {payload["source_sha256"] for payload in payloads}
    assert all("proposed_actions" in payload for payload in payloads)
    assert all("similar_notes" in payload for payload in payloads)

    with sqlite3.connect(db_path) as conn:
        count = conn.execute("SELECT COUNT(*) FROM suggestions").fetchone()[0]
        assert count >= 1


def test_generate_suggestions_skips_sensitive_paths(tmp_path):
    """Suggestion generation should skip policy-sensitive paths."""
    scan_results = {
        "notes": [
            {
                "path": "20_areas/health/private.md",
                "sha256": "abc123",
                "modified": 123.0,
                "size_bytes": 42,
                "frontmatter_keys": ["title"],
                "tags": ["project/x"],
            }
        ]
    }
    policy = AIPolicy(
        protected_paths=tuple(),
        llm_excluded_paths=tuple(),
        forbidden_actions=("delete_note", "rewrite_content"),
        allowed_actions=tuple(),
        sensitive_paths=("20_areas/health/",),
    )

    output_dir = tmp_path / "suggestions"
    db_path = tmp_path / "vault.db"
    result = generate_suggestions(scan_results, ["title", "tags"], policy, output_dir, db_path)
    assert result["count"] == 0
