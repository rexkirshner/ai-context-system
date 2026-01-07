#!/bin/bash

# test-repo-root.sh
# Tests get_repo_root() function from common-functions.sh
# Version: 4.1.0
#
# Tests:
# 1. From repo root - should return current directory
# 2. From subdirectory - should return repo root
# 3. From non-git directory - should return pwd (fallback)

set -e

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Testing get_repo_root() Function"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function for assertions
assert_equals() {
  local actual="$1"
  local expected="$2"
  local test_name="$3"

  if [ "$actual" = "$expected" ]; then
    echo -e "  ${GREEN}✅ PASS${NC}: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "  ${RED}❌ FAIL${NC}: $test_name"
    echo "    Expected: $expected"
    echo "    Actual:   $actual"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Source common-functions.sh
source "$PROJECT_ROOT/scripts/common-functions.sh"

# =============================================================================
# Test 1: From repo root
# =============================================================================
echo "Test 1: From repo root"

cd "$PROJECT_ROOT"
RESULT=$(get_repo_root)
assert_equals "$RESULT" "$PROJECT_ROOT" "get_repo_root() returns project root when called from root"

# =============================================================================
# Test 2: From subdirectory
# =============================================================================
echo ""
echo "Test 2: From subdirectory"

# Create a temp subdirectory structure for testing
TEST_SUBDIR="$PROJECT_ROOT/scripts/tests/temp_test_subdir"
mkdir -p "$TEST_SUBDIR"

cd "$TEST_SUBDIR"
RESULT=$(get_repo_root)
assert_equals "$RESULT" "$PROJECT_ROOT" "get_repo_root() returns project root when called from subdirectory"

# Cleanup
rmdir "$TEST_SUBDIR"

# =============================================================================
# Test 3: From non-git directory (should fallback to pwd)
# =============================================================================
echo ""
echo "Test 3: From non-git directory (fallback behavior)"

# Create temp directory outside of any git repo
NON_GIT_DIR=$(mktemp -d)

cd "$NON_GIT_DIR"
RESULT=$(get_repo_root)
assert_equals "$RESULT" "$NON_GIT_DIR" "get_repo_root() returns pwd when not in git repo"

# Cleanup
rmdir "$NON_GIT_DIR"

# =============================================================================
# Test 4: From deeply nested subdirectory
# =============================================================================
echo ""
echo "Test 4: From deeply nested subdirectory"

DEEP_DIR="$PROJECT_ROOT/scripts/tests/a/b/c"
mkdir -p "$DEEP_DIR"

cd "$DEEP_DIR"
RESULT=$(get_repo_root)
assert_equals "$RESULT" "$PROJECT_ROOT" "get_repo_root() works from deeply nested directory"

# Cleanup
rm -rf "$PROJECT_ROOT/scripts/tests/a"

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "  Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "  Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}❌ Some tests failed!${NC}"
  exit 1
fi
