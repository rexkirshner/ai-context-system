#!/bin/bash
# Test for MED-002 fix: "Don't ask again" option for archiving

source "$(dirname "$0")/test-helpers.sh"

TEST_NAME="MED-002 Don't Ask Again Option"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SAVE_FULL="$PROJECT_ROOT/.claude/commands/save-full.md"

# Test 1: Verify .no-archive check exists
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q ".no-archive" "$SAVE_FULL"; then
  pass ".no-archive flag check exists in save-full.md"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No .no-archive flag check in save-full.md"
fi

# Test 2: Verify informational message when archiving is disabled
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "Auto-archiving disabled\|archiving.*disabled" "$SAVE_FULL"; then
  pass "Info message exists for disabled archiving"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No info message for disabled archiving"
fi

# Test 3: Verify re-enable instructions
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "re-enable\|remove.*no-archive" "$SAVE_FULL"; then
  pass "Instructions to re-enable archiving exist"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No re-enable instructions"
fi

# Test 4: Verify "don't ask again" prompt exists
TESTS_RUN=$((TESTS_RUN + 1))
if grep -qi "don't ask again\|ask.*again" "$SAVE_FULL"; then
  pass "Don't ask again prompt exists"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No don't ask again prompt"
fi

# Test 5: Verify .no-archive file creation logic
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "touch.*\.no-archive" "$SAVE_FULL"; then
  pass "Logic to create .no-archive file exists"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No logic to create .no-archive file"
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
