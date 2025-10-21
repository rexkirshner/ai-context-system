#!/bin/bash

# install.sh
# Bootstrap installer for Claude Context System
# v2.2.1 - Organization and structural neatness
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/rexkirshner/claude-context-system/main/install.sh | bash
#   OR
#   ./install.sh

set -e

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

VERSION="2.2.1"
REPO_URL="https://github.com/rexkirshner/claude-context-system"
RAW_URL="https://raw.githubusercontent.com/rexkirshner/claude-context-system/main"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Claude Context System Installer (v${VERSION})${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# =============================================================================
# Step 1: Detect working directory
# =============================================================================

CURRENT_DIR=$(pwd)
echo -e "${BLUE}📁 Installation directory:${NC} $CURRENT_DIR"
echo ""

# =============================================================================
# Step 2: Check for existing installation
# =============================================================================

if [ -d ".claude/commands" ] && [ -f ".claude/commands/init-context.md" ]; then
  echo -e "${YELLOW}⚠️  Existing installation detected${NC}"
  echo ""

  # Try to detect version
  EXISTING_VERSION="unknown"
  if [ -f "scripts/validate-context.sh" ]; then
    EXISTING_VERSION=$(grep -m 1 "v[0-9]\+\.[0-9]\+\.[0-9]\+" scripts/validate-context.sh | sed 's/.*v\([0-9.]*\).*/\1/' || echo "unknown")
  fi

  echo "   Current version: ${EXISTING_VERSION}"
  echo "   New version: ${VERSION}"
  echo ""

  read -p "Overwrite existing installation? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installation cancelled${NC}"
    exit 0
  fi

  echo -e "${BLUE}📦 Backing up existing installation...${NC}"
  BACKUP_DIR=".claude-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"

  if [ -d ".claude" ]; then
    cp -r .claude "$BACKUP_DIR/" 2>/dev/null || true
  fi
  if [ -d "scripts" ]; then
    cp -r scripts "$BACKUP_DIR/" 2>/dev/null || true
  fi

  echo "   ✅ Backup created: $BACKUP_DIR"
  echo ""
fi

# =============================================================================
# Step 3: Create directory structure
# =============================================================================

echo -e "${BLUE}📂 Creating directory structure...${NC}"

mkdir -p .claude/commands
mkdir -p .claude/docs
mkdir -p scripts
mkdir -p templates
mkdir -p config
mkdir -p reference

echo "   ✅ Directories created"
echo ""

# =============================================================================
# Step 4: Download commands
# =============================================================================

echo -e "${BLUE}⬇️  Downloading slash commands...${NC}"

COMMANDS=(
  "init-context.md"
  "migrate-context.md"
  "save.md"
  "save-full.md"
  "save-context.md"
  "review-context.md"
  "code-review.md"
  "validate-context.md"
  "export-context.md"
  "update-context-system.md"
  "update-templates.md"
  "add-ai-header.md"
  "session-summary.md"
  "organize-docs.md"
)

FAILED_DOWNLOADS=0

for cmd in "${COMMANDS[@]}"; do
  echo -n "   Downloading $cmd... "
  if curl -sL "${RAW_URL}/.claude/commands/${cmd}" -o ".claude/commands/${cmd}" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${RED}✗${NC}"
    ((FAILED_DOWNLOADS++))
  fi
done

echo ""

# =============================================================================
# Step 5: Download templates
# =============================================================================

echo -e "${BLUE}⬇️  Downloading templates...${NC}"

TEMPLATES=(
  "claude.md.template"
  "cursor.md.template"
  "aider.md.template"
  "codex.md.template"
  "generic-ai-header.template.md"
  "CONTEXT.template.md"
  "STATUS.template.md"
  "DECISIONS.template.md"
  "SESSIONS.template.md"
  "CODE_MAP.template.md"
  "PRD.template.md"
  "ARCHITECTURE.template.md"
)

echo "   ℹ️  Note: QUICK_REF.template.md removed in v2.1 (Quick Reference now in STATUS.md)"

for tmpl in "${TEMPLATES[@]}"; do
  echo -n "   Downloading $tmpl... "
  if curl -sL "${RAW_URL}/templates/${tmpl}" -o "templates/${tmpl}" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${RED}✗${NC}"
    ((FAILED_DOWNLOADS++))
  fi
done

echo ""

# =============================================================================
# Step 6: Download scripts
# =============================================================================

echo -e "${BLUE}⬇️  Downloading scripts...${NC}"

SCRIPTS=(
  "validate-context.sh"
  "save-context-helper.sh"
)

for script in "${SCRIPTS[@]}"; do
  echo -n "   Downloading $script... "
  if curl -sL "${RAW_URL}/scripts/${script}" -o "scripts/${script}" 2>/dev/null; then
    chmod +x "scripts/${script}"
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${RED}✗${NC}"
    ((FAILED_DOWNLOADS++))
  fi
done

echo ""

# =============================================================================
# Step 7: Download configuration
# =============================================================================

echo -e "${BLUE}⬇️  Downloading configuration...${NC}"

CONFIG_FILES=(
  "context-config-schema.json"
)

for cfg in "${CONFIG_FILES[@]}"; do
  echo -n "   Downloading $cfg... "
  if curl -sL "${RAW_URL}/config/${cfg}" -o "config/${cfg}" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${RED}✗${NC}"
    ((FAILED_DOWNLOADS++))
  fi
done

# Download config template
echo -n "   Downloading .context-config.template.json... "
if curl -sL "${RAW_URL}/config/.context-config.template.json" -o "config/.context-config.template.json" 2>/dev/null; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC}"
  ((FAILED_DOWNLOADS++))
fi

echo ""

# =============================================================================
# Step 8: Download documentation
# =============================================================================

echo -e "${BLUE}⬇️  Downloading documentation...${NC}"

DOCS=(
  "command-philosophy.md"
  "save-context-guide.md"
)

for doc in "${DOCS[@]}"; do
  echo -n "   Downloading $doc... "
  if curl -sL "${RAW_URL}/.claude/docs/${doc}" -o ".claude/docs/${doc}" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${RED}✗${NC}"
    ((FAILED_DOWNLOADS++))
  fi
done

echo ""

# =============================================================================
# Step 9: Download reference files
# =============================================================================

echo -e "${BLUE}⬇️  Downloading reference files...${NC}"

# Download ORGANIZATION.md to reference/ (users can copy to root if desired)
echo -n "   Downloading ORGANIZATION.md... "
if curl -sL "${RAW_URL}/ORGANIZATION.md" -o "reference/ORGANIZATION.md" 2>/dev/null; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC}"
  ((FAILED_DOWNLOADS++))
fi

# Download migration guides
MIGRATION_GUIDES=(
  "MIGRATION_GUIDE_v2.0_to_v2.1.md"
  "MIGRATION_GUIDE_v2.1_to_v2.2.md"
)

for guide in "${MIGRATION_GUIDES[@]}"; do
  echo -n "   Downloading $guide... "
  if curl -sL "${RAW_URL}/${guide}" -o "reference/${guide}" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${YELLOW}⚠${NC} (not critical)"
  fi
done

echo ""

# =============================================================================
# Step 10: Verify installation
# =============================================================================

echo -e "${BLUE}🔍 Verifying installation...${NC}"

VERIFICATION_FAILED=0

# Check critical files (v2.1.0)
CRITICAL_FILES=(
  ".claude/commands/init-context.md"
  ".claude/commands/save.md"
  ".claude/commands/save-full.md"
  "templates/claude.md.template"
  "templates/CONTEXT.template.md"
  "templates/STATUS.template.md"
  "templates/DECISIONS.template.md"
  "scripts/validate-context.sh"
)

for file in "${CRITICAL_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "   ✅ $file"
  else
    echo -e "   ${RED}❌ $file${NC}"
    ((VERIFICATION_FAILED++))
  fi
done

echo ""

# =============================================================================
# Step 11: Installation summary
# =============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $FAILED_DOWNLOADS -eq 0 ] && [ $VERIFICATION_FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ Installation successful!${NC}"
  echo ""
  echo "Claude Context System v${VERSION} is now installed."
  echo ""
  echo -e "${BLUE}Next steps:${NC}"
  echo "   1. Run /init-context to initialize your project"
  echo "   2. Review context/CONTEXT.md for accuracy"
  echo "   3. Use TodoWrite during active work"
  echo "   4. Run /save frequently (2-3 min quick updates)"
  echo "   5. Run /save-full before breaks (10-15 min comprehensive)"
  echo "   6. Use /code-review for AI agent review"
  echo ""
  echo -e "${BLUE}Documentation:${NC}"
  echo "   - Command philosophy: .claude/docs/command-philosophy.md"
  echo "   - Save context guide: .claude/docs/save-context-guide.md"
  echo "   - GitHub: ${REPO_URL}"
  echo ""
  echo -e "${BLUE}v2.2.1 Features (Organization & Structural Neatness):${NC}"
  echo "   - ORGANIZATION.md guidelines (in reference/ - copy to root)"
  echo "   - /organize-docs command (interactive cleanup wizard)"
  echo "   - Organization validation (0-100 scoring in /validate-context)"
  echo "   - Cleanup reminders (gentle prompts in /save-full)"
  echo ""
  echo -e "${BLUE}Previous Features (v2.1.0):${NC}"
  echo "   - File consolidation (Quick Reference in STATUS.md)"
  echo "   - Multi-AI support (claude.md, cursor.md, etc.)"
  echo "   - Automated staleness detection"
  echo ""
  echo -e "${BLUE}Helpful commands:${NC}"
  echo "   /init-context          - Initialize context system"
  echo "   /save                  - Quick save (2-3 min)"
  echo "   /save-full             - Comprehensive save (10-15 min)"
  echo "   /validate-context      - Check documentation + organization"
  echo "   /organize-docs         - Interactive cleanup wizard (v2.2.1)"
  echo "   /update-context-system - Update to latest version"
  echo "   /update-templates      - Compare and update templates"
  echo ""
  exit 0
else
  echo -e "${RED}❌ Installation completed with errors${NC}"
  echo ""
  echo "   Failed downloads: $FAILED_DOWNLOADS"
  echo "   Failed verifications: $VERIFICATION_FAILED"
  echo ""
  echo "Please check your internet connection and try again."
  echo "If the problem persists, file an issue at:"
  echo "   ${REPO_URL}/issues"
  echo ""

  if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    echo "Your previous installation was backed up to: $BACKUP_DIR"
    echo ""
  fi

  exit 1
fi
