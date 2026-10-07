"""Folder ingester: orchestrates full integration pipeline per folder."""

import json
from dataclasses import asdict, dataclass, field
from datetime import datetime
from pathlib import Path

from voidlink_cli.extraction.extractor import ContentExtractor
from voidlink_cli.extraction.sidecar import SidecarWrapper
from voidlink_cli.ingest.backlinks import BacklinkDetector
from voidlink_cli.ingest.interactive import InteractiveReview
from voidlink_cli.llm.client import OllamaClient
from voidlink_cli.planning.para import ParaClassifier
from voidlink_cli.policy.loader import load_ai_policy
from voidlink_cli.scanning.vault_scanner import VaultScanner


@dataclass
class NoteModification:
    """Record of changes applied to a single note."""

    note_path: str
    metadata_updated: dict = field(default_factory=dict)
    backlinks_added: list[str] = field(default_factory=list)
    media_extracted: list[str] = field(default_factory=list)
    description_expanded: bool = False
    renamed: bool = False
    new_path: str | None = None
    status: str = "pending"  # pending | approved | applied | error
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())

    def to_dict(self) -> dict:
        """Convert to dictionary."""
        return asdict(self)


@dataclass
class FolderIngestReport:
    """Report of folder ingestion results."""

    folder_path: str
    processed_at: str
    summary: dict
    modifications: list[NoteModification]
    git_commit_sha: str | None = None
    git_commit_msg: str | None = None

    def to_dict(self) -> dict:
        """Convert to dictionary."""
        return {
            "folder_path": self.folder_path,
            "processed_at": self.processed_at,
            "summary": self.summary,
            "modifications": [m.to_dict() for m in self.modifications],
            "git_commit": {
                "sha": self.git_commit_sha,
                "message": self.git_commit_msg,
            },
        }


class FolderIngester:
    """Orchestrates folder ingestion with full enhancement pipeline."""

    def __init__(
        self,
        vault_root: Path,
        folder_path: str,
        use_llm: bool = False,
        extract_media: bool = False,
        interactive: bool = True,
        debug: bool = False,
    ):
        """Initialize ingester.

        Args:
            vault_root: Absolute path to vault root directory.
            folder_path: Relative path of the folder to ingest.
            use_llm: Enable LLM-assisted metadata extraction.
            extract_media: Extract text from media files found in the folder.
            interactive: Prompt for user confirmation at each step.
            debug: Print LLM prompts/responses and step-by-step pipeline details.
        """
        self.vault_root = Path(vault_root).resolve()
        requested = Path(folder_path)
        self.full_folder_path = (self.vault_root / requested).resolve()
        if requested.is_absolute() or not self.full_folder_path.is_relative_to(self.vault_root):
            raise ValueError("folder path must stay inside the vault")
        if not self.full_folder_path.is_dir():
            raise ValueError("folder path must name an existing directory")
        self.folder_path = self.full_folder_path.relative_to(self.vault_root).as_posix()

        self.use_llm = use_llm
        self.extract_media = extract_media
        self.interactive = interactive
        self.debug = debug

        self.scanner = VaultScanner(vault_root)
        self.extractor = ContentExtractor()
        self.sidecar = SidecarWrapper()
        self.detector = BacklinkDetector(vault_root)
        self.classifier = ParaClassifier()
        self.llm = OllamaClient(debug=debug) if use_llm else None
        self.policy = (
            load_ai_policy(self.vault_root / "99_system" / "ai_policy.yaml") if use_llm else None
        )
        self.reviewer = InteractiveReview(auto_approve=not interactive)

        self.modifications: list[NoteModification] = []

    # ------------------------------------------------------------------
    # Public interface
    # ------------------------------------------------------------------

    def ingest(self) -> FolderIngestReport:
        """Run the full ingestion pipeline for the configured folder.

        Steps:
          1. Scan folder for notes and media.
          2. Build backlink index.
          3. Process each note (metadata, backlinks, media).
          4. Ask user for final confirmation (interactive mode).
          5. Apply approved changes.
          6. Return ingestion report; Git staging and commits are manual.
        """
        if not self.interactive:
            raise ValueError("folder ingest requires interactive approval before changing notes")
        print(f"📂 Scanning {self.folder_path}...")
        scan_results = self.scanner.scan_vault()
        notes = [
            note
            for note in scan_results["notes"]
            if Path(note["path"]).is_relative_to(self.folder_path)
        ]
        media = [
            item
            for item in scan_results["media"]
            if Path(item["path"]).is_relative_to(self.folder_path)
        ]

        if not notes:
            print(f"⚠️ No notes found in {self.folder_path}")
            return self._empty_report()

        print(f"✓ Found {len(notes)} notes, {len(media)} media files")

        self.detector.index_notes(notes)

        for note in notes:
            self._process_note(note)

        summary = self._summarize()
        if not self.reviewer.prompt_confirm_all(summary):
            print("⚠️ Cancelled")
            return self._empty_report()

        self._apply_changes()
        return self._generate_report(None, None)

    # ------------------------------------------------------------------
    # Private pipeline steps
    # ------------------------------------------------------------------

    def _process_note(self, note: dict) -> None:
        """Process a single note through the full enhancement pipeline."""
        note_path = note.get("path", "")
        full_path = self.vault_root / note_path

        print(f"  → {note_path}")

        modification = NoteModification(note_path=note_path)

        try:
            with open(full_path, encoding="utf-8", errors="ignore") as f:
                content = f.read()
        except Exception:
            modification.status = "error"
            self.modifications.append(modification)
            return

        if self.debug:
            print(f"\033[90m[DEBUG] Read {len(content)} bytes from {note_path}\033[0m")

        # PARA classification
        para_result = self.classifier.classify(
            note_path=full_path,
            title=Path(note_path).stem,
            tags=note.get("tags", []),
            status=note.get("status", ""),
        )
        if self.debug:
            review_flag = " [requires review]" if para_result.requires_review else ""
            print(
                f"\033[90m[DEBUG] PARA classification: {para_result.category.value} "
                f"(confidence={para_result.confidence:.2f}){review_flag}\033[0m"
            )
            print(
                f"\033[90m[DEBUG] Classification reasons: {'; '.join(para_result.reasons)}\033[0m"
            )

        # LLM metadata extraction
        metadata: dict = {}
        if (
            self.use_llm
            and self.llm
            and self.llm.available
            and self.policy
            and not self.policy.is_llm_excluded_path(note_path)
        ):
            if self.debug:
                print("\033[90m[DEBUG] Sending content to LLM for frontmatter extraction…\033[0m")
            fm_result = self.llm.extract_frontmatter(content)
            if fm_result.get("success"):
                metadata = fm_result.get("metadata", {})
                if self.debug:
                    print(f"\033[90m[DEBUG] LLM extracted fields: {list(metadata)}\033[0m")
            else:
                if self.debug:
                    print("\033[90m[DEBUG] LLM frontmatter extraction failed\033[0m")

            # LLM PARA re-classification
            if self.debug:
                print("\033[90m[DEBUG] Sending content to LLM for PARA re-classification…\033[0m")
            llm_para = self.llm.classify_para_with_llm(
                note_path, content, para_result.category.value
            )
            if llm_para.get("used_llm"):
                if self.debug:
                    print(
                        f"\033[90m[DEBUG] LLM PARA result: {llm_para.get('llm_category')} "
                        f"(confidence={llm_para.get('confidence', 0):.2f})\033[0m"
                    )
                if llm_para.get("confidence", 0) > para_result.confidence and self.debug:
                    print(
                        f"\033[90m[DEBUG] LLM overrides heuristic: "
                        f"{para_result.category.value} → "
                        f"{llm_para.get('llm_category')}\033[0m"
                    )
        elif self.use_llm and self.debug:
            print("\033[33m[DEBUG] LLM unavailable or path excluded by policy\033[0m")

        if self.interactive and metadata:
            metadata = self.reviewer.prompt_metadata(note_path, metadata)
        modification.metadata_updated = metadata

        # Backlink suggestions
        backlinks = self.detector.find_backlinks(note_path, content)
        if self.debug:
            print(f"\033[90m[DEBUG] Backlinks found: {len(backlinks)}\033[0m")
            for bl in backlinks:
                print(
                    f"\033[90m[DEBUG]   ↳ {bl.target_note!r} "
                    f"(confidence={bl.confidence:.2f}, reason={bl.reason})\033[0m"
                )
        if backlinks:
            approved_links = self.reviewer.prompt_backlinks(backlinks)
            modification.backlinks_added = [s.target_note for s in approved_links]
            if self.debug:
                print(
                    "\033[90m[DEBUG] Backlinks approved: "
                    f"{len(modification.backlinks_added)}\033[0m"
                )

        # Media extraction
        if self.extract_media:
            media_in_folder = [
                m for m in note.get("media", []) if m.get("path", "").startswith(note_path)
            ]
            if self.debug:
                print(f"\033[90m[DEBUG] Media files to extract: {len(media_in_folder)}\033[0m")
            if media_in_folder:
                approved_media = self.reviewer.prompt_media_extraction(media_in_folder)
                for media_item in approved_media:
                    media_path = self.vault_root / media_item["path"]
                    try:
                        sidecar = self.sidecar.wrap_asset(media_path)
                        if sidecar:
                            modification.media_extracted.append(str(sidecar))
                    except Exception:
                        pass

        modification.status = "approved"
        self.modifications.append(modification)

    def _summarize(self) -> dict:
        """Return a summary dict of pending modifications."""
        return {
            "notes_processed": len(self.modifications),
            "notes_modified": sum(1 for m in self.modifications if m.metadata_updated),
            "links_created": sum(len(m.backlinks_added) for m in self.modifications),
            "media_extracted": sum(len(m.media_extracted) for m in self.modifications),
            "metadata_added": sum(1 for m in self.modifications if m.metadata_updated),
        }

    def _apply_changes(self) -> int:
        """Write all approved metadata changes back to vault files.

        Returns:
            Number of files successfully modified.
        """
        count = 0
        for modification in self.modifications:
            if modification.status != "approved":
                continue

            note_path = self.vault_root / modification.note_path

            if modification.metadata_updated:
                try:
                    with open(note_path, encoding="utf-8") as f:
                        lines = f.readlines()

                    if lines and lines[0].strip() == "---":
                        # Locate end of existing frontmatter
                        end_idx = 1
                        for i in range(1, len(lines)):
                            if lines[i].strip() == "---":
                                end_idx = i
                                break
                        new_fm = self._build_frontmatter(modification.metadata_updated)
                        with open(note_path, "w", encoding="utf-8") as f:
                            f.write(new_fm)
                            f.writelines(lines[end_idx + 1 :])
                    else:
                        # Prepend new frontmatter
                        new_fm = self._build_frontmatter(modification.metadata_updated) + "\n"
                        with open(note_path, "w", encoding="utf-8") as f:
                            f.write(new_fm)
                            f.writelines(lines)

                    count += 1
                except Exception:
                    pass

        return count

    @staticmethod
    def _build_frontmatter(metadata: dict) -> str:
        """Render a YAML frontmatter block from *metadata*."""
        lines = ["---"]
        for key, value in metadata.items():
            if isinstance(value, list):
                lines.append(f"{key}: {json.dumps(value)}")
            else:
                lines.append(f"{key}: {value}")
        lines.append("---")
        return "\n".join(lines) + "\n"

    def _generate_report(
        self, commit_sha: str | None, commit_msg: str | None
    ) -> FolderIngestReport:
        """Assemble and return the final ingestion report."""
        return FolderIngestReport(
            folder_path=self.folder_path,
            processed_at=datetime.now().isoformat(),
            summary=self._summarize(),
            modifications=self.modifications,
            git_commit_sha=commit_sha,
            git_commit_msg=commit_msg,
        )

    def _empty_report(self) -> FolderIngestReport:
        """Return an empty report (no notes found or operation cancelled)."""
        return FolderIngestReport(
            folder_path=self.folder_path,
            processed_at=datetime.now().isoformat(),
            summary={"notes_processed": 0},
            modifications=[],
        )
