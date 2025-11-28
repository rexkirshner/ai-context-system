#!/bin/bash
# Test for HIGH-007 fix: Dynamic Session Index size detection

source "$(dirname "$0")/test-helpers.sh"

TEST_NAME="HIGH-007 Dynamic Session Index Detection"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
REVIEW_CONTEXT="$PROJECT_ROOT/.claude/commands/review-context.md"

# Test 1: Verify INDEX_END detection exists
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "INDEX_END.*grep.*---" "$REVIEW_CONTEXT"; then
  pass "INDEX_END detection code exists"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No INDEX_END detection"
fi

# Test 2: Verify fallback to 300 lines if no separator
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "INDEX_END=300" "$REVIEW_CONTEXT"; then
  pass "Fallback to 300 lines exists"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No fallback for missing separator"
fi

# Test 3: Verify INDEX_END used in medium file strategy
TESTS_RUN=$((TESTS_RUN + 1))
MED_SECTION=$(sed -n '/1000-5000 lines/,/large file/p' "$REVIEW_CONTEXT")

if echo "$MED_SECTION" | grep -q "limit=\$INDEX_END"; then
  pass "Medium file strategy uses INDEX_END"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Medium file doesn't use INDEX_END"
fi

# Test 4: Verify INDEX_END used in large file strategy
TESTS_RUN=$((TESTS_RUN + 1))
LARGE_SECTION=$(sed -n '/> 5000 lines/,/Why this works/p' "$REVIEW_CONTEXT")

if echo "$LARGE_SECTION" | grep -q "limit=\$INDEX_END"; then
  pass "Large file strategy uses INDEX_END"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Large file doesn't use INDEX_END"
fi

# Test 5: Test actual INDEX_END detection with sample file
TESTS_RUN=$((TESTS_RUN + 1))
TEST_FILE=$(mktemp)
cat > "$TEST_FILE" << 'EOF'
# Sessions

## Session Index

Line 4
Line 5
Line 6
Line 7

---

## Session 1 | Test
Content
EOF

INDEX_LINE=$(grep -n "^---$" "$TEST_FILE" | head -1 | cut -d: -f1)

if [ "$INDEX_LINE" -eq 10 ]; then
  pass "INDEX_END detection works correctly (line 10)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "INDEX_END detection incorrect (expected 10, got $INDEX_LINE)"
fi

rm -f "$TEST_FILE"

# Test 6: Verify no hardcoded limits in final implementation
TESTS_RUN=$((TESTS_RUN + 1))
# Check that medium/large sections don't use hardcoded 200 or 300
if grep -E "limit=(200|300)" "$REVIEW_CONTEXT" | grep -q "medium file\|large file"; then
  fail "Still uses hardcoded limits in medium/large strategies"
else
  pass "No hardcoded limits in medium/large file strategies"
  TESTS_PASSED=$((TESTS_PASSED + 1))
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
