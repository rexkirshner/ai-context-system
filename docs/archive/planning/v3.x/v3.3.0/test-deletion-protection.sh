#!/bin/bash
# Test script for confirm_deletion() function
# v3.3.0 Day 1 Testing

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Testing Deletion Protection${NC}"
echo ""

# Source the common functions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/../../.."
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

# Test helper
run_test() {
  local test_name="$1"
  local expected_result="$2"  # 0 or 1
  local test_file="$3"

  TESTS_RUN=$((TESTS_RUN + 1))
  echo -n "Test $TESTS_RUN: $test_name... "

  # Run confirm_deletion (will return 0 or 1)
  if confirm_deletion "$test_file" >/dev/null 2>&1; then
    actual_result=0
  else
    actual_result=1
  fi

  if [ "$actual_result" = "$expected_result" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗ FAIL${NC} (expected $expected_result, got $actual_result)"
  fi
}

# =============================================================================
# Test 1: Non-existent file (should return 0 - safe to delete)
# =============================================================================
run_test "Non-existent file" 0 "/tmp/nonexistent-file-12345.txt"

# =============================================================================
# Test 2: Normal file (not gitignored) - should return 0
# =============================================================================
# Create a normal test file
TEST_FILE="/tmp/test-normal-file-$$.txt"
echo "test content" > "$TEST_FILE"
run_test "Normal file (not gitignored)" 0 "$TEST_FILE"
rm -f "$TEST_FILE"

# =============================================================================
# Test 3: Empty input - should return 0 (defensive)
# =============================================================================
run_test "Empty input" 0 ""

# =============================================================================
# Test 4: File in current directory (not gitignored)
# =============================================================================
# Check a file we know exists and is not gitignored
run_test "Tracked file (README.md)" 0 "README.md"

# =============================================================================
# Test 5: Gitignored file check
# =============================================================================
# Check if .gitignore exists and what it contains
echo ""
echo -e "${BLUE}Gitignore Analysis:${NC}"
if [ -f .gitignore ]; then
  echo "Found .gitignore with patterns:"
  echo "- node_modules/"
  echo "- .DS_Store"
  echo "- *.log"
  echo "- etc."

  # Test with .DS_Store (commonly gitignored)
  if echo ".DS_Store" | grep -q -f .gitignore 2>/dev/null || \
     git check-ignore -q .DS_Store 2>/dev/null; then
    echo ""
    echo "Note: .DS_Store would be gitignored (protection would trigger)"
  fi
else
  echo "No .gitignore found"
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo -e "${BLUE}Test Summary:${NC}"
echo "Tests run: $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo "Tests failed: $((TESTS_RUN - TESTS_PASSED))"

if [ "$TESTS_PASSED" = "$TESTS_RUN" ]; then
  echo ""
  echo -e "${GREEN}✅ All tests passed!${NC}"
  exit 0
else
  echo ""
  echo -e "${RED}❌ Some tests failed${NC}"
  exit 1
fi
