"""Tests for structured apply workflow."""

import json
import sqlite3
import subprocess
from pathlib import Path

from voidlink_cli.apply.workflow import apply_approved_suggestions, preview_approved_suggestions
from voidlink_cli.planning.suggestions import generate_suggestions
from voidlink_cli.policy.loader import AIPolicy
from voidlink_cli.scanning.vault_scanner import VaultScanner


def _init_git_repo(path):
    subprocess.run(["git", "-C", str(path), "init"], check=True, capture_output=True, text=True)
    subprocess.run(
        ["git", "-C", str(path), "config", "user.email", "test@example.com"],
        check=True,
        capture_output=True,
        text=True,
    )
    subprocess.run(
        ["git", "-C", str(path), "config", "user.name", "Test User"],
        check=True,
        capture_output=True,
        text=True,
    )


def test_apply_approved_suggestions_updates_note_and_status(tmp_path):
    """Apply should mutate approved notes and mark suggestion applied."""
    vault = tmp_path / "vault"
    vault.mkdir()
    (vault / "note1.md").write_text("# Title\ncontent", encoding="utf-8")
    _init_git_repo(vault)

    scan_results = VaultScanner(vault).scan_vault()
    scan_results["notes"][0]["tags"] = ["topic/test"]
    policy = AIPolicy(
        protected_paths=tuple(),
        llm_excluded_paths=tuple(),
        forbidden_actions=("delete_note", "rewrite_content"),
        allowed_actions=tuple(),
    )
    output_dir = vault / "99_system" / "ai_staging" / "suggestions"
    db_path = vault / "99_system" / "ai_index" / "vault.db"
    generate_suggestions(scan_results, ["title", "tags"], policy, output_dir, db_path)

    with sqlite3.connect(db_path) as conn:
        conn.execute("UPDATE suggestions SET status = 'approved'")
        conn.commit()

    subprocess.run(
        ["git", "-C", str(vault), "add", "-A"],
        check=True,
        capture_output=True,
        text=True,
    )
    subprocess.run(
        ["git", "-C", str(vault), "commit", "-m", "seed"],
        check=True,
        capture_output=True,
        text=True,
    )

    preview = preview_approved_suggestions(vault, db_path)
    assert preview["total"] == 1

    result = apply_approved_suggestions(vault, db_path, policy)
    assert result["applied"] == 1
    assert result["failed"] == 0
    assert Path(result["change_log"]).exists()
    assert Path(result["rollback_report"]).exists()

    with sqlite3.connect(db_path) as conn:
        status = conn.execute("SELECT status FROM suggestions LIMIT 1").fetchone()[0]
    assert status == "applied"
    content = (vault / "note1.md").read_text(encoding="utf-8")
    assert content.startswith("---")
    change_log = Path(result["change_log"]).read_text(encoding="utf-8")
    assert '"status": "applied"' in change_log


def test_move_updates_links_and_writes_patch(tmp_path):
    """Move action should update path-based links and emit a patch report."""
    vault = tmp_path / "vault"
    vault.mkdir()
    (vault / "notes").mkdir()
    (vault / "notes" / "note1.md").write_text("# Note 1\ncontent", encoding="utf-8")
    (vault / "notes" / "ref.md").write_text(
        "Link [[notes/note1]] and [md](notes/note1.md)",
        encoding="utf-8",
    )
    _init_git_repo(vault)

    scan_results = VaultScanner(vault).scan_vault()
    for note in scan_results["notes"]:
        if note["path"] == "notes/note1.md":
            note["tags"] = ["project/demo"]

    policy = AIPolicy(
        protected_paths=tuple(),
        llm_excluded_paths=tuple(),
        forbidden_actions=("delete_note", "rewrite_content"),
        allowed_actions=tuple(),
    )
    output_dir = vault / "99_system" / "ai_staging" / "suggestions"
    db_path = vault / "99_system" / "ai_index" / "vault.db"
    generate_suggestions(scan_results, ["title", "tags"], policy, output_dir, db_path)

    with sqlite3.connect(db_path) as conn:
        sid = conn.execute(
            "SELECT id FROM suggestions WHERE note_id = 'notes/note1.md' LIMIT 1"
        ).fetchone()[0]
        conn.execute("UPDATE suggestions SET status = 'approved' WHERE id = ?", (sid,))
        conn.commit()

    subprocess.run(
        ["git", "-C", str(vault), "add", "-A"],
        check=True,
        capture_output=True,
        text=True,
    )
    subprocess.run(
        ["git", "-C", str(vault), "commit", "-m", "seed"],
        check=True,
        capture_output=True,
        text=True,
    )

    result = apply_approved_suggestions(vault, db_path, policy)
    assert result["applied"] == 1
    assert not (vault / "notes" / "note1.md").exists()
    assert (vault / "01_projects" / "note1.md").exists()

    ref_content = (vault / "notes" / "ref.md").read_text(encoding="utf-8")
    assert "[[01_projects/note1]]" in ref_content
    assert "(01_projects/note1.md)" in ref_content
    assert (vault / "99_system" / "ai_staging" / "reports" / "diffs" / f"{sid}.patch").exists()
    rollback_text = Path(result["rollback_report"]).read_text(encoding="utf-8")
    assert sid in rollback_text


def test_move_to_protected_path_fails(tmp_path):
    """Apply should fail when move target path is protected."""
    vault = tmp_path / "vault"
    vault.mkdir()
    (vault / "note1.md").write_text("# Note 1\ncontent", encoding="utf-8")
    _init_git_repo(vault)

    scan_results = VaultScanner(vault).scan_vault()
    scan_results["notes"][0]["tags"] = ["project/demo"]
    policy = AIPolicy(
        protected_paths=("99_system/",),
        llm_excluded_paths=tuple(),
        forbidden_actions=("delete_note", "rewrite_content"),
        allowed_actions=tuple(),
    )
    output_dir = vault / "99_system" / "ai_staging" / "suggestions"
    db_path = vault / "99_system" / "ai_index" / "vault.db"
    generate_suggestions(scan_results, ["title", "tags"], policy, output_dir, db_path)

    with sqlite3.connect(db_path) as conn:
        sid = conn.execute("SELECT id FROM suggestions LIMIT 1").fetchone()[0]
        suggestion_path = conn.execute(
            "SELECT suggestion_path FROM suggestions WHERE id = ?", (sid,)
        ).fetchone()[0]
        payload = json.loads(Path(suggestion_path).read_text(encoding="utf-8"))
        for action in payload["proposed_actions"]:
            if action.get("type") == "move_note":
                action["target_path"] = "99_system/blocked.md"
        Path(suggestion_path).write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
        conn.execute("UPDATE suggestions SET status = 'approved' WHERE id = ?", (sid,))
        conn.commit()

    subprocess.run(
        ["git", "-C", str(vault), "add", "-A"],
        check=True,
        capture_output=True,
        text=True,
    )
    subprocess.run(
        ["git", "-C", str(vault), "commit", "-m", "seed"],
        check=True,
        capture_output=True,
        text=True,
    )
    result = apply_approved_suggestions(vault, db_path, policy)
    assert result["failed"] == 1

    with sqlite3.connect(db_path) as conn:
        status = conn.execute("SELECT status FROM suggestions WHERE id = ?", (sid,)).fetchone()[0]
    assert status == "failed"
