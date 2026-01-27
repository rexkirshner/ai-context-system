#!/bin/bash
#
# Install commands for Claude Code and OpenAI Codex
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Claude Code
mkdir -p ~/.claude/commands
cp "$SCRIPT_DIR/commands/"*.md ~/.claude/commands/

# OpenAI Codex
mkdir -p ~/.codex/prompts
cp "$SCRIPT_DIR/commands/"*.md ~/.codex/prompts/

echo "Installed to:"
echo ""
echo "  ~/.claude/commands/  (Claude Code)"
echo "  ~/.codex/prompts/    (OpenAI Codex)"
echo ""
echo "Commands:"
echo "  - /cleanup-acs     Remove AI Context System artifacts"
echo "  - /review          Comprehensive code review"
echo "  - /save-session    Record what happened this session"
echo "  - /update-context  Update CLAUDE.md and AGENTS.md"
