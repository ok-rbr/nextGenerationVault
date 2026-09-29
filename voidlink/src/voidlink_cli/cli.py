"""Main CLI entry point for vault-agent."""

from pathlib import Path

import typer

from voidlink_cli.commands import apply_app, ingest_app, plan_app, review_app, validate_app
from voidlink_cli.config import Config
from voidlink_cli.indexing.db import initialize_database
from voidlink_cli.run_logging import create_run_manifest, generate_run_id

app = typer.Typer(
    name="vault-agent",
    help="VoidLink vault-agent CLI — AI-assisted knowledge base management",
)

# Register command groups
app.add_typer(validate_app, name="validate")
app.add_typer(ingest_app, name="ingest")
app.add_typer(plan_app, name="plan")
app.add_typer(review_app, name="review")
app.add_typer(apply_app, name="apply")


@app.callback()
def setup(
    vault_root: Path | None = typer.Option(None, "--vault-root"),  # noqa: B008
    log_level: str = typer.Option("INFO", "--log-level"),  # noqa: B008
) -> None:
    """Global options for vault-agent."""
    pass


@app.command()
def init(
    vault_root: Path | None = typer.Option(None, "--vault-root"),  # noqa: B008
) -> None:
    """Initialize vault-agent configuration and directories."""
    if vault_root is None:
        vault_root = Path.cwd()

    config = Config(vault={"root": vault_root})
    staging = config.get_staging_path()
    schemas = config.get_schemas_path()
    index_db = config.get_index_db_path()
    initialize_database(index_db)

    typer.echo(f"✓ Vault root: {vault_root}")
    typer.echo(f"✓ Staging dir: {staging}")
    typer.echo(f"✓ Schemas dir: {schemas}")
    typer.echo(f"✓ Index DB: {index_db}")

    # Create run manifest for init
    run_id = generate_run_id()
    run_dir = create_run_manifest(run_id, staging, "init", {"vault_root": str(vault_root)})
    typer.echo(f"✓ Run ID: {run_id}")
    typer.echo(f"✓ Run directory: {run_dir}")


@app.command()
def health() -> None:
    """Check vault-agent health and configuration."""
    config = Config.from_file()
    try:
        staging = config.get_staging_path()
        schemas = config.get_schemas_path()
        index_db = config.get_index_db_path()
        initialize_database(index_db)
        typer.echo("✓ Health check passed")
        typer.echo(f"  Vault root: {config.vault.root}")
        typer.echo(f"  Staging dir: {staging}")
        typer.echo(f"  Schemas dir: {schemas}")
        typer.echo(f"  Index DB: {index_db}")
    except Exception as e:
        typer.echo(f"✗ Health check failed: {e}", err=True)
        raise typer.Exit(1) from e


def cli_entry() -> None:
    """Entry point for installed CLI."""
    app()


if __name__ == "__main__":
    app()
