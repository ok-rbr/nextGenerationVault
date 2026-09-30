"""Ingestion may not cross vault boundaries, bypass review or commit private data."""

import subprocess

import pytest

from voidlink_cli.ingest.folder_ingester import FolderIngester


def test_folder_scope_matches_only_descendants(tmp_path, monkeypatch):
    for name in ("client", "other_client"):
        folder = tmp_path / "01_projects" / name
        folder.mkdir(parents=True)
        (folder / "note.md").write_text("# Test", encoding="utf-8")

    ingester = FolderIngester(tmp_path, "01_projects/client")
    processed = []
    monkeypatch.setattr(ingester, "_process_note", lambda note: processed.append(note["path"]))
    monkeypatch.setattr(ingester.reviewer, "prompt_confirm_all", lambda summary: False)
    ingester.ingest()

    assert processed == ["01_projects/client/note.md"]


def test_folder_path_must_stay_inside_the_vault(tmp_path):
    outside = tmp_path.parent / (tmp_path.name + "_outside")
    outside.mkdir()
    (tmp_path / "escape").symlink_to(outside, target_is_directory=True)

    for path in ("../", str(outside), "escape"):
        with pytest.raises(ValueError, match="inside the vault"):
            FolderIngester(tmp_path, path)


def test_noninteractive_ingest_is_rejected(tmp_path):
    with pytest.raises(ValueError, match="interactive approval"):
        FolderIngester(tmp_path, ".", interactive=False).ingest()


def test_excluded_work_note_never_reaches_the_llm(tmp_path, monkeypatch):
    policy = tmp_path / "99_system"
    policy.mkdir()
    (policy / "ai_policy.yaml").write_text('llm_excluded_paths:\n  - "01_projects/"\n')
    folder = tmp_path / "01_projects" / "client"
    folder.mkdir(parents=True)
    (folder / "note.md").write_text("# Private work note")

    class FakeLLM:
        available = True

        def __init__(self, debug=False):
            pass

        def extract_frontmatter(self, content):
            raise AssertionError("excluded note was sent to LLM")

        def classify_para_with_llm(self, *args):
            raise AssertionError("excluded note was sent to LLM")

    monkeypatch.setattr("voidlink_cli.ingest.folder_ingester.OllamaClient", FakeLLM)
    ingester = FolderIngester(tmp_path, "01_projects/client", use_llm=True)
    ingester._process_note({"path": "01_projects/client/note.md", "tags": []})
    assert ingester.modifications[0].status == "approved"


def test_ingest_does_not_stage_or_commit_unrelated_files(tmp_path, monkeypatch):
    subprocess.run(["git", "-C", str(tmp_path), "init"], check=True, capture_output=True)
    subprocess.run(
        ["git", "-C", str(tmp_path), "config", "user.email", "test@example.com"],
        check=True,
    )
    subprocess.run(
        ["git", "-C", str(tmp_path), "config", "user.name", "Test User"],
        check=True,
    )
    folder = tmp_path / "00_knowledge"
    folder.mkdir()
    (folder / "example.md").write_text("# Example")
    subprocess.run(["git", "-C", str(tmp_path), "add", "00_knowledge"], check=True)
    subprocess.run(
        ["git", "-C", str(tmp_path), "commit", "-m", "seed"],
        check=True,
        capture_output=True,
    )
    (tmp_path / "private.md").write_text("# Not for version control")
    ingester = FolderIngester(tmp_path, "00_knowledge")
    monkeypatch.setattr(ingester.reviewer, "prompt_confirm_all", lambda summary: True)
    ingester.ingest()

    status = subprocess.run(
        ["git", "-C", str(tmp_path), "status", "--porcelain"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    assert status == "?? private.md\n"
