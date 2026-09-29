"""Suggest-only planning workflow with JSON and review artifact output."""

import json
import sqlite3
from dataclasses import asdict, dataclass
from datetime import datetime
from pathlib import Path
from uuid import uuid4

from voidlink_cli.indexing.db import initialize_database
from voidlink_cli.policy.loader import AIPolicy

ALLOWED_ACTIONS = {
    "update_frontmatter",
    "add_frontmatter_field",
    "normalize_tags",
    "move_note",
    "add_alias",
}


def _path_tokens(path: str) -> set[str]:
    parts = path.lower().replace("\\", "/").replace(".md", "").replace("_", " ").split("/")
    tokens: set[str] = set()
    for part in parts:
        tokens.update(word for word in part.split() if len(word) > 2)
    return tokens


def _compute_similarity_score(note: dict, other: dict) -> float:
    if note.get("path") == other.get("path"):
        return 0.0
    score = 0.0
    note_tags = set(note.get("tags", []))
    other_tags = set(other.get("tags", []))
    common_tags = note_tags & other_tags
    score += float(len(common_tags)) * 2.0

    note_links = set(note.get("wikilinks", []))
    other_links = set(other.get("wikilinks", []))
    score += float(len(note_links & other_links))

    note_top = str(note.get("path", "")).split("/", 1)[0]
    other_top = str(other.get("path", "")).split("/", 1)[0]
    if note_top and note_top == other_top:
        score += 1.0

    note_tokens = _path_tokens(note.get("path", ""))
    other_tokens = _path_tokens(other.get("path", ""))
    score += float(len(note_tokens & other_tokens)) * 0.5
    return score


def _find_similar_notes(note: dict, all_notes: list[dict], top_n: int = 5) -> list[str]:
    scored: list[tuple[float, str]] = []
    for other in all_notes:
        score = _compute_similarity_score(note, other)
        path = str(other.get("path", ""))
        if score > 0 and path:
            scored.append((score, path))
    scored.sort(key=lambda item: item[0], reverse=True)
    return [path for _, path in scored[:top_n]]


def _new_run_id() -> str:
    return f"suggest_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{uuid4().hex[:6]}"


@dataclass
class SuggestionAction:
    """A single proposed action for a note."""

    type: str
    field: str | None = None
    new_value: str | list[str] | dict | None = None
    target_path: str | None = None
    reason: str = ""

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class Suggestion:
    """Structured suggestion for a specific note."""

    suggestion_id: str
    run_id: str
    note: dict
    risk: str
    proposed_actions: list[SuggestionAction]
    status: str
    reasoning_summary: str
    requires_manual_review: bool
    source_sha256: str
    mtime: float
    file_size: int
    similar_notes: list[str]

    def to_dict(self) -> dict:
        payload = asdict(self)
        payload["proposed_actions"] = [a.to_dict() for a in self.proposed_actions]
        return payload


def _infer_target_path(path: str, tags: list[str]) -> str | None:
    current = path.replace("\\", "/")
    if current.startswith(("01_projects/", "02_areas/", "03_resources/", "04_archive/")):
        return None

    tag_set = set(tags)
    if any(t.startswith("project/") or t == "project" for t in tag_set):
        return f"01_projects/{Path(current).name}"
    if any(t.startswith("area/") or t == "area" for t in tag_set):
        return f"02_areas/{Path(current).name}"
    if any(t.startswith("resource/") or t == "resource" for t in tag_set):
        return f"03_resources/{Path(current).name}"
    return None


def _validate_suggestion_shape(data: dict) -> None:
    """Lightweight schema validation for required fields and action types."""
    required = {
        "suggestion_id",
        "run_id",
        "note",
        "risk",
        "proposed_actions",
        "status",
        "source_sha256",
        "mtime",
        "file_size",
    }
    missing = [k for k in required if k not in data]
    if missing:
        raise ValueError(f"suggestion missing required fields: {', '.join(sorted(missing))}")

    note = data.get("note", {})
    if not isinstance(note, dict) or "path" not in note or "sha256" not in note:
        raise ValueError("suggestion note block is invalid")

    actions = data.get("proposed_actions", [])
    if not isinstance(actions, list):
        raise ValueError("proposed_actions must be a list")

    for action in actions:
        action_type = action.get("type")
        if action_type not in ALLOWED_ACTIONS:
            raise ValueError(f"unsupported action type: {action_type}")


def _render_review_markdown(suggestion: Suggestion) -> str:
    """Create a readable markdown review artifact for a suggestion."""
    note_path = suggestion.note.get("path", "")
    lines = [
        f"# Review: {note_path}",
        "",
        f"- Suggestion ID: `{suggestion.suggestion_id}`",
        f"- Run ID: `{suggestion.run_id}`",
        f"- Risk: **{suggestion.risk}**",
        f"- Status: `{suggestion.status}`",
        f"- Source SHA256: `{suggestion.source_sha256}`",
        f"- Requires manual review: `{str(suggestion.requires_manual_review).lower()}`",
        "",
        "## Similar notes",
        "",
    ]
    if suggestion.similar_notes:
        lines.extend(f"- {path}" for path in suggestion.similar_notes)
    else:
        lines.append("- none")

    lines.extend(
        [
            "",
            "## Proposed actions",
            "",
        ]
    )

    for action in suggestion.proposed_actions:
        lines.append(f"- `{action.type}`: {action.reason}")
        if action.field:
            lines.append(f"  - field: `{action.field}`")
        if action.target_path:
            lines.append(f"  - target_path: `{action.target_path}`")
        if action.new_value is not None:
            lines.append(f"  - new_value: `{json.dumps(action.new_value, ensure_ascii=False)}`")

    lines.extend(
        [
            "",
            "## Reasoning summary",
            "",
            suggestion.reasoning_summary,
            "",
            "## Approval",
            "",
            "- [ ] approve",
        ]
    )
    return "\n".join(lines) + "\n"


def generate_suggestions(
    scan_results: dict,
    required_fields: list[str],
    policy: AIPolicy,
    output_dir: Path,
    db_path: Path,
) -> dict:
    """Generate suggest-only artifacts and persist suggestion records."""
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    db_path = initialize_database(db_path)

    run_id = _new_run_id()
    now = datetime.now().isoformat()
    suggestions: list[Suggestion] = []

    for note in scan_results.get("notes", []):
        path = note.get("path", "")
        if not path:
            continue
        if policy.is_protected_path(path):
            continue
        is_sensitive = policy.is_sensitive_path(path) or policy.is_llm_excluded_path(path)
        sensitivity_probe = f"{path} {' '.join(str(t) for t in note.get('tags', []))}"
        is_sensitive = is_sensitive or policy.contains_pii_text(sensitivity_probe)
        if is_sensitive:
            continue

        actions: list[SuggestionAction] = []
        current_keys = set(note.get("frontmatter_keys", []))
        tags = note.get("tags", [])
        normalized_tags = sorted({str(tag).lower().lstrip("#") for tag in tags if str(tag).strip()})

        for field in required_fields:
            if field not in current_keys:
                default_value = [] if field in {"tags", "related", "concepts", "aliases"} else ""
                actions.append(
                    SuggestionAction(
                        type="add_frontmatter_field",
                        field=field,
                        new_value=default_value,
                        reason=f"required field `{field}` is missing",
                    )
                )

        if tags and normalized_tags != list(tags):
            actions.append(
                SuggestionAction(
                    type="normalize_tags",
                    field="tags",
                    new_value=normalized_tags,
                    reason="normalize tags to lowercase and remove duplicates",
                )
            )

        target_path = _infer_target_path(path, normalized_tags)
        if target_path and target_path != path:
            actions.append(
                SuggestionAction(
                    type="move_note",
                    target_path=target_path,
                    reason="path does not match inferred PARA category from tags",
                )
            )

        filtered_actions = [a for a in actions if policy.is_action_allowed(a.type)]
        if not filtered_actions:
            continue

        risk = "medium" if any(a.type == "move_note" for a in filtered_actions) else "low"
        suggestion = Suggestion(
            suggestion_id=f"sug_{uuid4().hex[:10]}",
            run_id=run_id,
            note={"path": path, "sha256": note.get("sha256", "")},
            risk=risk,
            proposed_actions=filtered_actions,
            status="pending",
            reasoning_summary="; ".join(a.reason for a in filtered_actions),
            requires_manual_review=True,
            source_sha256=note.get("sha256", ""),
            mtime=float(note.get("modified", 0)),
            file_size=int(note.get("size_bytes", 0)),
            similar_notes=_find_similar_notes(note, scan_results.get("notes", []), top_n=5),
        )

        payload = suggestion.to_dict()
        _validate_suggestion_shape(payload)

        json_path = output_dir / f"{suggestion.suggestion_id}.json"
        review_path = output_dir / f"{suggestion.suggestion_id}.review.md"
        json_path.write_text(
            json.dumps(payload, indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )
        review_path.write_text(_render_review_markdown(suggestion), encoding="utf-8")
        suggestions.append(suggestion)

    with sqlite3.connect(db_path) as conn:
        conn.execute(
            """
            INSERT INTO audit_runs (id, run_type, started_at, finished_at, status)
            VALUES (?, ?, ?, ?, ?)
            """,
            (run_id, "suggest", now, datetime.now().isoformat(), "completed"),
        )
        for suggestion in suggestions:
            note_id = suggestion.note["path"]
            note_sensitive = 1 if policy.is_sensitive_path(note_id) else 0
            conn.execute(
                """
                INSERT OR REPLACE INTO notes (
                    id, path, sha256, mtime, size_bytes,
                    has_frontmatter, frontmatter_valid, protected, sensitive
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    note_id,
                    suggestion.note["path"],
                    suggestion.source_sha256,
                    str(suggestion.mtime),
                    suggestion.file_size,
                    1,
                    1,
                    0,
                    note_sensitive,
                ),
            )
            conn.execute(
                """
                INSERT OR REPLACE INTO suggestions (
                    id, run_id, note_id, source_sha256, risk, status, suggestion_path, review_path
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    suggestion.suggestion_id,
                    run_id,
                    note_id,
                    suggestion.source_sha256,
                    suggestion.risk,
                    suggestion.status,
                    str(output_dir / f"{suggestion.suggestion_id}.json"),
                    str(output_dir / f"{suggestion.suggestion_id}.review.md"),
                ),
            )
        conn.commit()

    return {
        "run_id": run_id,
        "count": len(suggestions),
        "output_dir": str(output_dir),
        "db_path": str(db_path),
    }
