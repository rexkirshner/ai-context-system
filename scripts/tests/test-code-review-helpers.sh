#!/bin/bash
# Test Script for Code Review Helpers
# Version: 3.4.0
#
# Tests all functions in code-review-helpers.sh to ensure they work correctly
# before integrating into the /code-review command.
#
# Usage:
#   ./scripts/tests/test-code-review-helpers.sh

# set -e  # Exit on error (temporarily disabled to see all test results)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test output directory
TEST_DIR="scripts/tests"
OUTPUT_DIR="$TEST_DIR/output"
rm -rf "$OUTPUT_DIR"  # Clean up from previous runs
mkdir -p "$OUTPUT_DIR"

# =============================================================================
# Test Utilities
# =============================================================================

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

assert_file_exists() {
  if [ -f "$1" ]; then
    pass
  else
    fail "File not found: $1"
  fi
}

assert_contains() {
  local file=$1
  local pattern=$2
  if grep -q "$pattern" "$file"; then
    pass
  else
    fail "Pattern not found in $file: $pattern"
  fi
}

assert_equals() {
  local actual=$1
  local expected=$2
  local description=$3
  if [ "$actual" = "$expected" ]; then
    pass
  else
    fail "$description: Expected '$expected', got '$actual'"
  fi
}

# =============================================================================
# Load Dependencies
# =============================================================================

print_header "Loading Dependencies"

# Source common functions
if [ -f "scripts/common-functions.sh" ]; then
  source scripts/common-functions.sh
  echo -e "${GREEN}✓${NC} Loaded common-functions.sh"
else
  echo -e "${RED}✗${NC} Failed to load common-functions.sh"
  exit 1
fi

# Source code review helpers
if [ -f "scripts/code-review-helpers.sh" ]; then
  source scripts/code-review-helpers.sh
  echo -e "${GREEN}✓${NC} Loaded code-review-helpers.sh"
else
  echo -e "${RED}✗${NC} Failed to load code-review-helpers.sh"
  exit 1
fi

# Check for jq (required for JSON processing)
if ! command -v jq &> /dev/null; then
  echo -e "${RED}✗${NC} jq not found - required for tests"
  echo "  Install with: brew install jq (macOS) or apt-get install jq (Linux)"
  exit 1
fi
echo -e "${GREEN}✓${NC} jq available"

# =============================================================================
# Test 1: Smart Issue Grouping
# =============================================================================

print_header "Test 1: Smart Issue Grouping"

print_test "Should group similar issues (4 jest-dom issues → 1 group)"
group_similar_issues \
  "$TEST_DIR/sample-review-issues.json" \
  "$OUTPUT_DIR/grouped-issues.json"
assert_file_exists "$OUTPUT_DIR/grouped-issues.json"

# Verify grouping worked
GROUPED_COUNT=$(jq '[.[] | select(.type == "grouped")] | length' "$OUTPUT_DIR/grouped-issues.json")
print_test "Should create at least 1 grouped task"
if [ "$GROUPED_COUNT" -ge 1 ]; then
  pass
else
  fail "Expected at least 1 grouped task, got $GROUPED_COUNT"
fi

# Verify individual tasks exist
INDIVIDUAL_COUNT=$(jq '[.[] | select(.type == "individual")] | length' "$OUTPUT_DIR/grouped-issues.json")
print_test "Should create individual tasks for unique issues"
if [ "$INDIVIDUAL_COUNT" -ge 1 ]; then
  pass
else
  fail "Expected individual tasks, got $INDIVIDUAL_COUNT"
fi

# Verify critical issues remain individual
CRITICAL_INDIVIDUAL=$(jq '[.[] | select(.type == "individual" and .severity == "CRITICAL")] | length' "$OUTPUT_DIR/grouped-issues.json")
print_test "Critical issues should be individual tasks"
if [ "$CRITICAL_INDIVIDUAL" -ge 1 ]; then
  pass
else
  fail "Critical issues should not be grouped"
fi

# =============================================================================
# Test 2: TodoWrite Task Generation
# =============================================================================

print_header "Test 2: TodoWrite Task Generation"

print_test "Should generate TodoWrite tasks from grouped issues"
generate_todowrite_tasks \
  "$OUTPUT_DIR/grouped-issues.json" \
  "HIGH" \
  "$OUTPUT_DIR/todowrite-tasks.md"
assert_file_exists "$OUTPUT_DIR/todowrite-tasks.md"

print_test "TodoWrite file should contain [pending] tasks"
assert_contains "$OUTPUT_DIR/todowrite-tasks.md" "\[pending\]"

print_test "Should include CRITICAL issues"
assert_contains "$OUTPUT_DIR/todowrite-tasks.md" "SQL injection"

print_test "Should include HIGH priority issues"
assert_contains "$OUTPUT_DIR/todowrite-tasks.md" "Missing error handling"

print_test "Should show file locations for individual tasks"
assert_contains "$OUTPUT_DIR/todowrite-tasks.md" "api/search.ts:123"

# Count generated tasks
TASK_COUNT=$(grep -c "^\- \[pending\]" "$OUTPUT_DIR/todowrite-tasks.md" || echo "0")
print_test "Should generate multiple tasks (expected: >= 5)"
if [ "$TASK_COUNT" -ge 5 ]; then
  pass
else
  fail "Expected >= 5 tasks, got $TASK_COUNT"
fi

# =============================================================================
# Test 3: KNOWN_ISSUES.md Integration
# =============================================================================

print_header "Test 3: KNOWN_ISSUES.md Integration"

# Create sample KNOWN_ISSUES.md
cat > "$OUTPUT_DIR/KNOWN_ISSUES.md" <<EOF
# Known Issues

Existing content here.

EOF

print_test "Should add CRITICAL issues to KNOWN_ISSUES.md"
# Convert grouped issues back to individual format for KNOWN_ISSUES
# (In real usage, we'd pass the original issues, not grouped)
jq '[.[] | if .type == "individual" then . else empty end]' \
  "$OUTPUT_DIR/grouped-issues.json" > "$OUTPUT_DIR/individual-issues.json"

# Add original critical issues that weren't in grouped (because they're still individual)
jq '[.[] | select(.severity == "CRITICAL")]' \
  "$TEST_DIR/sample-review-issues.json" >> "$OUTPUT_DIR/individual-issues.json"

# Merge and deduplicate
jq -s 'add | unique_by(.issue_id // .id)' \
  "$OUTPUT_DIR/individual-issues.json" > "$OUTPUT_DIR/all-individual-issues.json"

add_to_known_issues \
  "$OUTPUT_DIR/all-individual-issues.json" \
  "$OUTPUT_DIR/KNOWN_ISSUES.md" \
  "20" \
  "../artifacts/code-reviews/session-20-review.md" \
  "CRITICAL"
assert_file_exists "$OUTPUT_DIR/KNOWN_ISSUES.md"

print_test "Should include SQL injection issue"
assert_contains "$OUTPUT_DIR/KNOWN_ISSUES.md" "SQL injection"

print_test "Should include severity marker"
assert_contains "$OUTPUT_DIR/KNOWN_ISSUES.md" "\[CRITICAL\]"

print_test "Should include location"
assert_contains "$OUTPUT_DIR/KNOWN_ISSUES.md" "api/search.ts:123"

print_test "Should include review link"
assert_contains "$OUTPUT_DIR/KNOWN_ISSUES.md" "Code Review Report"

print_test "Should include status marker"
assert_contains "$OUTPUT_DIR/KNOWN_ISSUES.md" "🔴 Open"

# =============================================================================
# Test 4: STATUS.md Integration
# =============================================================================

print_header "Test 4: STATUS.md Integration"

# Create sample STATUS.md
cat > "$OUTPUT_DIR/STATUS.md" <<EOF
# Project Status

## Current Phase

Development

## Recent Changes

Existing changes here.

EOF

print_test "Should update STATUS.md with review summary"
update_status_summary \
  "$OUTPUT_DIR/STATUS.md" \
  "20" \
  "B" \
  "3" \
  "5" \
  "10" \
  "../artifacts/code-reviews/session-20-review.md"
assert_file_exists "$OUTPUT_DIR/STATUS.md"

print_test "Should include Code Review header"
assert_contains "$OUTPUT_DIR/STATUS.md" "Code Review - Session 20"

print_test "Should include grade"
assert_contains "$OUTPUT_DIR/STATUS.md" "\*\*Grade:\*\* B"

print_test "Should include critical count"
assert_contains "$OUTPUT_DIR/STATUS.md" "\*\*Critical Issues:\*\* 3"

print_test "Should include high priority count"
assert_contains "$OUTPUT_DIR/STATUS.md" "\*\*High Priority:\*\* 5"

print_test "Should include link to full report"
assert_contains "$OUTPUT_DIR/STATUS.md" "Code Review Details"

# =============================================================================
# Test 5: Review History Tracking
# =============================================================================

print_header "Test 5: Review History Tracking"

print_test "Should create review history INDEX.md"
create_review_history \
  "$OUTPUT_DIR/INDEX.md" \
  "20" \
  "B" \
  "3" \
  "5" \
  "10" \
  "8" \
  "45" \
  "session-20-review.md"
assert_file_exists "$OUTPUT_DIR/INDEX.md"

print_test "Should include table header"
assert_contains "$OUTPUT_DIR/INDEX.md" "Date.*Session.*Grade"

print_test "Should include session 20 entry"
assert_contains "$OUTPUT_DIR/INDEX.md" "| .* | 20 | B | 3 | 5 | 10 | 8 | 45 |"

print_test "Should include status indicator"
assert_contains "$OUTPUT_DIR/INDEX.md" "🔴 Critical\|⚠️ Issues"

# Add second entry to test history accumulation
print_test "Should append new entry to existing history"
create_review_history \
  "$OUTPUT_DIR/INDEX.md" \
  "21" \
  "A" \
  "0" \
  "2" \
  "5" \
  "8" \
  "45" \
  "session-21-review.md"

# Count table rows (should have 2 data rows now)
ROW_COUNT=$(grep -c "^| .* | [0-9]" "$OUTPUT_DIR/INDEX.md" 2>/dev/null || echo "0")
print_test "Should have 2 review entries"
if [ "$ROW_COUNT" -eq 2 ]; then
  pass
else
  fail "Expected 2 rows, got $ROW_COUNT"
fi

# =============================================================================
# Test 6: Review Comparison
# =============================================================================

print_header "Test 6: Review Comparison"

# Create "previous" review (with more issues)
cat > "$OUTPUT_DIR/previous-review.json" <<EOF
[
  {
    "id": "C1",
    "severity": "CRITICAL",
    "message": "SQL injection vulnerability in search API",
    "file": "api/search.ts",
    "line": 123,
    "category": "Security"
  },
  {
    "id": "C2",
    "severity": "CRITICAL",
    "message": "Missing rate limiting on authentication endpoints",
    "file": "api/auth/register.ts",
    "line": 45,
    "category": "Security"
  },
  {
    "id": "H1",
    "severity": "HIGH",
    "message": "Missing error handling in async database operations",
    "file": "api/users.ts",
    "line": 456,
    "category": "Error Handling"
  },
  {
    "id": "M1",
    "severity": "MEDIUM",
    "message": "Console.log statement in production code",
    "file": "utils/logger.ts",
    "line": 45,
    "category": "Code Quality"
  }
]
EOF

# Create "current" review (C1 and H1 fixed, M1 still open, M2 is new)
cat > "$OUTPUT_DIR/current-review.json" <<EOF
[
  {
    "id": "C2",
    "severity": "CRITICAL",
    "message": "Missing rate limiting on authentication endpoints",
    "file": "api/auth/register.ts",
    "line": 45,
    "category": "Security"
  },
  {
    "id": "M1",
    "severity": "MEDIUM",
    "message": "Console.log statement in production code",
    "file": "utils/logger.ts",
    "line": 45,
    "category": "Code Quality"
  },
  {
    "id": "M2",
    "severity": "MEDIUM",
    "message": "Missing JSDoc comment",
    "file": "utils/helpers.ts",
    "line": 67,
    "category": "Documentation"
  }
]
EOF

print_test "Should compare current with previous review"
compare_with_previous \
  "$OUTPUT_DIR/current-review.json" \
  "$OUTPUT_DIR/previous-review.json" \
  "$OUTPUT_DIR/comparison.json"
assert_file_exists "$OUTPUT_DIR/comparison.json"

print_test "Should detect resolved issues"
RESOLVED_COUNT=$(jq '.resolved_count' "$OUTPUT_DIR/comparison.json")
assert_equals "$RESOLVED_COUNT" "2" "Resolved count"

print_test "Should detect still open issues"
STILL_OPEN_COUNT=$(jq '.still_open_count' "$OUTPUT_DIR/comparison.json")
assert_equals "$STILL_OPEN_COUNT" "2" "Still open count"

print_test "Should detect new issues"
NEW_COUNT=$(jq '.new_issues_count' "$OUTPUT_DIR/comparison.json")
assert_equals "$NEW_COUNT" "1" "New issues count"

# =============================================================================
# Test 7: Utility Functions
# =============================================================================

print_header "Test 7: Utility Functions"

print_test "Should extract session number from filename"
SESSION_NUM=$(extract_session_number "session-20-review.md")
assert_equals "$SESSION_NUM" "20" "Session number extraction"

print_test "Should handle missing session number gracefully"
SESSION_NUM=$(extract_session_number "review.md")
assert_equals "$SESSION_NUM" "unknown" "Missing session number"

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
  echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 0
else
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}✗ SOME TESTS FAILED${NC}"
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 1
fi
