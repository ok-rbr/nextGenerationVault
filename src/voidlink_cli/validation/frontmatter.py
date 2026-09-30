"""Validate note frontmatter against the frontmatter JSON schema.

Read-only: notes are parsed and checked, never modified. Reports go to the
staging directory chosen by the caller.
"""

import fnmatch
import json
import re
from dataclasses import asdict, dataclass, field
from pathlib import Path, PurePosixPath

import yaml
from jsonschema import Draft202012Validator

from voidlink_cli.scanning.vault_scanner import VaultScanner

# Staging holds unconfirmed tool output and is never validated.
STAGING_PREFIX = "99_system/ai_staging/"
# The system layer is not made of notes: templates carry `{{ id }}` and
# `<% tp.date.now() %>` placeholders, the rest is documentation for this
# repository. It is skipped unless the caller asks for it.
SYSTEM_PREFIX = "99_system/"
SYSTEM_ROOT_FILES = frozenset({"README.md", "AGENTS.md", "CLAUDE.md"})
# Training note types and the list of exercises in them that `order` sequences.
TRAINING_LIST_TYPES = {"training_routine": "exercises", "workout": "entries"}


class _FrontmatterLoader(yaml.SafeLoader):
    """SafeLoader with YAML 1.2 core scalars, as Obsidian reads frontmatter.

    PyYAML follows YAML 1.1, which turns `20240101_1200` into an int,
    `12:30` into 750, `yes` into True and `2024-01-01` into a date. Obsidian
    keeps all of these as strings, so the schema must see them as strings too.
    """


_REPLACED_TAGS = {
    "tag:yaml.org,2002:bool",
    "tag:yaml.org,2002:int",
    "tag:yaml.org,2002:timestamp",
}
_FrontmatterLoader.yaml_implicit_resolvers = {
    first: [(tag, regexp) for tag, regexp in resolvers if tag not in _REPLACED_TAGS]
    for first, resolvers in yaml.SafeLoader.yaml_implicit_resolvers.items()
}
_FrontmatterLoader.add_implicit_resolver(
    "tag:yaml.org,2002:bool",
    re.compile(r"^(?:true|True|TRUE|false|False|FALSE)$"),
    list("tTfF"),
)
_FrontmatterLoader.add_implicit_resolver(
    "tag:yaml.org,2002:int",
    re.compile(r"^(?:[-+]?[0-9]+|0o[0-7]+|0x[0-9a-fA-F]+)$"),
    list("-+0123456789"),
)


class FrontmatterError(ValueError):
    """Raised when a frontmatter block cannot be read."""


@dataclass(frozen=True)
class FrontmatterIssue:
    """One problem found in a note's frontmatter."""

    path: str
    field: str
    message: str


@dataclass
class FrontmatterReport:
    """Result of validating a set of notes."""

    checked: int = 0
    skipped: int = 0
    issues: list[FrontmatterIssue] = field(default_factory=list)

    @property
    def notes_with_issues(self) -> list[str]:
        return sorted({issue.path for issue in self.issues})

    @property
    def ok(self) -> bool:
        return not self.issues


def load_frontmatter_validator(schema_path: Path) -> Draft202012Validator:
    """Load the frontmatter schema and return a validator for it."""
    schema = json.loads(Path(schema_path).read_text(encoding="utf-8"))
    Draft202012Validator.check_schema(schema)
    return Draft202012Validator(schema)


def parse_frontmatter(text: str) -> dict | None:
    """Return the parsed frontmatter mapping, or None if the note has none."""
    lines = text.removeprefix("﻿").splitlines()
    if not lines or lines[0].rstrip() != "---":
        return None

    for index, line in enumerate(lines[1:], start=1):
        if line.rstrip() in {"---", "..."}:
            block = "\n".join(lines[1:index])
            break
    else:
        raise FrontmatterError("frontmatter is not closed")

    try:
        data = yaml.load(block, Loader=_FrontmatterLoader)
    except yaml.YAMLError as exc:
        problem = getattr(exc, "problem", None) or str(exc)
        mark = getattr(exc, "problem_mark", None)
        where = f" (line {mark.line + 2})" if mark is not None else ""
        raise FrontmatterError(f"invalid YAML: {problem}{where}") from exc

    if data is None:
        return {}
    if not isinstance(data, dict):
        raise FrontmatterError("frontmatter must be a mapping")
    return data


def validate_note_text(
    text: str, validator: Draft202012Validator, path: str = ""
) -> list[FrontmatterIssue]:
    """Validate the frontmatter of one note's text."""
    try:
        data = parse_frontmatter(text)
    except FrontmatterError as exc:
        return [FrontmatterIssue(path, "", str(exc))]

    if data is None:
        return [FrontmatterIssue(path, "", "missing frontmatter")]

    errors = sorted(validator.iter_errors(data), key=lambda e: [str(p) for p in e.absolute_path])
    issues = [
        FrontmatterIssue(path, "/".join(str(p) for p in error.absolute_path), error.message)
        for error in errors
    ]

    # The id is the wiki-link target and must equal the file name stem
    # (voidCore ADR-005); JSON Schema cannot compare a value with the file name.
    # An all-digit id such as a daily note's `20260921` reads as an integer.
    note_id = data.get("id")
    if isinstance(note_id, int) and not isinstance(note_id, bool):
        note_id = str(note_id)
    stem = PurePosixPath(path).stem
    if path and isinstance(note_id, str) and note_id != stem:
        issues.append(
            FrontmatterIssue(path, "id", f"{note_id!r} does not match the file name stem {stem!r}")
        )
    issues.extend(_training_issues(data, path))
    return issues


def _training_issues(data: dict, path: str) -> list[FrontmatterIssue]:
    """Cross-field rules of training notes that JSON Schema cannot express."""
    issues = []
    note_type = data.get("type")
    if not isinstance(note_type, str):
        return issues

    # `order` sequences a routine or workout and keeps superset members in
    # place (voidApi#36); two entries at the same position make it ambiguous.
    list_field = TRAINING_LIST_TYPES.get(note_type)
    entries = data.get(list_field) if list_field else None
    if isinstance(entries, list):
        seen: set[int] = set()
        for index, entry in enumerate(entries):
            order = entry.get("order") if isinstance(entry, dict) else None
            if not isinstance(order, int):
                continue
            if order in seen:
                issues.append(
                    FrontmatterIssue(
                        path, f"{list_field}/{index}/order", f"order {order} is used twice"
                    )
                )
            seen.add(order)

    if note_type == "training_evaluation":
        start, end = data.get("period_start"), data.get("period_end")
        # ISO dates compare correctly as strings; the schema checks the format.
        if isinstance(start, str) and isinstance(end, str) and end < start:
            issues.append(
                FrontmatterIssue(path, "period_end", f"{end!r} is before period_start {start!r}")
            )
    return issues


def is_excluded(relative_path: str, include_system: bool = False) -> bool:
    """Return True for paths that are not notes and are skipped."""
    if relative_path.startswith(STAGING_PREFIX):
        return True
    if include_system:
        return False
    return relative_path.startswith(SYSTEM_PREFIX) or relative_path in SYSTEM_ROOT_FILES


def _iter_vault_notes(vault_root: Path, scope: str) -> list[Path]:
    scanner = VaultScanner(vault_root)
    notes = []
    for file_path in sorted(vault_root.rglob("*.md")):
        relative = file_path.relative_to(vault_root)
        if not file_path.is_file() or file_path.is_symlink() or scanner.should_ignore(relative):
            continue
        if scope != "all" and not fnmatch.fnmatch(relative.as_posix(), scope):
            continue
        notes.append(file_path)
    return notes


def validate_vault(
    vault_root: Path,
    validator: Draft202012Validator,
    scope: str = "all",
    paths: list[Path] | None = None,
    include_system: bool = False,
) -> FrontmatterReport:
    """Validate notes in the vault, or only `paths` when given."""
    vault_root = Path(vault_root).resolve()
    report = FrontmatterReport()

    candidates = (
        [Path(p) for p in paths if Path(p).suffix.lower() == ".md"]
        if paths is not None
        else _iter_vault_notes(vault_root, scope)
    )

    for candidate in candidates:
        absolute = candidate if candidate.is_absolute() else Path.cwd() / candidate
        absolute = absolute.resolve()
        try:
            relative = absolute.relative_to(vault_root).as_posix()
        except ValueError:
            report.issues.append(FrontmatterIssue(str(candidate), "", "outside the vault root"))
            continue

        if is_excluded(relative, include_system):
            report.skipped += 1
            continue

        report.checked += 1
        try:
            text = absolute.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError) as exc:
            report.issues.append(FrontmatterIssue(relative, "", f"cannot read note: {exc}"))
            continue
        report.issues.extend(validate_note_text(text, validator, relative))

    return report


def write_frontmatter_report(report: FrontmatterReport, output_dir: Path) -> dict[str, Path]:
    """Write the report as Markdown and JSON into `output_dir`."""
    output_dir.mkdir(parents=True, exist_ok=True)

    json_path = output_dir / "frontmatter_validation.json"
    json_path.write_text(
        json.dumps(
            {
                "checked": report.checked,
                "skipped": report.skipped,
                "notes_with_issues": len(report.notes_with_issues),
                "issues": [asdict(issue) for issue in report.issues],
            },
            indent=2,
            ensure_ascii=False,
        )
        + "\n",
        encoding="utf-8",
    )

    lines = [
        "# Frontmatter validation",
        "",
        f"- Notes checked: {report.checked}",
        f"- Notes skipped: {report.skipped}",
        f"- Notes with issues: {len(report.notes_with_issues)}",
        f"- Issues: {len(report.issues)}",
        "",
    ]
    if report.ok:
        lines.append("All checked notes match the frontmatter schema.")
    else:
        current = None
        for issue in sorted(report.issues, key=lambda i: (i.path, i.field)):
            if issue.path != current:
                if current is not None:
                    lines.append("")
                current = issue.path
                lines.extend([f"## {issue.path}", ""])
            location = f"`{issue.field}`: " if issue.field else ""
            lines.append(f"- {location}{issue.message}")
    md_path = output_dir / "frontmatter_validation.md"
    md_path.write_text("\n".join(lines).rstrip("\n") + "\n", encoding="utf-8")

    return {"frontmatter_validation.md": md_path, "frontmatter_validation.json": json_path}
