"""Main CLI entry point."""

import click
from rich.console import Console

console = Console()


@click.group()
@click.version_option()
def cli():
    """Python CLI Fixture - A test CLI for ACS v5.0."""
    pass


@cli.command()
@click.argument("name", default="World")
def hello(name: str):
    """Say hello to someone."""
    console.print(f"[green]Hello, {name}![/green]")


@cli.command()
@click.option("--count", "-c", default=1, help="Number of times to repeat")
def repeat(count: int):
    """Repeat a message."""
    for i in range(count):
        console.print(f"[blue]Repetition {i + 1}[/blue]")


if __name__ == "__main__":
    cli()
