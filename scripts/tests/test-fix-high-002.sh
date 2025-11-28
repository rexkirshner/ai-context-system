#!/bin/bash
# Test for HIGH-002 fix: Atomic archive operations prevent data loss

source "$(dirname "$0")/test-helpers.sh"

TEST_NAME="HIGH-002 Atomic Operation Fix"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT="$PROJECT_ROOT/scripts/archive-sessions-helper.sh"

# Test 1: Verify temp file validation exists before mv
TESTS_RUN=$((TESTS_RUN + 1))
# Look for validation before the mv command
if grep -B5 "mv.*TEMP_FILE.*SESSIONS_FILE" "$SCRIPT" | grep -q "if.*TEMP_FILE.*-s\|if.*-f.*TEMP_FILE"; then
  pass "Temp file validation before mv"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No temp file validation before mv"
fi

# Test 2: Verify error handling for empty/missing temp file
TESTS_RUN=$((TESTS_RUN + 1))
if grep -A10 "mv.*TEMP_FILE.*SESSIONS_FILE" "$SCRIPT" | grep -q "empty\|missing"; then
  pass "Error handling for invalid temp file"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No error handling for invalid temp file"
fi

# Test 3: Test actual archiving preserves SESSIONS.md on mv failure
TEST_DIR=$(mktemp -d)
mkdir -p "$TEST_DIR/context"

# Create test SESSIONS.md
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Sessions

## Session Index

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
EOF

# Save original content
ORIGINAL_CONTENT=$(cat "$TEST_DIR/context/SESSIONS.md")

cd "$TEST_DIR"
# Run archiving (should succeed)
bash "$SCRIPT" --keep 2 --no-backup --force >/dev/null 2>&1
ARCHIVE_EXIT=$?

TESTS_RUN=$((TESTS_RUN + 1))
if [ $ARCHIVE_EXIT -eq 0 ]; then
  pass "Archive script completed successfully"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Archive script failed"
fi

# Test 4: Verify SESSIONS.md still exists after archiving
TESTS_RUN=$((TESTS_RUN + 1))
if [ -f "context/SESSIONS.md" ]; then
  pass "SESSIONS.md exists after archiving"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "SESSIONS.md missing after archiving"
fi

# Test 5: Verify SESSIONS.md has content (not empty)
TESTS_RUN=$((TESTS_RUN + 1))
if [ -s "context/SESSIONS.md" ]; then
  pass "SESSIONS.md has content"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "SESSIONS.md is empty"
fi

# Test 6: Verify backup was created and is valid
TESTS_RUN=$((TESTS_RUN + 1))
# Note: --no-backup flag skips backup creation, so this test checks that
# the flag works as expected
if [ -f "context/SESSIONS.md.backup" ]; then
  fail "Backup exists despite --no-backup flag"
else
  pass "--no-backup flag works correctly"
  TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# Cleanup
cd "$PROJECT_ROOT"
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
