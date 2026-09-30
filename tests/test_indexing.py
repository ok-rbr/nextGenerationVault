"""Tests for SQLite index schema initialization."""

import sqlite3

from voidlink_cli.indexing.db import SCHEMA_VERSION, initialize_database


def test_initialize_database_creates_required_tables(tmp_path):
    """Initialize database and verify schema footprint."""
    db_path = initialize_database(tmp_path / "vault.db")
    assert db_path.exists()

    expected_tables = {
        "schema_meta",
        "audit_runs",
        "notes",
        "tags",
        "links",
        "suggestions",
        "approvals",
        "changes",
    }

    with sqlite3.connect(db_path) as conn:
        table_rows = conn.execute("SELECT name FROM sqlite_master WHERE type = 'table';").fetchall()
        tables = {row[0] for row in table_rows}
        assert expected_tables.issubset(tables)

        version = conn.execute(
            "SELECT value FROM schema_meta WHERE key = 'schema_version';"
        ).fetchone()
        assert version is not None
        assert version[0] == SCHEMA_VERSION
