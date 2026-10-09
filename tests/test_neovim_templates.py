"""Tests for the Neovim templates under 99_system/015_templates/.

voidCore's lua/notes/templates.lua instantiates them: it strips a `location:`
line from the frontmatter, prompts for every `{{ variable }}` it finds and sets
`id` to the file name stem. These tests render a template the same way and
check that the note it produces is valid.
"""

import re
from pathlib import Path

import pytest

from voidlink_cli.validation.frontmatter import load_frontmatter_validator, validate_note_text

ROOT = Path(__file__).parents[1]
TEMPLATES = ROOT / "99_system" / "015_templates"
SCHEMA = ROOT / "99_system" / "05_schemas" / "frontmatter.schema.json"
DASHBOARD = TEMPLATES / "00_knowledge" / "vault_dashboard.md"

# The same patterns templates.lua uses (Lua patterns translated to regex).
PLACEHOLDER = re.compile(r"\{\{\s*(\w+)\s*\}\}")
LOCATION = re.compile(r"\nlocation:\s*[\"']?([^\"'\n]+)[\"']?\s*\n")
DATAVIEW_BLOCK = re.compile(r"```dataview\n(.*?)```", re.DOTALL)


def render(template: str, values: dict[str, str]) -> tuple[str, str | None]:
    """Instantiate a template like templates.lua: return (content, location)."""
    match = LOCATION.search(template)
    location = match.group(1).strip() if match else None
    content = LOCATION.sub("\n", template, count=1)
    return PLACEHOLDER.sub(lambda m: values[m.group(1)], content), location


@pytest.fixture
def dashboard() -> str:
    return DASHBOARD.read_text(encoding="utf-8")


def test_dashboard_prompts_only_for_the_title(dashboard):
    # id and created are supplied by Neovim; anything else would be an extra
    # prompt every time the dashboard is created.
    assert set(PLACEHOLDER.findall(dashboard)) == {"title", "id", "created"}


def test_dashboard_renders_to_a_valid_note(dashboard):
    content, location = render(
        dashboard,
        {"title": "Vault Dashboard", "id": "vault_dashboard", "created": "2026-09-25 17:06"},
    )

    assert location == "00_knowledge"
    assert "\nlocation:" not in content
    issues = validate_note_text(
        content, load_frontmatter_validator(SCHEMA), f"{location}/vault_dashboard.md"
    )
    assert issues == []


def test_dashboard_covers_every_query_of_issue_5(dashboard):
    queries = DATAVIEW_BLOCK.findall(dashboard)

    assert any("GROUP BY" in q and "02_areas" in q for q in queries)  # notes per area
    assert any("file.inlinks" in q for q in queries)  # orphans
    assert any("!tags" in q for q in queries)  # notes without tags
    assert any(q.startswith("TASK") and '"01_projects"' in q for q in queries)  # open tasks
    assert any("file.mtime DESC" in q and "LIMIT 10" in q for q in queries)  # recent


def test_dashboard_queries_skip_system_and_contain_no_placeholders(dashboard):
    for query in DATAVIEW_BLOCK.findall(dashboard):
        assert not PLACEHOLDER.search(query)
        source = re.search(r"^FROM (.+)$", query, re.MULTILINE).group(1)
        # A query over the whole vault would count templates and schemas.
        assert source.startswith(('-"99_system"', '"0', "#"))


TRAINING = TEMPLATES / "02_areas" / "health" / "training"
TRAINING_VALUES = {
    "title": "Pull Up",
    "created": "2026-09-26 18:00",
    "current_date": "2026-09-26",
    "exercise_ref": "pull_up",
    "movement_pattern": "pull",
    "primary_muscle_group": "lats",
    "routine_ref": "pull_day_a",
    "period_start": "2026-09-01",
    "period_end": "2026-09-30",
}
# Template -> (location, placeholders besides title, id and created).
TRAINING_TEMPLATES = {
    "exercise.md": (
        "02_areas/health/training/exercises",
        {"exercise_ref", "movement_pattern", "primary_muscle_group"},
    ),
    "training_routine.md": ("02_areas/health/training/routines", {"routine_ref"}),
    "workout.md": ("02_areas/health/training/workouts", {"current_date", "routine_ref"}),
    "training_evaluation.md": (
        "02_areas/health/training/evaluations",
        {"period_start", "period_end"},
    ),
}


def render_training(name: str) -> tuple[str, str | None]:
    stem = name.removesuffix(".md")
    return render((TRAINING / name).read_text(encoding="utf-8"), {**TRAINING_VALUES, "id": stem})


@pytest.mark.parametrize("name", TRAINING_TEMPLATES)
def test_training_templates_prompt_only_for_what_they_need(name):
    template = (TRAINING / name).read_text(encoding="utf-8")
    expected = {"title", "id", "created"} | TRAINING_TEMPLATES[name][1]
    assert set(PLACEHOLDER.findall(template)) == expected


@pytest.mark.parametrize("name", TRAINING_TEMPLATES)
def test_training_templates_render_to_valid_notes(name):
    content, location = render_training(name)

    assert location == TRAINING_TEMPLATES[name][0]
    issues = validate_note_text(content, load_frontmatter_validator(SCHEMA), f"{location}/{name}")
    assert issues == []


@pytest.mark.parametrize("name", ["training_routine.md", "workout.md"])
def test_training_template_examples_complete_the_note(name):
    # The YAML example in the body is what the user pastes into frontmatter;
    # with it the note must pass as an active routine or completed workout.
    content, location = render_training(name)
    example = re.search(r"```yaml\n(.*?)```", content, re.DOTALL).group(1)
    status = "active" if name == "training_routine.md" else "completed"
    frontmatter, body = content.removeprefix("---\n").split("\n---\n", 1)
    frontmatter = re.sub(r"^(exercises|entries): \[\]\n", "", frontmatter, flags=re.MULTILINE)
    frontmatter = re.sub(r'^status: "\w+"', f'status: "{status}"', frontmatter, flags=re.MULTILINE)
    note = f"---\n{frontmatter}\n{example}---\n{body}"

    issues = validate_note_text(note, load_frontmatter_validator(SCHEMA), f"{location}/{name}")
    assert issues == []


@pytest.mark.parametrize("name", TRAINING_TEMPLATES)
def test_training_queries_skip_system_and_contain_no_placeholders(name):
    queries = DATAVIEW_BLOCK.findall((TRAINING / name).read_text(encoding="utf-8"))

    assert queries
    for query in queries:
        assert not PLACEHOLDER.search(query)
        assert re.search(r'^FROM #training AND -"99_system"$', query, re.MULTILINE)


@pytest.mark.parametrize("name", ["daily.md", "task.md"])
def test_global_neovim_templates_render_valid_notes(name):
    template = (TEMPLATES / name).read_text(encoding="utf-8")
    values = {
        "title": "Example",
        "id": "example_note",
        "created": "2026-09-30 12:00",
        "date": "2026-09-30",
        "previous": "20260929",
        "next": "20261001",
        "client": "",
        "project": "",
        "due": "",
        "wait_until": "",
        "priority": "",
        "task_uuid": "",
    }
    content, location = render(template, values)
    if name == "daily.md":
        location = "02_areas/life/logs/daily"
        values["id"] = "20260930"
        content, _ = render(template, values)
    assert not PLACEHOLDER.search(content)
    assert (
        validate_note_text(
            content, load_frontmatter_validator(SCHEMA), f"{location}/{values['id']}.md"
        )
        == []
    )


@pytest.mark.parametrize(
    "name",
    [
        "projects_daily_default.md",
        "projects_weekly_default.md",
        "projects_meetings_default.md",
        "projects_docs_default.md",
        "projects_task_default.md",
    ],
)
def test_generic_work_templates_generate_valid_local_notes(name):
    template = (TEMPLATES / "01_projects" / "default" / name).read_text(encoding="utf-8")
    values = {
        "title": "Example",
        "id": "example_note",
        "created": "2026-09-30 12:00",
        "created_date": "2026-09-30",
        "client_slug": "example",
        "project_slug": "sample",
        "due": "",
        "wait_until": "",
        "priority": "",
        "task_uuid": "",
    }
    content, location = render(template, values)
    location = PLACEHOLDER.sub(lambda match: values[match.group(1)], location)
    assert location.startswith("01_projects/example/sample/")
    assert not PLACEHOLDER.search(content)
    assert (
        validate_note_text(
            content, load_frontmatter_validator(SCHEMA), f"{location}/example_note.md"
        )
        == []
    )


def test_monthly_notes_created_by_neovim_are_in_the_schema():
    template = (TEMPLATES / "monthly.md").read_text(encoding="utf-8")
    assert '"monthly"' in SCHEMA.read_text(encoding="utf-8")
    assert template.startswith("---\n")


def test_neovim_expands_and_validates_variable_template_locations():
    source = (ROOT / "nvim/lua/notes/templates.lua").read_text(encoding="utf-8")
    assert 'extract_variables(template_content .. "\\n" .. (template_location or ""))' in source
    assert "replace_variables(template_location, values)" in source
    assert 'location:find("{{%s*[%w_]+%s*}}")' in source


MEDIA = TEMPLATES / "03_resources" / "media"


@pytest.mark.parametrize("name", ["manga", "book", "series", "movie", "default"])
def test_media_templates_render_to_valid_notes(name):
    template = (MEDIA / f"media_{name}.md").read_text(encoding="utf-8")
    values = {
        "title": "Berserk",
        "creator": "Kentaro Miura",
        "medium": "game",
        "id": "berserk",
        "created": "2026-09-25 17:06",
    }
    assert set(PLACEHOLDER.findall(template)) <= set(values)
    content, location = render(template, values)

    assert location == "03_resources/media"
    issues = validate_note_text(
        content, load_frontmatter_validator(SCHEMA), f"{location}/berserk.md"
    )
    assert issues == []
