#!/bin/bash
# Test for CRIT-003 fix: Prevent duplicate sessions via date-based archives

source "$(dirname "$0")/test-helpers.sh"

TEST_NAME="CRIT-003 No Duplicate Sessions Fix"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

# Create test directory
TEST_DIR=$(mktemp -d)
mkdir -p "$TEST_DIR/context"

# Create SESSIONS.md with 20 sessions
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Sessions

## Session Index

All sessions listed below

---

## Session 1 | 2025-01-01 | First
Content 1

## Session 2 | 2025-01-02 | Second
Content 2

## Session 3 | 2025-01-03 | Third
Content 3

## Session 4 | 2025-01-04 | Fourth
Content 4

## Session 5 | 2025-01-05 | Fifth
Content 5

## Session 6 | 2025-01-06 | Sixth
Content 6

## Session 7 | 2025-01-07 | Seventh
Content 7

## Session 8 | 2025-01-08 | Eighth
Content 8

## Session 9 | 2025-01-09 | Ninth
Content 9

## Session 10 | 2025-01-10 | Tenth
Content 10

## Session 11 | 2025-01-11 | Eleventh
Content 11

## Session 12 | 2025-01-12 | Twelfth
Content 12

## Session 13 | 2025-01-13 | Thirteenth
Content 13

## Session 14 | 2025-01-14 | Fourteenth
Content 14

## Session 15 | 2025-01-15 | Fifteenth
Content 15

## Session 16 | 2025-01-16 | Sixteenth
Content 16

## Session 17 | 2025-01-17 | Seventeenth
Content 17

## Session 18 | 2025-01-18 | Eighteenth
Content 18

## Session 19 | 2025-01-19 | Nineteenth
Content 19

## Session 20 | 2025-01-20 | Twentieth
Content 20
EOF

# Test 1: First archiving run (archive first 10, keep last 10)
TESTS_RUN=$((TESTS_RUN + 1))
cd "$TEST_DIR"
bash "$OLDPWD/scripts/archive-sessions-helper.sh" --keep 10 --no-backup --force >/dev/null 2>&1

YEAR=$(date +%Y)
DATE=$(date +%Y-%m-%d)
ARCHIVE_FILE=$(find context -name "SESSIONS-archive-*.md" | head -1)

if [ -n "$ARCHIVE_FILE" ]; then
  pass "First archive created: $ARCHIVE_FILE"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "First archive file not created"
fi

# Test 2: Verify archive file uses timestamp-based naming
TESTS_RUN=$((TESTS_RUN + 1))
if echo "$ARCHIVE_FILE" | grep -qE "SESSIONS-archive-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}\.md"; then
  pass "Archive uses timestamp-based naming (YYYY-MM-DD-HHMMSS)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Archive doesn't use timestamp-based naming: $ARCHIVE_FILE"
fi

# Test 3: Add more sessions and archive again
cat >> "$TEST_DIR/context/SESSIONS.md" << 'EOF'

## Session 21 | 2025-01-21 | Twenty-first
Content 21

## Session 22 | 2025-01-22 | Twenty-second
Content 22

## Session 23 | 2025-01-23 | Twenty-third
Content 23

## Session 24 | 2025-01-24 | Twenty-fourth
Content 24

## Session 25 | 2025-01-25 | Twenty-fifth
Content 25
EOF

# Sleep to ensure different timestamp (timestamp has second precision)
sleep 1

TESTS_RUN=$((TESTS_RUN + 1))
bash "$OLDPWD/scripts/archive-sessions-helper.sh" --keep 10 --no-backup --force >/dev/null 2>&1

# Count archive files
ARCHIVE_COUNT=$(find context -name "SESSIONS-archive-*.md" | wc -l | tr -d ' ')

if [ "$ARCHIVE_COUNT" -eq 2 ]; then
  pass "Second archive created new file (total: 2 archive files)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Expected 2 archive files, found: $ARCHIVE_COUNT"
fi

# Test 4: Verify no duplicate session numbers across archives
TESTS_RUN=$((TESTS_RUN + 1))
ALL_SESSIONS=$(grep -hE "^## Session [0-9]+" context/SESSIONS-archive-*.md | grep -oE 'Session [0-9]+' | grep -oE '[0-9]+' | sort -n)
UNIQUE_SESSIONS=$(echo "$ALL_SESSIONS" | uniq)

if [ "$(echo "$ALL_SESSIONS" | wc -l)" -eq "$(echo "$UNIQUE_SESSIONS" | wc -l)" ]; then
  pass "No duplicate session numbers in archives"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Found duplicate session numbers in archives"
  echo "  All: $(echo "$ALL_SESSIONS" | tr '\n' ' ')"
  echo "  Unique: $(echo "$UNIQUE_SESSIONS" | tr '\n' ' ')"
fi

# Test 5: Verify each archive has correct header with date
TESTS_RUN=$((TESTS_RUN + 1))
HEADERS_WITH_DATE=$(grep -h "Archived:" context/SESSIONS-archive-*.md | wc -l | tr -d ' ')

if [ "$HEADERS_WITH_DATE" -eq "$ARCHIVE_COUNT" ]; then
  pass "Each archive has dated header"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Not all archives have dated headers (expected $ARCHIVE_COUNT, found $HEADERS_WITH_DATE)"
fi

# Test 6: Verify old year-only archives still work (backward compatibility)
TESTS_RUN=$((TESTS_RUN + 1))
# Create an old-style archive file
cat > "$TEST_DIR/context/SESSIONS-archive-2024.md" << 'EOF'
# Archived Sessions (2024)

This is an old-style archive.

**Archived:** 2024-12-31
**Sessions:** Session 1 through Session 50

---

## Session 1 | 2024-01-01 | Old Session
Content
EOF

# Archive script should create new file, not break on old file
bash "$OLDPWD/scripts/archive-sessions-helper.sh" --keep 10 --no-backup --force >/dev/null 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  pass "Script works with existing old-style archives"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Script failed with old-style archive present"
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
