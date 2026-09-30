"""Sidecar wrapper: persists extracted content alongside vault assets."""

from pathlib import Path

from voidlink_cli.extraction.extractor import ContentExtractor, ExtractionResult


class SidecarWrapper:
    """Create ``*.extracted.txt`` sidecars for vault assets."""

    def __init__(self) -> None:
        """Initialize wrapper with a ContentExtractor."""
        self.extractor = ContentExtractor()

    # ------------------------------------------------------------------
    # Static helpers
    # ------------------------------------------------------------------

    @staticmethod
    def get_sidecar_path(source_path: Path) -> Path:
        """Return the expected sidecar path for *source_path*.

        The sidecar is placed in the same directory as the source file and
        named ``<stem>.extracted.txt``, e.g.
        ``document.pdf`` → ``document.extracted.txt``.

        Args:
            source_path: Path to the source asset.

        Returns:
            Path object for the sidecar file (may or may not exist yet).
        """
        return source_path.parent / f"{source_path.stem}.extracted.txt"

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def wrap_asset(self, asset_path: Path) -> Path | None:
        """Extract content from *asset_path* and write a sidecar file.

        Args:
            asset_path: Absolute path to the vault asset to extract.

        Returns:
            Path to the written sidecar file, or ``None`` if extraction
            failed.
        """
        result: ExtractionResult = self.extractor.extract(asset_path)

        if not result.success:
            return None

        sidecar_path = self.get_sidecar_path(asset_path)

        header = (
            f"# Extracted from: {asset_path.name}\n"
            f"# Type: {result.extraction_type}\n"
            f"# Confidence: {result.confidence:.2%}\n"
            "# ---\n\n"
        )

        with open(sidecar_path, "w", encoding="utf-8") as f:
            f.write(header)
            f.write(result.extracted_text)

        return sidecar_path
