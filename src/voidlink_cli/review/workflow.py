"""SQLite-backed review operations for suggestion lifecycle management."""

import json
import sqlite3
from datetime import datetime
from pathlib import Path

from voidlink_cli.indexing.db import initialize_database


def _connect(db_path: Path) -> sqlite3.Connection:
    db_path = initialize_database(db_path)
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    return conn


def list_pending_suggestions(db_path: Path) -> list[dict]:
    """Return pending suggestions ordered by newest first."""
    with _connect(db_path) as conn:
        rows = conn.execute(
            """
            SELECT s.id, s.note_id, s.risk, s.status, s.suggestion_path, s.review_path
            FROM suggestions s
            WHERE s.status = 'pending'
            ORDER BY s.id DESC
            """
        ).fetchall()
    return [dict(row) for row in rows]


def show_suggestion(db_path: Path, suggestion_id: str) -> dict:
    """Load a suggestion payload from its stored JSON path."""
    with _connect(db_path) as conn:
        row = conn.execute(
            """
            SELECT id, note_id, risk, status, suggestion_path, review_path
            FROM suggestions
            WHERE id = ?
            """,
            (suggestion_id,),
        ).fetchone()
    if row is None:
        raise ValueError(f"suggestion not found: {suggestion_id}")

    payload = dict(row)
    suggestion_path = Path(payload["suggestion_path"])
    if suggestion_path.exists():
        payload["payload"] = json.loads(suggestion_path.read_text(encoding="utf-8"))
    else:
        payload["payload"] = None
    return payload


def _decide_suggestion(
    db_path: Path, suggestion_id: str, decision: str, decided_by: str
) -> tuple[str, str]:
    if decision not in {"approved", "rejected"}:
        raise ValueError(f"invalid decision: {decision}")

    with _connect(db_path) as conn:
        row = conn.execute("SELECT id FROM suggestions WHERE id = ?", (suggestion_id,)).fetchone()
        if row is None:
            raise ValueError(f"suggestion not found: {suggestion_id}")

        conn.execute("UPDATE suggestions SET status = ? WHERE id = ?", (decision, suggestion_id))
        conn.execute(
            """
            INSERT INTO approvals (suggestion_id, decision, decided_at, decided_by)
            VALUES (?, ?, ?, ?)
            ON CONFLICT(suggestion_id) DO UPDATE SET
                decision = excluded.decision,
                decided_at = excluded.decided_at,
                decided_by = excluded.decided_by
            """,
            (suggestion_id, decision, datetime.now().isoformat(), decided_by),
        )
        conn.commit()
    return suggestion_id, decision


def approve_suggestion(db_path: Path, suggestion_id: str, decided_by: str) -> tuple[str, str]:
    """Approve a suggestion and persist reviewer metadata."""
    return _decide_suggestion(db_path, suggestion_id, "approved", decided_by)


def reject_suggestion(db_path: Path, suggestion_id: str, decided_by: str) -> tuple[str, str]:
    """Reject a suggestion and persist reviewer metadata."""
    return _decide_suggestion(db_path, suggestion_id, "rejected", decided_by)


def sync_review_files(db_path: Path, decided_by: str) -> dict:
    """Apply markdown checkbox decisions (`- [x] approve`) to SQLite status."""
    updated = 0
    with _connect(db_path) as conn:
        rows = conn.execute(
            "SELECT id, review_path FROM suggestions WHERE status = 'pending'"
        ).fetchall()
        for row in rows:
            review_path = Path(row["review_path"]) if row["review_path"] else None
            if not review_path or not review_path.exists():
                continue
            content = review_path.read_text(encoding="utf-8")
            if "- [x] approve" in content.lower():
                conn.execute(
                    "UPDATE suggestions SET status = 'approved' WHERE id = ?",
                    (row["id"],),
                )
                conn.execute(
                    """
                    INSERT INTO approvals (suggestion_id, decision, decided_at, decided_by)
                    VALUES (?, 'approved', ?, ?)
                    ON CONFLICT(suggestion_id) DO UPDATE SET
                        decision = excluded.decision,
                        decided_at = excluded.decided_at,
                        decided_by = excluded.decided_by
                    """,
                    (row["id"], datetime.now().isoformat(), decided_by),
                )
                updated += 1
        conn.commit()
    return {"updated": updated}
