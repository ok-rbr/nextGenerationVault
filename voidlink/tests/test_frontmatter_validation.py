"""Tests for full frontmatter validation against the JSON schema."""

import json
import shutil
from pathlib import Path

import pytest
from typer.testing import CliRunner

from voidlink_cli.cli import app
from voidlink_cli.validation.frontmatter import (
    FrontmatterError,
    load_frontmatter_validator,
    parse_frontmatter,
    validate_note_text,
    validate_vault,
    write_frontmatter_report,
)

SCHEMA = Path(__file__).parents[1] / "99_system" / "05_schemas" / "frontmatter.schema.json"

# A note as voidCore's notes/frontmatter.lua writes it; `id` is the file name stem.
NOTE = """---
title: Valid note
aliases: [Valid note]
id: {id}
created: 2024-01-01 12:00
updated: 2024-01-02 08:15
lang: de
category: project
status: active
tags: [project, client/acme_gmbh, tool/entra_id, how-to]
client: acme_gmbh
---

Body.
"""
VALID_NOTE = NOTE.format(id="good")

runner = CliRunner()


@pytest.fixture
def validator():
    return load_frontmatter_validator(SCHEMA)


@pytest.fixture
def vault(tmp_path):
    root = tmp_path / "vault"
    schemas = root / "99_system" / "05_schemas"
    schemas.mkdir(parents=True)
    shutil.copy(SCHEMA, schemas / "frontmatter.schema.json")
    return root


def _write(root: Path, relative: str, content: str) -> Path:
    path = root / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    return path


def test_valid_note_has_no_issues(validator):
    assert validate_note_text(VALID_NOTE, validator, "01_projects/good.md") == []


@pytest.mark.parametrize(
    ("path", "frontmatter"),
    [
        (
            "02_areas/daily/20260921.md",
            "title: Daily Note - 2026-09-21\nid: 20260921\ncreated: 2026-09-21 07:00\n"
            "lang: en\ntags: [daily]\ncategory: daily\ndate: 2026-09-21",
        ),
        (
            "01_projects/acme/20260921_1030_migration.md",
            "title: Migrate tenant\nid: 20260921_1030_migration\ncreated: 2026-09-21 10:30\n"
            "tags: [task]\ncategory: task\nstatus: waiting\nclient: acme\n"
            "project: migration\ndue: ''\nwait_until: 2026-10-01\npriority: H\n"
            "urgency: 8.2\ntask_uuid: 5f0c",
        ),
        (
            "03_resources/clients/acme/acme_client_index.md",
            "title: ACME\nid: acme_client_index\ncreated: 2026-09-21 10:30\n"
            "tags: [client/acme]\ncategory: client\nstatus: active\nclient: acme",
        ),
        (
            "00_knowledge/01_atomic/20260921_1100_idea.md",
            "title: Idea\nid: 20260921_1100_idea\ncreated: 2026-09-21 11:00\n"
            "tags: [knowledge]\ncategory: knowledge\ntype: atomic",
        ),
    ],
)
def test_notes_written_by_voidcore_are_valid(validator, path, frontmatter):
    assert validate_note_text(f"---\n{frontmatter}\n---\n", validator, path) == []


def test_id_must_match_the_file_name_stem(validator):
    issues = validate_note_text(
        NOTE.format(id="20240101_1200"), validator, "01_projects/20240101_1200_good.md"
    )

    assert [(issue.field, issue.message) for issue in issues] == [
        ("id", "'20240101_1200' does not match the file name stem '20240101_1200_good'")
    ]


def test_unquoted_all_digit_id_is_compared_with_the_stem(validator):
    note = (
        "---\ntitle: Day\nid: 20260921\ncreated: 2026-09-21 07:00\ntags: []\ncategory: daily\n---\n"
    )

    assert validate_note_text(note, validator, "20260921.md") == []
    assert [i.field for i in validate_note_text(note, validator, "20260922.md")] == ["id"]


def test_status_is_required_only_where_it_is_queried(validator):
    without_status = VALID_NOTE.replace("status: active\n", "")

    project = validate_note_text(without_status, validator, "good.md")
    area = validate_note_text(
        without_status.replace("category: project", "category: area"), validator, "good.md"
    )

    assert [issue.message for issue in project] == ["'status' is a required property"]
    assert area == []


def test_unquoted_scalars_stay_strings_as_in_obsidian():
    data = parse_frontmatter(
        "---\nid: 20240101_1200\ncreated: 2024-01-01 12:00\nday: 2024-01-01\n"
        "time: 12:30\nflag: yes\ndone: true\ncount: 3\n---\n"
    )
    assert data == {
        "id": "20240101_1200",
        "created": "2024-01-01 12:00",
        "day": "2024-01-01",
        "time": "12:30",
        "flag": "yes",
        "done": True,
        "count": 3,
    }


def test_wrong_types_and_values_are_reported_with_their_field(validator):
    note = VALID_NOTE.replace("tags: [project,", "tags: [Topic Python,")
    note = note.replace("status: active", "status: someday")
    note = note.replace("client: acme_gmbh", "client: acme.migration\nschemaVersion: 0")

    issues = validate_note_text(note, validator, "good.md")

    assert {issue.field for issue in issues} == {"client", "schemaVersion", "status", "tags/0"}
    assert all(issue.path == "good.md" for issue in issues)


def test_missing_required_fields_are_reported(validator):
    issues = validate_note_text("---\ntitle: Only a title\n---\n", validator)
    missing = {issue.message for issue in issues}
    assert missing == {
        f"'{name}' is a required property" for name in ("id", "created", "tags", "category")
    }


@pytest.mark.parametrize(
    ("text", "message"),
    [
        ("# No frontmatter\n", "missing frontmatter"),
        ("---\ntitle: open\n", "frontmatter is not closed"),
        ("---\n- a\n- b\n---\n", "frontmatter must be a mapping"),
        ("---\ntitle: [unclosed\n---\n", "invalid YAML"),
    ],
)
def test_unreadable_frontmatter_is_one_issue(validator, text, message):
    issues = validate_note_text(text, validator)
    assert len(issues) == 1
    assert issues[0].message.startswith(message)


def test_parse_frontmatter_raises_for_unclosed_block():
    with pytest.raises(FrontmatterError):
        parse_frontmatter("---\ntitle: x\n")


def test_vault_skips_system_layer_and_staging_by_default(vault, validator):
    _write(vault, "01_projects/good.md", VALID_NOTE)
    _write(vault, "02_areas/bad.md", "# no frontmatter\n")
    _write(vault, "99_system/01_templates/t.md", "---\nid: {{ id }}\n---\n")
    _write(vault, "99_system/ai_staging/out.md", "# staged\n")
    _write(vault, "README.md", "# repo docs\n")
    _write(vault, ".obsidian/hidden.md", "# ignored\n")

    report = validate_vault(vault, validator)

    assert report.checked == 2
    assert report.skipped == 3
    assert report.notes_with_issues == ["02_areas/bad.md"]


def test_include_system_checks_templates_but_never_staging(vault, validator):
    _write(vault, "99_system/01_templates/t.md", "---\nid: {{ id }}\n---\n")
    _write(vault, "99_system/ai_staging/out.md", "# staged\n")

    report = validate_vault(vault, validator, include_system=True)

    assert report.checked == 1
    assert report.notes_with_issues == ["99_system/01_templates/t.md"]


def test_scope_limits_the_notes(vault, validator):
    _write(vault, "01_projects/a.md", "# a\n")
    _write(vault, "02_areas/b.md", "# b\n")

    report = validate_vault(vault, validator, scope="02_areas/*")

    assert report.notes_with_issues == ["02_areas/b.md"]


def test_explicit_paths_are_checked_alone(vault, validator, tmp_path):
    good = _write(vault, "01_projects/good.md", VALID_NOTE)
    _write(vault, "01_projects/bad.md", "# bad\n")
    outside = _write(tmp_path, "elsewhere.md", VALID_NOTE)
    other = _write(vault, "01_projects/data.json", "{}")

    report = validate_vault(vault, validator, paths=[good, outside, other])

    assert report.checked == 1
    assert [issue.message for issue in report.issues] == ["outside the vault root"]


def test_report_lists_every_issue(vault, validator, tmp_path):
    _write(vault, "01_projects/a.md", "# a\n")
    _write(vault, "02_areas/b.md", "---\ntitle: b\n---\n")
    report = validate_vault(vault, validator)

    paths = write_frontmatter_report(report, tmp_path / "out")

    data = json.loads(paths["frontmatter_validation.json"].read_text(encoding="utf-8"))
    assert data["checked"] == 2
    assert data["notes_with_issues"] == 2
    assert len(data["issues"]) == len(report.issues)
    markdown = paths["frontmatter_validation.md"].read_text(encoding="utf-8")
    assert "## 01_projects/a.md" in markdown
    assert "## 02_areas/b.md" in markdown


def test_cli_exits_1_and_lists_issues(vault, monkeypatch):
    monkeypatch.chdir(vault)
    _write(vault, "01_projects/good.md", VALID_NOTE)
    _write(vault, "02_areas/bad.md", NOTE.format(id="bad").replace("lang: de", "lang: fr"))

    result = runner.invoke(app, ["validate", "frontmatter"])

    assert result.exit_code == 1
    assert "02_areas/bad.md: lang: 'fr' is not one of ['en', 'de']" in result.stdout
    staged = vault / "99_system" / "ai_staging" / "validation" / "frontmatter_validation.md"
    assert staged.exists()


def test_cli_exits_0_for_clean_vault_without_report(vault, monkeypatch):
    monkeypatch.chdir(vault)
    _write(vault, "01_projects/good.md", VALID_NOTE)

    result = runner.invoke(app, ["validate", "frontmatter", "--no-report"])

    assert result.exit_code == 0
    assert not (vault / "99_system" / "ai_staging").exists()


def test_cli_exits_2_without_schema(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    result = runner.invoke(app, ["validate", "frontmatter"])

    assert result.exit_code == 2
