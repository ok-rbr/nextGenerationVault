"""The shared system checkout must not track vault contents or local templates."""

import subprocess
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]


def _git(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True, check=False)


@pytest.mark.parametrize(
    "path",
    [
        "00_knowledge/private.md",
        "01_projects/client/project/notes.md",
        "02_areas/work/meetings.md",
        "03_resources/clients/client.md",
        "04_archive/old.md",
        "nvim/.env",
        "99_system/ai_staging/report.json",
        "99_system/attachments/imgs/image.png",
        "99_system/01_templates/01_projects/client/project/template.md",
        "99_system/015_templates/01_projects/client/project/template.md",
        "99_system/015_templates/01_projects/default/customer_project.md",
        "99_system/015_templates/02_areas/health/training/private.md",
        "99_system/015_templates/02_areas/health/training/image.png",
        "99_system/01_templates/01_projects/eldenring/local.md",
        "99_system/01_templates/02_areas/health/private.pdf",
        "99_system/01_templates/02_areas/notes/untitled",
        "99_system/015_templates/02_areas/contacts/local.md",
        "ok_vault_3.1/local.md",
        "ok_vault_experimental/local.md",
        "voidlink/local.md",
    ],
)
def test_local_content_is_ignored(path):
    assert _git("check-ignore", "--no-index", "-q", path).returncode == 0


@pytest.mark.parametrize(
    "path",
    [
        "99_system/015_templates/daily.md",
        "99_system/015_templates/task.md",
        "99_system/015_templates/01_projects/default/projects_task_default.md",
        "99_system/01_templates/01_projects/eldenring/elden-ring-boss-template.md",
    ],
)
def test_reviewed_generic_and_fictional_templates_can_be_tracked(path):
    assert _git("check-ignore", "--no-index", "-q", path).returncode == 1


def test_legacy_vaults_and_machine_config_are_not_tracked():
    paths = _git("ls-files").stdout.splitlines()
    assert all(
        not path.startswith(("ok_vault_3.1/", "ok_vault_experimental/", "voidlink/"))
        for path in paths
    )
    assert "nvim/.env" not in paths
    assert all(
        not path.startswith(
            ("00_knowledge/", "01_projects/", "02_areas/", "03_resources/", "04_archive/")
        )
        for path in paths
    )
