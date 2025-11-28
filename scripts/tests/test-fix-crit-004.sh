#!/bin/bash
# Test for CRIT-004 fix: Archive script path should work from subdirectories

source "$(dirname "$0")/test-helpers.sh"

TEST_NAME="CRIT-004 Archive Script Path Fix"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

# Create test directory structure
TEST_DIR=$(mktemp -d)
mkdir -p "$TEST_DIR/context"
mkdir -p "$TEST_DIR/scripts"
mkdir -p "$TEST_DIR/backend/src"

# Copy archive script to test location
cp "$(dirname "$0")/../archive-sessions-helper.sh" "$TEST_DIR/scripts/"

# Create test SESSIONS.md with 15 sessions
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

# Test 1: OLD BROKEN PATTERN - Relative path fails from subdirectory
TESTS_RUN=$((TESTS_RUN + 1))
cd "$TEST_DIR/backend/src"
CONTEXT_DIR="$TEST_DIR/context"

# Try old pattern (should fail)
bash scripts/archive-sessions-helper.sh --keep 10 --context "$CONTEXT_DIR" --no-backup >/dev/null 2>&1
if [ $? -ne 0 ]; then
  pass "Old relative path fails from subdirectory (expected)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Old relative path should fail from subdirectory"
fi

# Test 2: NEW FIXED PATTERN - Absolute path works from subdirectory
TESTS_RUN=$((TESTS_RUN + 1))
cd "$TEST_DIR/backend/src"
CONTEXT_DIR="$TEST_DIR/context"

# Try new pattern using dirname (should work)
bash "$(dirname "$CONTEXT_DIR")/scripts/archive-sessions-helper.sh" --keep 10 --context "$CONTEXT_DIR" --no-backup >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "New absolute path works from subdirectory"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "New absolute path should work from subdirectory"
fi

# Test 3: Verify archive was created from subdirectory
TESTS_RUN=$((TESTS_RUN + 1))
YEAR=$(date +%Y)
if [ -f "$TEST_DIR/context/SESSIONS-archive-$YEAR.md" ]; then
  pass "Archive file created successfully from subdirectory"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Archive file not created"
fi

# Test 4: NEW PATTERN works from project root too
TESTS_RUN=$((TESTS_RUN + 1))
cd "$TEST_DIR"
CONTEXT_DIR="$TEST_DIR/context"

# Remove archive to test again
rm -f "$TEST_DIR/context/SESSIONS-archive-$YEAR.md"

bash "$(dirname "$CONTEXT_DIR")/scripts/archive-sessions-helper.sh" --keep 10 --context "$CONTEXT_DIR" --no-backup >/dev/null 2>&1
if [ $? -eq 0 ]; then
  pass "New pattern works from project root"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "New pattern should work from project root"
fi

# Test 5: Verify dirname logic works correctly
TESTS_RUN=$((TESTS_RUN + 1))
CONTEXT_DIR="$TEST_DIR/context"
PROJECT_ROOT="$(dirname "$CONTEXT_DIR")"
EXPECTED_ROOT="$TEST_DIR"

if [ "$PROJECT_ROOT" = "$EXPECTED_ROOT" ]; then
  pass "dirname extracts project root correctly"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Expected: $EXPECTED_ROOT, Got: $PROJECT_ROOT"
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
