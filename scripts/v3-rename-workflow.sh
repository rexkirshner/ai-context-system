#!/bin/bash
# v3-rename-workflow.sh
# Automated rename workflow for v3.0.0 rebrand
#
# AI Context System (formerly Claude Context System)
#
# Purpose: Batch-update all files from "Claude Context System" to "AI Context System"
# Usage: ./scripts/v3-rename-workflow.sh [--dry-run]
#
# IMPORTANT: Review terminology-guardrails.md before running
# IMPORTANT: Run with --dry-run first to preview changes

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  echo -e "${YELLOW}🔍 DRY RUN MODE - No changes will be made${NC}"
  echo ""
fi

# Change counter
CHANGES=0

#=============================================================================
# Helper Functions
#=============================================================================

log_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

log_warn() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
  echo -e "${RED}❌ $1${NC}"
}

# Safe replace function - checks before modifying
safe_replace() {
  local file="$1"
  local pattern="$2"
  local replacement="$3"
  local context="$4"

  if ! [[ -f "$file" ]]; then
    log_warn "File not found: $file"
    return 1
  fi

  # Check if pattern exists
  if ! grep -q "$pattern" "$file"; then
    return 0  # Pattern not found, nothing to do
  fi

  # Count matches
  local count=$(grep -c "$pattern" "$file" || true)

  if [[ $DRY_RUN == true ]]; then
    echo "  [DRY RUN] Would replace in $file: '$pattern' → '$replacement' ($count matches)"
    CHANGES=$((CHANGES + count))
  else
    # Create backup
    cp "$file" "$file.bak"

    # Perform replacement
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      sed -i '' "s|$pattern|$replacement|g" "$file"
    else
      # Linux
      sed -i "s|$pattern|$replacement|g" "$file"
    fi

    log_success "Replaced in $file: $count matches ($context)"
    CHANGES=$((CHANGES + count))

    # Remove backup if successful
    rm "$file.bak"
  fi
}

# Verify file hasn't changed (for files that should stay the same)
verify_unchanged() {
  local file="$1"
  local pattern="$2"

  if [[ -f "$file" ]] && grep -q "$pattern" "$file"; then
    log_error "FAIL: $file still contains: $pattern"
    log_error "This file should have been updated!"
    return 1
  fi

  return 0
}

#=============================================================================
# Pre-flight Checks
#=============================================================================

log_info "Running pre-flight checks..."

# Check we're in the right directory
if [[ ! -f "README.md" ]] || [[ ! -d ".claude" ]]; then
  log_error "Must run from repository root"
  exit 1
fi

# Check for uncommitted changes
if [[ $DRY_RUN == false ]]; then
  if ! git diff-index --quiet HEAD --; then
    log_error "Uncommitted changes detected. Commit or stash first."
    exit 1
  fi
  log_success "No uncommitted changes"
fi

# Check guardrails document exists
if [[ ! -f "planning/v3.0.0/terminology-guardrails.md" ]]; then
  log_warn "terminology-guardrails.md not found - proceeding anyway"
fi

log_success "Pre-flight checks passed"
echo ""

#=============================================================================
# Phase 1: File Renames
#=============================================================================

log_info "Phase 1: File Renames"

# Rename feedback template
if [[ -f "templates/claude-context-feedback.template.md" ]]; then
  if [[ $DRY_RUN == true ]]; then
    echo "  [DRY RUN] Would rename: templates/claude-context-feedback.template.md → templates/context-feedback.template.md"
    CHANGES=$((CHANGES + 1))
  else
    git mv templates/claude-context-feedback.template.md templates/context-feedback.template.md
    log_success "Renamed: templates/claude-context-feedback.template.md → templates/context-feedback.template.md"
    CHANGES=$((CHANGES + 1))
  fi
else
  log_warn "Template file already renamed or not found"
fi

echo ""

#=============================================================================
# Phase 2: System Name Replacement
#=============================================================================

log_info "Phase 2: System Name Replacement"

# Pattern: "Claude Context System" → "AI Context System"
FILES_TO_UPDATE=(
  "README.md"
  "install.sh"
  "CHANGELOG.md"
  "VERSION"
  ".claude/commands/init-context.md"
  ".claude/commands/update-context-system.md"
  ".claude/commands/validate-context.md"
  ".claude/commands/organize-docs.md"
  ".claude/commands/code-review.md"
  ".claude/commands/save.md"
  ".claude/commands/save-full.md"
  ".claude/commands/export-context.md"
  ".claude/commands/session-summary.md"
  ".claude/commands/review-context.md"
  ".claude/commands/migrate-context.md"
  ".claude/commands/add-ai-header.md"
  ".claude/docs/command-philosophy.md"
  ".claude/docs/save-context-guide.md"
  "scripts/common-functions.sh"
  "scripts/validate-context.sh"
)

for file in "${FILES_TO_UPDATE[@]}"; do
  if [[ -f "$file" ]]; then
    safe_replace "$file" "Claude Context System" "AI Context System" "system name"
  else
    log_warn "File not found: $file"
  fi
done

echo ""

#=============================================================================
# Phase 3: Feedback File References
#=============================================================================

log_info "Phase 3: Feedback File References"

# Pattern: "claude-context-feedback.md" → "context-feedback.md"
FEEDBACK_FILES=(
  ".claude/commands/init-context.md"
  ".claude/commands/update-context-system.md"
  ".claude/commands/validate-context.md"
  ".claude/commands/organize-docs.md"
  ".claude/commands/code-review.md"
  ".claude/commands/save.md"
  ".claude/commands/save-full.md"
  "README.md"
  "CHANGELOG.md"
)

for file in "${FEEDBACK_FILES[@]}"; do
  if [[ -f "$file" ]]; then
    safe_replace "$file" "claude-context-feedback\\.md" "context-feedback.md" "feedback filename"
    safe_replace "$file" "claude-context-feedback" "context-feedback" "feedback filename (no ext)"
  fi
done

echo ""

#=============================================================================
# Phase 4: Repository URL Updates
#=============================================================================

log_info "Phase 4: Repository URL Updates"

# Pattern: github.com/rexkirshner/claude-context-system → github.com/rexkirshner/ai-context-system
URL_FILES=(
  "README.md"
  "install.sh"
  "CHANGELOG.md"
  ".claude/commands/update-context-system.md"
)

for file in "${URL_FILES[@]}"; do
  if [[ -f "$file" ]]; then
    safe_replace "$file" "github\\.com/rexkirshner/claude-context-system" "github.com/rexkirshner/ai-context-system" "repo URL"
  fi
done

echo ""

#=============================================================================
# Phase 5: Version Number Updates
#=============================================================================

log_info "Phase 5: Version Number Updates"

# Update VERSION file
if [[ -f "VERSION" ]]; then
  if [[ $DRY_RUN == true ]]; then
    echo "  [DRY RUN] Would update VERSION: 2.3.2 → 3.0.0"
    CHANGES=$((CHANGES + 1))
  else
    echo "3.0.0" > VERSION
    log_success "Updated VERSION: 3.0.0"
    CHANGES=$((CHANGES + 1))
  fi
fi

# Update config template
if [[ -f "config/.context-config.template.json" ]]; then
  safe_replace "config/.context-config.template.json" '"version": "2\\.3\\.2"' '"version": "3.0.0"' "version number"
  safe_replace "config/.context-config.template.json" '"configVersion": "2\\.3\\.2"' '"configVersion": "3.0.0"' "config version"
fi

# Update command footers (version numbers at bottom of commands)
for file in .claude/commands/*.md; do
  if [[ -f "$file" ]]; then
    safe_replace "$file" "Version: 2\\.3\\.2" "Version: 3.0.0" "footer version"
    safe_replace "$file" "\\*\\*Version:\\*\\* 2\\.3\\.2" "**Version:** 3.0.0" "footer version (bold)"
  fi
done

echo ""

#=============================================================================
# Phase 6: Template Content Updates
#=============================================================================

log_info "Phase 6: Template Content Updates"

# Update feedback template (now with new filename)
if [[ -f "templates/context-feedback.template.md" ]]; then
  safe_replace "templates/context-feedback.template.md" "claude-context-feedback" "context-feedback" "internal references"
fi

echo ""

#=============================================================================
# Phase 7: Add Attribution Lines
#=============================================================================

log_info "Phase 7: Add Attribution Lines (Manual)"

log_warn "MANUAL STEP: Add 'Originally designed for Claude Code, supports all AI assistants' to:"
echo "  - README.md (in tagline section)"
echo "  - Migration messaging in update-context-system.md"
echo "  - Release announcements"
echo ""

#=============================================================================
# Phase 8: Verification
#=============================================================================

log_info "Phase 8: Verification"

if [[ $DRY_RUN == false ]]; then
  log_info "Running verification checks..."

  # Check for missed "Claude Context System" (excluding CHANGELOG historical)
  MISSED=$(grep -r "Claude Context System" . \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --exclude-dir=planning \
    --exclude="*.bak" \
    2>/dev/null || true)

  if [[ -n "$MISSED" ]]; then
    log_warn "Found remaining 'Claude Context System' references:"
    echo "$MISSED"
    echo ""
    log_warn "Review these manually - may be historical or intentional"
  else
    log_success "No 'Claude Context System' found in current docs"
  fi

  # Check for missed feedback filename
  MISSED_FEEDBACK=$(grep -r "claude-context-feedback\.md" . \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --exclude-dir=planning \
    --exclude="*.bak" \
    2>/dev/null | grep -v "OLD_FEEDBACK" || true)

  if [[ -n "$MISSED_FEEDBACK" ]]; then
    log_warn "Found remaining 'claude-context-feedback.md' references:"
    echo "$MISSED_FEEDBACK"
  else
    log_success "No old feedback filename found (except migration variables)"
  fi

  # Verify claude.md is still referenced (should be)
  CLAUDE_MD_REFS=$(grep -r "claude\.md" . \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --exclude-dir=planning \
    2>/dev/null | wc -l)

  if [[ $CLAUDE_MD_REFS -gt 0 ]]; then
    log_success "claude.md still referenced ($CLAUDE_MD_REFS times) - CORRECT"
  else
    log_error "claude.md not found in any files - this is WRONG!"
  fi

  # Verify new template exists
  if [[ -f "templates/context-feedback.template.md" ]]; then
    log_success "New template exists: templates/context-feedback.template.md"
  else
    log_error "New template NOT found!"
  fi

  # Verify old template is gone
  if [[ -f "templates/claude-context-feedback.template.md" ]]; then
    log_error "Old template still exists - should have been renamed!"
  else
    log_success "Old template removed"
  fi
fi

echo ""

#=============================================================================
# Summary
#=============================================================================

log_info "Summary"
echo ""

if [[ $DRY_RUN == true ]]; then
  echo "  Total changes that would be made: $CHANGES"
  echo ""
  log_info "Run without --dry-run to apply changes"
else
  echo "  Total changes made: $CHANGES"
  echo ""
  log_success "Rename workflow complete!"
  echo ""
  log_info "Next steps:"
  echo "  1. Review changes: git diff"
  echo "  2. Run tests: ./scripts/test-*.sh"
  echo "  3. Manual additions (see Phase 7 above)"
  echo "  4. Commit: git add -A && git commit -m 'v3.0.0: System rebrand'"
fi

echo ""

#=============================================================================
# Audit Trail
#=============================================================================

if [[ $DRY_RUN == false ]]; then
  # Generate change report
  REPORT_FILE="planning/v3.0.0/rename-audit-$(date +%Y-%m-%d-%H%M%S).txt"

  {
    echo "v3.0.0 Rename Workflow Audit"
    echo "============================"
    echo ""
    echo "Date: $(date)"
    echo "Total changes: $CHANGES"
    echo ""
    echo "Files modified:"
    git status --short
  } > "$REPORT_FILE"

  log_success "Audit report saved: $REPORT_FILE"
fi

exit 0
