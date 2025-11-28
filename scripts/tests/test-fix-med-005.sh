#!/bin/bash
# Test for MED-005 fix: Remove trailing blank lines in archived sessions

source "$(dirname "$0")/test-helpers.sh"

TEST_NAME="MED-005 No Trailing Blank Lines"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ARCHIVE_SCRIPT="$PROJECT_ROOT/scripts/archive-sessions-helper.sh"

# Test 1: Verify conditional blank line logic in archive loop
TESTS_RUN=$((TESTS_RUN + 1))
if grep -B 2 'echo "" >> "$ARCHIVE_TEMP"' "$ARCHIVE_SCRIPT" | grep -q 'if.*KEEP_START_INDEX'; then
  pass "Archive loop has conditional blank line"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Archive loop doesn't check if last session"
fi

# Test 2: Verify conditional blank line logic in keep sessions loop
TESTS_RUN=$((TESTS_RUN + 1))
if grep -B 2 'echo "" >> "$TEMP_FILE"' "$ARCHIVE_SCRIPT" | grep -q 'if.*TOTAL_SESSIONS'; then
  pass "Keep loop has conditional blank line"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Keep loop doesn't check if last session"
fi

# Test 3: Run actual archiving and verify no trailing blank lines
TESTS_RUN=$((TESTS_RUN + 1))
TEST_DIR=$(mktemp -d)
mkdir -p "$TEST_DIR/context"

# Create test SESSIONS.md with 15 sessions
# Sessions should not have blank lines between them - that's what the archiving script adds
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Sessions

## Session Index

- Session 1
- Session 2
- Session 3

---
## Session 1 | First
Content 1
## Session 2 | Second
Content 2
## Session 3 | Third
Content 3
## Session 4 | Fourth
Content 4
## Session 5 | Fifth
Content 5
## Session 6 | Sixth
Content 6
## Session 7 | Seventh
Content 7
## Session 8 | Eighth
Content 8
## Session 9 | Ninth
Content 9
## Session 10 | Tenth
Content 10
## Session 11 | Eleventh
Content 11
## Session 12 | Twelfth
Content 12
## Session 13 | Thirteenth
Content 13
## Session 14 | Fourteenth
Content 14
## Session 15 | Fifteenth
Content 15
EOF

# Archive with --force to skip prompt, keep last 5 sessions (archive first 10)
bash "$ARCHIVE_SCRIPT" --keep 5 --context "$TEST_DIR/context" --force --no-backup > /dev/null 2>&1

# Find the created archive file
ARCHIVE_FILE=$(ls "$TEST_DIR/context"/SESSIONS-archive-*.md 2>/dev/null | head -1)

if [ -f "$ARCHIVE_FILE" ]; then
  # Check that archive doesn't end with blank line
  LAST_LINE=$(tail -1 "$ARCHIVE_FILE")
  if [ -n "$LAST_LINE" ]; then
    pass "Archive file doesn't end with blank line"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    fail "Archive file ends with blank line"
  fi
else
  fail "Archive file not created"
fi

# Test 4: Verify SESSIONS.md doesn't have trailing blank line
TESTS_RUN=$((TESTS_RUN + 1))
if [ -f "$TEST_DIR/context/SESSIONS.md" ]; then
  LAST_LINE=$(tail -1 "$TEST_DIR/context/SESSIONS.md")
  if [ -n "$LAST_LINE" ]; then
    pass "SESSIONS.md doesn't end with blank line"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    fail "SESSIONS.md ends with blank line"
  fi
else
  fail "SESSIONS.md not found"
fi

# Test 5: Verify sessions in archive are properly separated
TESTS_RUN=$((TESTS_RUN + 1))
if [ -f "$ARCHIVE_FILE" ]; then
  # Count sessions in archive (should be 10)
  SESSION_COUNT=$(grep -cE "^## Session [0-9]+" "$ARCHIVE_FILE")

  if [ "$SESSION_COUNT" -eq 10 ]; then
    # Check that sessions 1 and 2 are separated by exactly one blank line
    SESSION_1_2=$(sed -n '/^## Session 1/,/^## Session 2/p' "$ARCHIVE_FILE")
    SEPARATOR_COUNT=$(echo "$SESSION_1_2" | grep -c "^$" || echo "0")

    if [ "$SEPARATOR_COUNT" -eq 1 ]; then
      pass "Sessions properly separated (1 blank line between sessions)"
      TESTS_PASSED=$((TESTS_PASSED + 1))
    else
      fail "Sessions not properly separated ($SEPARATOR_COUNT blank lines between sessions 1 and 2)"
    fi
  else
    fail "Wrong session count in archive ($SESSION_COUNT, expected 10)"
  fi
fi

# Test 6: Verify sessions in SESSIONS.md are still separated
TESTS_RUN=$((TESTS_RUN + 1))
if [ -f "$TEST_DIR/context/SESSIONS.md" ]; then
  # Count sessions (should be 5 kept sessions)
  SESSION_COUNT=$(grep -cE "^## Session [0-9]+" "$TEST_DIR/context/SESSIONS.md")

  if [ "$SESSION_COUNT" -eq 5 ]; then
    pass "Correct number of sessions kept ($SESSION_COUNT)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    fail "Wrong session count in SESSIONS.md ($SESSION_COUNT, expected 5)"
  fi
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
