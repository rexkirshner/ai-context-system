#!/bin/bash
# Test Upgrade Path for AI Context System
# Validates that installer includes all required files and dependencies
# Version-agnostic: reads current version from VERSION file

# Note: Don't use set -e, we want to run all tests even if some fail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get current version
CURRENT_VERSION=$(cat VERSION 2>/dev/null | tr -d ' \n' || echo "unknown")

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

print_header() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "${BLUE}$1${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

print_test() {
  echo -e "${YELLOW}TEST $((TESTS_RUN + 1)):${NC} $1"
}

pass() {
  echo -e "  ${GREEN}✓ PASS${NC}"
  ((TESTS_PASSED++))
  ((TESTS_RUN++))
}

fail() {
  echo -e "  ${RED}✗ FAIL${NC}: $1"
  ((TESTS_FAILED++))
  ((TESTS_RUN++))
}

assert_contains() {
  local file=$1
  local pattern=$2
  local description=${3:-""}

  if grep -q "$pattern" "$file"; then
    pass
  else
    fail "Pattern not found in $file: $pattern"
    if [ -n "$description" ]; then
      echo "     $description"
    fi
  fi
}

assert_file_exists() {
  local file=$1
  local description=${2:-""}

  if [ -f "$file" ]; then
    pass
  else
    fail "File not found: $file"
    if [ -n "$description" ]; then
      echo "     $description"
    fi
  fi
}

assert_executable() {
  local file=$1

  if [ -x "$file" ]; then
    pass
  else
    fail "File not executable: $file"
  fi
}

print_header "Upgrade Path Validation (v$CURRENT_VERSION)"

# =============================================================================
# Test 1: VERSION file is valid
# =============================================================================

print_header "Test 1: Version Consistency"

print_test "VERSION file exists and has valid format"
if [[ "$CURRENT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  pass
else
  fail "VERSION file invalid: '$CURRENT_VERSION'"
fi

print_test "CHANGELOG.md has entry for current version"
CHANGELOG_PATTERN="## \[${CURRENT_VERSION}\]"
if grep -q "$CHANGELOG_PATTERN" "CHANGELOG.md"; then
  pass
else
  # Also check without brackets (some formats)
  if grep -q "## ${CURRENT_VERSION}" "CHANGELOG.md"; then
    pass
  else
    fail "No CHANGELOG entry for v$CURRENT_VERSION"
  fi
fi

# =============================================================================
# Test 2: Installer includes required files
# =============================================================================

print_header "Test 2: Installer Configuration"

print_test "install.sh includes code-review-helpers.sh in SCRIPTS array"
assert_contains "install.sh" "code-review-helpers.sh" \
  "Required for code review features"

print_test "install.sh includes common-functions.sh in CRITICAL_FILES"
assert_contains "install.sh" "scripts/common-functions.sh" \
  "Core utility library must be verified"

print_test "install.sh includes code-review.md in CRITICAL_FILES"
assert_contains "install.sh" ".claude/commands/code-review.md" \
  "Updated command file must be verified"

print_test "install.sh includes init-context.md in COMMANDS array"
assert_contains "install.sh" "init-context.md" \
  "Core command must be included"

print_test "install.sh includes save.md in COMMANDS array"
assert_contains "install.sh" "save.md" \
  "Core command must be included"

print_test "install.sh includes save-full.md in COMMANDS array"
assert_contains "install.sh" "save-full.md" \
  "Core command must be included"

# =============================================================================
# Test 3: Required files exist
# =============================================================================

print_header "Test 3: Required Files Exist"

print_test "scripts/common-functions.sh exists"
assert_file_exists "scripts/common-functions.sh" "Core utility library"

print_test "scripts/common-functions.sh is executable"
assert_executable "scripts/common-functions.sh"

print_test "scripts/code-review-helpers.sh exists"
assert_file_exists "scripts/code-review-helpers.sh" "Code review helper"

print_test "scripts/code-review-helpers.sh is executable"
assert_executable "scripts/code-review-helpers.sh"

print_test ".claude/commands/init-context.md exists"
assert_file_exists ".claude/commands/init-context.md"

print_test ".claude/commands/save.md exists"
assert_file_exists ".claude/commands/save.md"

print_test ".claude/commands/save-full.md exists"
assert_file_exists ".claude/commands/save-full.md"

print_test ".claude/commands/code-review.md exists"
assert_file_exists ".claude/commands/code-review.md"

# =============================================================================
# Test 4: Template files exist
# =============================================================================

print_header "Test 4: Template Files"

print_test "templates/CLAUDE.md.template exists"
assert_file_exists "templates/CLAUDE.md.template"

print_test "templates/CONTEXT.template.md exists"
assert_file_exists "templates/CONTEXT.template.md"

print_test "templates/STATUS.template.md exists"
assert_file_exists "templates/STATUS.template.md"

print_test "templates/SESSIONS.template.md exists"
assert_file_exists "templates/SESSIONS.template.md"

print_test "templates/DECISIONS.template.md exists"
assert_file_exists "templates/DECISIONS.template.md"

# =============================================================================
# Test 5: Dependency management
# =============================================================================

print_header "Test 5: Dependency Management"

print_test "Installer checks for jq"
assert_contains "install.sh" "command -v jq" \
  "Should check if jq is installed"

print_test "Installer provides jq installation instructions"
assert_contains "install.sh" "brew install jq" \
  "macOS users need installation command"

print_test "Installer provides Linux jq instructions"
assert_contains "install.sh" "apt-get install jq" \
  "Linux users need installation command"

# =============================================================================
# Test 6: Common functions library
# =============================================================================

print_header "Test 6: Common Functions Library"

print_test "common-functions.sh has version info"
if grep -q "Version:" "scripts/common-functions.sh"; then
  pass
else
  fail "No version info in common-functions.sh"
fi

print_test "common-functions.sh defines get_repo_root()"
assert_contains "scripts/common-functions.sh" "get_repo_root()" \
  "Required for working directory detection"

print_test "common-functions.sh defines download_with_retry()"
assert_contains "scripts/common-functions.sh" "download_with_retry()" \
  "Required for robust downloads"

print_test "common-functions.sh defines update_last_modified()"
assert_contains "scripts/common-functions.sh" "update_last_modified()" \
  "Required for auto-timestamps"

print_test "common-functions.sh defines count_unfilled_placeholders()"
assert_contains "scripts/common-functions.sh" "count_unfilled_placeholders()" \
  "Required for context completeness detection"

print_test "common-functions.sh defines detect_project_name()"
assert_contains "scripts/common-functions.sh" "detect_project_name()" \
  "Required for auto-detection"

# =============================================================================
# Test Summary
# =============================================================================

print_header "Test Summary"

echo ""
echo "Total Tests: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
  echo -e "${RED}Failed: $TESTS_FAILED${NC}"
else
  echo -e "${GREEN}Failed: 0${NC}"
fi
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✓ UPGRADE PATH VALIDATED (v$CURRENT_VERSION)${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "The installer is ready for v$CURRENT_VERSION release:"
  echo "  ✅ Version consistency validated"
  echo "  ✅ All required files included"
  echo "  ✅ Template files present"
  echo "  ✅ Dependencies documented"
  echo "  ✅ Core functions available"
  echo ""
  exit 0
else
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}✗ UPGRADE PATH VALIDATION FAILED${NC}"
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "Fix the failed tests before releasing v$CURRENT_VERSION"
  echo ""
  exit 1
fi
