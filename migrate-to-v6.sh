#!/bin/bash
#
# migrate-to-v6.sh — One-time migration from pre-v6 to v6.0
#
# DO NOT USE IF:
#   - This is a fresh install (use /init-context instead)
#   - You're already on v6.0+ (use /update-context-system instead)
#
# This script:
#   1. Deletes v5.x infrastructure (scripts, agents, schemas, etc.)
#   2. KEEPS old context files for Claude to migrate
#   3. Installs v6.0 commands
#   4. Instructs Claude to extract value and complete cleanup
#
# No backups are created — use git to rollback if needed.
#

set -e

echo "==============================================================="
echo "  AI Context System - Pre-v6 to v6.0 Migration"
echo "==============================================================="
echo ""

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "ERROR: git is not installed"
    echo ""
    echo "This script requires git to download v6.0 commands."
    echo "Install git and try again."
    exit 1
fi

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
echo "IMPORTANT: Ensure your files are committed to git before proceeding."
echo "           Use 'git checkout' to rollback if needed."
echo ""

# 1. Delete v5.x INFRASTRUCTURE (no valuable content)
echo "Removing v5.x infrastructure..."

# Scripts and templates (no user content)
rm -rf scripts/ templates/ config/ test/ reference/ artifacts/

# Old .claude directories (no user content)
rm -rf .claude/agents/ .claude/skills/ .claude/schemas/ .claude/hooks/ .claude/docs/
rm -f .claude/acs-settings.json .claude/.last-update-check

# Old AI-specific files (no user content)
rm -f context/cursor.md context/aider.md context/codex.md
rm -f context/generic-ai-header.md context/context-feedback.md
rm -f context/ai-context-system-feedback.md
rm -f context/.context-config.json

# Old docs directories
rm -rf docs/audits/ docs/skills/ docs/migration/ docs/archive/

# Root level files
rm -f install.sh VERSION

echo "  Infrastructure removed"
echo ""

# 2. List context files that need migration (NOT deleted yet)
echo "Context files kept for migration:"
FOUND_FILES=0
[ -f "context/SESSIONS.md" ] && echo "  - context/SESSIONS.md (session history)" && FOUND_FILES=1
[ -f "context/CONTEXT.md" ] && echo "  - context/CONTEXT.md (project context)" && FOUND_FILES=1
[ -f "context/STATUS.md" ] && echo "  - context/STATUS.md (needs format update)" && FOUND_FILES=1
[ -f "context/DECISIONS.md" ] && echo "  - context/DECISIONS.md (needs format update)" && FOUND_FILES=1
[ "$FOUND_FILES" -eq 0 ] && echo "  (none found - Claude will create fresh context files)"
echo ""

# 3. Download v6.0 commands
echo "Downloading v6.0 commands..."
TEMP_DIR=$(mktemp -d)

if ! git clone --depth 1 https://github.com/rexkirshner/ai-context-system.git "$TEMP_DIR"; then
    echo ""
    echo "ERROR: Failed to download v6.0 commands from GitHub."
    echo ""
    echo "Check your internet connection and try again."
    echo "Use 'git checkout' to restore deleted files if needed."
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

# 4. Delete self before Claude session
echo "Removing migration script..."
rm -f "$0"
echo "  Done"
echo ""

# 5. Next steps
echo "==============================================================="
echo "  MIGRATION ALMOST COMPLETE"
echo "==============================================================="
echo ""
echo "v6.0 commands installed. Two more steps:"
echo ""
echo "1. Restart Claude Code (exit and reopen)"
echo ""
echo "2. Run:  /init-context"
echo ""
echo "   This will:"
echo "   - Read your old context files"
echo "   - Create v6.0 format STATUS.md and DECISIONS.md"
echo "   - Add Session Loop to CLAUDE.md if missing"
echo "   - Delete old files (SESSIONS.md, CONTEXT.md)"
echo ""
echo "==============================================================="
