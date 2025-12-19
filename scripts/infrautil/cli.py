"""Command-line interface for infrautil."""

import sys

import click

from infrautil.commands.namespace import execute_namespace
from infrautil.commands.snapshot import execute_snapshot
from infrautil.config import (
    DEFAULT_APP_DIR,
    DEFAULT_HELM_SNAPSHOT_INPUT,
    DEFAULT_HELM_SNAPSHOT_OUTPUT,
    DEFAULT_NAMESPACE_OUTPUT,
    DEFAULT_SNAPSHOT_OUTPUT,
)
from infrautil.logging_config import setup_logging


@click.group()
@click.option("-v", "--verbose", is_flag=True, help="Enable verbose output")
@click.pass_context
def cli(ctx: click.Context, verbose: bool) -> None:
    """Infrastructure utility for Kubernetes manifest management."""
    ctx.ensure_object(dict)
    ctx.obj["verbose"] = verbose
    setup_logging(verbose=verbose)


@cli.command()
@click.option(
    "-d",
    "--app-dir",
    default=DEFAULT_APP_DIR,
    help="Application directory containing Jsonnet files",
)
@click.option(
    "-o",
    "--output",
    default=DEFAULT_SNAPSHOT_OUTPUT,
    help="Output directory for YAML snapshots",
)
@click.pass_context
def snapshot(ctx: click.Context, app_dir: str, output: str) -> None:
    """Generate YAML snapshots from Jsonnet manifests."""
    exit_code = execute_snapshot(app_dir, output)
    sys.exit(exit_code)


@cli.command()
@click.option(
    "-d",
    "--app-dir",
    default=DEFAULT_APP_DIR,
    help="Application directory",
)
@click.option(
    "-o",
    "--output",
    default=DEFAULT_NAMESPACE_OUTPUT,
    help="Output file path for namespace manifest",
)
@click.pass_context
def namespace(ctx: click.Context, app_dir: str, output: str) -> None:
    """Generate namespace manifest from application configurations."""
    exit_code = execute_namespace(app_dir, output)
    sys.exit(exit_code)


@cli.command(name="helm-snapshot")
@click.option(
    "-d",
    "--snapshot-dir",
    default=DEFAULT_HELM_SNAPSHOT_INPUT,
    help="Application snapshot directory",
)
@click.option(
    "-o",
    "--output",
    default=DEFAULT_HELM_SNAPSHOT_OUTPUT,
    help="Output directory for Helm snapshots",
)
@click.pass_context
def helm_snapshot(ctx: click.Context, snapshot_dir: str, output: str) -> None:
    """Generate Helm chart snapshots (placeholder - not yet implemented)."""
    click.echo("helm-snapshot command not yet implemented", err=True)
    sys.exit(1)


def main() -> None:
    """Main entry point for the CLI."""
    cli(obj={})


if __name__ == "__main__":
    main()
