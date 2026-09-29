"""SQLite schema initialization for vault indexing and audit workflows."""

import sqlite3
from pathlib import Path

SCHEMA_VERSION = "1"

DDL_STATEMENTS: tuple[str, ...] = (
    """
    CREATE TABLE IF NOT EXISTS schema_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS audit_runs (
        id TEXT PRIMARY KEY,
        run_type TEXT NOT NULL,
        started_at TEXT NOT NULL,
        finished_at TEXT,
        status TEXT NOT NULL,
        git_commit_before TEXT,
        git_commit_after TEXT
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS notes (
        id TEXT PRIMARY KEY,
        path TEXT NOT NULL UNIQUE,
        sha256 TEXT NOT NULL,
        mtime TEXT NOT NULL,
        size_bytes INTEGER NOT NULL,
        has_frontmatter INTEGER NOT NULL DEFAULT 0,
        frontmatter_valid INTEGER NOT NULL DEFAULT 0,
        protected INTEGER NOT NULL DEFAULT 0,
        sensitive INTEGER NOT NULL DEFAULT 0
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS tags (
        id TEXT PRIMARY KEY,
        note_id TEXT NOT NULL,
        name TEXT NOT NULL,
        normalized_name TEXT NOT NULL,
        count INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS links (
        id TEXT PRIMARY KEY,
        source_note_id TEXT NOT NULL,
        target_raw TEXT NOT NULL,
        resolved INTEGER NOT NULL DEFAULT 0,
        broken INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (source_note_id) REFERENCES notes(id) ON DELETE CASCADE
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS suggestions (
        id TEXT PRIMARY KEY,
        run_id TEXT NOT NULL,
        note_id TEXT NOT NULL,
        source_sha256 TEXT NOT NULL,
        risk TEXT NOT NULL,
        status TEXT NOT NULL,
        suggestion_path TEXT NOT NULL,
        review_path TEXT,
        FOREIGN KEY (run_id) REFERENCES audit_runs(id) ON DELETE CASCADE,
        FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS approvals (
        suggestion_id TEXT PRIMARY KEY,
        decision TEXT NOT NULL,
        decided_at TEXT NOT NULL,
        decided_by TEXT NOT NULL,
        FOREIGN KEY (suggestion_id) REFERENCES suggestions(id) ON DELETE CASCADE
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS changes (
        id TEXT PRIMARY KEY,
        suggestion_id TEXT NOT NULL,
        action_type TEXT NOT NULL,
        status TEXT NOT NULL,
        applied_at TEXT,
        error_message TEXT,
        FOREIGN KEY (suggestion_id) REFERENCES suggestions(id) ON DELETE CASCADE
    );
    """,
    """
    CREATE INDEX IF NOT EXISTS idx_notes_path ON notes(path);
    """,
    """
    CREATE INDEX IF NOT EXISTS idx_tags_note_id ON tags(note_id);
    """,
    """
    CREATE INDEX IF NOT EXISTS idx_tags_normalized_name ON tags(normalized_name);
    """,
    """
    CREATE INDEX IF NOT EXISTS idx_links_source ON links(source_note_id);
    """,
    """
    CREATE INDEX IF NOT EXISTS idx_suggestions_status ON suggestions(status);
    """,
    """
    CREATE INDEX IF NOT EXISTS idx_suggestions_note_id ON suggestions(note_id);
    """,
)


def initialize_database(db_path: Path) -> Path:
    """Create the SQLite database and ensure required tables/indexes exist."""
    db_path = Path(db_path)
    db_path.parent.mkdir(parents=True, exist_ok=True)

    with sqlite3.connect(db_path) as conn:
        conn.execute("PRAGMA foreign_keys = ON;")
        for statement in DDL_STATEMENTS:
            conn.execute(statement)
        conn.execute(
            """
            INSERT INTO schema_meta (key, value)
            VALUES ('schema_version', ?)
            ON CONFLICT(key) DO UPDATE SET value = excluded.value;
            """,
            (SCHEMA_VERSION,),
        )
        conn.commit()

    return db_path
