#!/bin/bash
# Test for HIGH-001 fix: Cleanup trap removes temp files on error

source "$(dirname "$0")/test-helpers.sh"

TEST_NAME="HIGH-001 Cleanup Trap Fix"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

# Create test directory
TEST_DIR=$(mktemp -d)
mkdir -p "$TEST_DIR/context"

# Test 1: Verify cleanup trap exists in script
TESTS_RUN=$((TESTS_RUN + 1))
SCRIPT_PATH="$(dirname "$(dirname "$0")")/archive-sessions-helper.sh"
if grep -q "trap cleanup" "$SCRIPT_PATH"; then
  pass "Cleanup trap defined in script"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No cleanup trap found in script"
fi

# Test 2: Verify cleanup function exists
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "cleanup()" "$SCRIPT_PATH"; then
  pass "Cleanup function defined"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No cleanup function found"
fi

# Test 3: Force error by providing invalid SESSIONS.md (missing --- separator)
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Sessions

## Session Index

No separator here!

## Session 1 | 2025-01-01 | First
Content
EOF

cd "$TEST_DIR"
# Run script, expect it to fail
bash "$OLDPWD/scripts/archive-sessions-helper.sh" --keep 2 --no-backup --force >/dev/null 2>&1
EXIT_CODE=$?

TESTS_RUN=$((TESTS_RUN + 1))
if [ $EXIT_CODE -ne 0 ]; then
  pass "Script exits with error on invalid input (expected)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Script should fail on invalid input"
fi

# Test 4: Verify no temp files left behind after error
TESTS_RUN=$((TESTS_RUN + 1))
TEMP_FILES=$(find context -name "*.tmp" 2>/dev/null | wc -l | tr -d ' ')

if [ "$TEMP_FILES" -eq 0 ]; then
  pass "No temp files left after error"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Found $TEMP_FILES temp files after error:"
  find context -name "*.tmp"
fi

# Test 5: Force error with non-numeric --keep value
cd "$TEST_DIR"
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Sessions

## Session Index

---

## Session 1 | 2025-01-01 | First
Content
EOF

bash "$OLDPWD/scripts/archive-sessions-helper.sh" --keep invalid --context context --no-backup --force >/dev/null 2>&1
EXIT_CODE=$?

TESTS_RUN=$((TESTS_RUN + 1))
if [ $EXIT_CODE -ne 0 ]; then
  pass "Script exits with error on invalid --keep value"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Script should fail on invalid --keep value"
fi

# Test 6: Verify temp files cleaned up after validation error
TESTS_RUN=$((TESTS_RUN + 1))
TEMP_FILES=$(find context -name "*.tmp" 2>/dev/null | wc -l | tr -d ' ')

if [ "$TEMP_FILES" -eq 0 ]; then
  pass "No temp files after validation error"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Found $TEMP_FILES temp files after validation error"
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
