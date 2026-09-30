"""Tests for review workflow helpers."""

import sqlite3

from voidlink_cli.planning.suggestions import generate_suggestions
from voidlink_cli.policy.loader import AIPolicy
from voidlink_cli.review.workflow import (
    approve_suggestion,
    list_pending_suggestions,
    reject_suggestion,
    show_suggestion,
    sync_review_files,
)


def _seed_suggestion(tmp_path):
    scan_results = {
        "notes": [
            {
                "path": "notes/example.md",
                "sha256": "abc123",
                "modified": 123.0,
                "size_bytes": 42,
                "frontmatter_keys": ["title"],
                "tags": ["topic/ai"],
            }
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
    generate_suggestions(scan_results, ["title", "tags"], policy, output_dir, db_path)
    with sqlite3.connect(db_path) as conn:
        sid = conn.execute("SELECT id FROM suggestions LIMIT 1").fetchone()[0]
    return db_path, output_dir, sid


def test_review_workflow_approve_reject_and_show(tmp_path):
    """Review helper functions should update suggestion status."""
    db_path, _, sid = _seed_suggestion(tmp_path)

    pending = list_pending_suggestions(db_path)
    assert len(pending) == 1

    data = show_suggestion(db_path, sid)
    assert data["id"] == sid
    assert data["payload"]["status"] == "pending"

    approve_suggestion(db_path, sid, "tester")
    with sqlite3.connect(db_path) as conn:
        status = conn.execute("SELECT status FROM suggestions WHERE id = ?", (sid,)).fetchone()[0]
    assert status == "approved"

    reject_suggestion(db_path, sid, "tester")
    with sqlite3.connect(db_path) as conn:
        status = conn.execute("SELECT status FROM suggestions WHERE id = ?", (sid,)).fetchone()[0]
    assert status == "rejected"


def test_review_sync_marks_checked_items(tmp_path):
    """Sync should mark pending suggestion approved from review markdown checkbox."""
    db_path, output_dir, sid = _seed_suggestion(tmp_path)
    review_file = output_dir / f"{sid}.review.md"
    review_file.write_text(
        review_file.read_text(encoding="utf-8") + "\n- [x] approve\n",
        encoding="utf-8",
    )

    result = sync_review_files(db_path, "sync-user")
    assert result["updated"] == 1

    with sqlite3.connect(db_path) as conn:
        status = conn.execute("SELECT status FROM suggestions WHERE id = ?", (sid,)).fetchone()[0]
    assert status == "approved"
