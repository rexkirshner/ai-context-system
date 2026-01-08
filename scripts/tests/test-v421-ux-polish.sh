#!/bin/bash
# test-v421-ux-polish.sh - Tests for v4.2.1 UX polish fixes
# Tests Fix 1 (ACS_UPDATING suppression), Fix 2 (update-guide.md removal)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

pass() {
  TESTS_PASSED=$((TESTS_PASSED + 1))
  echo -e "${GREEN}✓ PASS${NC}: $1"
}

fail() {
  TESTS_FAILED=$((TESTS_FAILED + 1))
  echo -e "${RED}✗ FAIL${NC}: $1"
  echo "  Expected: $2"
  echo "  Got: $3"
}

run_test() {
  TESTS_RUN=$((TESTS_RUN + 1))
}

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  v4.2.1 UX Polish Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# =============================================================================
# Fix 1: ACS_UPDATING Suppression Tests
# =============================================================================
echo "Fix 1: ACS_UPDATING Suppression"
echo "--------------------------------"

# Source common functions for testing
source "$PROJECT_ROOT/scripts/common-functions.sh" 2>/dev/null || true

# Test 1.1: check_for_updates function exists
run_test
if type check_for_updates &>/dev/null; then
  pass "check_for_updates function exists"
else
  fail "check_for_updates function exists" "function defined" "not found"
fi

# Test 1.2: ACS_UPDATING=true should suppress update notice
run_test
export ACS_UPDATING=true
# Create a mock scenario where version differs
# We can't easily test the curl call, but we can test the suppression logic exists
if grep -q 'ACS_UPDATING' "$PROJECT_ROOT/scripts/common-functions.sh"; then
  pass "ACS_UPDATING check exists in common-functions.sh"
else
  fail "ACS_UPDATING check in common-functions.sh" "ACS_UPDATING check present" "not found"
fi
unset ACS_UPDATING

# Test 1.3: ACS_UPDATING export exists in update-context-system.md
run_test
if grep -q 'ACS_UPDATING' "$PROJECT_ROOT/.claude/commands/update-context-system.md"; then
  pass "ACS_UPDATING export exists in update-context-system.md"
else
  fail "ACS_UPDATING export in update-context-system.md" "export present" "not found"
fi

# Test 1.4: Suppression check is early in check_for_updates function
run_test
# The check should come before the curl call to avoid unnecessary network requests
FUNC_CONTENT=$(sed -n '/^check_for_updates()/,/^}/p' "$PROJECT_ROOT/scripts/common-functions.sh")
UPDATING_LINE=$(echo "$FUNC_CONTENT" | grep -n 'ACS_UPDATING' | head -1 | cut -d: -f1 2>/dev/null || echo "0")
CURL_LINE=$(echo "$FUNC_CONTENT" | grep -n 'curl' | head -1 | cut -d: -f1 2>/dev/null || echo "999")

# Handle empty results
[ -z "$UPDATING_LINE" ] && UPDATING_LINE="0"
[ -z "$CURL_LINE" ] && CURL_LINE="999"

if [ "$UPDATING_LINE" != "0" ] && [ "$UPDATING_LINE" -lt "$CURL_LINE" ]; then
  pass "ACS_UPDATING check comes before curl call"
else
  fail "ACS_UPDATING check order" "before curl" "after curl or not found"
fi

echo ""

# =============================================================================
# Fix 2: update-guide.md Removal Tests
# =============================================================================
echo "Fix 2: update-guide.md Removal"
echo "-------------------------------"

# Test 2.1: update-guide.md should not exist
run_test
if [ ! -f "$PROJECT_ROOT/.claude/docs/update-guide.md" ]; then
  pass "update-guide.md has been removed"
else
  fail "update-guide.md removal" "file removed" "file still exists"
fi

# Test 2.2: No references to update-guide.md in install.sh
run_test
if ! grep -q 'update-guide\.md' "$PROJECT_ROOT/install.sh" 2>/dev/null; then
  pass "No update-guide.md reference in install.sh"
else
  fail "update-guide.md reference in install.sh" "no reference" "reference found"
fi

# Test 2.3: No references to update-guide.md in any command files
run_test
if ! grep -r 'update-guide\.md' "$PROJECT_ROOT/.claude/commands/" 2>/dev/null | grep -v '\.bak'; then
  pass "No update-guide.md reference in command files"
else
  fail "update-guide.md reference in commands" "no reference" "reference found"
fi

# Test 2.4: No "What's New in v3" strings in active docs (excluding historical files)
run_test
# Only check .claude/docs/ - the location that gets copied to user projects
# CHANGELOG.md, development/, etc. are historical records and acceptable
WHATS_NEW_V3=$(grep -r "What's New in v3" "$PROJECT_ROOT/.claude/docs" \
  --include="*.md" \
  2>/dev/null || true)

if [ -z "$WHATS_NEW_V3" ]; then
  pass "No outdated 'What's New in v3' strings in .claude/docs/"
else
  fail "Outdated What's New strings in .claude/docs/" "none" "found"
fi

echo ""

# =============================================================================
# Summary
# =============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Tests run:    $TESTS_RUN"
echo -e "  ${GREEN}Passed:       $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
  echo -e "  ${RED}Failed:       $TESTS_FAILED${NC}"
fi
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed.${NC}"
  exit 1
fi
