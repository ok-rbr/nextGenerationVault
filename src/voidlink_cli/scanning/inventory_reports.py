"""Inventory report generation from scanner output."""

import json
from collections import Counter, defaultdict
from pathlib import Path


def _build_known_context(notes: list[dict]) -> dict:
    known_tags = sorted({tag for note in notes for tag in note.get("tags", [])})
    frontmatter_fields = sorted({k for note in notes for k in note.get("frontmatter_keys", [])})
    folder_patterns: dict[str, list[str]] = defaultdict(list)

    for note in notes:
        path = note.get("path", "")
        top_level = path.split("/", 1)[0] if "/" in path else "(root)"
        inferred_type = _infer_path_type(path)
        if inferred_type and inferred_type not in folder_patterns[top_level]:
            folder_patterns[top_level].append(inferred_type)

    return {
        "known_tags": known_tags,
        "known_types": sorted({typ for types in folder_patterns.values() for typ in types}),
        "folder_patterns": dict(sorted(folder_patterns.items())),
        "frontmatter_fields": frontmatter_fields,
    }


def _infer_path_type(path: str) -> str | None:
    lower = path.lower()
    if "project" in lower or lower.startswith("01_"):
        return "project"
    if "area" in lower or lower.startswith("02_"):
        return "area"
    if "resource" in lower or lower.startswith("03_"):
        return "resource"
    if "archive" in lower or lower.startswith("04_"):
        return "archive"
    return None


def _resolve_target_path(current_path: str, target_raw: str, paths: set[str]) -> str | None:
    candidate = target_raw.split("|", 1)[0].split("#", 1)[0].strip()
    if not candidate:
        return None
    if candidate in paths:
        return candidate
    if f"{candidate}.md" in paths:
        return f"{candidate}.md"
    if "/" in current_path:
        current_dir = current_path.rsplit("/", 1)[0]
        joined = f"{current_dir}/{candidate}"
        if joined in paths:
            return joined
        if f"{joined}.md" in paths:
            return f"{joined}.md"
    return None


def generate_inventory_reports(
    scan_results: dict, output_dir: Path, required_fields: list[str] | None = None
) -> dict[str, Path]:
    """Generate standardized inventory report artifacts in *output_dir*."""
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    required_fields = required_fields or [
        "title",
        "id",
        "created",
        "tags",
        "category",
        "status",
        "lang",
    ]
    notes = scan_results.get("notes", [])
    note_paths = {note.get("path", "") for note in notes}
    title_to_path = {Path(path).stem: path for path in note_paths if path}

    missing_metadata: list[str] = []
    parser_errors: list[str] = []
    tag_counter: Counter[str] = Counter()
    key_counter: Counter[str] = Counter()
    outbound_links: Counter[str] = Counter()
    inbound_links: Counter[str] = Counter()
    broken_links: list[str] = []

    for note in notes:
        path = note.get("path", "")
        keys = set(note.get("frontmatter_keys", []))
        tags = note.get("tags", [])
        parse_errors = note.get("parse_errors", [])
        wikilinks = note.get("wikilinks", [])
        md_links = note.get("markdown_links", [])

        tag_counter.update(tags)
        key_counter.update(keys)
        parser_errors.extend(f"{path}: {err}" for err in parse_errors)

        if not note.get("has_frontmatter"):
            missing_metadata.append(f"- {path}: missing frontmatter")
        else:
            missing = sorted(field for field in required_fields if field not in keys)
            if missing:
                missing_metadata.append(f"- {path}: missing {', '.join(missing)}")

        for target in wikilinks:
            outbound_links[path] += 1
            resolved = _resolve_target_path(path, target, note_paths)
            if not resolved:
                resolved = title_to_path.get(target.split("|", 1)[0].split("#", 1)[0].strip())
            if resolved:
                inbound_links[resolved] += 1
            else:
                broken_links.append(f"- {path}: [[{target}]]")

        for target in md_links:
            if target.startswith(("http://", "https://", "mailto:")):
                continue
            outbound_links[path] += 1
            resolved = _resolve_target_path(path, target, note_paths)
            if resolved:
                inbound_links[resolved] += 1
            else:
                broken_links.append(f"- {path}: ({target})")

    orphan_notes = sorted(
        path
        for path in note_paths
        if outbound_links.get(path, 0) == 0 and inbound_links.get(path, 0) == 0
    )
    duplicated_tags = sorted((tag, count) for tag, count in tag_counter.items() if count > 1)
    known_context = _build_known_context(notes)

    files: dict[str, Path] = {}

    files["vault_summary.md"] = output_dir / "vault_summary.md"
    files["vault_summary.md"].write_text(
        "\n".join(
            [
                "# Vault Summary",
                "",
                f"- Vault root: {scan_results.get('vault_root', '')}",
                f"- Scope: {scan_results.get('scope', 'all')}",
                f"- Total files: {scan_results.get('stats', {}).get('total_files', 0)}",
                f"- Notes: {len(notes)}",
                f"- Media: {len(scan_results.get('media', []))}",
                f"- Assets: {len(scan_results.get('assets', []))}",
            ]
        )
        + "\n",
        encoding="utf-8",
    )

    files["missing_metadata.md"] = output_dir / "missing_metadata.md"
    files["missing_metadata.md"].write_text(
        "# Missing Metadata\n\n"
        + ("\n".join(missing_metadata) if missing_metadata else "No missing metadata.\n"),
        encoding="utf-8",
    )

    files["duplicate_tags.md"] = output_dir / "duplicate_tags.md"
    files["duplicate_tags.md"].write_text(
        "# Duplicate Tags\n\n"
        + (
            "\n".join(f"- {tag}: {count}" for tag, count in duplicated_tags)
            if duplicated_tags
            else "No duplicate tags.\n"
        ),
        encoding="utf-8",
    )

    files["orphan_notes.md"] = output_dir / "orphan_notes.md"
    files["orphan_notes.md"].write_text(
        "# Orphan Notes\n\n"
        + (
            "\n".join(f"- {path}" for path in orphan_notes)
            if orphan_notes
            else "No orphan notes.\n"
        ),
        encoding="utf-8",
    )

    files["broken_links.md"] = output_dir / "broken_links.md"
    files["broken_links.md"].write_text(
        "# Broken Links\n\n" + ("\n".join(broken_links) if broken_links else "No broken links.\n"),
        encoding="utf-8",
    )

    files["frontmatter_keys.md"] = output_dir / "frontmatter_keys.md"
    files["frontmatter_keys.md"].write_text(
        "# Frontmatter Keys\n\n"
        + (
            "\n".join(f"- {key}: {count}" for key, count in key_counter.most_common())
            if key_counter
            else "No frontmatter keys found.\n"
        ),
        encoding="utf-8",
    )

    files["parser_errors.md"] = output_dir / "parser_errors.md"
    files["parser_errors.md"].write_text(
        "# Parser Errors\n\n"
        + (
            "\n".join(f"- {err}" for err in parser_errors)
            if parser_errors
            else "No parser errors.\n"
        ),
        encoding="utf-8",
    )

    files["known_context.json"] = output_dir / "known_context.json"
    files["known_context.json"].write_text(
        json.dumps(known_context, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )

    return files
