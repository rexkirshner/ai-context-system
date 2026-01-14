#!/bin/bash
# test-feedback-archiving.sh - Verify feedback file archiving logic
# Tests that template examples are excluded and real entries are detected

set -e

echo "=== Feedback Archiving Logic Verification ==="
echo ""

PASS=0
FAIL=0

check() {
  if eval "$1" > /dev/null 2>&1; then
    echo "✓ $2"
    PASS=$((PASS + 1))
  else
    echo "✗ $2"
    FAIL=$((FAIL + 1))
  fi
}

# Helper: Count user entries using the improved detection logic
count_user_entries() {
  local file="$1"
  local count
  # grep -c exits with 1 when no matches but still outputs "0"
  # Use || true to prevent exit, and rely on grep's output
  count=$(sed -n '/^## Feedback Entries/,/^## Examples/p' "$file" 2>/dev/null | \
    grep -c "^## [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" 2>/dev/null || true)
  # Default to 0 if empty (file doesn't exist or no section found)
  echo "${count:-0}" | tr -d '[:space:]'
}

echo "--- Template Structure ---"
check "grep -q '^## Feedback Entries' templates/context-feedback.template.md" "Feedback Entries section exists"
check "grep -q '^## Examples (Delete after reading)' templates/context-feedback.template.md" "Examples section exists"
check "grep -q 'DELETE THIS ENTIRE SECTION' templates/context-feedback.template.md" "Deletion instruction visible"
check "grep -q 'Only entries in this section' templates/context-feedback.template.md" "Archive scope documented"

echo ""
echo "--- Entry Detection (Fresh Template) ---"
FRESH_COUNT=$(count_user_entries templates/context-feedback.template.md)
check "[ '$FRESH_COUNT' -eq 0 ]" "Fresh template has 0 detected entries (got: $FRESH_COUNT)"

# Verify examples exist but aren't counted
TOTAL_DATED_HEADERS=$(grep -c "^## [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" templates/context-feedback.template.md 2>/dev/null || true)
check "[ '$TOTAL_DATED_HEADERS' -eq 3 ]" "Template has 3 example entries (not counted)"

echo ""
echo "--- Entry Detection (Simulated User Feedback) ---"

# Create a test file with real user feedback
TEST_DIR=$(mktemp -d)
TEST_FILE="$TEST_DIR/test-feedback.md"

cat > "$TEST_FILE" << 'EOF'
# Test Feedback File

## Feedback Entries

## 2026-01-13 - /save - Bug 🐛

**What happened**: Test bug report

---

## 2026-01-12 - /code-review - Feature Request ✨

**What happened**: Test feature request

---

## Examples (Delete after reading)

## 2024-10-21 - Example entry that should NOT be counted
EOF

USER_COUNT=$(count_user_entries "$TEST_FILE")
check "[ '$USER_COUNT' -eq 2 ]" "Simulated file detects 2 user entries (got: $USER_COUNT)"

# Test empty feedback section
cat > "$TEST_FILE" << 'EOF'
# Test Feedback File

## Feedback Entries

<!-- No feedback yet -->

## Examples (Delete after reading)

## 2024-10-21 - Example entry
EOF

EMPTY_COUNT=$(count_user_entries "$TEST_FILE")
check "[ '$EMPTY_COUNT' -eq 0 ]" "Empty feedback section detects 0 entries (got: $EMPTY_COUNT)"

# Clean up
rm -rf "$TEST_DIR"

echo ""
echo "--- Command Integration ---"
check "grep -q 'sed -n.*Feedback Entries.*Examples' .claude/commands/update-context-system.md" "Update command uses improved detection"
check "grep -q 'artifacts/feedback' .claude/commands/update-context-system.md" "Archive path is artifacts/feedback/"
check "grep -q 'PRE_UPGRADE_VERSION' .claude/commands/update-context-system.md" "Uses version in archive filename"

echo ""
echo "=== Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "✅ ALL FEEDBACK ARCHIVING TESTS PASSED"
else
  echo "❌ SOME TESTS FAILED"
fi

exit $FAIL
