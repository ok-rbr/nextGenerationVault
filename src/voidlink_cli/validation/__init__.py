"""Frontmatter validation against the JSON schema."""

from voidlink_cli.validation.frontmatter import (
    FrontmatterIssue,
    FrontmatterReport,
    load_frontmatter_validator,
    parse_frontmatter,
    validate_note_text,
    validate_vault,
    write_frontmatter_report,
)

__all__ = [
    "FrontmatterIssue",
    "FrontmatterReport",
    "load_frontmatter_validator",
    "parse_frontmatter",
    "validate_note_text",
    "validate_vault",
    "write_frontmatter_report",
]
