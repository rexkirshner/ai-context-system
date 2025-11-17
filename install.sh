#!/bin/bash

# install.sh
# Bootstrap installer for AI Context System
# v3.0.0 - Multi-AI support and real-world feedback improvements
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/install.sh | bash
#   OR
#   ./install.sh

set -e

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository configuration
REPO_URL="https://github.com/rexkirshner/ai-context-system"
RAW_URL="https://raw.githubusercontent.com/rexkirshner/ai-context-system/main"

# Get version from GitHub VERSION file (with validation)
VERSION=$(curl -sL "${RAW_URL}/VERSION" 2>/dev/null || echo "3.0.0")

# Validate VERSION format (must be X.Y.Z)
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo -e "${YELLOW}⚠️  Warning: Could not fetch version from GitHub${NC}"
  echo "   Using fallback version: 3.0.0"
  VERSION="3.0.0"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  AI Context System Installer (v${VERSION})${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# =============================================================================
# Step 0: Parse command line flags
# =============================================================================

NON_INTERACTIVE=false
if [[ "$1" == "--yes" ]] || [[ "$1" == "-y" ]] || [[ "$1" == "--force" ]]; then
  NON_INTERACTIVE=true
fi

# =============================================================================
# Utility Functions
# =============================================================================

# Validate downloaded file contents
validate_file() {
  local file="$1"
  local min_size="${2:-50}"  # Minimum size in bytes (default 50)

  # Check file exists
  if [ ! -f "$file" ]; then
    return 1
  fi

  # Check file size (404 errors are typically ~14 bytes)
  local size=$(wc -c < "$file" | tr -d ' ')
  if [ "$size" -lt "$min_size" ]; then
    echo -e "${RED}✗${NC} (file too small: ${size} bytes)"
    return 1
  fi

  # Check for 404 error pages (only check first 3 lines to avoid false positives)
  # Real 404 errors appear at the start: "404: Not Found" or "HTTP/1.1 404"
  # Don't check entire file - legitimate code may contain "NOT_FOUND" constants
  if head -3 "$file" | grep -Eq "^404: Not Found$|^HTTP.*404|404.*Not Found"; then
    echo -e "${RED}✗${NC} (404 error page)"
    return 1
  fi

  # Check for HTML error pages
  if head -3 "$file" | grep -qi "<!DOCTYPE\|<html"; then
    echo -e "${RED}✗${NC} (HTML error page)"
    return 1
  fi

  return 0
}

# Download and validate file with retry logic (v3.3.1)
download_file() {
  local url="$1"
  local output="$2"
  local min_size="${3:-50}"
  local max_attempts=3
  local attempt=1
  local sleep_time=2

  while [ $attempt -le $max_attempts ]; do
    # Download file
    if curl -sL "$url" -o "$output" 2>/dev/null; then
      # Validate content
      if validate_file "$output" "$min_size"; then
        echo -e "${GREEN}✓${NC}"
        return 0
      fi
    fi

    # Failed - clean up and retry if attempts remain
    rm -f "$output"

    if [ $attempt -lt $max_attempts ]; then
      # Silent retry (don't spam output)
      sleep $sleep_time
      attempt=$((attempt + 1))
      sleep_time=$((sleep_time * 2))  # Exponential backoff
    else
      # Final attempt failed
      echo -e "${RED}✗${NC} (failed after $max_attempts attempts)"
      return 1
    fi
  done

  return 1
}

# Update version field in context/.context-config.json
# Uses temp file approach for portability (macOS/Linux compatible)
update_config_version() {
  local config_file="context/.context-config.json"
  local new_version="${1:-$VERSION}"

  # Check if config file exists
  if [ ! -f "$config_file" ]; then
    return 0  # Skip if no config file (fresh install)
  fi

  # Use temp file for portable sed (works on macOS and Linux)
  if sed "s/\"version\": \"[^\"]*\"/\"version\": \"$new_version\"/" "$config_file" > "$config_file.tmp"; then
    # Validate output before overwriting
    if [ -s "$config_file.tmp" ]; then
      mv "$config_file.tmp" "$config_file"
      echo -e "${BLUE}📝 Updated config version to v${new_version}${NC}"
      return 0
    else
      echo -e "${YELLOW}⚠️  Version update failed (empty output), preserving original${NC}"
      rm -f "$config_file.tmp"
      return 1
    fi
  else
    echo -e "${YELLOW}⚠️  Version update failed, preserving original${NC}"
    rm -f "$config_file.tmp"
    return 1
  fi
}

# Rollback installation on error
rollback_installation() {
  if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    echo ""
    echo -e "${RED}❌ Installation failed${NC}"
    echo -e "${BLUE}🔄 Restoring from backup...${NC}"

    # Restore .claude directory
    if [ -d "$BACKUP_DIR/.claude" ]; then
      rm -rf .claude 2>/dev/null || true
      cp -r "$BACKUP_DIR/.claude" . 2>/dev/null || true
    fi

    # Restore scripts directory
    if [ -d "$BACKUP_DIR/scripts" ]; then
      rm -rf scripts 2>/dev/null || true
      cp -r "$BACKUP_DIR/scripts" . 2>/dev/null || true
    fi

    echo -e "${GREEN}✅ System restored from backup${NC}"
    echo ""
    echo "Backup preserved at: $BACKUP_DIR"
    exit 1
  else
    echo ""
    echo -e "${RED}❌ Installation failed (no backup available)${NC}"
    exit 1
  fi
}

# Post-installation validation and auto-repair (v3.3.1)
post_install_validation() {
  echo ""
  echo -e "${BLUE}🔍 Validating installation...${NC}"

  local issues_found=0
  local issues_fixed=0

  # Check 1: Version sync
  if [ -f "VERSION" ] && [ -f "context/.context-config.json" ]; then
    local version_file=$(cat VERSION | tr -d ' \n')
    local config_version=$(grep '"version"' context/.context-config.json | sed 's/.*"version": "\([^"]*\)".*/\1/')

    if [ "$version_file" != "$config_version" ]; then
      echo -e "   ${YELLOW}⚠️  Version mismatch detected${NC} (VERSION=$version_file, config=$config_version)"
      issues_found=$((issues_found + 1))

      # Auto-fix
      if update_config_version "$version_file" >/dev/null 2>&1; then
        echo "   ${GREEN}✅ Fixed version sync${NC}"
        issues_fixed=$((issues_fixed + 1))
      fi
    fi
  fi

  # Check 2: Script permissions
  for script in scripts/*.sh; do
    if [ -f "$script" ] && [ ! -x "$script" ]; then
      echo -e "   ${YELLOW}⚠️  Script not executable${NC}: $script"
      issues_found=$((issues_found + 1))
      chmod +x "$script" 2>/dev/null && {
        echo "   ${GREEN}✅ Fixed permissions${NC}: $script"
        issues_fixed=$((issues_fixed + 1))
      }
    fi
  done

  # Summary
  echo ""
  if [ $issues_found -eq 0 ]; then
    echo -e "${GREEN}✅ Installation validated${NC} - no issues found"
  elif [ $issues_fixed -eq $issues_found ]; then
    echo -e "${GREEN}✅ Installation validated${NC} - all $issues_fixed issue(s) auto-fixed"
  else
    echo -e "${YELLOW}⚠️  Installation validated${NC} - fixed $issues_fixed/$issues_found issue(s)"
  fi
}

# Set error trap
trap 'rollback_installation' ERR

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

  # Try to detect version (priority order)
  EXISTING_VERSION="unknown"

  # 1. Check VERSION file (most reliable)
  if [ -f "VERSION" ]; then
    EXISTING_VERSION=$(cat VERSION | tr -d '\n' | tr -d ' ')

  # 2. Check config file
  elif [ -f "context/.context-config.json" ]; then
    EXISTING_VERSION=$(grep '"version":' context/.context-config.json | head -1 | sed 's/.*"version":[[:space:]]*"\([^"]*\)".*/\1/' || echo "unknown")

  # 3. Fallback to script grepping
  elif [ -f "scripts/validate-context.sh" ]; then
    EXISTING_VERSION=$(grep -m 1 "v[0-9]\+\.[0-9]\+\.[0-9]\+" scripts/validate-context.sh | sed 's/.*v\([0-9.]*\).*/\1/' || echo "unknown")
  fi

  echo "   Current version: ${EXISTING_VERSION}"
  echo "   New version: ${VERSION}"
  echo ""

  if [ "$NON_INTERACTIVE" = true ]; then
    echo "   Non-interactive mode: Proceeding with installation"
    REPLY="y"
  else
    read -p "Overwrite existing installation? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo -e "${YELLOW}Installation cancelled${NC}"
      exit 0
    fi
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
# Step 4: Download VERSION file and scripts
# =============================================================================

echo -e "${BLUE}⬇️  Downloading VERSION and scripts...${NC}"

# Download VERSION file
echo -n "   Downloading VERSION... "
if download_file "${RAW_URL}/VERSION" "VERSION" 1; then
  : # Success message already printed
else
  echo -e "${RED}CRITICAL: VERSION file download failed${NC}"
  rollback_installation
fi

# Download common-functions.sh
echo -n "   Downloading common-functions.sh... "
if download_file "${RAW_URL}/scripts/common-functions.sh" "scripts/common-functions.sh" 100; then
  chmod +x "scripts/common-functions.sh"
else
  echo -e "${RED}CRITICAL: common-functions.sh download failed${NC}"
  rollback_installation
fi

echo ""

# =============================================================================
# Initialize counters
# =============================================================================

FAILED_DOWNLOADS=0
VERIFICATION_FAILED=0

# =============================================================================
# Step 5: Download commands
# =============================================================================

echo -e "${BLUE}⬇️  Downloading slash commands...${NC}"

COMMANDS=(
  "init-context.md"
  "migrate-context.md"
  "save.md"
  "save-full.md"
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

for cmd in "${COMMANDS[@]}"; do
  echo -n "   Downloading $cmd... "
  if ! download_file "${RAW_URL}/.claude/commands/${cmd}" ".claude/commands/${cmd}" 100; then
    echo -e "${RED}CRITICAL: Command download failed${NC}"
    rollback_installation
  fi
done

echo ""

# =============================================================================
# Step 6: Download templates
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
  "context-feedback.template.md"
)

echo "   ℹ️  Note: QUICK_REF.template.md removed in v2.1 (Quick Reference now in STATUS.md)"

for tmpl in "${TEMPLATES[@]}"; do
  echo -n "   Downloading $tmpl... "
  if ! download_file "${RAW_URL}/templates/${tmpl}" "templates/${tmpl}" 100; then
    echo -e "${RED}CRITICAL: Template download failed${NC}"
    rollback_installation
  fi
done

echo ""

# =============================================================================
# Step 7: Download remaining scripts
# =============================================================================

echo -e "${BLUE}⬇️  Downloading scripts...${NC}"

SCRIPTS=(
  "validate-context.sh"
  "save-full-helper.sh"
  "find-context-folder.sh"
  "update-quick-reference.sh"
)

for script in "${SCRIPTS[@]}"; do
  echo -n "   Downloading $script... "
  if download_file "${RAW_URL}/scripts/${script}" "scripts/${script}" 100; then
    chmod +x "scripts/${script}"
  else
    echo -e "${RED}CRITICAL: Script download failed${NC}"
    rollback_installation
  fi
done

echo ""

# =============================================================================
# Step 8: Download configuration
# =============================================================================

echo -e "${BLUE}⬇️  Downloading configuration...${NC}"

CONFIG_FILES=(
  "context-config-schema.json"
)

for cfg in "${CONFIG_FILES[@]}"; do
  echo -n "   Downloading $cfg... "
  if ! download_file "${RAW_URL}/config/${cfg}" "config/${cfg}" 100; then
    ((FAILED_DOWNLOADS++))
  fi
done

# Download config template
echo -n "   Downloading .context-config.template.json... "
if ! download_file "${RAW_URL}/config/.context-config.template.json" "config/.context-config.template.json" 100; then
  ((FAILED_DOWNLOADS++))
fi

echo ""

# =============================================================================
# Step 9: Download documentation
# =============================================================================

echo -e "${BLUE}⬇️  Downloading documentation...${NC}"

DOCS=(
  "command-philosophy.md"
  "update-guide.md"
)

for doc in "${DOCS[@]}"; do
  echo -n "   Downloading $doc... "
  if ! download_file "${RAW_URL}/.claude/docs/${doc}" ".claude/docs/${doc}" 100; then
    ((FAILED_DOWNLOADS++))
  fi
done

echo ""

# =============================================================================
# Step 10: Download reference files
# =============================================================================

echo -e "${BLUE}⬇️  Downloading reference files...${NC}"

# Download ORGANIZATION.md to reference/ (users can copy to root if desired)
echo -n "   Downloading ORGANIZATION.md... "
if ! download_file "${RAW_URL}/ORGANIZATION.md" "reference/ORGANIZATION.md" 100; then
  ((FAILED_DOWNLOADS++))
fi

echo ""

# =============================================================================
# Step 11: Verify installation
# =============================================================================

echo -e "${BLUE}🔍 Verifying installation...${NC}"

VERIFICATION_FAILED=0

# Check critical files (v3.3.1)
CRITICAL_FILES=(
  "VERSION"
  "scripts/common-functions.sh"
  ".claude/commands/init-context.md"
  ".claude/commands/save.md"
  ".claude/commands/save-full.md"
  "templates/claude.md.template"
  "templates/CONTEXT.template.md"
  "templates/STATUS.template.md"
  "templates/DECISIONS.template.md"
  "scripts/validate-context.sh"
  "scripts/find-context-folder.sh"
  "scripts/update-quick-reference.sh"
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
# Step 12: Installation summary
# =============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $FAILED_DOWNLOADS -eq 0 ] && [ $VERIFICATION_FAILED -eq 0 ]; then
  # Disable error trap - installation complete, don't rollback for prompt failures
  trap - ERR

  echo -e "${GREEN}✅ Installation successful!${NC}"
  echo ""
  echo "AI Context System v${VERSION} is now installed."

  # Run post-installation validation (v3.3.1: auto-fixes common issues)
  post_install_validation

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
  echo "   - GitHub: ${REPO_URL}"
  echo ""
  echo -e "${BLUE}v3.0.0 Features (Universal AI Support + Critical Fixes):${NC}"
  echo "   - Rebrand: Claude Context System → AI Context System"
  echo "   - Enhanced git push protection (commit ≠ push)"
  echo "   - Smart SESSIONS.md loading (handles large files)"
  echo "   - Context folder detection (works from subdirectories)"
  echo "   - Validated with real-world production feedback"
  echo "   - Multi-AI support (Claude, Cursor, Aider, Codex)"
  echo ""
  echo -e "${BLUE}v2.3.1 Features (Feedback System):${NC}"
  echo "   - Built-in feedback collection (context-feedback.md)"
  echo "   - Structured templates for bugs, improvements, questions"
  echo "   - Auto-archive on update with version tracking"
  echo ""
  echo -e "${BLUE}v2.3.0 Features (Production-Ready Quality):${NC}"
  echo "   - Performance: 10-100x faster on large repos"
  echo "   - Network: Robust error handling with retry logic"
  echo "   - Security: Input validation, download verification"
  echo "   - Shared utilities: scripts/common-functions.sh"
  echo "   - Single VERSION file source of truth"
  echo ""
  echo -e "${BLUE}v2.2.1 Features (Organization):${NC}"
  echo "   - ORGANIZATION.md guidelines (in reference/)"
  echo "   - /organize-docs (interactive cleanup wizard)"
  echo "   - Organization validation (0-100 scoring)"
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

  # ==========================================================================
  # Optional: Prompt to initialize context
  # ==========================================================================

  if [ "$NON_INTERACTIVE" = true ]; then
    # Skip prompt in non-interactive mode
    echo -e "${BLUE}Non-interactive mode: Skipping initialization prompt${NC}"
    echo ""
    echo "To initialize context system later, run: /init-context"
    echo ""
  else
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "Initialize context system now? This will run /init-context. [Y/n] " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
      echo ""
      echo -e "${GREEN}Running /init-context...${NC}"
      echo ""

      # Check if Claude Code is available
      if command -v claude &> /dev/null; then
        echo "Launching /init-context in Claude Code..."
        echo "Note: This will open in Claude Code interface"
        echo ""
        claude /init-context
      else
        echo -e "${YELLOW}Claude Code not found in PATH${NC}"
        echo ""
        echo "To initialize context:"
        echo "  1. Open this project in Claude Code"
        echo "  2. Run: /init-context"
        echo ""
      fi
    else
      echo ""
      echo -e "${BLUE}Skipped initialization${NC}"
      echo ""
      echo "When ready, run: /init-context"
      echo ""
    fi
  fi

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
