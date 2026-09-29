"""Ingest module for folder-by-folder vault integration."""

from voidlink_cli.ingest.backlinks import BacklinkDetector, BacklinkSuggestion
from voidlink_cli.ingest.folder_ingester import FolderIngester, FolderIngestReport, NoteModification
from voidlink_cli.ingest.interactive import InteractiveReview

__all__ = [
    "BacklinkDetector",
    "BacklinkSuggestion",
    "FolderIngestReport",
    "FolderIngester",
    "InteractiveReview",
    "NoteModification",
]
