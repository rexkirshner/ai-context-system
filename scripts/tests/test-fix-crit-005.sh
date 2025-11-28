#!/bin/bash
# Test for CRIT-005 fix: Smart loading should be instructions, not bash code

source "$(dirname "$0")/test-helpers.sh"

TEST_NAME="CRIT-005 Smart Loading Instructions Fix"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

# Test 1: Verify no bash code blocks with Read tool calls
TESTS_RUN=$((TESTS_RUN + 1))
# Look for bash code blocks that contain "Read" (Claude tool)
BASH_BLOCKS_WITH_READ=$(sed -n '/```bash/,/```/p' .claude/commands/review-context.md | grep "Read " | wc -l | tr -d ' ')

if [ "$BASH_BLOCKS_WITH_READ" -eq 0 ]; then
  pass "No bash code blocks contain Read tool calls"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Found $BASH_BLOCKS_WITH_READ bash code blocks with Read tool calls"
fi

# Test 2: Verify smart loading section exists
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "SESSIONS.md Smart Loading" .claude/commands/review-context.md; then
  pass "Smart loading section exists"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Smart loading section not found"
fi

# Test 3: Verify instructions mention file size thresholds
TESTS_RUN=$((TESTS_RUN + 1))
THRESHOLD_COUNT=$(grep -E "(1000|5000) lines" .claude/commands/review-context.md | wc -l | tr -d ' ')

if [ "$THRESHOLD_COUNT" -ge 2 ]; then
  pass "File size thresholds documented (found $THRESHOLD_COUNT mentions)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "File size thresholds not properly documented (found $THRESHOLD_COUNT mentions, need 2+)"
fi

# Test 4: Verify Read tool is mentioned in context of loading
TESTS_RUN=$((TESTS_RUN + 1))
# Look for "Read" tool mentions in smart loading section
# Extract lines from "Smart Loading" to next "##" section
SMART_LOADING_SECTION=$(sed -n '/SESSIONS.md Smart Loading/,/^##/p' .claude/commands/review-context.md)
READ_MENTIONS=$(echo "$SMART_LOADING_SECTION" | grep "Read" | wc -l | tr -d ' ')

if [ "$READ_MENTIONS" -ge 3 ]; then
  pass "Read tool mentioned in smart loading section ($READ_MENTIONS times)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Read tool not sufficiently mentioned in smart loading (found $READ_MENTIONS, need 3+)"
fi

# Test 5: Verify three loading strategies are documented
TESTS_RUN=$((TESTS_RUN + 1))
# Look for strategic keywords
STRATEGY_KEYWORDS=0
echo "$SMART_LOADING_SECTION" | grep -q "small\|full" && STRATEGY_KEYWORDS=$((STRATEGY_KEYWORDS + 1))
echo "$SMART_LOADING_SECTION" | grep -q "medium\|strategic" && STRATEGY_KEYWORDS=$((STRATEGY_KEYWORDS + 1))
echo "$SMART_LOADING_SECTION" | grep -q "large\|minimal" && STRATEGY_KEYWORDS=$((STRATEGY_KEYWORDS + 1))

if [ "$STRATEGY_KEYWORDS" -ge 2 ]; then
  pass "Multiple loading strategies documented"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Loading strategies not clearly documented"
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
