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
        self.vault_root = Path(vault_root)
        self.folder_path = folder_path
        self.full_folder_path = self.vault_root / folder_path

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
          6. Commit changes to git.
          7. Return ingestion report.
        """
        print(f"📂 Scanning {self.folder_path}...")
        scan_results = self.scanner.scan_vault(scope=f"*{self.folder_path}*")
        notes = scan_results["notes"]
        media = scan_results["media"]

        if not notes:
            print(f"⚠️ No notes found in {self.folder_path}")
            return self._empty_report()

        print(f"✓ Found {len(notes)} notes, {len(media)} media files")

        self.detector.index_notes(notes)

        for note in notes:
            self._process_note(note)

        if self.interactive:
            summary = self._summarize()
            if not self.reviewer.prompt_confirm_all(summary):
                print("⚠️ Cancelled")
                return self._empty_report()

        applied_count = self._apply_changes()
        commit_sha, commit_msg = self._git_commit(applied_count)

        return self._generate_report(commit_sha, commit_msg)

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
            preview = content[:300].replace("\n", "↵")
            print(f"\033[90m[DEBUG] Content preview: {preview!r}\033[0m")

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
        if self.use_llm and self.llm and self.llm.available:
            if self.debug:
                print("\033[90m[DEBUG] Sending content to LLM for frontmatter extraction…\033[0m")
            fm_result = self.llm.extract_frontmatter(content)
            if fm_result.get("success"):
                metadata = fm_result.get("metadata", {})
                if self.debug:
                    print(f"\033[90m[DEBUG] LLM extracted metadata: {metadata}\033[0m")
            else:
                if self.debug:
                    print(
                        f"\033[90m[DEBUG] LLM frontmatter extraction failed: "
                        f"{fm_result.get('error')}\033[0m"
                    )

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
                        f"(confidence={llm_para.get('confidence', 0):.2f}) "
                        f"— {llm_para.get('reasoning')}\033[0m"
                    )
                if llm_para.get("confidence", 0) > para_result.confidence and self.debug:
                    print(
                        f"\033[90m[DEBUG] LLM overrides heuristic: "
                        f"{para_result.category.value} → "
                        f"{llm_para.get('llm_category')}\033[0m"
                    )
        elif self.use_llm and self.debug:
            print("\033[33m[DEBUG] LLM not available, skipping LLM steps\033[0m")

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

    def _git_commit(self, count: int) -> tuple[str | None, str | None]:
        """Stage and commit all vault changes.

        Args:
            count: Number of notes modified (used in commit message).

        Returns:
            Tuple of (short SHA, commit message) or (None, None) on failure.
        """
        try:
            import subprocess

            summary = self._summarize()
            msg = (
                f"vault(ingest): {self.folder_path} — {count} notes, "
                f"{summary['links_created']} links, {summary['media_extracted']} media"
            )

            subprocess.run(
                ["git", "-C", str(self.vault_root), "add", "-A"],
                check=False,
            )

            result = subprocess.run(
                ["git", "-C", str(self.vault_root), "commit", "-m", msg],
                capture_output=True,
                text=True,
                check=False,
            )

            if result.returncode == 0:
                sha_result = subprocess.run(
                    ["git", "-C", str(self.vault_root), "rev-parse", "HEAD"],
                    capture_output=True,
                    text=True,
                    check=True,
                )
                return sha_result.stdout.strip()[:8], msg
        except Exception:
            pass

        return None, None

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
