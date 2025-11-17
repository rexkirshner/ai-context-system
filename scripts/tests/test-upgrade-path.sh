#!/bin/bash
# Test Upgrade Path for v3.4.0
# Validates that installer includes all new files and dependencies

# Note: Don't use set -e, we want to run all tests even if some fail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

print_header "v3.4.0 Upgrade Path Validation"

# =============================================================================
# Test 1: Installer includes new helper script
# =============================================================================

print_header "Test 1: Installer Configuration"

print_test "install.sh includes code-review-helpers.sh in SCRIPTS array"
assert_contains "install.sh" "code-review-helpers.sh" \
  "Required for code review actionability features"

print_test "install.sh includes code-review-helpers.sh in CRITICAL_FILES"
assert_contains "install.sh" "scripts/code-review-helpers.sh" \
  "Must be verified during installation"

print_test "install.sh includes code-review.md in CRITICAL_FILES"
assert_contains "install.sh" ".claude/commands/code-review.md" \
  "Updated command file must be verified"

# =============================================================================
# Test 2: Version consistency
# =============================================================================

print_header "Test 2: Version Consistency"

print_test "VERSION file shows 3.4.0"
VERSION_CONTENT=$(cat VERSION | tr -d ' \n')
if [ "$VERSION_CONTENT" = "3.4.0" ]; then
  pass
else
  fail "VERSION file shows $VERSION_CONTENT, expected 3.4.0"
fi

print_test "CHANGELOG.md has v3.4.0 entry"
assert_contains "CHANGELOG.md" "## \[3.4.0\]" \
  "Changelog must document new release"

print_test "CHANGELOG.md mentions code review features"
assert_contains "CHANGELOG.md" "Code Review Actionability" \
  "Release notes should describe main feature"

# =============================================================================
# Test 3: Installer feature announcements
# =============================================================================

print_header "Test 3: Installer Feature Announcements"

print_test "install.sh announces v3.4.0 features"
assert_contains "install.sh" "v3.4.0 Features" \
  "Users should see what's new"

print_test "install.sh mentions smart issue grouping"
assert_contains "install.sh" "Smart issue grouping" \
  "Key feature should be highlighted"

print_test "install.sh mentions jq dependency"
assert_contains "install.sh" "jq" \
  "Users should know about new dependency"

# =============================================================================
# Test 4: Required files exist
# =============================================================================

print_header "Test 4: Required Files Exist"

print_test "scripts/code-review-helpers.sh exists"
if [ -f "scripts/code-review-helpers.sh" ]; then
  pass
else
  fail "Helper script not found"
fi

print_test "scripts/code-review-helpers.sh is executable"
if [ -x "scripts/code-review-helpers.sh" ]; then
  pass
else
  fail "Helper script not executable"
fi

print_test ".claude/commands/code-review.md exists"
if [ -f ".claude/commands/code-review.md" ]; then
  pass
else
  fail "Updated command file not found"
fi

print_test ".claude/commands/code-review.md shows v3.4.0"
assert_contains ".claude/commands/code-review.md" "Version.*3.4.0" \
  "Command version should match release"

print_test ".claude/commands/code-review.md has Step 8"
assert_contains ".claude/commands/code-review.md" "Step 8: Integration & Actionability" \
  "New step must be documented"

# =============================================================================
# Test 5: Test infrastructure
# =============================================================================

print_header "Test 5: Test Infrastructure"

print_test "Test suite exists"
if [ -f "scripts/tests/test-code-review-helpers.sh" ]; then
  pass
else
  fail "Test suite not found"
fi

print_test "Test data exists"
if [ -f "scripts/tests/sample-review-issues.json" ]; then
  pass
else
  fail "Test data not found"
fi

# =============================================================================
# Test 6: Dependency check in installer
# =============================================================================

print_header "Test 6: Dependency Management"

print_test "Installer checks for jq"
assert_contains "install.sh" "command -v jq" \
  "Should check if jq is installed"

print_test "Installer provides jq installation instructions"
assert_contains "install.sh" "brew install jq" \
  "macOS users need installation command"

assert_contains "install.sh" "apt-get install jq" \
  "Linux users need installation command"

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
  echo -e "${GREEN}✓ UPGRADE PATH VALIDATED${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "The installer is ready for v3.4.0 release:"
  echo "  ✅ All new files included"
  echo "  ✅ Version consistency validated"
  echo "  ✅ Feature announcements present"
  echo "  ✅ Dependencies documented"
  echo "  ✅ Test infrastructure in place"
  echo ""
  exit 0
else
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}✗ UPGRADE PATH VALIDATION FAILED${NC}"
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "Fix the failed tests before releasing v3.4.0"
  echo ""
  exit 1
fi
