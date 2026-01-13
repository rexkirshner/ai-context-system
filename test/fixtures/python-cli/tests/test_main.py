"""Tests for main CLI commands."""

from click.testing import CliRunner
from cli.main import cli


def test_hello_default():
    """Test hello command with default name."""
    runner = CliRunner()
    result = runner.invoke(cli, ["hello"])
    assert result.exit_code == 0
    assert "Hello, World!" in result.output


def test_hello_with_name():
    """Test hello command with custom name."""
    runner = CliRunner()
    result = runner.invoke(cli, ["hello", "ACS"])
    assert result.exit_code == 0
    assert "Hello, ACS!" in result.output


def test_repeat():
    """Test repeat command."""
    runner = CliRunner()
    result = runner.invoke(cli, ["repeat", "-c", "3"])
    assert result.exit_code == 0
    assert "Repetition 1" in result.output
    assert "Repetition 3" in result.output
