"""Utility functions for the CLI."""

from pathlib import Path


def get_config_path() -> Path:
    """Get the path to the config directory."""
    return Path.home() / ".config" / "mycli"


def ensure_config_dir() -> Path:
    """Ensure the config directory exists."""
    config_path = get_config_path()
    config_path.mkdir(parents=True, exist_ok=True)
    return config_path
