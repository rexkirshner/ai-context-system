#!/bin/bash

# test-doc-health-check.sh
# Tests check_documentation_health() function from common-functions.sh
# Version: 5.1.0
#
# Tests:
# 1. Healthy project - both files exist and are current
# 2. Missing CLAUDE.md - should detect as incomplete
# 3. Missing CONTEXT.md - should detect as incomplete
# 4. Template placeholders in CONTEXT.md - should detect as incomplete

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
echo "Testing check_documentation_health() Function"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Create temp test directory
TEST_DIR=$(mktemp -d)
echo "Test directory: $TEST_DIR"
echo ""

# Helper function for assertions
assert_equals() {
  local actual="$1"
  local expected="$2"
  local test_name="$3"

  if [ "$actual" = "$expected" ]; then
    echo -e "  ${GREEN}PASS${NC}: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "  ${RED}FAIL${NC}: $test_name"
    echo "    Expected: $expected"
    echo "    Actual:   $actual"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_true() {
  local condition="$1"
  local test_name="$2"

  if eval "$condition"; then
    echo -e "  ${GREEN}PASS${NC}: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "  ${RED}FAIL${NC}: $test_name"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Source common-functions.sh
source "$PROJECT_ROOT/scripts/common-functions.sh"

# =============================================================================
# Test 1: Healthy project - both files exist
# =============================================================================
echo "Test 1: Healthy project with both files"

# Setup - create both CLAUDE.md and CONTEXT.md
mkdir -p "$TEST_DIR/test1/context"
echo "# CLAUDE.md for Test Project" > "$TEST_DIR/test1/CLAUDE.md"
cat > "$TEST_DIR/test1/context/CONTEXT.md" << 'EOF'
# Project Context

This is a test project with no template placeholders.
EOF

# Run test (need to cd to test directory for get_repo_root to work correctly)
# We'll mock get_repo_root by setting the path explicitly
cd "$TEST_DIR/test1"
# Create a .git directory to make get_repo_root work
mkdir -p .git

check_documentation_health "context"
assert_equals "$DOC_HEALTH_STATUS" "healthy" "Status is healthy"
assert_equals "$DOC_HEALTH_WARNINGS" "0" "No warnings"

# =============================================================================
# Test 2: Missing CLAUDE.md
# =============================================================================
echo ""
echo "Test 2: Missing CLAUDE.md"

mkdir -p "$TEST_DIR/test2/context"
mkdir -p "$TEST_DIR/test2/.git"
cat > "$TEST_DIR/test2/context/CONTEXT.md" << 'EOF'
# Project Context
Test content.
EOF

cd "$TEST_DIR/test2"
check_documentation_health "context"
assert_equals "$DOC_HEALTH_STATUS" "incomplete" "Status is incomplete"
assert_true '[ "$DOC_HEALTH_WARNINGS" -ge 1 ]' "At least 1 warning"

# =============================================================================
# Test 3: Missing CONTEXT.md
# =============================================================================
echo ""
echo "Test 3: Missing CONTEXT.md"

mkdir -p "$TEST_DIR/test3/context"
mkdir -p "$TEST_DIR/test3/.git"
echo "# CLAUDE.md" > "$TEST_DIR/test3/CLAUDE.md"

cd "$TEST_DIR/test3"
check_documentation_health "context"
assert_equals "$DOC_HEALTH_STATUS" "incomplete" "Status is incomplete"
assert_true '[ "$DOC_HEALTH_WARNINGS" -ge 1 ]' "At least 1 warning"

# =============================================================================
# Test 4: CONTEXT.md with unfilled placeholders
# =============================================================================
echo ""
echo "Test 4: CONTEXT.md with unfilled placeholders"

mkdir -p "$TEST_DIR/test4/context"
mkdir -p "$TEST_DIR/test4/.git"
echo "# CLAUDE.md" > "$TEST_DIR/test4/CLAUDE.md"
cat > "$TEST_DIR/test4/context/CONTEXT.md" << 'EOF'
# Project Context

Name: [FILL: project name]
Type: [FILL: project type]
EOF

cd "$TEST_DIR/test4"
check_documentation_health "context"
assert_equals "$DOC_HEALTH_STATUS" "incomplete" "Status is incomplete due to placeholders"
assert_true '[ "$DOC_HEALTH_WARNINGS" -ge 1 ]' "At least 1 warning for placeholders"

# =============================================================================
# Test 5: format_documentation_health output (healthy)
# =============================================================================
echo ""
echo "Test 5: format_documentation_health output"

cd "$TEST_DIR/test1"
check_documentation_health "context"
OUTPUT=$(format_documentation_health)
assert_true 'echo "$OUTPUT" | grep -q "Documentation Health Check"' "Output contains header"
assert_true 'echo "$OUTPUT" | grep -q "CLAUDE.md current"' "Shows CLAUDE.md status"

# =============================================================================
# Cleanup
# =============================================================================
rm -rf "$TEST_DIR"

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
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed!${NC}"
  exit 1
fi
