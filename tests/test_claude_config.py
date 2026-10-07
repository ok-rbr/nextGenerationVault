"""Tests for the Claude Code configuration under .claude/.

The guard hook is the technical form of the vault rules in AGENTS.md: no
personal notes read or written, no ``draft: true`` note changed, no staging
output committed. These tests pin that, and that system files such as the
templates under ``99_system/015_templates/02_areas/`` stay editable.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[1]
CLAUDE_DIR = REPO_ROOT / ".claude"
GUARD = CLAUDE_DIR / "hooks" / "guard.py"


def _guard(payload: dict | str, env: dict[str, str] | None = None) -> subprocess.CompletedProcess:
    data = payload if isinstance(payload, str) else json.dumps(payload)
    environment = {k: v for k, v in os.environ.items() if k != "VOIDLINK_VAULT__ROOT"}
    environment.update({"CLAUDE_PROJECT_DIR": str(REPO_ROOT), **(env or {})})
    # the hook under test is a file of this repository, not untrusted input
    return subprocess.run(  # noqa: S603
        [sys.executable, str(GUARD)],
        input=data,
        capture_output=True,
        text=True,
        check=False,
        env=environment,
    )


def _bash(command: str) -> dict:
    return {"tool_name": "Bash", "tool_input": {"command": command}}


def _file(tool: str, path: str | Path) -> dict:
    return {"tool_name": tool, "tool_input": {"file_path": str(path)}}


@pytest.mark.parametrize(
    "payload",
    [
        _file("Read", REPO_ROOT / "02_areas" / "health" / "note.md"),
        _file("Edit", REPO_ROOT / "01_projects" / "x.md"),
        _file("Write", "04_archive/old.md"),
        _bash("cat 02_areas/health/blood.md"),
        _bash("grep -r iban ./03_resources/"),
        _bash("git add 99_system/ai_staging/scan_full.json"),
        _bash("rm -rf 99_system/_scripts"),
        _bash("git push --force"),
        _bash("git reset --hard"),
        _bash("git clean -fdx"),
        _bash("cat .env"),
        _file("Read", REPO_ROOT / ".env"),
        _file("Edit", REPO_ROOT / ".git" / "config"),
    ],
)
def test_guard_blocks_vault_content_and_destructive_operations(payload: dict) -> None:
    result = _guard(payload)
    assert result.returncode == 2, payload
    assert "blocked by .claude/hooks/guard.py" in result.stderr


@pytest.mark.parametrize(
    "payload",
    [
        _file("Edit", REPO_ROOT / "99_system/015_templates/02_areas/health/training/workout.md"),
        _file("Read", REPO_ROOT / "99_system/05_schemas/frontmatter.schema.json"),
        _file("Edit", REPO_ROOT / "src/voidlink_cli/validation/frontmatter.py"),
        _bash("cat 99_system/015_templates/02_areas/health/training/workout.md"),
        _bash("uv run pytest"),
        _bash("git add .claude tests"),
        _bash("cat > docs.md <<'EOF'\nnever cat 02_areas/health/x.md\nEOF"),
    ],
)
def test_guard_allows_system_files_and_validation(payload: dict) -> None:
    result = _guard(payload)
    assert result.returncode == 0, result.stderr


def test_guard_protects_a_vault_outside_the_repository(tmp_path: Path) -> None:
    note = tmp_path / "02_areas" / "life" / "journal.md"
    env = {"VOIDLINK_VAULT__ROOT": str(tmp_path)}
    assert _guard(_file("Read", note), env).returncode == 2
    staging = tmp_path / "99_system" / "ai_staging" / "plan.json"
    assert _guard(_file("Read", staging), env).returncode == 0


def test_guard_refuses_to_edit_a_draft_note(tmp_path: Path) -> None:
    draft = tmp_path / "draft.md"
    draft.write_text("---\ntitle: idea\ndraft: true\n---\nbody\n", encoding="utf-8")
    final = tmp_path / "final.md"
    final.write_text("---\ntitle: idea\ndraft: false\n---\nbody\n", encoding="utf-8")
    body_only = tmp_path / "body.md"
    body_only.write_text("no frontmatter\ndraft: true\n", encoding="utf-8")

    assert _guard(_file("Edit", draft)).returncode == 2
    assert _guard(_file("Write", draft)).returncode == 2
    assert _guard(_file("Read", draft)).returncode == 0
    assert _guard(_file("Edit", final)).returncode == 0
    assert _guard(_file("Edit", body_only)).returncode == 0


def test_guard_allows_an_unparseable_payload() -> None:
    assert _guard("not json").returncode == 0


def test_settings_register_every_hook_that_exists() -> None:
    settings = json.loads((CLAUDE_DIR / "settings.json").read_text())
    for groups in settings["hooks"].values():
        for group in groups:
            for hook in group["hooks"]:
                script = CLAUDE_DIR / "hooks" / Path(hook["command"]).name
                assert script.is_file(), hook["command"]
                assert os.access(script, os.X_OK), f"{script} is not executable"
    assert "Bash(uv run vault-agent apply:*)" in settings["permissions"]["ask"]


def _frontmatter(path: Path) -> dict[str, str]:
    text = path.read_text()
    assert text.startswith("---\n"), f"{path} has no frontmatter"
    fields = {}
    for line in text.split("---\n", 2)[1].splitlines():
        key, _, value = line.partition(":")
        fields[key.strip()] = value.strip()
    return fields


@pytest.mark.parametrize(
    "path",
    sorted((CLAUDE_DIR / "agents").glob("*.md"))
    + sorted((CLAUDE_DIR / "skills").glob("*/SKILL.md")),
    ids=lambda p: str(p.relative_to(CLAUDE_DIR)),
)
def test_agents_and_skills_carry_name_and_description(path: Path) -> None:
    fields = _frontmatter(path)
    expected = path.parent.name if path.name == "SKILL.md" else path.stem
    assert fields.get("name") == expected
    assert len(fields.get("description", "")) > 40
