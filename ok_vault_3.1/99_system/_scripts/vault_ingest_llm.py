#!/usr/bin/env python3

from pathlib import Path
from datetime import datetime
import argparse
import json
import re
import sys
import urllib.request
import urllib.error

VAULT_REQUIRED_DIRS = [
    "00_knowledge",
    "99_system",
]

INBOX_ROOT = Path("00_knowledge/00_inbox")

TARGET_DIRS = {
    "atomic": Path("00_knowledge/01_atomic"),
    "literature": Path("00_knowledge/02_literature"),
    "permanent": Path("00_knowledge/03_permanent"),
}

TEXT_EXTENSIONS = {
    ".md",
    ".txt",
    ".text",
}

PDF_EXTENSIONS = {
    ".pdf",
}

AUDIO_EXTENSIONS = {
    ".wav",
    ".mp3",
    ".m4a",
    ".aiff",
    ".flac",
    ".webm",
    ".whisper",
}


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(1)


def assert_vault_root() -> None:
    missing = [p for p in VAULT_REQUIRED_DIRS if not Path(p).exists()]
    if missing:
        fail(f"Not in vault root. Missing: {', '.join(missing)}")


def slugify(value: str) -> str:
    value = value.lower()
    value = (
        value.replace("ä", "ae")
        .replace("ö", "oe")
        .replace("ü", "ue")
        .replace("ß", "ss")
    )
    value = re.sub(r"[^a-z0-9]+", "_", value)
    value = re.sub(r"_+", "_", value)
    return value.strip("_") or "untitled"


def detect_input_type(path: Path) -> str:
    parts = set(path.parts)

    if "transcripts" in parts:
        return "transcript"
    if "clippings" in parts:
        return "clipping"
    if "notes" in parts:
        return "note"
    if "pdfs" in parts:
        return "pdf"

    suffix = path.suffix.lower()

    if suffix in PDF_EXTENSIONS:
        return "pdf"
    if suffix in AUDIO_EXTENSIONS:
        return "audio"

    return "note"


def read_text(path: Path) -> str:
    suffix = path.suffix.lower()

    if suffix not in TEXT_EXTENSIONS:
        fail(f"Only text inputs are supported for LLM ingest right now: {suffix}")

    content = path.read_text(encoding="utf-8", errors="replace").strip()

    if not content:
        fail("Input file is empty")

    return content


def source_path(path: Path) -> str:
    try:
        return path.resolve().relative_to(Path.cwd().resolve()).as_posix()
    except ValueError:
        return path.resolve().as_posix()


def ollama_chat(model: str, prompt: str, host: str) -> dict:
    schema = {
        "type": "object",
        "properties": {
            "note_type": {
                "type": "string",
                "enum": ["atomic", "literature", "permanent"],
            },
            "title": {"type": "string"},
            "tags": {
                "type": "array",
                "items": {"type": "string"},
            },
            "concepts": {
                "type": "array",
                "items": {"type": "string"},
            },
            "aliases": {
                "type": "array",
                "items": {"type": "string"},
            },
            "summary": {"type": "string"},
            "body_markdown": {"type": "string"},
        },
        "required": [
            "note_type",
            "title",
            "tags",
            "concepts",
            "aliases",
            "summary",
            "body_markdown",
        ],
    }

    payload = {
        "model": model,
        "stream": False,
        "format": schema,
        "options": {
            "temperature": 0.2,
        },
        "messages": [
            {
                "role": "system",
                "content": (
                    "You create Obsidian vault notes for a German personal knowledge system. "
                    "Return only JSON matching the provided schema. "
                    "Do not invent facts. Use only the provided raw input. "
                    "Choose note_type as atomic, literature, or permanent. "
                    "atomic = one focused idea. "
                    "literature = source-bound summary from transcript, article, clipping, or document. "
                    "permanent = stable reusable knowledge independent of one source. "
                    "Write note content in German unless the source is clearly English technical material."
                ),
            },
            {
                "role": "user",
                "content": prompt,
            },
        ],
    }

    req = urllib.request.Request(
        f"{host.rstrip('/')}/api/chat",
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=300) as response:
            data = json.loads(response.read().decode("utf-8"))
    except urllib.error.URLError as exc:
        fail(f"Ollama request failed: {exc}")

    message = data.get("message", {})
    content = message.get("content", "")

    try:
        return json.loads(content)
    except json.JSONDecodeError:
        fail(f"Ollama returned invalid JSON:\n{content}")


def yaml_list(values: list[str]) -> str:
    clean = []
    for value in values:
        slug = slugify(str(value))
        if slug and slug not in clean:
            clean.append(slug)
    return json.dumps(clean, ensure_ascii=False)


def build_note(
    result: dict,
    note_id: str,
    created: str,
    source: str,
    input_type: str,
) -> str:
    title = result["title"].strip() or "untitled"
    title_slug = slugify(title)

    tags = result.get("tags", [])
    concepts = result.get("concepts", [])
    aliases = result.get("aliases", [])
    summary = result.get("summary", "").strip()
    body = result.get("body_markdown", "").strip()

    if "ai_generated" not in tags:
        tags.append("ai_generated")

    return f"""---
title: "{title_slug}"
id: "{note_id}"
created: "{created}"
tags: {yaml_list(tags)}
category: "knowledge"
status: "in-progress"
related: []
concepts: {yaml_list(concepts)}
aliases: {json.dumps(aliases, ensure_ascii=False)}
source: "{source}"
input_type: "{input_type}"
processed: false
---

# {title}

## Summary

{summary}

## Notes

{body}

## Source

- `{source}`
"""


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input_file")
    parser.add_argument("--model", default="qwen3")
    parser.add_argument("--host", default="http://localhost:11434")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    assert_vault_root()

    source = Path(args.input_file).expanduser()

    if not source.exists():
        fail(f"Input file does not exist: {source}")

    if not source.is_file():
        fail(f"Input path is not a file: {source}")

    raw_content = read_text(source)
    input_type = detect_input_type(source)
    source_rel = source_path(source)

    prompt = f"""
Raw input source: {source_rel}
Input type: {input_type}

Create exactly one Obsidian knowledge note from this raw input.

Classification rules:
- atomic: one focused concept or idea
- literature: source-bound summary from transcript, clipping, article, PDF text, or meeting notes
- permanent: stable reusable knowledge that is independent from this one source

Rules:
- Use only the raw input.
- Do not invent people, dates, facts, links, or commitments.
- If the source is a transcript or clipping, prefer literature unless it clearly contains one reusable concept.
- body_markdown must be valid Markdown.
- Keep it concise.
- Preserve important technical terms.

Raw input:

---
{raw_content}
---
""".strip()

    result = ollama_chat(args.model, prompt, args.host)

    note_type = result["note_type"]
    target_dir = TARGET_DIRS[note_type]
    target_dir.mkdir(parents=True, exist_ok=True)

    now = datetime.now()
    note_id = now.strftime("%Y%m%d_%H%M%S")
    created = now.strftime("%Y-%m-%d %H:%M")

    title_slug = slugify(result["title"])
    output = target_dir / f"{title_slug}.md"

    if output.exists():
        fail(f"Target note already exists, refusing overwrite: {output}")

    note = build_note(
        result=result,
        note_id=note_id,
        created=created,
        source=source_rel,
        input_type=input_type,
    )

    if args.dry_run:
        print(note)
        return

    output.write_text(note, encoding="utf-8")
    print(output.as_posix())


if __name__ == "__main__":
    main()
