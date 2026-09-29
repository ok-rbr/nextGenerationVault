"""Command implementations for vault-agent CLI."""

import json
from pathlib import Path

import typer

from voidlink_cli.apply.workflow import apply_approved_suggestions, preview_approved_suggestions
from voidlink_cli.config import Config
from voidlink_cli.planning.engine import PlanningEngine
from voidlink_cli.planning.suggestions import generate_suggestions
from voidlink_cli.policy.loader import (
    AIPolicy,
    find_dead_policy_paths,
    load_ai_policy,
    load_required_frontmatter_fields,
)
from voidlink_cli.review.workflow import (
    approve_suggestion,
    list_pending_suggestions,
    reject_suggestion,
    show_suggestion,
    sync_review_files,
)
from voidlink_cli.scanning.inventory_reports import generate_inventory_reports
from voidlink_cli.scanning.vault_scanner import VaultScanner
from voidlink_cli.validation.frontmatter import (
    SYSTEM_PREFIX,
    load_frontmatter_validator,
    validate_vault,
    write_frontmatter_report,
)

validate_app = typer.Typer(help="Validation commands")
ingest_app = typer.Typer(help="Ingestion commands")
plan_app = typer.Typer(help="Planning commands")
review_app = typer.Typer(help="Review commands")
apply_app = typer.Typer(help="Apply commands")


def _warn_dead_policy_paths(policy: AIPolicy, vault_root: Path) -> None:
    """Warn about policy paths that protect nothing in this vault (#32)."""
    for message in find_dead_policy_paths(policy, vault_root):
        typer.echo(f"⚠️ ai_policy.yaml {message}; this rule protects nothing", err=True)


@validate_app.command()
def schemas(
    scope: str = typer.Option("all", "--scope", help="Scope: 'all' or path pattern"),  # noqa: B008
    output: Path = typer.Option(None, "--output", help="Output JSON file"),  # noqa: B008
) -> None:
    """Scan and validate vault schemas."""
    config = Config.from_file()
    scanner = VaultScanner(config.vault.root)

    typer.echo(f"🔍 Scanning vault ({scope})...", err=True)
    results = scanner.scan_vault(scope=scope)

    if output:
        output.parent.mkdir(parents=True, exist_ok=True)
        with open(output, "w") as f:
            json.dump(results, f, indent=2, default=str)
        typer.echo(f"✓ Scan written to {output}")

    typer.echo(scanner.get_scan_summary(results), err=True)


@validate_app.command()
def inventory(
    scope: str = typer.Option("all", "--scope", help="Scope: 'all' or path pattern"),  # noqa: B008
    output_dir: Path | None = typer.Option(  # noqa: B008
        None, "--output-dir", help="Output directory for inventory reports"
    ),
) -> None:
    """Generate standardized inventory reports from a vault scan."""
    config = Config.from_file()
    scanner = VaultScanner(config.vault.root)

    typer.echo(f"🔍 Scanning vault ({scope})...", err=True)
    scan_results = scanner.scan_vault(scope=scope)

    if output_dir is None:
        output_dir = config.get_staging_path() / "inventory"

    schema_path = config.get_schemas_path() / "frontmatter.schema.json"
    required_fields = load_required_frontmatter_fields(schema_path)
    report_paths = generate_inventory_reports(
        scan_results, output_dir=output_dir, required_fields=required_fields
    )

    typer.echo(scanner.get_scan_summary(scan_results), err=True)
    typer.echo(f"✓ Inventory reports: {output_dir}")
    for name, path in sorted(report_paths.items()):
        typer.echo(f"  - {name}: {path}")


@validate_app.command()
def frontmatter(
    paths: list[Path] | None = typer.Argument(  # noqa: B008
        None, help="Notes to check (default: every note in scope)"
    ),
    scope: str = typer.Option("all", "--scope", help="Scope: 'all' or path pattern"),  # noqa: B008
    output_dir: Path | None = typer.Option(  # noqa: B008
        None, "--output-dir", help="Output directory for the validation report"
    ),
    include_system: bool = typer.Option(  # noqa: B008
        False,
        "--include-system",
        help=f"Also check {SYSTEM_PREFIX} (templates, docs) and the repository docs at the root",
    ),
    report: bool = typer.Option(  # noqa: B008
        True, "--report/--no-report", help="Write the report to the staging directory"
    ),
) -> None:
    """Validate note frontmatter against frontmatter.schema.json (exit 1 on issues)."""
    config = Config.from_file()
    schema_path = config.vault.root / config.vault.schemas_dir / "frontmatter.schema.json"
    if not schema_path.exists():
        typer.echo(f"✗ Schema not found: {schema_path}", err=True)
        raise typer.Exit(2)

    validator = load_frontmatter_validator(schema_path)
    result = validate_vault(
        config.vault.root,
        validator,
        scope=scope,
        paths=paths or None,
        include_system=include_system,
    )

    for issue in result.issues:
        location = f"{issue.field}: " if issue.field else ""
        typer.echo(f"{issue.path}: {location}{issue.message}")

    if report:
        if output_dir is None:
            output_dir = config.get_staging_path() / "validation"
        report_paths = write_frontmatter_report(result, output_dir)
        typer.echo(f"✓ Report: {report_paths['frontmatter_validation.md']}", err=True)

    typer.echo(
        f"Checked {result.checked} notes, skipped {result.skipped}: "
        f"{len(result.issues)} issues in {len(result.notes_with_issues)} notes",
        err=True,
    )
    if not result.ok:
        raise typer.Exit(1)


@ingest_app.command()
def folder(
    path: str = typer.Option(..., "--path", help="Folder path (e.g., 02_Areas/Health)"),  # noqa: B008
    with_llm: bool = typer.Option(False, "--with-llm", help="Use Qwen LLM"),  # noqa: B008
    read_content: bool = typer.Option(False, "--read-content", help="Read file content"),  # noqa: B008
    extract_media: bool = typer.Option(False, "--extract-media", help="Extract media"),  # noqa: B008
    interactive: bool = typer.Option(
        True,
        "--interactive/--no-interactive",
        help="Interactive mode",  # noqa: B008
    ),
    debug: bool = typer.Option(  # noqa: B008
        False,
        "--debug",
        help="Show LLM prompts/responses and step-by-step pipeline details",
    ),
    output: Path = typer.Option(None, "--output", help="Output report JSON"),  # noqa: B008
) -> None:
    """Ingest and integrate a folder with full enhancement pipeline."""
    from voidlink_cli.ingest.folder_ingester import FolderIngester

    config = Config.from_file()

    typer.echo(f"🚀 Starting folder ingest: {path}", err=True)
    if debug:
        typer.echo(
            "🐛 Debug mode enabled — LLM prompts/responses and pipeline steps will be shown",
            err=True,
        )

    ingester = FolderIngester(
        vault_root=config.vault.root,
        folder_path=path,
        use_llm=with_llm,
        extract_media=extract_media,
        interactive=interactive,
        debug=debug,
    )

    report = ingester.ingest()

    if output:
        output.parent.mkdir(parents=True, exist_ok=True)
        with open(output, "w") as f:
            json.dump(report.to_dict(), f, indent=2, default=str)
        typer.echo(f"✓ Report → {output}")

    summary = report.summary
    typer.echo(
        f"✓ Ingested {summary.get('notes_processed', 0)} notes, "
        f"{summary.get('links_created', 0)} links, "
        f"{summary.get('media_extracted', 0)} media",
        err=True,
    )
    if report.git_commit_sha:
        typer.echo(f"✓ Committed: {report.git_commit_sha}", err=True)


@ingest_app.command()
def hevy() -> None:
    """Ingest Hevy training data."""
    typer.echo("ingest hevy command (placeholder)")


@plan_app.command()
def para(
    scope: str = typer.Option("all", "--scope", help="Scope: 'all' or pattern"),  # noqa: B008
    output: Path = typer.Option(None, "--output", help="Output file"),  # noqa: B008
    use_llm: bool = typer.Option(
        False,
        "--with-llm",
        help="Use Qwen LLM for enhancement",  # noqa: B008
    ),
    read_content: bool = typer.Option(
        False,
        "--read-content",
        help="Read file content for LLM",  # noqa: B008
    ),
) -> None:
    """Generate PARA placement plan (optionally LLM-enhanced)."""
    config = Config.from_file()
    scanner = VaultScanner(config.vault.root)

    typer.echo(f"🔍 Scanning ({scope})...", err=True)
    scan_results = scanner.scan_vault(scope=scope)

    typer.echo(f"📝 Planning PARA{'+ LLM' if use_llm else ''}...", err=True)

    notes = [
        {
            "path": note["path"],
            "title": Path(note["path"]).stem,
            "tags": [],
            "status": "active",
            "category": "area",
        }
        for note in scan_results["notes"]
    ]

    if use_llm:
        from voidlink_cli.llm.enhanced_engine import EnhancedPlanningEngine

        engine = EnhancedPlanningEngine(use_llm=True)
        plan = engine.generate_plan(
            notes, vault_path=str(config.vault.root), read_content=read_content, sample_size=50
        )
    else:
        engine = PlanningEngine()
        plan = engine.generate_plan(notes)

    plan_dict = plan.to_dict()
    plan_json = json.dumps(plan_dict, indent=2, default=str)

    if output:
        output.parent.mkdir(parents=True, exist_ok=True)
        with open(output, "w") as f:
            f.write(plan_json)
        typer.echo(f"✓ Plan → {output}")

    typer.echo(scanner.get_scan_summary(scan_results), err=True)
    if use_llm:
        llm_count = sum(1 for a in plan.actions if getattr(a, "llm_enhanced", False))
        typer.echo(f"✓ {len(plan.actions)} actions ({llm_count} LLM-enhanced)", err=True)
    else:
        typer.echo(f"✓ {len(plan.actions)} actions planned", err=True)


@plan_app.command()
def suggest(
    scope: str = typer.Option("all", "--scope", help="Scope: 'all' or pattern"),  # noqa: B008
    output_dir: Path | None = typer.Option(  # noqa: B008
        None, "--output-dir", help="Directory for suggestion JSON/review files"
    ),
) -> None:
    """Generate suggest-only review artifacts and persist them in SQLite."""
    config = Config.from_file()
    scanner = VaultScanner(config.vault.root)

    typer.echo(f"🔍 Scanning ({scope})...", err=True)
    scan_results = scanner.scan_vault(scope=scope)

    policy_path = config.vault.root / "99_system" / "ai_policy.yaml"
    if policy_path.exists():
        policy = load_ai_policy(policy_path)
        _warn_dead_policy_paths(policy, config.vault.root)
    else:
        policy = AIPolicy(
            protected_paths=tuple(),
            llm_excluded_paths=tuple(),
            forbidden_actions=("delete_note", "rewrite_content"),
            allowed_actions=tuple(),
        )
        typer.echo(f"⚠️ Policy not found: {policy_path}; using permissive defaults", err=True)

    if output_dir is None:
        output_dir = config.get_staging_path() / "suggestions"

    required_fields = load_required_frontmatter_fields(
        config.get_schemas_path() / "frontmatter.schema.json"
    )
    result = generate_suggestions(
        scan_results=scan_results,
        required_fields=required_fields,
        policy=policy,
        output_dir=output_dir,
        db_path=config.get_index_db_path(),
    )

    typer.echo(f"✓ Suggestions generated: {result['count']}")
    typer.echo(f"✓ Run ID: {result['run_id']}")
    typer.echo(f"✓ Output dir: {result['output_dir']}")


@review_app.command()
def pending() -> None:
    """List pending suggestions from SQLite review queue."""
    config = Config.from_file()
    items = list_pending_suggestions(config.get_index_db_path())
    if not items:
        typer.echo("No pending suggestions.")
        return

    for item in items:
        typer.echo(
            f"- {item['id']} | note={item['note_id']} | risk={item['risk']}"
            f" | status={item['status']}"
        )


@review_app.command()
def show(suggestion_id: str = typer.Argument(..., help="Suggestion ID")) -> None:
    """Show details of a specific suggestion."""
    config = Config.from_file()
    try:
        data = show_suggestion(config.get_index_db_path(), suggestion_id)
    except ValueError as exc:
        typer.echo(f"✗ {exc}", err=True)
        raise typer.Exit(1) from exc

    typer.echo(
        json.dumps(
            {
                "id": data["id"],
                "note_id": data["note_id"],
                "risk": data["risk"],
                "status": data["status"],
                "payload": data.get("payload"),
            },
            indent=2,
            ensure_ascii=False,
        )
    )


@review_app.command()
def approve(
    suggestion_id: str = typer.Argument(..., help="Suggestion ID"),
    decided_by: str = typer.Option("local-user", "--by", help="Reviewer identity"),  # noqa: B008
) -> None:
    """Approve a pending suggestion."""
    config = Config.from_file()
    try:
        sid, decision = approve_suggestion(config.get_index_db_path(), suggestion_id, decided_by)
    except ValueError as exc:
        typer.echo(f"✗ {exc}", err=True)
        raise typer.Exit(1) from exc
    typer.echo(f"✓ {sid} -> {decision}")


@review_app.command()
def reject(
    suggestion_id: str = typer.Argument(..., help="Suggestion ID"),
    decided_by: str = typer.Option("local-user", "--by", help="Reviewer identity"),  # noqa: B008
) -> None:
    """Reject a pending suggestion."""
    config = Config.from_file()
    try:
        sid, decision = reject_suggestion(config.get_index_db_path(), suggestion_id, decided_by)
    except ValueError as exc:
        typer.echo(f"✗ {exc}", err=True)
        raise typer.Exit(1) from exc
    typer.echo(f"✓ {sid} -> {decision}")


@review_app.command()
def sync(
    decided_by: str = typer.Option("local-user", "--by", help="Reviewer identity"),  # noqa: B008
) -> None:
    """Sync checked review markdown files into SQLite approvals."""
    config = Config.from_file()
    result = sync_review_files(config.get_index_db_path(), decided_by)
    typer.echo(f"✓ Synced approvals: {result['updated']}")


@apply_app.command()
def preview() -> None:
    """Preview approved suggestion application without mutating files."""
    config = Config.from_file()
    result = preview_approved_suggestions(config.vault.root, config.get_index_db_path())
    typer.echo(
        f"Approved suggestions: total={result['total']} "
        f"ready={result['ready']} stale={result['stale']}"
    )


@apply_app.command()
def commit(
    approved_only: bool = typer.Option(
        True, "--approved-only/--all", help="Apply only approved suggestions"
    ),  # noqa: B008
) -> None:
    """Apply approved suggestions with safety checks and audit logging."""
    if not approved_only:
        typer.echo("✗ Only --approved-only mode is supported.", err=True)
        raise typer.Exit(1)

    config = Config.from_file()
    policy_path = config.vault.root / "99_system" / "ai_policy.yaml"
    if policy_path.exists():
        policy = load_ai_policy(policy_path)
        _warn_dead_policy_paths(policy, config.vault.root)
    else:
        policy = AIPolicy(
            protected_paths=tuple(),
            llm_excluded_paths=tuple(),
            forbidden_actions=("delete_note", "rewrite_content"),
            allowed_actions=tuple(),
        )

    try:
        result = apply_approved_suggestions(config.vault.root, config.get_index_db_path(), policy)
    except RuntimeError as exc:
        typer.echo(f"✗ {exc}", err=True)
        raise typer.Exit(1) from exc

    typer.echo(
        f"✓ Apply run {result['run_id']} | applied={result['applied']} "
        f"stale={result['stale']} failed={result['failed']}"
    )
    typer.echo(f"✓ Change log: {result['change_log']}")
    typer.echo(f"✓ Rollback report: {result['rollback_report']}")
