"""Tests for AI policy loading and schema metadata requirements."""

import json
from pathlib import Path

import jsonschema
import pytest

from voidlink_cli.policy.loader import (
    AIPolicy,
    find_dead_policy_paths,
    load_ai_policy,
    load_required_frontmatter_fields,
)

REPO_ROOT = Path(__file__).resolve().parents[1]
POLICY_FILE = REPO_ROOT / "99_system" / "ai_policy.yaml"
POLICY_SCHEMA = REPO_ROOT / "99_system" / "05_schemas" / "ai_policy.schema.json"


def test_load_ai_policy_normalizes_paths(tmp_path):
    """Policy loader should normalize path prefixes and expose checks."""
    policy_file = tmp_path / "ai_policy.yaml"
    policy_file.write_text(
        """
protected_paths:
  - "99_system"
llm_excluded_paths:
  - "20_areas/private"
forbidden_actions:
  - "delete_note"
allowed_actions:
  - "normalize_tags"
""",
        encoding="utf-8",
    )

    policy = load_ai_policy(policy_file)
    assert policy.is_protected_path("99_system/file.md")
    assert policy.is_llm_excluded_path("20_areas/private/note.md")
    assert not policy.is_action_allowed("delete_note")
    assert policy.is_action_allowed("normalize_tags")
    assert not policy.is_action_allowed("move_note")


def test_load_required_frontmatter_fields(tmp_path):
    """Schema helper should return required field list from JSON schema."""
    schema = tmp_path / "frontmatter.schema.json"
    schema.write_text(
        json.dumps({"type": "object", "required": ["title", "id", "tags"]}), encoding="utf-8"
    )

    required = load_required_frontmatter_fields(schema)
    assert required == ["title", "id", "tags"]


def test_load_ai_policy_inline_list_values(tmp_path):
    """Policy parser should support inline list values."""
    policy_file = tmp_path / "ai_policy.yaml"
    policy_file.write_text(
        (
            "protected_paths: []\n"
            "llm_excluded_paths: []\n"
            "forbidden_actions: [delete_note]\n"
            "allowed_actions: []\n"
        ),
        encoding="utf-8",
    )

    policy = load_ai_policy(policy_file)
    assert policy.forbidden_actions == ("delete_note",)
    assert policy.allowed_actions == tuple()


def test_policy_sensitive_path_and_pii_detection(tmp_path):
    """Policy should expose sensitive path and PII keyword checks."""
    policy_file = tmp_path / "ai_policy.yaml"
    policy_file.write_text(
        (
            "protected_paths: []\n"
            "llm_excluded_paths: []\n"
            "sensitive_paths: [20_areas/health/]\n"
            "pii_keywords: [passport, iban]\n"
            "forbidden_actions: [delete_note]\n"
            "allowed_actions: []\n"
        ),
        encoding="utf-8",
    )
    policy = load_ai_policy(policy_file)
    assert policy.is_sensitive_path("20_areas/health/note.md")
    assert policy.contains_pii_text("Customer passport number noted")


# Real folder names from the vault inventory. #32: every rule named `20_areas/`
# while the vault uses `02_areas/`, so health and private notes matched nothing.
@pytest.mark.parametrize(
    ("check", "must_match", "must_not_match"),
    [
        ("is_protected_path", "02_areas/health/nutrition/meal.md", "02_areas/botanic/plant.md"),
        ("is_protected_path", "02_areas/safehouse/accounting/q3.md", "02_areas/ideas/idea.md"),
        ("is_llm_excluded_path", "02_areas/health/yoga/session.md", "00_knowledge/01_atomic/a.md"),
        ("is_llm_excluded_path", "02_areas/life/logs/2026-05-01.md", "01_projects/voidsystem/x.md"),
        ("is_llm_excluded_path", "03_resources/people/private/p.md", "03_resources/img/a.md"),
        ("is_llm_excluded_path", "04_archive/Privat/Steuer/2024.md", "04_archive/studium/m.md"),
        ("is_sensitive_path", "02_areas/health/habits/h.md", "02_areas/botanic/plant.md"),
        ("is_sensitive_path", "04_archive/BackUp/WhatsApp/chat.txt", "04_archive/music/a.md"),
    ],
)
def test_repository_policy_matches_real_vault_paths(check, must_match, must_not_match):
    """The shipped policy must apply to the vault's real folders, not near misses."""
    policy = load_ai_policy(POLICY_FILE)
    assert getattr(policy, check)(must_match)
    assert not getattr(policy, check)(must_not_match)


def test_repository_policy_names_no_path_outside_the_vault_roots():
    """A prefix like `20_areas/` is reported without needing the vault."""
    assert find_dead_policy_paths(load_ai_policy(POLICY_FILE)) == []


def test_repository_policy_matches_its_schema():
    """The schema pins every policy path to a vault root."""
    raw = load_ai_policy(POLICY_FILE)
    document = {
        "protected_paths": list(raw.protected_paths),
        "llm_excluded_paths": list(raw.llm_excluded_paths),
        "sensitive_paths": list(raw.sensitive_paths),
        "forbidden_actions": list(raw.forbidden_actions),
        "allowed_actions": list(raw.allowed_actions),
    }
    schema = json.loads(POLICY_SCHEMA.read_text(encoding="utf-8"))
    jsonschema.validate(document, schema)
    with pytest.raises(jsonschema.ValidationError):
        jsonschema.validate({**document, "protected_paths": ["20_areas/health/"]}, schema)


def _policy(**paths: tuple[str, ...]) -> AIPolicy:
    return AIPolicy(
        protected_paths=paths.get("protected_paths", ()),
        llm_excluded_paths=paths.get("llm_excluded_paths", ()),
        sensitive_paths=paths.get("sensitive_paths", ()),
        forbidden_actions=(),
        allowed_actions=(),
    )


def test_find_dead_policy_paths_reports_a_prefix_outside_the_vault_roots():
    """The #32 typo is caught statically."""
    messages = find_dead_policy_paths(_policy(llm_excluded_paths=("20_areas/health/",)))
    assert len(messages) == 1
    assert "llm_excluded_paths: 20_areas/health/ is outside the vault roots" in messages[0]


def test_find_dead_policy_paths_reports_a_missing_folder(tmp_path):
    """A guessed folder that does not exist in the vault is reported."""
    (tmp_path / "02_areas" / "health").mkdir(parents=True)
    policy = _policy(
        protected_paths=("02_areas/health/",),
        sensitive_paths=("02_areas/private/",),
    )
    assert find_dead_policy_paths(policy, tmp_path) == [
        f"sensitive_paths: 02_areas/private/ does not exist in {tmp_path}"
    ]
