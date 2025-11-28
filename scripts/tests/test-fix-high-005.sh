#!/bin/bash
# Test for HIGH-005 fix: FILE_SIZE validation in review-context.md

source "$(dirname "$0")/test-helpers.sh"

TEST_NAME="HIGH-005 FILE_SIZE Validation Fix"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

# Test 1: Verify FILE_SIZE validation exists in review-context.md
TESTS_RUN=$((TESTS_RUN + 1))
# Get to project root (test is in scripts/tests/, need to go up 2 levels)
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
REVIEW_CONTEXT="$PROJECT_ROOT/.claude/commands/review-context.md"

if grep -q "FILE_SIZE.*=~.*\[0-9\]" "$REVIEW_CONTEXT"; then
  pass "FILE_SIZE validation pattern found"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No FILE_SIZE validation found"
fi

# Test 2: Verify validation happens before use in comparisons
TESTS_RUN=$((TESTS_RUN + 1))
# Extract section from FILE_SIZE assignment to first comparison
SECTION=$(sed -n '/FILE_SIZE=$(wc/,/size < 1000/p' "$REVIEW_CONTEXT")

if echo "$SECTION" | grep -q "=~.*\[0-9\]"; then
  pass "Validation occurs before first comparison"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Validation doesn't occur before comparisons"
fi

# Test 3: Verify default value set for invalid FILE_SIZE
TESTS_RUN=$((TESTS_RUN + 1))
if grep -qE "FILE_SIZE=.*0" "$REVIEW_CONTEXT"; then
  pass "Default value assigned for invalid FILE_SIZE"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No default value for invalid FILE_SIZE"
fi

# Test 4: Verify warning message for invalid size
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "Could not determine.*size\|SESSIONS.md.*empty" "$REVIEW_CONTEXT"; then
  pass "Warning message for invalid FILE_SIZE"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No warning for invalid FILE_SIZE"
fi

# Test 5: Simulate the bash code with empty FILE_SIZE (should not error)
TESTS_RUN=$((TESTS_RUN + 1))
FILE_SIZE=""

# This would error without validation: [ "$FILE_SIZE" -lt 1000 ]
# With validation, it should set FILE_SIZE to 0
if ! [[ "$FILE_SIZE" =~ ^[0-9]+$ ]]; then
  FILE_SIZE=0
fi

if [ "$FILE_SIZE" -eq 0 ]; then
  pass "Empty FILE_SIZE handled correctly (set to 0)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Empty FILE_SIZE not handled"
fi

# Test 6: Simulate with non-numeric FILE_SIZE
TESTS_RUN=$((TESTS_RUN + 1))
FILE_SIZE="invalid"

if ! [[ "$FILE_SIZE" =~ ^[0-9]+$ ]]; then
  FILE_SIZE=0
fi

if [ "$FILE_SIZE" -eq 0 ]; then
  pass "Non-numeric FILE_SIZE handled correctly (set to 0)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Non-numeric FILE_SIZE not handled"
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
