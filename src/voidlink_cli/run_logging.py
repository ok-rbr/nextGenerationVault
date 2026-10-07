"""Logging utilities for vault-agent."""

import json
import logging
import sys
from datetime import datetime
from pathlib import Path
from uuid import uuid4

import structlog


def setup_logging(log_dir: Path, log_level: str = "INFO") -> None:
    """Configure structured logging with file and console output."""
    log_dir.mkdir(parents=True, exist_ok=True)

    # Configure structlog
    structlog.configure(
        processors=[
            structlog.stdlib.add_log_level,
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.StackInfoRenderer(),
            structlog.processors.format_exc_info,
            structlog.processors.UnicodeDecoder(),
            structlog.dev.ConsoleRenderer(),
        ],
        context_class=dict,
        logger_factory=structlog.PrintLoggerFactory(),
        wrapper_class=structlog.make_filtering_bound_logger(logging.getLevelName(log_level)),
    )

    # Also configure stdlib logging
    logging.basicConfig(
        format="%(message)s",
        stream=sys.stdout,
        level=log_level,
    )


def generate_run_id() -> str:
    """Generate a unique run ID."""
    return f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{uuid4().hex[:8]}"


def create_run_manifest(
    run_id: str,
    staging_dir: Path,
    command: str,
    args: dict | None = None,
) -> Path:
    """Create and return path to run manifest JSON file."""
    run_dir = staging_dir / "runs" / run_id
    run_dir.mkdir(parents=True, exist_ok=True)

    manifest_path = run_dir / "manifest.json"
    manifest = {
        "run_id": run_id,
        "timestamp": datetime.now().isoformat(),
        "command": command,
        "args": args or {},
    }

    with open(manifest_path, "w") as f:
        json.dump(manifest, f, indent=2)

    return run_dir
