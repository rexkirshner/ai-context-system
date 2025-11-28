#!/bin/bash
# Test for CRIT-007 fix: Session count pattern should exclude "## Session Index"

source "$(dirname "$0")/test-helpers.sh"

TEST_NAME="CRIT-007 Session Count Fix"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

# Create test SESSIONS.md with "## Session Index" header
TEST_DIR=$(mktemp -d)
mkdir -p "$TEST_DIR/context"

cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Sessions

## Session Index

Links to all sessions below.

---

## Session 1 | 2025-01-01 | First Session

Content here

## Session 2 | 2025-01-02 | Second Session

Content here

## Session 3 | 2025-01-03 | Third Session

Content here
EOF

# Test 1: Verify grep -c "^## Session" counts 4 (includes Index)
TESTS_RUN=$((TESTS_RUN + 1))
WRONG_COUNT=$(grep -c "^## Session" "$TEST_DIR/context/SESSIONS.md")
if [ "$WRONG_COUNT" -eq 4 ]; then
  pass "Old pattern counts Session Index (4)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Old pattern should count 4, got: $WRONG_COUNT"
fi

# Test 2: Verify grep -cE "^## Session [0-9]+" counts 3 (excludes Index)
TESTS_RUN=$((TESTS_RUN + 1))
CORRECT_COUNT=$(grep -cE "^## Session [0-9]+" "$TEST_DIR/context/SESSIONS.md")
if [ "$CORRECT_COUNT" -eq 3 ]; then
  pass "New pattern excludes Session Index (3)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "New pattern should count 3, got: $CORRECT_COUNT"
fi

# Test 3: Verify pattern works with sessions 1-9 (single digit)
TESTS_RUN=$((TESTS_RUN + 1))
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
## Session Index
## Session 1 | Test
## Session 5 | Test
## Session 9 | Test
EOF
COUNT=$(grep -cE "^## Session [0-9]+" "$TEST_DIR/context/SESSIONS.md")
if [ "$COUNT" -eq 3 ]; then
  pass "Pattern works with single-digit sessions"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Should count 3 single-digit sessions, got: $COUNT"
fi

# Test 4: Verify pattern works with sessions 10+ (multi-digit)
TESTS_RUN=$((TESTS_RUN + 1))
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
## Session Index
## Session 10 | Test
## Session 25 | Test
## Session 100 | Test
EOF
COUNT=$(grep -cE "^## Session [0-9]+" "$TEST_DIR/context/SESSIONS.md")
if [ "$COUNT" -eq 3 ]; then
  pass "Pattern works with multi-digit sessions"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Should count 3 multi-digit sessions, got: $COUNT"
fi

# Test 5: Verify pattern handles mixed content
TESTS_RUN=$((TESTS_RUN + 1))
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
## Session Index
Some text mentioning Session stuff
## Session 1 | Test
More text about sessions
## Session Notes
This should not be counted
## Session 2 | Test
EOF
COUNT=$(grep -cE "^## Session [0-9]+" "$TEST_DIR/context/SESSIONS.md")
if [ "$COUNT" -eq 2 ]; then
  pass "Pattern ignores '## Session Notes' and text"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Should count 2 numbered sessions, got: $COUNT"
fi

# Cleanup
rm -rf "$TEST_DIR"

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
