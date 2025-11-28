#!/bin/bash
# Test for HIGH-006 fix: Actionable fix guidance for phase mismatch

source "$(dirname "$0")/test-helpers.sh"

TEST_NAME="HIGH-006 Actionable Fix Guidance"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
REVIEW_CONTEXT="$PROJECT_ROOT/.claude/commands/review-context.md"

# Test 1: Verify phase mismatch shows both values
TESTS_RUN=$((TESTS_RUN + 1))
MISMATCH_SECTION=$(sed -n '/Phase mismatch detected/,/^fi$/p' "$REVIEW_CONTEXT")

if echo "$MISMATCH_SECTION" | grep -q "CONTEXT.md.*STATUS.md"; then
  pass "Phase mismatch shows both file values"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Phase mismatch doesn't show file values"
fi

# Test 2: Verify actionable guidance exists
TESTS_RUN=$((TESTS_RUN + 1))
if echo "$MISMATCH_SECTION" | grep -qi "action"; then
  pass "Actionable guidance provided"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No actionable guidance"
fi

# Test 3: Verify guidance mentions which file is usually current
TESTS_RUN=$((TESTS_RUN + 1))
if echo "$MISMATCH_SECTION" | grep -qi "usually.*STATUS"; then
  pass "Guidance mentions STATUS.md is usually current"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Doesn't indicate which file is usually current"
fi

# Test 4: Verify guidance provides steps
TESTS_RUN=$((TESTS_RUN + 1))
STEP_COUNT=$(echo "$MISMATCH_SECTION" | grep -c "1\.\|2\.\|3\.\|4\.")

if [ "$STEP_COUNT" -ge 3 ]; then
  pass "Provides step-by-step guidance ($STEP_COUNT steps)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Not enough step-by-step guidance ($STEP_COUNT steps)"
fi

# Test 5: Verify message is more detailed than before
TESTS_RUN=$((TESTS_RUN + 1))
MESSAGE_LINES=$(echo "$MISMATCH_SECTION" | wc -l | tr -d ' ')

if [ "$MESSAGE_LINES" -gt 3 ]; then
  pass "Detailed message ($MESSAGE_LINES lines)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Message too brief ($MESSAGE_LINES lines)"
fi

# Test 6: Verify both resolution paths mentioned
TESTS_RUN=$((TESTS_RUN + 1))
if echo "$MISMATCH_SECTION" | grep -qi "edit.*CONTEXT\|update.*STATUS"; then
  pass "Both resolution paths mentioned"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Doesn't mention both resolution paths"
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
