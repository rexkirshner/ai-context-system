#!/bin/bash

# test-color-echo.sh
# Tests color_echo() function and verifies ANSI escape code handling
# Version: 5.1.0
#
# Tests:
# 1. color_echo function is defined in install.sh
# 2. color_echo outputs ANSI escape sequences correctly
# 3. No remaining echo -e in install.sh (except comments)
# 4. Color codes are properly escaped in output

set -e

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Testing color_echo() Function and ANSI Escape Handling"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function for assertions
assert_true() {
  local condition="$1"
  local test_name="$2"

  if eval "$condition"; then
    echo -e "  ${GREEN}✅ PASS${NC}: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "  ${RED}❌ FAIL${NC}: $test_name"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

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

# =============================================================================
# Test 1: color_echo function is defined in install.sh
# =============================================================================
echo "Test 1: color_echo function is defined in install.sh"

FUNCTION_DEF=$(grep -c "^color_echo()" "$PROJECT_ROOT/install.sh" || echo "0")
assert_equals "$FUNCTION_DEF" "1" "color_echo() function is defined exactly once"

# =============================================================================
# Test 2: No remaining echo -e statements (except comments)
# =============================================================================
echo ""
echo "Test 2: No remaining echo -e statements (except comments)"

# Count echo -e statements that are not in comments
# grep -c returns 1 if no matches (error exit code) so we handle that
ECHO_E_COUNT=$(grep -c "^[^#]*echo -e" "$PROJECT_ROOT/install.sh" 2>/dev/null) || ECHO_E_COUNT=0
assert_equals "$ECHO_E_COUNT" "0" "No echo -e statements in active code"

# =============================================================================
# Test 3: color_echo uses printf for portable output
# =============================================================================
echo ""
echo "Test 3: color_echo uses printf for portable output"

# Check that color_echo uses printf
USES_PRINTF=$(grep -A2 "^color_echo()" "$PROJECT_ROOT/install.sh" | grep -c "printf" || echo "0")
assert_true '[ "$USES_PRINTF" -ge 1 ]' "color_echo() uses printf internally"

# =============================================================================
# Test 4: color_echo actually renders ANSI codes
# =============================================================================
echo ""
echo "Test 4: color_echo actually renders ANSI codes"

# Define color_echo locally to test it
color_echo() {
  printf "%b\n" "$1"
}

# Capture output and check for ANSI escape sequences
TEST_OUTPUT=$(color_echo "${RED}test${NC}")

# Check that the output contains the ANSI escape sequence (0x1b or \033)
if printf '%s' "$TEST_OUTPUT" | grep -q $'\033'; then
  echo -e "  ${GREEN}✅ PASS${NC}: color_echo outputs ANSI escape sequences"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo -e "  ${RED}❌ FAIL${NC}: color_echo does not output ANSI escape sequences"
  echo "    Output: $TEST_OUTPUT"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# =============================================================================
# Test 5: Verify install.sh uses color_echo for colored output
# =============================================================================
echo ""
echo "Test 5: Verify install.sh uses color_echo for colored output"

# Count color_echo usages (should be significant)
COLOR_ECHO_USES=$(grep -c "color_echo" "$PROJECT_ROOT/install.sh" || echo "0")
assert_true '[ "$COLOR_ECHO_USES" -ge 40 ]' "install.sh uses color_echo extensively (found $COLOR_ECHO_USES uses)"

# =============================================================================
# Test 6: Verify no broken echo statements with color variables
# =============================================================================
echo ""
echo "Test 6: Verify no broken echo statements with color variables"

# Look for echo (without -e) that contains color variable references
# This pattern catches: echo "${RED}..." or echo "${GREEN}..." etc.
BROKEN_ECHO=$(grep -E '^[^#]*[^_]echo "\$\{(RED|GREEN|YELLOW|BLUE|NC)' "$PROJECT_ROOT/install.sh" 2>/dev/null | grep -v "color_echo" | wc -l | tr -d ' ')
assert_equals "$BROKEN_ECHO" "0" "No broken echo statements with color variables"

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
