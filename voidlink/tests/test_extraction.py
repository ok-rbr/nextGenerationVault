"""Tests for content extraction."""

from pathlib import Path

from voidlink_cli.extraction.extractor import ContentExtractor, ExtractionResult
from voidlink_cli.extraction.sidecar import SidecarWrapper


def test_extraction_result_dataclass():
    """Test ExtractionResult initialization."""
    result = ExtractionResult(
        source_file=Path("test.pdf"),
        extracted_text="Sample text",
        confidence=0.95,
        extraction_type="pdf_text",
    )

    assert result.source_file == Path("test.pdf")
    assert result.extracted_text == "Sample text"
    assert result.confidence == 0.95
    assert result.extraction_type == "pdf_text"


def test_extractor_supported_formats():
    """Test supported file format detection."""
    extractor = ContentExtractor()
    assert ".pdf" in extractor.supported_formats
    assert ".png" in extractor.supported_formats
    assert ".docx" in extractor.supported_formats


def test_extractor_missing_file():
    """Test extraction with missing file."""
    extractor = ContentExtractor()
    result = extractor.extract(Path("/nonexistent/file.pdf"))

    assert result.extracted_text == ""
    assert result.confidence == 0.0
    assert result.errors is not None
    assert "not found" in result.errors[0].lower()


def test_extractor_unsupported_format():
    """Test extraction with unsupported format."""
    extractor = ContentExtractor()
    result = extractor.extract(Path("test.xyz"))

    assert result.extracted_text == ""
    assert result.confidence == 0.0
    assert result.errors is not None
    assert "unsupported" in result.errors[0].lower()


def test_sidecar_path_generation():
    """Test sidecar path naming convention."""
    source = Path("vault/documents/research.pdf")
    sidecar = SidecarWrapper.get_sidecar_path(source)

    assert sidecar.name == "research.extracted.txt"
    assert sidecar.parent == source.parent


def test_sidecar_wrapper_content_format(tmp_path):
    """Test sidecar content format."""
    result = ExtractionResult(
        source_file=Path("test.pdf"),
        extracted_text="This is extracted text.",
        confidence=0.95,
        extraction_type="pdf_text",
    )

    sidecar_path = tmp_path / "test.extracted.txt"
    sidecar_path.parent.mkdir(parents=True, exist_ok=True)

    with open(sidecar_path, "w") as f:
        f.write(f"# Extracted from: {result.source_file.name}\n")
        f.write(f"# Type: {result.extraction_type}\n")
        f.write(f"# Confidence: {result.confidence:.2%}\n")
        f.write("# ---\n\n")
        f.write(result.extracted_text)

    content = sidecar_path.read_text()
    assert "Extracted from: test.pdf" in content
    assert "Type: pdf_text" in content
    assert "Confidence: 95" in content  # Match 95.00% or 95%
    assert "This is extracted text." in content
