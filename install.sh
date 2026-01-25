#!/bin/bash
# AI Context System Installer v6.0.0
# This script enables upgrades from v5.x and fresh installs

set -e

REPO_URL="https://github.com/rexkirshner/ai-context-system.git"
TEMP_DIR="/tmp/acs-install-$$"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 AI Context System Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if we're in a project directory
if [ ! -d ".claude" ] && [ ! -f "package.json" ] && [ ! -f "README.md" ]; then
    echo "⚠️  Warning: This doesn't look like a project directory."
    echo "   Run this from your project root."
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Clone the repo
echo "📥 Downloading latest version..."
rm -rf "$TEMP_DIR"
git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null || {
    echo "❌ Failed to clone repository"
    echo "   Check your internet connection and try again."
    exit 1
}

# Get version
NEW_VERSION=$(cat "$TEMP_DIR/.claude/VERSION" 2>/dev/null || echo "unknown")
OLD_VERSION=$(cat ".claude/VERSION" 2>/dev/null || echo "none")

echo "   Current version: $OLD_VERSION"
echo "   New version: $NEW_VERSION"

# Backup existing .claude if it exists
if [ -d ".claude" ]; then
    echo "📦 Backing up existing .claude/ to .claude-backup-$OLD_VERSION/"
    cp -r .claude ".claude-backup-$OLD_VERSION" 2>/dev/null || true
fi

# Create .claude directory if needed
mkdir -p .claude

# Copy new commands
echo "🔄 Installing commands..."
rm -rf .claude/commands
cp -r "$TEMP_DIR/.claude/commands" .claude/
cp "$TEMP_DIR/.claude/VERSION" .claude/

echo "   ✅ Installed 8 command files"
echo "   ✅ Updated .claude/VERSION to $NEW_VERSION"

# Remove root VERSION file if it exists (v6.0 only uses .claude/VERSION)
if [ -f "VERSION" ]; then
    rm -f VERSION
    echo "   ✅ Removed root VERSION file (v6.0 uses .claude/VERSION)"
fi

# Clean up legacy v5.x artifacts if they exist
if [ -d ".claude/agents" ] || [ -d ".claude/schemas" ] || [ -d ".claude/skills" ] || [ -d "scripts" ] || [ -d "templates" ]; then
    echo ""
    echo "🧹 Detected v5.x artifacts. Cleaning up..."

    # Clean .claude/ subdirectories
    rm -rf .claude/agents .claude/docs .claude/schemas .claude/hooks .claude/skills 2>/dev/null || true
    rm -f .claude/acs-settings.json .claude/.last-update-check 2>/dev/null || true

    # Clean root-level v5.x directories
    rm -rf scripts templates 2>/dev/null || true

    # Clean v5.x context files
    rm -f context/SESSIONS.md context/CONTEXT.md context/.context-config.json 2>/dev/null || true
    rm -f context/ai-context-system-feedback.md context/context-feedback.md 2>/dev/null || true
    rm -f context/cursor.md context/aider.md context/codex.md context/generic-ai-header.md 2>/dev/null || true

    echo "   ✅ Removed legacy v5.x directories and files"
    echo ""
    echo "⚠️  Manual steps still needed for v5.x → v6.0 migration:"
    echo "   1. Update STATUS.md to new format (see MIGRATIONS.md)"
    echo "   2. Add Session Loop to top of CLAUDE.md"
    echo ""
    echo "   See: https://github.com/rexkirshner/ai-context-system/blob/main/MIGRATIONS.md"
fi

# Clean up temp directory
rm -rf "$TEMP_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Installation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code (required for new commands)"
echo "  2. Run /init-context if this is a new project"
echo "  3. Run /save to test the installation"
echo ""
