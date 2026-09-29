"""Staging output never enters Git (#43).

``99_system/ai_staging/`` receives vault-agent scans and plans: note paths,
sizes and planned changes of the real vault. Only the placeholder is tracked.
"""

import shutil
import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[1]
STAGING = "99_system/ai_staging"


def _git(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args], cwd=REPO_ROOT, capture_output=True, text=True, check=False
    )


@pytest.fixture(scope="module")
def git_checkout() -> None:
    if shutil.which("git") is None or _git("rev-parse", "--git-dir").returncode != 0:
        pytest.skip("not a git checkout")


def test_only_the_placeholder_is_tracked(git_checkout) -> None:
    tracked = _git("ls-files", "--", STAGING).stdout.split()
    assert tracked == [f"{STAGING}/.gitkeep"]


@pytest.mark.parametrize(
    "path",
    [
        f"{STAGING}/scan_full.json",
        f"{STAGING}/20261001_migration_plan.json",
        f"{STAGING}/runs/20261001_000000_abcdef12/manifest.json",
        f"{STAGING}/suggestions/02_areas/health/note.json",
    ],
)
def test_staging_output_is_ignored(git_checkout, path: str) -> None:
    assert _git("check-ignore", "--no-index", "-q", path).returncode == 0, path


def test_the_placeholder_is_not_ignored(git_checkout) -> None:
    assert _git("check-ignore", "--no-index", "-q", f"{STAGING}/.gitkeep").returncode == 1


def test_pre_commit_rejects_staging_output() -> None:
    config = (REPO_ROOT / ".pre-commit-config.yaml").read_text(encoding="utf-8")
    assert "id: no-ai-staging-output" in config
    assert "language: fail" in config
    assert "exclude: ^99_system/ai_staging/" not in config.replace(
        "exclude: ^99_system/ai_staging/\\.gitkeep$", ""
    ), "a global exclude would hide staging files from the hook"
