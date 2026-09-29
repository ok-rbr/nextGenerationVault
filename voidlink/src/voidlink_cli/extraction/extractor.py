"""Content extractor for PDFs, images, and Office documents."""

import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path


@dataclass
class ExtractionResult:
    """Result of content extraction from a single file."""

    source_file: Path
    extracted_text: str
    confidence: float
    extraction_type: str
    errors: list[str] | None = None

    @property
    def success(self) -> bool:
        """Return True when extraction produced text without errors."""
        return (self.errors is None or len(self.errors) == 0) and bool(self.extracted_text)


def _error_result(
    source_file: Path,
    extraction_type: str,
    error: str,
) -> ExtractionResult:
    """Build a failed ExtractionResult with a single error message."""
    return ExtractionResult(
        source_file=source_file,
        extracted_text="",
        confidence=0.0,
        extraction_type=extraction_type,
        errors=[error],
    )


class ContentExtractor:
    """Extract text from various document formats."""

    #: Mapping of file extension → extraction type label.
    supported_formats: dict[str, str] = {
        ".pdf": "pdf_text",
        ".png": "image_ocr",
        ".jpg": "image_ocr",
        ".jpeg": "image_ocr",
        ".tiff": "image_ocr",
        ".gif": "image_ocr",
        ".docx": "office_text",
        ".doc": "office_text",
        ".odt": "office_text",
        ".xlsx": "excel_text",
    }

    def extract(self, file_path: Path) -> ExtractionResult:
        """Extract content from *file_path*, dispatching to the right handler.

        Args:
            file_path: Path to the source file.

        Returns:
            ExtractionResult with extracted text, confidence score, and any
            errors encountered.
        """
        suffix = file_path.suffix.lower()
        extraction_type = self.supported_formats.get(suffix)

        if extraction_type is None:
            return _error_result(
                file_path,
                "unknown",
                f"unsupported format: {suffix}",
            )

        if not file_path.exists():
            return _error_result(file_path, extraction_type, f"file not found: {file_path}")

        if suffix == ".pdf":
            return self._extract_pdf(file_path)
        if suffix in {".png", ".jpg", ".jpeg", ".tiff", ".gif"}:
            return self._extract_image(file_path)
        if suffix in {".docx", ".doc", ".odt"}:
            return self._extract_office(file_path)
        if suffix == ".xlsx":
            return self._extract_excel(file_path)

        # Should not be reached, but keeps type-checker happy
        return _error_result(
            file_path, extraction_type, f"no handler for {suffix}"
        )  # pragma: no cover

    # ------------------------------------------------------------------
    # Private extraction helpers
    # ------------------------------------------------------------------

    def _extract_pdf(self, file_path: Path) -> ExtractionResult:
        """Extract text from a PDF using pdftotext."""
        tool = shutil.which("pdftotext")
        if not tool:
            return _error_result(file_path, "pdf_text", "pdftotext not found")

        try:
            result = subprocess.run(
                ["pdftotext", str(file_path), "-"],
                capture_output=True,
                text=True,
                timeout=30,
            )
            if result.returncode != 0:
                return _error_result(file_path, "pdf_text", f"pdftotext failed: {result.stderr}")
            return ExtractionResult(
                source_file=file_path,
                extracted_text=result.stdout,
                confidence=0.9,
                extraction_type="pdf_text",
            )
        except subprocess.TimeoutExpired:
            return _error_result(file_path, "pdf_text", "pdftotext timed out")
        except Exception as exc:
            return _error_result(file_path, "pdf_text", f"PDF extraction failed: {exc}")

    def _extract_image(self, file_path: Path) -> ExtractionResult:
        """Extract text from an image using Tesseract OCR."""
        tool = shutil.which("tesseract")
        if not tool:
            return _error_result(file_path, "image_ocr", "tesseract not found")

        try:
            result = subprocess.run(
                ["tesseract", str(file_path), "stdout"],
                capture_output=True,
                text=True,
                timeout=60,
            )
            if result.returncode != 0:
                return _error_result(file_path, "image_ocr", f"tesseract failed: {result.stderr}")
            return ExtractionResult(
                source_file=file_path,
                extracted_text=result.stdout,
                confidence=0.75,
                extraction_type="image_ocr",
            )
        except subprocess.TimeoutExpired:
            return _error_result(file_path, "image_ocr", "tesseract timed out")
        except Exception as exc:
            return _error_result(file_path, "image_ocr", f"image OCR failed: {exc}")

    def _extract_office(self, file_path: Path) -> ExtractionResult:
        """Extract text from Word / ODF documents using python-docx."""
        try:
            from docx import Document

            doc = Document(file_path)
            text = "\n".join(p.text for p in doc.paragraphs if p.text)
            return ExtractionResult(
                source_file=file_path,
                extracted_text=text,
                confidence=0.95,
                extraction_type="office_text",
            )
        except ImportError:
            return _error_result(file_path, "office_text", "python-docx not installed")
        except Exception as exc:
            return _error_result(file_path, "office_text", f"office extraction failed: {exc}")

    def _extract_excel(self, file_path: Path) -> ExtractionResult:
        """Extract text from Excel files using openpyxl."""
        try:
            from openpyxl import load_workbook

            wb = load_workbook(file_path)
            lines: list[str] = []
            for sheet_name in wb.sheetnames:
                ws = wb[sheet_name]
                lines.append(f"=== Sheet: {sheet_name} ===")
                for row in ws.iter_rows(values_only=True):
                    row_text = " | ".join(str(cell) if cell else "" for cell in row)
                    if row_text.strip():
                        lines.append(row_text)
            return ExtractionResult(
                source_file=file_path,
                extracted_text="\n".join(lines),
                confidence=0.9,
                extraction_type="excel_text",
            )
        except ImportError:
            return _error_result(file_path, "excel_text", "openpyxl not installed")
        except Exception as exc:
            return _error_result(file_path, "excel_text", f"Excel extraction failed: {exc}")
