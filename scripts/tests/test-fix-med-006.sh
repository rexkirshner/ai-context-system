#!/bin/bash
# Test for MED-006 fix: Flexible date parsing

source "$(dirname "$0")/test-helpers.sh"

TEST_NAME="MED-006 Flexible Date Parsing"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
REVIEW_CONTEXT="$PROJECT_ROOT/.claude/commands/review-context.md"

# Test 1: Verify flexible date parsing pattern exists for CONTEXT_DATE
TESTS_RUN=$((TESTS_RUN + 1))
if grep "CONTEXT_DATE=" "$REVIEW_CONTEXT" | grep -q "grep -oE.*[0-9]"; then
  pass "CONTEXT_DATE uses flexible parsing"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "CONTEXT_DATE doesn't use flexible parsing"
fi

# Test 2: Verify flexible date parsing pattern exists for STATUS_DATE
TESTS_RUN=$((TESTS_RUN + 1))
if grep "STATUS_DATE=" "$REVIEW_CONTEXT" | grep -q "grep -oE.*[0-9]"; then
  pass "STATUS_DATE uses flexible parsing"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "STATUS_DATE doesn't use flexible parsing"
fi

# Test 3: Verify flexible date parsing pattern exists for SESSIONS_DATE
TESTS_RUN=$((TESTS_RUN + 1))
if grep "SESSIONS_DATE=" "$REVIEW_CONTEXT" | grep -q "grep -oE.*[0-9]"; then
  pass "SESSIONS_DATE uses flexible parsing"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "SESSIONS_DATE doesn't use flexible parsing"
fi

# Test 4: Test flexible parsing with various date formats
TESTS_RUN=$((TESTS_RUN + 1))
TEST_FILE=$(mktemp)

# Test different date formats
echo "Last Updated: 2025-11-28" > "$TEST_FILE"
DATE1=$(grep "Last Updated:" "$TEST_FILE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')

echo "Last Updated: 2025-11-28 14:30" > "$TEST_FILE"
DATE2=$(grep "Last Updated:" "$TEST_FILE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')

echo "Last Updated: November 28, 2025 (2025-11-28)" > "$TEST_FILE"
DATE3=$(grep "Last Updated:" "$TEST_FILE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')

if [ "$DATE1" = "2025-11-28" ] && [ "$DATE2" = "2025-11-28" ] && [ "$DATE3" = "2025-11-28" ]; then
  pass "Flexible parsing extracts date from various formats"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Parsing failed for some formats (got: $DATE1, $DATE2, $DATE3)"
fi

rm -f "$TEST_FILE"

# Test 5: Test that parsing handles missing dates gracefully
TESTS_RUN=$((TESTS_RUN + 1))
TEST_FILE=$(mktemp)

echo "Some content without dates" > "$TEST_FILE"
DATE=$(grep "Last Updated:" "$TEST_FILE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || echo "")

if [ -z "$DATE" ]; then
  pass "Parsing returns empty for missing dates"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Parsing should return empty for missing dates"
fi

rm -f "$TEST_FILE"

# Test 6: Test with multiple "Last Updated" occurrences (takes first)
TESTS_RUN=$((TESTS_RUN + 1))
TEST_FILE=$(mktemp)

cat > "$TEST_FILE" << 'EOF'
Some header
Last Updated: 2025-11-28

Content section
Last Updated: 2025-11-15
EOF

DATE=$(grep "Last Updated:" "$TEST_FILE" | head -1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')

if [ "$DATE" = "2025-11-28" ]; then
  pass "Parsing takes first occurrence with head -1"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Parsing should take first occurrence (got: $DATE)"
fi

rm -f "$TEST_FILE"

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
