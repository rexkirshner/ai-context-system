#!/bin/bash
# Test for CRIT-001 fix: Archive header should show session numbers, not line numbers

TEST_NAME="CRIT-001 Archive Header Fix"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

# Create test directory
TEST_DIR=$(mktemp -d)
mkdir -p "$TEST_DIR/context"

# Create SESSIONS.md with 15 sessions
# Session headers start at different line numbers (not 1, 2, 3...)
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Sessions

## Session Index

All sessions listed below

---

## Session 1 | 2025-01-01 | First Session

Content for session 1

## Session 2 | 2025-01-02 | Second Session

Content for session 2

## Session 3 | 2025-01-03 | Third Session

Content

## Session 4 | 2025-01-04 | Fourth

Content

## Session 5 | 2025-01-05 | Fifth

Content

## Session 6 | 2025-01-06 | Sixth

Content

## Session 7 | 2025-01-07 | Seventh

Content

## Session 8 | 2025-01-08 | Eighth

Content

## Session 9 | 2025-01-09 | Ninth

Content

## Session 10 | 2025-01-10 | Tenth

Content

## Session 11 | 2025-01-11 | Eleventh

Content

## Session 12 | 2025-01-12 | Twelfth

Content

## Session 13 | 2025-01-13 | Thirteenth

Content

## Session 14 | 2025-01-14 | Fourteenth

Content

## Session 15 | 2025-01-15 | Fifteenth

Content
EOF

# Test 1: Run archive script to keep last 10 sessions (archive first 5)
TESTS_RUN=$((TESTS_RUN + 1))
cd "$TEST_DIR"
bash "$OLDPWD/scripts/archive-sessions-helper.sh" --keep 10 --no-backup >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "✓ Archive script executed successfully"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "✗ Archive script failed"
fi

# Test 2: Verify archive file was created
TESTS_RUN=$((TESTS_RUN + 1))
YEAR=$(date +%Y)
if [ -f "context/SESSIONS-archive-$YEAR.md" ]; then
  echo "✓ Archive file created"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "✗ Archive file not found"
fi

# Test 3: Check archive header contains correct session numbers
TESTS_RUN=$((TESTS_RUN + 1))
HEADER=$(grep "^\*\*Sessions:\*\*" "context/SESSIONS-archive-$YEAR.md")
echo "  Archive header: $HEADER"

if echo "$HEADER" | grep -q "Session 1 through Session 5"; then
  echo "✓ Header shows correct session numbers (1 through 5)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "✗ Header does not show correct session numbers"
  echo "  Expected: 'Session 1 through Session 5'"
  echo "  Got: $HEADER"
fi

# Test 4: Verify header does NOT contain large line numbers
TESTS_RUN=$((TESTS_RUN + 1))
# If bug was present, would show line numbers like 8, 15, 22, etc
if echo "$HEADER" | grep -qE "[0-9]{2,}"; then
  # Check if it's NOT our expected session numbers
  if ! echo "$HEADER" | grep -qE "Session [1-5]"; then
    echo "✗ Header appears to contain line numbers instead of session numbers"
    TESTS_PASSED=$ echo "✓ Header does not contain unexpected large numbers"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  fi
else
  echo "✓ Header format looks correct (no large numbers)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# Test 5: Verify main file kept sessions 6-15 (10 sessions)
TESTS_RUN=$((TESTS_RUN + 1))
KEPT_COUNT=$(grep -cE "^## Session [0-9]+" "context/SESSIONS.md")
if [ "$KEPT_COUNT" -eq 10 ]; then
  echo "✓ Main file kept 10 sessions as requested"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "✗ Main file should have 10 sessions, has: $KEPT_COUNT"
fi

# Test 6: Verify first session in main file is Session 6
TESTS_RUN=$((TESTS_RUN + 1))
FIRST_KEPT=$(grep -m 1 -E "^## Session [0-9]+" "context/SESSIONS.md")
if echo "$FIRST_KEPT" | grep -q "Session 6"; then
  echo "✓ First kept session is Session 6"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "✗ First kept session should be Session 6, got: $FIRST_KEPT"
fi

# Cleanup
cd "$OLDPWD"
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
