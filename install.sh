#!/bin/bash
#
# Install commands for Claude Code and OpenAI Codex
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Active commands (delete old versions, install new)
ACTIVE_COMMANDS=(
  "cleanup-acs.md"
  "review.md"
  "save-session.md"
  "update-context.md"
)

# Inactive commands (delete, don't replace)
INACTIVE_COMMANDS=(
  # Add removed commands here, e.g.:
  # "old-command.md"
)

install_to() {
  local target_dir="$1"
  mkdir -p "$target_dir"

  # Remove active commands (will be replaced)
  for cmd in "${ACTIVE_COMMANDS[@]}"; do
    rm -f "$target_dir/$cmd"
  done

  # Remove inactive commands (retired)
  for cmd in "${INACTIVE_COMMANDS[@]}"; do
    rm -f "$target_dir/$cmd"
  done

  # Install active commands
  for cmd in "${ACTIVE_COMMANDS[@]}"; do
    cp "$SCRIPT_DIR/commands/$cmd" "$target_dir/"
  done
}

# Claude Code
install_to ~/.claude/commands

# OpenAI Codex
install_to ~/.codex/prompts

echo "Installed to:"
echo ""
echo "  ~/.claude/commands/  (Claude Code)"
echo "  ~/.codex/prompts/    (OpenAI Codex)"
echo ""
echo "Commands:"
for cmd in "${ACTIVE_COMMANDS[@]}"; do
  name="${cmd%.md}"
  echo "  - /$name"
done
