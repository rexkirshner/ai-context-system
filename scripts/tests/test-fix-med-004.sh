#!/bin/bash
# Test for MED-004 fix: Validate --context directory

source "$(dirname "$0")/test-helpers.sh"

TEST_NAME="MED-004 Context Directory Validation"
TESTS_RUN=0
TESTS_PASSED=0

echo "Testing: $TEST_NAME"
echo ""

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ARCHIVE_SCRIPT="$PROJECT_ROOT/scripts/archive-sessions-helper.sh"

# Test 1: Verify validation code exists
TESTS_RUN=$((TESTS_RUN + 1))
if grep -A 3 'CONTEXT_DIR="$2"' "$ARCHIVE_SCRIPT" | grep -q 'if \[ ! -d "$CONTEXT_DIR" \]'; then
  pass "Context directory validation exists"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "No context directory validation"
fi

# Test 2: Verify error message mentions directory
TESTS_RUN=$((TESTS_RUN + 1))
if grep -A 3 'if \[ ! -d "$CONTEXT_DIR" \]' "$ARCHIVE_SCRIPT" | grep -qi "directory"; then
  pass "Error message mentions 'directory'"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Error message doesn't mention 'directory'"
fi

# Test 3: Test with non-existent directory
TESTS_RUN=$((TESTS_RUN + 1))
OUTPUT=$(bash "$ARCHIVE_SCRIPT" --context "/nonexistent/path/12345" --force 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  if echo "$OUTPUT" | grep -qi "directory"; then
    pass "Script exits with directory error for non-existent path"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    fail "Script exits but error message unclear: $OUTPUT"
  fi
else
  fail "Script should fail for non-existent directory"
fi

# Test 4: Test with valid directory
TESTS_RUN=$((TESTS_RUN + 1))
TEST_DIR=$(mktemp -d)
mkdir -p "$TEST_DIR/context"

# Create minimal SESSIONS.md
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Sessions

## Session Index

---
## Session 1 | Test
Content
EOF

OUTPUT=$(bash "$ARCHIVE_SCRIPT" --context "$TEST_DIR/context" --force --no-backup 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  pass "Script succeeds with valid directory"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  # It's okay if it fails for other reasons (like not enough sessions)
  if echo "$OUTPUT" | grep -qi "No archiving needed\|No sessions"; then
    pass "Script accepts valid directory (no sessions to archive)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    fail "Script fails with valid directory: $OUTPUT"
  fi
fi

rm -rf "$TEST_DIR"

# Test 5: Test validation happens before other errors
TESTS_RUN=$((TESTS_RUN + 1))
OUTPUT=$(bash "$ARCHIVE_SCRIPT" --context "/tmp/definitely-does-not-exist-$(date +%s%N)" --keep 5 --force 2>&1)

if echo "$OUTPUT" | head -1 | grep -qi "directory"; then
  pass "Directory validation error shown first"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  fail "Other error shown before directory validation"
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
