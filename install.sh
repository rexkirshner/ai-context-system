#!/bin/bash

# install.sh
# Bootstrap installer for AI Context System
# Version: See VERSION file at repository root
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

# Portable colored output (works on bash, zsh, sh)
# Use this instead of echo -e for color output
color_echo() {
  printf "%b\n" "$1"
}

# Repository configuration
REPO_URL="https://github.com/rexkirshner/ai-context-system"
RAW_URL="https://raw.githubusercontent.com/rexkirshner/ai-context-system/main"

# =============================================================================
# CRITICAL: Detect update vs fresh install BEFORE doing anything else! (v5.0.2)
# This MUST happen before we create any directories or download files
# =============================================================================
IS_UPDATE=false
if [ -f "context/.context-config.json" ] || \
   [ -f "context/STATUS.md" ] || \
   [ -d ".claude/commands" ]; then
  IS_UPDATE=true
fi

# Optional files (download failures won't block installation)
OPTIONAL_FILES=(
  "reference/ORGANIZATION.md"
)

# Get version from GitHub VERSION file (with validation)
VERSION=$(curl -sL "${RAW_URL}/VERSION" 2>/dev/null || echo "5.0.0")

# Validate VERSION format (must be X.Y.Z)
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  color_echo "${YELLOW}⚠️  Warning: Could not fetch version from GitHub${NC}"
  echo "   Using fallback version: 5.0.0"
  VERSION="5.0.0"
fi

color_echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
color_echo "${BLUE}  AI Context System Installer (v${VERSION})${NC}"
color_echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# =============================================================================
# Step 0: Parse command line flags
# =============================================================================

NON_INTERACTIVE=false
INSTALL_VERSION=""

# Parse all arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --yes|-y|--force)
      NON_INTERACTIVE=true
      shift
      ;;
    --version)
      INSTALL_VERSION="$2"
      shift 2
      ;;
    --version=*)
      INSTALL_VERSION="${1#*=}"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# If specific version requested, use tag URL for reproducible installs
if [ -n "$INSTALL_VERSION" ]; then
  RAW_URL="https://raw.githubusercontent.com/rexkirshner/ai-context-system/refs/tags/v${INSTALL_VERSION}"
  color_echo "${BLUE}Installing specific version: v${INSTALL_VERSION}${NC}"
  VERSION="$INSTALL_VERSION"
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
    color_echo "${RED}✗${NC} (file too small: ${size} bytes)"
    return 1
  fi

  # Check for 404 error pages (only check first 3 lines to avoid false positives)
  # Real 404 errors appear at the start: "404: Not Found" or "HTTP/1.1 404"
  # Don't check entire file - legitimate code may contain "NOT_FOUND" constants
  if head -3 "$file" | grep -Eq "^404: Not Found$|^HTTP.*404|404.*Not Found"; then
    color_echo "${RED}✗${NC} (404 error page)"
    return 1
  fi

  # Check for HTML error pages
  if head -3 "$file" | grep -qi "<!DOCTYPE\|<html"; then
    color_echo "${RED}✗${NC} (HTML error page)"
    return 1
  fi

  return 0
}

# Check if a file is in the optional files list
is_optional() {
  local file="$1"
  for opt in "${OPTIONAL_FILES[@]}"; do
    [[ "$file" == "$opt" ]] && return 0
  done
  return 1
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
        color_echo "${GREEN}✓${NC}"
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
      color_echo "${RED}✗${NC} (failed after $max_attempts attempts)"
      return 1
    fi
  done

  return 1
}

# Update version fields in context/.context-config.json
# Uses temp file approach for portability (macOS/Linux compatible)
update_config_version() {
  local config_file="context/.context-config.json"
  local new_version="${1:-$VERSION}"

  # Check if config file exists
  if [ ! -f "$config_file" ]; then
    return 0  # Skip if no config file (fresh install)
  fi

  # Use temp file for portable sed (works on macOS and Linux)
  # Update both "version" and "configVersion" fields
  if sed -e "s/\"version\": \"[^\"]*\"/\"version\": \"$new_version\"/" \
         -e "s/\"configVersion\": \"[^\"]*\"/\"configVersion\": \"$new_version\"/" \
         "$config_file" > "$config_file.tmp"; then
    # Validate output before overwriting
    if [ -s "$config_file.tmp" ]; then
      mv "$config_file.tmp" "$config_file"
      color_echo "${BLUE}📝 Updated config version to v${new_version}${NC}"
      return 0
    else
      color_echo "${YELLOW}⚠️  Version update failed (empty output), preserving original${NC}"
      rm -f "$config_file.tmp"
      return 1
    fi
  else
    color_echo "${YELLOW}⚠️  Version update failed, preserving original${NC}"
    rm -f "$config_file.tmp"
    return 1
  fi
}

# Rollback installation on error (v3.3.1: enhanced)
rollback_installation() {
  if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    echo ""
    color_echo "${RED}❌ Installation failed${NC}"
    color_echo "${BLUE}🔄 Restoring from backup...${NC}"

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

    # Restore VERSION file
    if [ -f "$BACKUP_DIR/VERSION" ]; then
      cp "$BACKUP_DIR/VERSION" . 2>/dev/null || true
    fi

    # Restore context directory
    if [ -d "$BACKUP_DIR/context" ]; then
      rm -rf context 2>/dev/null || true
      cp -r "$BACKUP_DIR/context" . 2>/dev/null || true
    fi

    color_echo "${GREEN}✅ System restored from backup${NC}"
    echo ""
    echo "Backup preserved at: $BACKUP_DIR"
    exit 1
  else
    echo ""
    color_echo "${RED}❌ Installation failed (no backup available)${NC}"
    exit 1
  fi
}

# Post-installation validation and auto-repair (v3.3.1)
post_install_validation() {
  echo ""
  color_echo "${BLUE}🔍 Validating installation...${NC}"

  local issues_found=0
  local issues_fixed=0

  # Check 1: Version sync
  if [ -f "VERSION" ] && [ -f "context/.context-config.json" ]; then
    local version_file=$(cat VERSION | tr -d ' \n')
    local config_version=$(grep '"version"' context/.context-config.json | sed 's/.*"version": "\([^"]*\)".*/\1/')

    if [ "$version_file" != "$config_version" ]; then
      color_echo "   ${YELLOW}⚠️  Version mismatch detected${NC} (VERSION=$version_file, config=$config_version)"
      issues_found=$((issues_found + 1))

      # Auto-fix
      if update_config_version "$version_file" >/dev/null 2>&1; then
        color_echo "   ${GREEN}✅ Fixed version sync${NC}"
        issues_fixed=$((issues_fixed + 1))
      fi
    fi
  fi

  # Check 2: jq dependency (required for v3.4.0 code review features)
  if ! command -v jq &> /dev/null; then
    color_echo "   ${YELLOW}⚠️  Optional dependency 'jq' not found${NC}"
    color_echo "   ${BLUE}ℹ️  Required for /code-review smart grouping and TodoWrite generation${NC}"
    echo "   Install: brew install jq (macOS) or apt-get install jq (Linux)"
    issues_found=$((issues_found + 1))
    # Note: This is informational, not critical - don't block installation
  fi

  # Check 3: Script permissions
  for script in scripts/*.sh; do
    if [ -f "$script" ] && [ ! -x "$script" ]; then
      color_echo "   ${YELLOW}⚠️  Script not executable${NC}: $script"
      issues_found=$((issues_found + 1))
      chmod +x "$script" 2>/dev/null && {
        color_echo "   ${GREEN}✅ Fixed permissions${NC}: $script"
        issues_fixed=$((issues_fixed + 1))
      }
    fi
  done

  # Summary
  echo ""
  if [ $issues_found -eq 0 ]; then
    color_echo "${GREEN}✅ Installation validated${NC} - no issues found"
  elif [ $issues_fixed -eq $issues_found ]; then
    color_echo "${GREEN}✅ Installation validated${NC} - all $issues_fixed issue(s) auto-fixed"
  else
    color_echo "${YELLOW}⚠️  Installation validated${NC} - fixed $issues_fixed/$issues_found issue(s)"
  fi
}

# Set error trap
trap 'rollback_installation' ERR

# =============================================================================
# Step 1: Detect working directory
# =============================================================================

CURRENT_DIR=$(pwd)
color_echo "${BLUE}📁 Installation directory:${NC} $CURRENT_DIR"
echo ""

# =============================================================================
# Step 2: Check for existing installation
# =============================================================================

if [ -d ".claude/commands" ] && [ -f ".claude/commands/init-context.md" ]; then
  color_echo "${YELLOW}⚠️  Existing installation detected${NC}"
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
      color_echo "${YELLOW}Installation cancelled${NC}"
      exit 0
    fi
  fi

  color_echo "${BLUE}📦 Backing up existing installation...${NC}"
  BACKUP_DIR=".claude-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"

  # Backup system directories and files (v3.3.1: enhanced)
  if [ -d ".claude" ]; then
    cp -r .claude "$BACKUP_DIR/" 2>/dev/null || true
  fi
  if [ -d "scripts" ]; then
    cp -r scripts "$BACKUP_DIR/" 2>/dev/null || true
  fi
  if [ -f "VERSION" ]; then
    cp VERSION "$BACKUP_DIR/" 2>/dev/null || true
  fi
  if [ -d "context" ]; then
    cp -r context "$BACKUP_DIR/" 2>/dev/null || true
  fi

  echo "   ✅ Backup created: $BACKUP_DIR"
  echo ""
fi

# =============================================================================
# Step 3: Create directory structure
# =============================================================================

color_echo "${BLUE}📂 Creating directory structure...${NC}"

mkdir -p .claude/commands
mkdir -p .claude/docs
mkdir -p .claude/agents       # v5.0.0 agent-based review
mkdir -p .claude/schemas      # v5.0.0 JSON schemas
mkdir -p .claude/skills       # v5.0.0 modular skills
mkdir -p .claude/hooks        # v5.0.0 session automation
mkdir -p scripts
mkdir -p templates
mkdir -p config
mkdir -p reference
mkdir -p docs/audits/archive  # v4.0.0 audit system

echo "   ✅ Directories created"
echo ""

# =============================================================================
# Step 4: Download VERSION file and scripts
# =============================================================================

color_echo "${BLUE}⬇️  Downloading VERSION and scripts...${NC}"

# Download VERSION file
echo -n "   Downloading VERSION... "
if download_file "${RAW_URL}/VERSION" "VERSION" 1; then
  : # Success message already printed
else
  color_echo "${RED}CRITICAL: VERSION file download failed${NC}"
  rollback_installation
fi

# Download common-functions.sh
echo -n "   Downloading common-functions.sh... "
if download_file "${RAW_URL}/scripts/common-functions.sh" "scripts/common-functions.sh" 100; then
  chmod +x "scripts/common-functions.sh"
else
  color_echo "${RED}CRITICAL: common-functions.sh download failed${NC}"
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

color_echo "${BLUE}⬇️  Downloading slash commands...${NC}"

COMMANDS=(
  # Core commands
  "init-context.md"
  "migrate-context.md"
  "save.md"
  "save-full.md"
  "review-context.md"
  "validate-context.md"
  "export-context.md"
  "update-context-system.md"
  "update-templates.md"
  "add-ai-header.md"
  "session-summary.md"
  "organize-docs.md"
  # Modular code review system (v4.0.0)
  "code-review.md"
  "code-review-security.md"
  "code-review-performance.md"
  "code-review-accessibility.md"
  "code-review-seo.md"
  "code-review-database.md"
  "code-review-infrastructure.md"
  "code-review-typescript.md"
  "code-review-testing.md"
  "build-check.md"
)

for cmd in "${COMMANDS[@]}"; do
  echo -n "   Downloading $cmd... "
  if ! download_file "${RAW_URL}/.claude/commands/${cmd}" ".claude/commands/${cmd}" 100; then
    color_echo "${RED}CRITICAL: Command download failed${NC}"
    rollback_installation
  fi
done

echo ""

# =============================================================================
# Step 6: Download templates
# =============================================================================

color_echo "${BLUE}⬇️  Downloading templates...${NC}"

TEMPLATES=(
  # AI tool headers
  "CLAUDE.md.template"
  "cursor.md.template"
  "aider.md.template"
  "codex.md.template"
  "generic-ai-header.template.md"
  # Core context files
  "CONTEXT.template.md"
  "STATUS.template.md"
  "DECISIONS.template.md"
  "SESSIONS.template.md"
  "context-feedback.template.md"
  # Optional documentation
  "CODE_MAP.template.md"
  "CODE_STYLE.template.md"
  "KNOWN_ISSUES.template.md"
  "PRD.template.md"
  "ARCHITECTURE.template.md"
  # Audit system
  "audits-index.template.md"
  # Migration
  "MIGRATION_SUMMARY.md"
)

for tmpl in "${TEMPLATES[@]}"; do
  echo -n "   Downloading $tmpl... "
  if ! download_file "${RAW_URL}/templates/${tmpl}" "templates/${tmpl}" 100; then
    color_echo "${RED}CRITICAL: Template download failed${NC}"
    rollback_installation
  fi
done

echo ""

# =============================================================================
# Step 7: Download remaining scripts
# =============================================================================

color_echo "${BLUE}⬇️  Downloading scripts...${NC}"

SCRIPTS=(
  "validate-context.sh"
  "save-full-helper.sh"
  "find-context-folder.sh"
  "update-quick-reference.sh"
  "code-review-helpers.sh"
  "archive-sessions-helper.sh"
  "export-sessions-json.sh"
)

for script in "${SCRIPTS[@]}"; do
  echo -n "   Downloading $script... "
  if download_file "${RAW_URL}/scripts/${script}" "scripts/${script}" 100; then
    chmod +x "scripts/${script}"
  else
    color_echo "${RED}CRITICAL: Script download failed${NC}"
    rollback_installation
  fi
done

echo ""

# =============================================================================
# Step 8: Download configuration
# =============================================================================

color_echo "${BLUE}⬇️  Downloading configuration...${NC}"

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

color_echo "${BLUE}⬇️  Downloading documentation...${NC}"

DOCS=(
  "command-philosophy.md"
  "code-review-guide.md"
  "README.md"
  "review-context-guide.md"
  "TROUBLESHOOTING.md"
  "usage-examples.md"
  "VERSION_MANAGEMENT.md"
)

for doc in "${DOCS[@]}"; do
  echo -n "   Downloading $doc... "
  if ! download_file "${RAW_URL}/.claude/docs/${doc}" ".claude/docs/${doc}" 100; then
    ((FAILED_DOWNLOADS++))
  fi
done

echo ""

# =============================================================================
# Step 9.5: Download agents (v5.0.0 - Agent-Based Code Review)
# =============================================================================

color_echo "${BLUE}⬇️  Downloading agents...${NC}"

AGENTS=(
  "code-reviewer.md"
  "codebase-scanner.md"
  "synthesis-agent.md"
  "audit-compare.md"
  "security-reviewer.md"
  "performance-reviewer.md"
  "accessibility-reviewer.md"
  "seo-reviewer.md"
  "database-reviewer.md"
  "infrastructure-reviewer.md"
  "test-coverage-reviewer.md"
  "type-safety-reviewer.md"
)

for agent in "${AGENTS[@]}"; do
  echo -n "   Downloading $agent... "
  if ! download_file "${RAW_URL}/.claude/agents/${agent}" ".claude/agents/${agent}" 100; then
    ((FAILED_DOWNLOADS++))
  fi
done

echo ""

# =============================================================================
# Step 9.6: Download schemas (v5.0.0 - JSON Schema Validation)
# =============================================================================

color_echo "${BLUE}⬇️  Downloading schemas...${NC}"

SCHEMAS=(
  "agent-contract.json"
  "audit-finding.json"
  "audit-report.json"
  "context-health.json"
  "handoff-package.json"
  "session-entry.json"
  "settings.json"
)

for schema in "${SCHEMAS[@]}"; do
  echo -n "   Downloading $schema... "
  if ! download_file "${RAW_URL}/.claude/schemas/${schema}" ".claude/schemas/${schema}" 50; then
    ((FAILED_DOWNLOADS++))
  fi
done

echo ""

# =============================================================================
# Step 9.7: Download skills (v5.0.0 - Modular Skill System)
# =============================================================================

color_echo "${BLUE}⬇️  Downloading skills...${NC}"

SKILLS=(
  "export"
  "init"
  "review"
  "save"
  "save-full"
  "update"
  "validate"
)

for skill in "${SKILLS[@]}"; do
  mkdir -p ".claude/skills/${skill}"
  echo -n "   Downloading skills/${skill}/SKILL.md... "
  if ! download_file "${RAW_URL}/.claude/skills/${skill}/SKILL.md" ".claude/skills/${skill}/SKILL.md" 100; then
    ((FAILED_DOWNLOADS++))
  fi
done

echo ""

# =============================================================================
# Step 9.8: Download hooks (v5.0.0 - Session Automation)
# =============================================================================

color_echo "${BLUE}⬇️  Downloading hooks...${NC}"

echo -n "   Downloading session-start.sh... "
if download_file "${RAW_URL}/.claude/hooks/session-start.sh" ".claude/hooks/session-start.sh" 50; then
  chmod +x ".claude/hooks/session-start.sh"
else
  ((FAILED_DOWNLOADS++))
fi

echo ""

# =============================================================================
# Step 9.9: Download settings (v5.0.0 - Profile Configuration)
# =============================================================================

color_echo "${BLUE}⬇️  Downloading settings...${NC}"

echo -n "   Downloading settings.json... "
# Only download if settings.json doesn't exist (preserve user customizations)
if [ ! -f ".claude/settings.json" ]; then
  if ! download_file "${RAW_URL}/.claude/settings.json" ".claude/settings.json" 50; then
    ((FAILED_DOWNLOADS++))
  fi
else
  color_echo "${BLUE}(preserved existing)${NC}"
fi

echo ""

# =============================================================================
# Step 10: Download reference files
# =============================================================================

color_echo "${BLUE}⬇️  Downloading reference files...${NC}"

# Download ORGANIZATION.md to reference/ (users can copy to root if desired)
echo -n "   Downloading ORGANIZATION.md... "
if ! download_file "${RAW_URL}/reference/ORGANIZATION.md" "reference/ORGANIZATION.md" 100; then
  # Check if this is an optional file
  if is_optional "reference/ORGANIZATION.md"; then
    echo "   (optional file, skipping)"
  else
    ((FAILED_DOWNLOADS++))
  fi
fi

echo ""

# =============================================================================
# Step 11: Verify installation
# =============================================================================

color_echo "${BLUE}🔍 Verifying installation...${NC}"

VERIFICATION_FAILED=0

# Check critical files (v5.0.1)
CRITICAL_FILES=(
  "VERSION"
  "scripts/common-functions.sh"
  ".claude/commands/init-context.md"
  ".claude/commands/save.md"
  ".claude/commands/save-full.md"
  ".claude/commands/code-review.md"
  "templates/CLAUDE.md.template"
  "templates/CONTEXT.template.md"
  "templates/STATUS.template.md"
  "templates/DECISIONS.template.md"
  "scripts/validate-context.sh"
  "scripts/find-context-folder.sh"
  "scripts/update-quick-reference.sh"
  "scripts/code-review-helpers.sh"
  # v5.0.0 additions
  ".claude/agents/code-reviewer.md"
  ".claude/agents/security-reviewer.md"
  ".claude/schemas/agent-contract.json"
  ".claude/schemas/audit-finding.json"
  ".claude/skills/save/SKILL.md"
  ".claude/skills/review/SKILL.md"
  ".claude/hooks/session-start.sh"
)

for file in "${CRITICAL_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "   ✅ $file"
  else
    color_echo "   ${RED}❌ $file${NC}"
    ((VERIFICATION_FAILED++))
  fi
done

echo ""

# =============================================================================
# Step 12: Installation summary
# =============================================================================

color_echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $FAILED_DOWNLOADS -eq 0 ] && [ $VERIFICATION_FAILED -eq 0 ]; then
  # Disable error trap - installation complete, don't rollback for prompt failures
  trap - ERR

  color_echo "${GREEN}✅ Installation successful!${NC}"
  echo ""
  echo "AI Context System v${VERSION} is now installed."

  # Run post-installation validation (v3.3.1: auto-fixes common issues)
  post_install_validation

  # Show context-appropriate next steps (v5.0.2)
  if [ "$IS_UPDATE" = "true" ]; then
    color_echo "${BLUE}✅ Update complete!${NC}"
    echo ""
    echo "What's new in v${VERSION}:"
    echo "   Run 'cat .claude/docs/CHANGELOG.md | head -50' to see recent changes"
    echo ""
    color_echo "${BLUE}Next steps:${NC}"
    echo "   1. Run /validate-context to verify the update"
    echo "   2. Run /review-context to resume work"
    echo "   3. Check .claude/docs/ for any new documentation"
  else
    color_echo "${BLUE}Next steps:${NC}"
    echo "   1. Run /init-context to initialize your project"
    echo "   2. Review context/CONTEXT.md for accuracy"
    echo "   3. Use TodoWrite during active work"
    echo "   4. Run /save frequently (2-3 min quick updates)"
    echo "   5. Run /save-full before breaks (10-15 min comprehensive)"
    echo "   6. Use /code-review for AI agent review"
  fi
  echo ""
  color_echo "${BLUE}Documentation:${NC}"
  echo "   - Command philosophy: .claude/docs/command-philosophy.md"
  echo "   - GitHub: ${REPO_URL}"
  echo ""
  color_echo "${BLUE}Key Features:${NC}"
  echo "   - 8 specialized audit commands: /code-review-security,"
  echo "     /code-review-performance, /code-review-accessibility, etc."
  echo "   - /code-review is an interactive orchestrator"
  echo "   - Reports saved to docs/audits/{type}-audit-NN.md"
  echo "   - Auto-detect platform (Prisma, Vercel, Next.js, etc.)"
  echo "   - Pre-launch presets: --prelaunch, --backend, --frontend"
  echo ""
  color_echo "${BLUE}Helpful commands:${NC}"
  echo "   /init-context          - Initialize context system"
  echo "   /save                  - Quick save (2-3 min)"
  echo "   /save-full             - Comprehensive save (10-15 min)"
  echo "   /validate-context      - Check documentation + organization"
  echo "   /organize-docs         - Interactive documentation cleanup"
  echo "   /update-context-system - Update to latest version"
  echo "   /update-templates      - Compare and update templates"
  echo ""

  # ==========================================================================
  # Optional: Prompt to initialize context (v5.0.2: skip for updates)
  # ==========================================================================

  # Skip init-context prompt for updates - context already exists
  if [ "$IS_UPDATE" = "true" ]; then
    color_echo "${BLUE}Update complete - context system already initialized${NC}"
    echo ""
    echo "Run /validate-context to verify your documentation"
    echo ""
  elif [ "$NON_INTERACTIVE" = true ]; then
    # Skip prompt in non-interactive mode
    color_echo "${BLUE}Non-interactive mode: Skipping initialization prompt${NC}"
    echo ""
    echo "To initialize context system later, run: /init-context"
    echo ""
  else
    color_echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "Initialize context system now? This will run /init-context. [Y/n] " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
      echo ""
      color_echo "${GREEN}Running /init-context...${NC}"
      echo ""

      # Check if Claude Code is available
      if command -v claude &> /dev/null; then
        echo "Launching /init-context in Claude Code..."
        echo "Note: This will open in Claude Code interface"
        echo ""
        claude /init-context
      else
        color_echo "${YELLOW}Claude Code not found in PATH${NC}"
        echo ""
        echo "To initialize context:"
        echo "  1. Open this project in Claude Code"
        echo "  2. Run: /init-context"
        echo ""
      fi
    else
      echo ""
      color_echo "${BLUE}Skipped initialization${NC}"
      echo ""
      echo "When ready, run: /init-context"
      echo ""
    fi
  fi

  exit 0
else
  color_echo "${RED}❌ Installation completed with errors${NC}"
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
