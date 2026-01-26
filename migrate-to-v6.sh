#!/bin/bash
#
# migrate-to-v6.sh — One-time migration from pre-v6 to v6.0
#
# DO NOT USE IF:
#   - This is a fresh install (use /init-context instead)
#   - You're already on v6.0+ (use /update-context-system instead)
#
# This script DELETES ITSELF after successful migration.
#

set -e

echo "==============================================================="
echo "  AI Context System - Pre-v6 to v6.0 Migration"
echo "==============================================================="
echo ""

# Check if already on v6.0
if [ -f ".claude/VERSION" ]; then
    VERSION=$(cat .claude/VERSION)
    if [[ "$VERSION" == 6.* ]]; then
        echo "ERROR: Already on v6.x ($VERSION)"
        echo ""
        echo "This script is for pre-v6 migrations only."
        echo "Use /update-context-system to upgrade from v6.x to v6.y."
        exit 1
    fi
fi

# Check if this is a fresh project (no v5.x artifacts)
if [ ! -d "scripts" ] && [ ! -d ".claude/agents" ] && [ ! -f "context/SESSIONS.md" ]; then
    echo "ERROR: No v5.x installation detected"
    echo ""
    echo "This script is for migrating existing v5.x installations."
    echo "For fresh installs, use /init-context instead."
    exit 1
fi

echo "Detected pre-v6 installation"
echo ""

# 1. Backup
BACKUP_DIR="context-backup-$(date +%Y%m%d-%H%M%S)"
echo "Creating backup in $BACKUP_DIR/"
mkdir -p "$BACKUP_DIR"
[ -d "context" ] && cp -r context "$BACKUP_DIR/"
[ -d ".claude" ] && cp -r .claude "$BACKUP_DIR/"
[ -f "CLAUDE.md" ] && cp CLAUDE.md "$BACKUP_DIR/"
echo "  Backup complete"
echo ""

# 2. Delete v5.x artifacts
echo "Removing v5.x artifacts..."

# Scripts and templates
rm -rf scripts/ templates/ config/ test/ reference/ artifacts/

# Old .claude directories
rm -rf .claude/agents/ .claude/skills/ .claude/schemas/ .claude/hooks/ .claude/docs/
rm -f .claude/acs-settings.json .claude/.last-update-check

# Old context files
rm -f context/SESSIONS.md context/CONTEXT.md context/.context-config.json
rm -f context/cursor.md context/aider.md context/codex.md
rm -f context/generic-ai-header.md context/context-feedback.md
rm -f context/ai-context-system-feedback.md

# Old docs
rm -rf docs/audits/ docs/skills/ docs/migration/ docs/archive/

# Root level files
rm -f install.sh VERSION

echo "  v5.x artifacts removed"
echo ""

# 3. Download v6.0 commands
echo "Downloading v6.0 commands..."
TEMP_DIR=$(mktemp -d)

if ! git clone --depth 1 https://github.com/rexkirshner/ai-context-system.git "$TEMP_DIR"; then
    echo ""
    echo "ERROR: Failed to download v6.0 commands from GitHub."
    echo ""
    echo "Check your internet connection and try again."
    echo "Your backup is safe in $BACKUP_DIR/"
    rm -rf "$TEMP_DIR"
    exit 1
fi

rm -rf .claude/commands/
mkdir -p .claude
cp -r "$TEMP_DIR/.claude/commands" .claude/
cp "$TEMP_DIR/.claude/VERSION" .claude/

rm -rf "$TEMP_DIR"
echo "  v6.0 commands installed"
echo ""

# 4. Report next steps
echo "==============================================================="
echo "  MANUAL STEPS REQUIRED"
echo "==============================================================="
echo ""
echo "v6.0 commands are installed, but your context files need"
echo "migration to v6.0 format."
echo ""
echo "1. Restart Claude Code (exit and reopen)"
echo ""
echo "2. Ask Claude to migrate your context files:"
echo "   \"Please migrate context/STATUS.md and context/DECISIONS.md"
echo "    to v6.0 format. Backup is in $BACKUP_DIR/\""
echo ""
echo "STATUS.md v6.0 format:"
echo "  # Status"
echo "  SchemaVersion: 1"
echo "  LastUpdated: YYYY-MM-DD"
echo "  HeadCommit: [git SHA]"
echo "  Objective: [goal]"
echo "  ## Working Set"
echo "  ## Next Actions"
echo "  ## Blocked On"
echo ""
echo "DECISIONS.md v6.0 format:"
echo "  ## YYYY-MM-DD: [Area] Title"
echo "  Why: [reason]"
echo "  Tradeoff: [cost]"
echo "  RevisitWhen: [trigger]"
echo ""

# 5. Delete self
echo "Removing migration script (no longer needed)..."
rm -f "$0"
echo "  Migration script removed"
echo ""
echo "==============================================================="
echo "  Migration complete. Restart Claude Code now."
echo "==============================================================="
