"""Tests for vault-agent CLI."""

import sqlite3
import subprocess

from typer.testing import CliRunner

from voidlink_cli.cli import app

runner = CliRunner()


def test_help():
    """Test --help output."""
    result = runner.invoke(app, ["--help"])
    assert result.exit_code == 0
    assert "vault-agent" in result.stdout


def test_init_command(tmp_path):
    """Test init command creates directories and manifest."""
    result = runner.invoke(app, ["init", "--vault-root", str(tmp_path)])
    assert result.exit_code == 0
    assert "Vault root" in result.stdout
    assert "Staging dir" in result.stdout


def test_health_command(tmp_path, monkeypatch):
    """Test health command uses the vault root from VOIDLINK_VAULT__ROOT."""
    monkeypatch.chdir(tmp_path)
    vault_root = tmp_path / "vault"
    vault_root.mkdir()
    result = runner.invoke(app, ["health"], env={"VOIDLINK_VAULT__ROOT": str(vault_root)})
    assert result.exit_code == 0
    assert "Health check passed" in result.stdout
    assert f"Vault root: {vault_root}" in result.stdout
    assert (vault_root / "99_system" / "ai_index" / "vault.db").is_file()


def test_validate_schemas_command(tmp_path, monkeypatch):
    """Test validate schemas with mock vault."""
    (tmp_path / "cwd").mkdir()
    monkeypatch.chdir(tmp_path / "cwd")
    # Create minimal vault structure
    vault_root = tmp_path / "vault"
    vault_root.mkdir()
    (vault_root / ".gitignore").write_text(
        "99_system/ai_index/\n99_system/ai_staging/\n",
        encoding="utf-8",
    )
    (vault_root / "note1.md").write_text("# Note 1\ntest content")
    (vault_root / "note2.md").write_text("# Note 2\nmore content")

    result = runner.invoke(
        app,
        ["validate", "schemas", "--scope", "all"],
        env={"VOIDLINK_VAULT__ROOT": str(vault_root)},
    )
    assert result.exit_code == 0
    assert "Notes (*.md): 2" in result.stderr


def test_validate_inventory_command(tmp_path, monkeypatch):
    """Test inventory report generation command."""
    (tmp_path / "cwd").mkdir()
    monkeypatch.chdir(tmp_path / "cwd")
    vault_root = tmp_path / "vault"
    vault_root.mkdir()
    (vault_root / "note1.md").write_text("# Note 1\ntest content", encoding="utf-8")

    result = runner.invoke(
        app,
        ["validate", "inventory", "--scope", "all"],
        env={"VOIDLINK_VAULT__ROOT": str(vault_root)},
    )
    assert result.exit_code == 0
    assert "Inventory reports" in result.stdout
    assert (vault_root / "99_system" / "ai_staging" / "inventory" / "vault_summary.md").is_file()


def test_ingest_hevy_command():
    """Test ingest hevy subcommand placeholder."""
    result = runner.invoke(app, ["ingest", "hevy"])
    assert result.exit_code == 0
    assert "ingest hevy command" in result.stdout


def test_plan_para_command(tmp_path, monkeypatch):
    """Test plan para with mock vault."""
    (tmp_path / "cwd").mkdir()
    monkeypatch.chdir(tmp_path / "cwd")
    vault_root = tmp_path / "vault"
    vault_root.mkdir()
    (vault_root / "note1.md").write_text("# Note 1")
    (vault_root / "01_Projects").mkdir(parents=True, exist_ok=True)
    (vault_root / "01_Projects" / "proj1.md").write_text("# Project 1")

    result = runner.invoke(
        app,
        ["plan", "para", "--scope", "all"],
        env={"VOIDLINK_VAULT__ROOT": str(vault_root)},
    )
    assert result.exit_code == 0
    assert "Notes (*.md): 2" in result.stderr


def test_plan_suggest_command(tmp_path, monkeypatch):
    """Test suggest-only planning command with mock vault."""
    monkeypatch.chdir(tmp_path)
    vault_root = tmp_path / "vault"
    vault_root.mkdir()
    (tmp_path / "vault-agent.yml").write_text(
        f'[vault]\nroot = "{vault_root}"\n',
        encoding="utf-8",
    )
    (vault_root / "note1.md").write_text("# Note 1\n#tag/test", encoding="utf-8")
    (vault_root / "99_system").mkdir(parents=True, exist_ok=True)
    (vault_root / "99_system" / "ai_policy.yaml").write_text(
        (
            "protected_paths: []\n"
            "llm_excluded_paths: []\n"
            "forbidden_actions: [delete_note]\n"
            "allowed_actions: []\n"
        ),
        encoding="utf-8",
    )
    (vault_root / "99_system" / "05_schemas").mkdir(parents=True, exist_ok=True)
    (vault_root / "99_system" / "05_schemas" / "frontmatter.schema.json").write_text(
        '{"required": ["title", "tags"]}',
        encoding="utf-8",
    )

    result = runner.invoke(
        app,
        ["plan", "suggest", "--scope", "all"],
    )
    assert result.exit_code == 0
    assert "Suggestions generated" in result.stdout


def test_plan_suggest_warns_about_a_policy_path_that_matches_nothing(tmp_path, monkeypatch):
    """A dead policy prefix is reported instead of silently protecting nothing (#32)."""
    monkeypatch.chdir(tmp_path)
    vault_root = tmp_path / "vault"
    (vault_root / "02_areas" / "health").mkdir(parents=True)
    (tmp_path / "vault-agent.yml").write_text(
        f'[vault]\nroot = "{vault_root}"\n',
        encoding="utf-8",
    )
    (vault_root / "note1.md").write_text("# Note 1\n#tag/test", encoding="utf-8")
    (vault_root / "99_system" / "05_schemas").mkdir(parents=True)
    (vault_root / "99_system" / "ai_policy.yaml").write_text(
        (
            "protected_paths: [02_areas/health/]\n"
            "llm_excluded_paths: [20_areas/health/, 02_areas/private/]\n"
            "forbidden_actions: [delete_note]\n"
            "allowed_actions: []\n"
        ),
        encoding="utf-8",
    )
    (vault_root / "99_system" / "05_schemas" / "frontmatter.schema.json").write_text(
        '{"required": ["title", "tags"]}',
        encoding="utf-8",
    )

    result = runner.invoke(app, ["plan", "suggest", "--scope", "all"])

    assert result.exit_code == 0
    assert "llm_excluded_paths: 20_areas/health/ is outside the vault roots" in result.stderr
    assert "llm_excluded_paths: 02_areas/private/ does not exist" in result.stderr
    assert "02_areas/health/" not in result.stderr


def test_review_commands_flow(tmp_path, monkeypatch):
    """Test review pending/show/approve commands."""
    monkeypatch.chdir(tmp_path)
    vault_root = tmp_path / "vault"
    vault_root.mkdir()
    (tmp_path / "vault-agent.yml").write_text(
        f'[vault]\nroot = "{vault_root}"\n',
        encoding="utf-8",
    )
    (vault_root / ".gitignore").write_text(
        "99_system/ai_index/\n99_system/ai_staging/\n",
        encoding="utf-8",
    )
    (vault_root / "note1.md").write_text("# Note 1\n#tag/test", encoding="utf-8")
    (vault_root / "99_system").mkdir(parents=True, exist_ok=True)
    (vault_root / "99_system" / "ai_policy.yaml").write_text(
        (
            "protected_paths: []\n"
            "llm_excluded_paths: []\n"
            "forbidden_actions: [delete_note]\n"
            "allowed_actions: []\n"
        ),
        encoding="utf-8",
    )
    (vault_root / "99_system" / "05_schemas").mkdir(parents=True, exist_ok=True)
    (vault_root / "99_system" / "05_schemas" / "frontmatter.schema.json").write_text(
        '{"required": ["title", "tags"]}',
        encoding="utf-8",
    )

    suggest_result = runner.invoke(app, ["plan", "suggest", "--scope", "all"])
    assert suggest_result.exit_code == 0

    db_path = vault_root / "99_system" / "ai_index" / "vault.db"
    with sqlite3.connect(db_path) as conn:
        suggestion_id = conn.execute("SELECT id FROM suggestions LIMIT 1").fetchone()[0]

    pending = runner.invoke(app, ["review", "pending"])
    assert pending.exit_code == 0
    assert suggestion_id in pending.stdout

    show = runner.invoke(app, ["review", "show", suggestion_id])
    assert show.exit_code == 0
    assert suggestion_id in show.stdout

    approve = runner.invoke(app, ["review", "approve", suggestion_id])
    assert approve.exit_code == 0
    assert "approved" in approve.stdout


def test_review_pending_command(tmp_path, monkeypatch):
    """Test review pending subcommand with empty queue."""
    monkeypatch.chdir(tmp_path)
    vault_root = tmp_path / "vault"
    vault_root.mkdir()
    (tmp_path / "vault-agent.yml").write_text(
        f'[vault]\nroot = "{vault_root}"\n',
        encoding="utf-8",
    )
    result = runner.invoke(app, ["review", "pending"])
    assert result.exit_code == 0
    assert "No pending suggestions." in result.stdout


def test_apply_preview_and_commit_commands(tmp_path, monkeypatch):
    """Test apply preview/commit in clean git repo with empty approval queue."""
    monkeypatch.chdir(tmp_path)
    vault_root = tmp_path / "vault"
    vault_root.mkdir()
    (vault_root / ".gitignore").write_text(
        "99_system/ai_index/\n99_system/ai_staging/\n",
        encoding="utf-8",
    )
    (tmp_path / "vault-agent.yml").write_text(
        f'[vault]\nroot = "{vault_root}"\n',
        encoding="utf-8",
    )
    subprocess.run(
        ["git", "-C", str(vault_root), "init"],
        check=True,
        capture_output=True,
        text=True,
    )
    subprocess.run(
        ["git", "-C", str(vault_root), "config", "user.email", "test@example.com"],
        check=True,
        capture_output=True,
        text=True,
    )
    subprocess.run(
        ["git", "-C", str(vault_root), "config", "user.name", "Test User"],
        check=True,
        capture_output=True,
        text=True,
    )
    subprocess.run(
        ["git", "-C", str(vault_root), "add", "-A"],
        check=True,
        capture_output=True,
        text=True,
    )
    subprocess.run(
        ["git", "-C", str(vault_root), "commit", "-m", "init"],
        check=True,
        capture_output=True,
        text=True,
    )

    preview = runner.invoke(app, ["apply", "preview"])
    assert preview.exit_code == 0
    assert "Approved suggestions" in preview.stdout

    result = runner.invoke(app, ["apply", "commit", "--approved-only"])
    assert result.exit_code == 0
    assert "applied=0" in result.stdout
