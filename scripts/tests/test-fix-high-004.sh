#!/bin/bash
# Test for HIGH-004 fix: Improved error handling in save-full.md

source "$(dirname "$0")/test-helpers.sh"

TEST_NAME="HIGH-004 Error Handling Fix"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SAVE_FULL="$PROJECT_ROOT/.claude/commands/save-full.md"

# Test 1: Verify error handling mentions backup file
TESTS_RUN=$((TESTS_RUN + 1))
if grep -A10 "Archiving failed" "$SAVE_FULL" | grep -iq "backup"; then
  pass "Error message mentions backup file"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Error message doesn't mention backup"
fi

# Test 2: Verify error handling provides recovery instructions
TESTS_RUN=$((TESTS_RUN + 1))
if grep -A10 "Archiving failed" "$SAVE_FULL" | grep -iq "restore\|recover\|check"; then
  pass "Error message provides recovery guidance"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No recovery guidance in error message"
fi

# Test 3: Verify error handling warns about data state
TESTS_RUN=$((TESTS_RUN + 1))
if grep -A10 "Archiving failed" "$SAVE_FULL" | grep -iq "corrupt\|check\|verify"; then
  pass "Error message warns about potential issues"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No warning about data state"
fi

# Test 4: Verify error block is more than just a single line
TESTS_RUN=$((TESTS_RUN + 1))
ERROR_LINES=$(grep -A10 "Archiving failed" "$SAVE_FULL" | head -11 | wc -l | tr -d ' ')
if [ "$ERROR_LINES" -gt 3 ]; then
  pass "Error handling has detailed message (>3 lines)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Error handling too brief ($ERROR_LINES lines)"
fi

# Test 5: Verify success path still exists and is clear
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "Old sessions archived successfully" "$SAVE_FULL"; then
  pass "Success message still present"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Success message missing"
fi

# Test 6: Verify error handling doesn't just continue silently
TESTS_RUN=$((TESTS_RUN + 1))
# Error handling should be visible, not just "continue"
if grep -A5 "Archiving failed" "$SAVE_FULL" | grep -iq "echo\|warning\|error"; then
  pass "Error is communicated to user"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Error might be silent"
fi

# Summary
echo ""
echo "Results: $TESTS_PASSED/$TESTS_RUN tests passed"
echo ""

if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
  echo "✓ ALL TESTS PASSED"
  exit 0
else
  echo "✗ SOME TESTS FAILED"
  exit 1
fi
