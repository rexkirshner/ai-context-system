#!/bin/bash
# Test script for auto-timestamp functionality (v3.7.0)
#
# Tests the update_last_modified() function from common-functions.sh
#
# Usage:
#   ./scripts/tests/test-auto-timestamps.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Track test results
TESTS_PASSED=0
TESTS_FAILED=0

# Test directory
TEST_DIR="/tmp/test-auto-timestamps-$$"

# Cleanup function
cleanup() {
  rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# Setup
setup() {
  mkdir -p "$TEST_DIR"
  # Source the common functions from the project root
  cd "$(dirname "$0")/../.."
  source scripts/common-functions.sh
  cd "$TEST_DIR"
}

# Test helper functions
pass() {
  echo -e "${GREEN}PASS${NC}: $1"
  TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
  echo -e "${RED}FAIL${NC}: $1"
  TESTS_FAILED=$((TESTS_FAILED + 1))
}

# =============================================================================
# Test Cases
# =============================================================================

test_file_with_timestamp() {
  echo "Test 1: File with **Last Updated:** pattern"

  # Create test file with old date
  cat > "$TEST_DIR/test1.md" << 'EOF'
# Test Document

**Last Updated:** 2020-01-01

Some content here.
EOF

  # Run update
  update_last_modified "$TEST_DIR/test1.md"

  # Verify date changed to today
  local today=$(date +%Y-%m-%d)
  if grep -F "**Last Updated:** $today" "$TEST_DIR/test1.md" > /dev/null; then
    pass "File with timestamp - date updated to $today"
  else
    fail "File with timestamp - date not updated"
    echo "  Expected: **Last Updated:** $today"
    echo "  Got: $(grep 'Last Updated' "$TEST_DIR/test1.md")"
  fi
}

test_file_without_timestamp() {
  echo "Test 2: File without **Last Updated:** pattern"

  # Create test file without timestamp
  cat > "$TEST_DIR/test2.md" << 'EOF'
# Test Document

Some content without a timestamp.
EOF

  # Save original content
  local original=$(cat "$TEST_DIR/test2.md")

  # Run update
  update_last_modified "$TEST_DIR/test2.md"

  # Verify file unchanged
  local after=$(cat "$TEST_DIR/test2.md")
  if [ "$original" = "$after" ]; then
    pass "File without timestamp - content unchanged"
  else
    fail "File without timestamp - content was modified"
  fi
}

test_file_not_found() {
  echo "Test 3: Non-existent file"

  # Run update on non-existent file
  if update_last_modified "$TEST_DIR/nonexistent.md" 2>/dev/null; then
    fail "Non-existent file - should have returned error"
  else
    pass "Non-existent file - returned error as expected"
  fi
}

test_multiple_timestamps() {
  echo "Test 4: File with multiple **Last Updated:** patterns"

  # Create test file with multiple timestamps
  cat > "$TEST_DIR/test4.md" << 'EOF'
# Test Document

**Last Updated:** 2020-01-01

## Section 1

**Last Updated:** 2019-06-15

More content.
EOF

  # Run update
  update_last_modified "$TEST_DIR/test4.md"

  # Verify both dates changed to today
  local today=$(date +%Y-%m-%d)
  local count=$(grep -F "**Last Updated:** $today" "$TEST_DIR/test4.md" | wc -l | tr -d ' ')
  if [ "$count" = "2" ]; then
    pass "Multiple timestamps - all updated to $today"
  else
    fail "Multiple timestamps - not all updated (found $count, expected 2)"
  fi
}

test_different_date_formats() {
  echo "Test 5: Different placeholder formats"

  # Create test file with placeholder
  cat > "$TEST_DIR/test5.md" << 'EOF'
# Test Document

**Last Updated:** [Auto-updated by /save]

Content.
EOF

  # Run update
  update_last_modified "$TEST_DIR/test5.md"

  # Verify placeholder replaced with date
  local today=$(date +%Y-%m-%d)
  if grep -F "**Last Updated:** $today" "$TEST_DIR/test5.md" > /dev/null; then
    pass "Placeholder format - replaced with $today"
  else
    fail "Placeholder format - not replaced"
    echo "  Got: $(grep 'Last Updated' "$TEST_DIR/test5.md")"
  fi
}

test_preserve_other_content() {
  echo "Test 6: Preserve other content in file"

  # Create test file with various content
  cat > "$TEST_DIR/test6.md" << 'EOF'
# Important Document

**Last Updated:** 2020-01-01

## Code Example

```javascript
const x = 1;
```

## List
- Item 1
- Item 2

**Bold text** and *italic text*.
EOF

  # Run update
  update_last_modified "$TEST_DIR/test6.md"

  # Verify other content preserved
  local today=$(date +%Y-%m-%d)
  local has_code=$(grep -c 'const x = 1' "$TEST_DIR/test6.md")
  local has_list=$(grep -c 'Item 1' "$TEST_DIR/test6.md")
  local has_date=$(grep -F "**Last Updated:** $today" "$TEST_DIR/test6.md" | wc -l | tr -d ' ')

  if [ "$has_code" = "1" ] && [ "$has_list" = "1" ] && [ "$has_date" = "1" ]; then
    pass "Other content preserved correctly"
  else
    fail "Other content not preserved (code=$has_code, list=$has_list, date=$has_date)"
  fi
}

# =============================================================================
# Run Tests
# =============================================================================

echo "========================================"
echo "Auto-Timestamp Tests (v3.7.0)"
echo "========================================"
echo ""

setup

test_file_with_timestamp
test_file_without_timestamp
test_file_not_found
test_multiple_timestamps
test_different_date_formats
test_preserve_other_content

echo ""
echo "========================================"
echo "Results: $TESTS_PASSED passed, $TESTS_FAILED failed"
echo "========================================"

if [ $TESTS_FAILED -gt 0 ]; then
  exit 1
fi

exit 0
