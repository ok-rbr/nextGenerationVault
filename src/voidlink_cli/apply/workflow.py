"""Structured apply pipeline for approved suggestion artifacts."""

import difflib
import json
import sqlite3
import subprocess
from datetime import datetime
from pathlib import Path
from uuid import uuid4

from voidlink_cli.indexing.db import initialize_database
from voidlink_cli.policy.loader import AIPolicy
from voidlink_cli.scanning.vault_scanner import VaultScanner


def _connect(db_path: Path) -> sqlite3.Connection:
    db_path = initialize_database(db_path)
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    return conn


def _git_clean(vault_root: Path) -> bool:
    result = subprocess.run(
        ["git", "-C", str(vault_root), "status", "--porcelain"],
        capture_output=True,
        text=True,
        check=False,
    )
    return result.returncode == 0 and result.stdout.strip() == ""


def _load_approved_rows(db_path: Path) -> list[sqlite3.Row]:
    with _connect(db_path) as conn:
        return conn.execute(
            """
            SELECT
                s.id, s.note_id, s.source_sha256, s.suggestion_path,
                s.review_path, s.risk, a.decided_by
            FROM suggestions s
            LEFT JOIN approvals a ON a.suggestion_id = s.id
            WHERE s.status = 'approved'
            ORDER BY s.id
            """
        ).fetchall()


def _is_stale(current_sha: str, source_sha: str) -> bool:
    return bool(current_sha and source_sha and current_sha != source_sha)


def _extract_frontmatter(content: str) -> tuple[dict[str, object], str]:
    if not content.startswith("---\n"):
        return {}, content
    parts = content.split("\n---\n", 1)
    if len(parts) != 2:
        return {}, content
    fm_block = parts[0].replace("---\n", "", 1)
    body = parts[1]
    metadata: dict[str, object] = {}
    current_list_key: str | None = None
    for raw in fm_block.splitlines():
        line = raw.rstrip()
        if not line.strip():
            continue
        if line.startswith("  - ") and current_list_key:
            existing = metadata.get(current_list_key, [])
            if isinstance(existing, list):
                existing.append(line.replace("  - ", "", 1).strip().strip("'\""))
                metadata[current_list_key] = existing
            continue
        if ":" in line:
            key, value = line.split(":", 1)
            key = key.strip()
            value = value.strip()
            if not value:
                metadata[key] = []
                current_list_key = key
                continue
            current_list_key = None
            if value.startswith("[") and value.endswith("]"):
                inner = value[1:-1].strip()
                metadata[key] = (
                    [] if not inner else [item.strip().strip("'\"") for item in inner.split(",")]
                )
            else:
                metadata[key] = value.strip("'\"")
    return metadata, body


def _render_frontmatter(metadata: dict[str, object], body: str) -> str:
    lines = ["---"]
    for key in sorted(metadata.keys()):
        value = metadata[key]
        if isinstance(value, list):
            lines.append(f"{key}:")
            for item in value:
                lines.append(f"  - {item}")
        else:
            lines.append(f"{key}: {value}")
    lines.append("---")
    return "\n".join(lines) + "\n\n" + body.lstrip("\n")


def _relative_path(vault_root: Path, absolute_path: Path) -> str:
    return str(absolute_path.relative_to(vault_root)).replace("\\", "/")


def _iter_vault_markdown_files(vault_root: Path) -> list[Path]:
    files: list[Path] = []
    scanner = VaultScanner(vault_root)
    for path in vault_root.rglob("*.md"):
        if not path.is_file() or path.is_symlink():
            continue
        relative = path.relative_to(vault_root)
        if (
            scanner.should_ignore(relative)
            or relative.parts[0] == "99_system"
            or relative.as_posix() in {"README.md", "AGENTS.md", "CLAUDE.md"}
        ):
            continue
        files.append(path)
    return files


def _update_links_after_move(vault_root: Path, old_rel: str, new_rel: str, policy: AIPolicy) -> int:
    """Update path-based wiki/markdown links after note move."""
    old_no_ext = old_rel[:-3] if old_rel.endswith(".md") else old_rel
    new_no_ext = new_rel[:-3] if new_rel.endswith(".md") else new_rel
    updated_files = 0

    for file_path in _iter_vault_markdown_files(vault_root):
        rel = _relative_path(vault_root, file_path)
        if policy.is_protected_path(rel):
            continue
        content = file_path.read_text(encoding="utf-8")
        new_content = content

        new_content = new_content.replace(f"[[{old_no_ext}]]", f"[[{new_no_ext}]]")
        new_content = new_content.replace(f"({old_rel})", f"({new_rel})")
        new_content = new_content.replace(f"({old_no_ext})", f"({new_no_ext})")

        if new_content != content:
            file_path.write_text(new_content, encoding="utf-8")
            updated_files += 1

    return updated_files


def _write_patch_report(
    vault_root: Path,
    suggestion_id: str,
    before_path: str,
    before_content: str,
    after_path: str,
    after_content: str,
) -> Path:
    """Write unified diff patch for applied note changes."""
    diff_lines = list(
        difflib.unified_diff(
            before_content.splitlines(keepends=True),
            after_content.splitlines(keepends=True),
            fromfile=f"a/{before_path}",
            tofile=f"b/{after_path}",
            lineterm="",
        )
    )
    reports_dir = vault_root / "99_system" / "ai_staging" / "reports" / "diffs"
    reports_dir.mkdir(parents=True, exist_ok=True)
    patch_path = reports_dir / f"{suggestion_id}.patch"
    patch_path.write_text("".join(diff_lines) + "\n", encoding="utf-8")
    return patch_path


def _append_change_log(vault_root: Path, entries: list[dict]) -> Path:
    """Append JSONL change log entries for the current apply run."""
    reports_dir = vault_root / "99_system" / "ai_staging" / "reports"
    reports_dir.mkdir(parents=True, exist_ok=True)
    log_path = reports_dir / "change_log.jsonl"
    with open(log_path, "a", encoding="utf-8") as handle:
        for entry in entries:
            handle.write(json.dumps(entry, ensure_ascii=False) + "\n")
    return log_path


def _write_rollback_report(vault_root: Path, run_id: str, entries: list[dict]) -> Path:
    """Generate markdown rollback guidance for applied changes."""
    reports_dir = vault_root / "99_system" / "ai_staging" / "reports"
    reports_dir.mkdir(parents=True, exist_ok=True)
    rollback_path = reports_dir / "rollback.md"
    applied_entries = [entry for entry in entries if entry.get("status") == "applied"]

    lines = [
        "# Rollback Guide",
        "",
        f"- Run ID: `{run_id}`",
        f"- Generated: `{datetime.now().isoformat()}`",
        "",
    ]
    if not applied_entries:
        lines.append("No applied changes to rollback.")
    else:
        lines.extend(["## Applied changes", ""])
        for entry in applied_entries:
            lines.extend(
                [
                    f"- Suggestion `{entry['suggestion_id']}`: "
                    f"`{entry.get('before_path', '')}` -> `{entry.get('after_path', '')}`",
                    f"  - Patch: `{entry.get('patch_path', '')}`",
                    f"  - Reviewer: `{entry.get('approved_by', 'unknown')}`",
                    (
                        "  - Restore command: "
                        f'`git -C "{vault_root}" checkout -- "{entry.get("after_path", "")}"`'
                    ),
                ]
            )
    rollback_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return rollback_path


def _apply_note_actions(
    vault_root: Path, note_path: Path, actions: list[dict], policy: AIPolicy
) -> tuple[Path, str, str, int]:
    vault_root = vault_root.resolve()
    if note_path.is_symlink() or not note_path.resolve().is_relative_to(vault_root):
        raise ValueError("note path must stay inside the vault")
    if not note_path.exists():
        raise FileNotFoundError(f"note not found: {note_path}")
    note_rel = _relative_path(vault_root, note_path)
    if policy.is_protected_path(note_rel):
        raise ValueError(f"path blocked by policy: {note_rel}")

    before_content = note_path.read_text(encoding="utf-8")
    metadata, body = _extract_frontmatter(before_content)
    current_path = note_path
    link_updates = 0

    for action in actions:
        action_type = action.get("type", "")
        if not policy.is_action_allowed(action_type):
            raise ValueError(f"action blocked by policy: {action_type}")
        if action_type == "delete_note":
            raise ValueError("delete_note is forbidden")

        if action_type in {"add_frontmatter_field", "update_frontmatter"}:
            field = action.get("field")
            if not field:
                raise ValueError("frontmatter action missing field")
            metadata[field] = action.get("new_value", "")
        elif action_type == "normalize_tags":
            metadata["tags"] = action.get("new_value", [])
        elif action_type == "add_alias":
            aliases = metadata.get("aliases", [])
            if not isinstance(aliases, list):
                aliases = []
            new_alias = action.get("new_value")
            if new_alias and new_alias not in aliases:
                aliases.append(new_alias)
            metadata["aliases"] = aliases
        elif action_type == "move_note":
            target_rel = action.get("target_path")
            if not isinstance(target_rel, str) or not target_rel:
                raise ValueError("move_note missing target_path")
            target_path = Path(target_rel)
            if target_path.is_absolute() or target_path.suffix != ".md":
                raise ValueError("move target must be a relative Markdown path")
            target_abs = (vault_root / target_path).resolve()
            if not target_abs.is_relative_to(vault_root):
                raise ValueError("move target must stay inside the vault")
            target_rel = target_abs.relative_to(vault_root).as_posix()
            old_rel = _relative_path(vault_root, note_path)
            if policy.is_protected_path(target_rel):
                raise ValueError(f"target path blocked by policy: {target_rel}")
            if target_abs.exists() or (vault_root / target_path).is_symlink():
                raise FileExistsError(f"target already exists: {target_rel}")
            target_abs.parent.mkdir(parents=True, exist_ok=True)
            note_path.rename(target_abs)
            link_updates += _update_links_after_move(
                vault_root=vault_root,
                old_rel=old_rel,
                new_rel=target_rel,
                policy=policy,
            )
            note_path = target_abs
            current_path = target_abs
        else:
            raise ValueError(f"unsupported action: {action_type}")

    after_content = _render_frontmatter(metadata, body)
    note_path.write_text(after_content, encoding="utf-8")
    return current_path, before_content, after_content, link_updates


def preview_approved_suggestions(vault_root: Path, db_path: Path) -> dict:
    """Preview count/risk/staleness for approved suggestions."""
    scanner = VaultScanner(vault_root)
    scan_results = scanner.scan_vault()
    sha_by_path = {n.get("path"): n.get("sha256", "") for n in scan_results.get("notes", [])}

    rows = _load_approved_rows(db_path)
    stale = 0
    for row in rows:
        current_sha = sha_by_path.get(row["note_id"], "")
        if _is_stale(current_sha, row["source_sha256"]):
            stale += 1
    return {"total": len(rows), "stale": stale, "ready": len(rows) - stale}


def apply_approved_suggestions(vault_root: Path, db_path: Path, policy: AIPolicy) -> dict:
    """Apply approved suggestions with staleness and policy checks."""
    if not _git_clean(vault_root):
        raise RuntimeError("git working tree is not clean; aborting apply")

    scanner = VaultScanner(vault_root)
    scan_results = scanner.scan_vault()
    sha_by_path = {n.get("path"): n.get("sha256", "") for n in scan_results.get("notes", [])}

    rows = _load_approved_rows(db_path)
    run_id = f"apply_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{uuid4().hex[:6]}"
    applied = 0
    stale = 0
    failed = 0
    change_entries: list[dict] = []

    with _connect(db_path) as conn:
        conn.execute(
            """
            INSERT INTO audit_runs (id, run_type, started_at, status)
            VALUES (?, 'apply', ?, 'running')
            """,
            (run_id, datetime.now().isoformat()),
        )

        for row in rows:
            suggestion_id = row["id"]
            note_rel = row["note_id"]
            current_sha = sha_by_path.get(note_rel, "")
            if _is_stale(current_sha, row["source_sha256"]):
                conn.execute(
                    "UPDATE suggestions SET status = 'stale' WHERE id = ?",
                    (suggestion_id,),
                )
                change_entries.append(
                    {
                        "run_id": run_id,
                        "timestamp": datetime.now().isoformat(),
                        "suggestion_id": suggestion_id,
                        "status": "stale",
                        "before_path": note_rel,
                        "after_path": note_rel,
                        "approved_by": row["decided_by"] or "unknown",
                        "error": "stale_source_hash",
                    }
                )
                stale += 1
                continue

            payload = json.loads(Path(row["suggestion_path"]).read_text(encoding="utf-8"))
            actions = payload.get("proposed_actions", [])

            try:
                before_path = note_rel
                final_path, before_content, after_content, link_updates = _apply_note_actions(
                    vault_root, vault_root / note_rel, actions, policy
                )
                after_path = _relative_path(vault_root, final_path)
                patch_path = _write_patch_report(
                    vault_root=vault_root,
                    suggestion_id=suggestion_id,
                    before_path=before_path,
                    before_content=before_content,
                    after_path=after_path,
                    after_content=after_content,
                )
                conn.execute(
                    "UPDATE suggestions SET status = 'applied' WHERE id = ?",
                    (suggestion_id,),
                )
                conn.execute(
                    """
                    INSERT INTO changes (
                        id, suggestion_id, action_type, status, applied_at, error_message
                    )
                    VALUES (?, ?, ?, 'applied', ?, NULL)
                    """,
                    (
                        f"chg_{uuid4().hex[:10]}",
                        suggestion_id,
                        ",".join(a.get("type", "") for a in actions)
                        + f"|links_updated={link_updates}|patch={patch_path}",
                        datetime.now().isoformat(),
                    ),
                )
                change_entries.append(
                    {
                        "run_id": run_id,
                        "timestamp": datetime.now().isoformat(),
                        "suggestion_id": suggestion_id,
                        "status": "applied",
                        "before_path": before_path,
                        "after_path": after_path,
                        "actions": [a.get("type", "") for a in actions],
                        "patch_path": str(patch_path),
                        "approved_by": row["decided_by"] or "unknown",
                    }
                )
                applied += 1
            except Exception as exc:
                conn.execute(
                    "UPDATE suggestions SET status = 'failed' WHERE id = ?",
                    (suggestion_id,),
                )
                conn.execute(
                    """
                    INSERT INTO changes (
                        id, suggestion_id, action_type, status, applied_at, error_message
                    )
                    VALUES (?, ?, ?, 'failed', ?, ?)
                    """,
                    (
                        f"chg_{uuid4().hex[:10]}",
                        suggestion_id,
                        ",".join(a.get("type", "") for a in actions),
                        datetime.now().isoformat(),
                        str(exc),
                    ),
                )
                change_entries.append(
                    {
                        "run_id": run_id,
                        "timestamp": datetime.now().isoformat(),
                        "suggestion_id": suggestion_id,
                        "status": "failed",
                        "before_path": note_rel,
                        "after_path": note_rel,
                        "actions": [a.get("type", "") for a in actions],
                        "approved_by": row["decided_by"] or "unknown",
                        "error": str(exc),
                    }
                )
                failed += 1

        conn.execute(
            """
            UPDATE audit_runs SET finished_at = ?, status = ?
            WHERE id = ?
            """,
            (datetime.now().isoformat(), "completed", run_id),
        )
        conn.commit()

    change_log_path = _append_change_log(vault_root, change_entries)
    rollback_path = _write_rollback_report(vault_root, run_id, change_entries)
    return {
        "run_id": run_id,
        "applied": applied,
        "stale": stale,
        "failed": failed,
        "change_log": str(change_log_path),
        "rollback_report": str(rollback_path),
    }
