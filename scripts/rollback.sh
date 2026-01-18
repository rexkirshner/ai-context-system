#!/bin/bash
# rollback.sh - Rollback v5.0 to previous version
# Part of AI Context System v5.0
#
# Usage: ./scripts/rollback.sh [backup-dir]
#        ./scripts/rollback.sh                    # Uses most recent backup
#        ./scripts/rollback.sh .claude-backup-20260113-143022

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "╔════════════════════════════════════════════╗"
echo "║    AI Context System Rollback              ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Find repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# Find backup directory
BACKUP_DIR="$1"

if [ -z "$BACKUP_DIR" ]; then
    # Find most recent backup
    BACKUP_DIR=$(ls -dt .claude-backup-* 2>/dev/null | head -1)

    if [ -z "$BACKUP_DIR" ]; then
        echo -e "${RED}Error: No backup directory found${NC}"
        echo "Usage: ./scripts/rollback.sh [backup-dir]"
        exit 1
    fi

    echo "Using most recent backup: $BACKUP_DIR"
fi

# Validate backup exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}Error: Backup directory not found: $BACKUP_DIR${NC}"
    exit 1
fi

# Check backup has required components
REQUIRED_BACKUP_FILES=()
if [ -d "$BACKUP_DIR/.claude" ]; then
    REQUIRED_BACKUP_FILES+=(".claude")
fi
if [ -f "$BACKUP_DIR/VERSION" ]; then
    REQUIRED_BACKUP_FILES+=("VERSION")
fi

if [ ${#REQUIRED_BACKUP_FILES[@]} -eq 0 ]; then
    echo -e "${RED}Error: Backup directory appears empty or invalid${NC}"
    exit 1
fi

echo "Backup validated. Proceeding with rollback..."
echo ""

# Confirm
echo -e "${YELLOW}WARNING: This will:${NC}"
echo "  - Remove current v5.0 structure"
echo "  - Restore from backup: $BACKUP_DIR"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Rollback cancelled."
    exit 0
fi

# Step 1: Remove v5.0 structure
echo ""
echo "Step 1: Removing v5.0 structure..."

# Remove v5.0 specific directories
V5_DIRS=(".claude/skills" ".claude/agents" ".claude/hooks" ".claude/schemas" ".claude/cache")
for dir in "${V5_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        rm -rf "$dir"
        echo "  Removed: $dir"
    fi
done

# Remove v5.0+ settings (renamed in v5.1.2 to avoid Claude Code conflict)
if [ -f ".claude/acs-settings.json" ]; then
    rm -f ".claude/acs-settings.json"
    echo "  Removed: .claude/acs-settings.json"
fi
# Also remove old settings.json if present (pre-v5.1.2)
if [ -f ".claude/settings.json" ]; then
    rm -f ".claude/settings.json"
    echo "  Removed: .claude/settings.json (legacy)"
fi

# Step 2: Restore from backup
echo ""
echo "Step 2: Restoring from backup..."

# Restore .claude directory if backed up
if [ -d "$BACKUP_DIR/.claude" ]; then
    cp -R "$BACKUP_DIR/.claude/"* ".claude/" 2>/dev/null || true
    echo "  Restored: .claude/"
fi

# Restore scripts directory if backed up
if [ -d "$BACKUP_DIR/scripts" ]; then
    mkdir -p scripts
    cp -R "$BACKUP_DIR/scripts/"* "scripts/" 2>/dev/null || true
    echo "  Restored: scripts/"
fi

# Restore templates directory if backed up
if [ -d "$BACKUP_DIR/templates" ]; then
    mkdir -p templates
    cp -R "$BACKUP_DIR/templates/"* "templates/" 2>/dev/null || true
    echo "  Restored: templates/"
fi

# Restore VERSION file
if [ -f "$BACKUP_DIR/VERSION" ]; then
    cp "$BACKUP_DIR/VERSION" "VERSION"
    echo "  Restored: VERSION"
fi

# Step 3: Preserve user content (CRITICAL)
echo ""
echo "Step 3: Verifying user content preserved..."

# User content files that must NEVER be deleted
CONTENT_FILES=("context/CONTEXT.md" "context/STATUS.md" "context/DECISIONS.md" "context/SESSIONS.md")

for file in "${CONTENT_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file present"
    else
        echo -e "  ${YELLOW}⚠${NC} $file not found (may not have existed)"
    fi
done

# Step 4: Clean up
echo ""
echo "Step 4: Clean up..."

# Don't remove the backup directory - keep it for safety
echo "  Keeping backup at: $BACKUP_DIR"

# Step 5: Log rollback
echo ""
echo "Step 5: Logging rollback..."

if [ -f "context/SESSIONS.md" ]; then
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    ROLLBACK_NOTE="
<!-- System: Rollback from v5.0 at $TIMESTAMP -->
<!-- Backup restored from: $BACKUP_DIR -->
"
    # Append to SESSIONS.md (append-only principle)
    echo "$ROLLBACK_NOTE" >> "context/SESSIONS.md"
    echo "  Added rollback note to SESSIONS.md"
fi

# Summary
echo ""
echo "━━━ Rollback Complete ━━━"
echo ""
if [ -f "VERSION" ]; then
    RESTORED_VERSION=$(cat VERSION)
    echo -e "Restored version: ${GREEN}$RESTORED_VERSION${NC}"
else
    echo -e "${YELLOW}No VERSION file found${NC}"
fi
echo "Backup preserved at: $BACKUP_DIR"
echo ""
echo "Next steps:"
echo "  1. Verify your context files are intact"
echo "  2. Run your usual commands to confirm functionality"
echo "  3. Report any issues at https://github.com/rexkirshner/ai-context-system/issues"
echo ""
exit 0
