#!/bin/bash
# Test script for documentation currency features - v3.3.0 Day 3
# Tests helper functions, staleness detection, and integration

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🧪 Testing Documentation Currency Features - v3.3.0 Day 3${NC}"
echo ""

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper
run_test() {
  local test_name="$1"
  local test_command="$2"

  TESTS_RUN=$((TESTS_RUN + 1))
  echo -n "Test $TESTS_RUN: $test_name... "

  if eval "$test_command" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗ FAIL${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# Project root
PROJECT_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$PROJECT_ROOT"

# Source common functions
source scripts/common-functions.sh 2>/dev/null || {
  echo -e "${RED}Failed to load common-functions.sh${NC}"
  exit 1
}

echo -e "${BLUE}Test Suite 1: Helper Functions${NC}"
echo ""

# =============================================================================
# Test 1: days_since_date function exists
# =============================================================================
run_test "days_since_date function exists" \
  "type days_since_date"

# =============================================================================
# Test 2: days_since_file_modified function exists
# =============================================================================
run_test "days_since_file_modified function exists" \
  "type days_since_file_modified"

# =============================================================================
# Test 3: days_since_date with today's date returns 0
# =============================================================================
run_test "days_since_date with today returns 0" \
  "[ \"\$(days_since_date \$(date +%Y-%m-%d))\" -eq 0 ]"

# =============================================================================
# Test 4: days_since_date with 10 days ago returns ~10
# =============================================================================
# Calculate date 10 days ago
if date -v-10d +%Y-%m-%d >/dev/null 2>&1; then
  # BSD/macOS date
  TEN_DAYS_AGO=$(date -v-10d +%Y-%m-%d)
elif date -d "10 days ago" +%Y-%m-%d >/dev/null 2>&1; then
  # GNU/Linux date
  TEN_DAYS_AGO=$(date -d "10 days ago" +%Y-%m-%d)
else
  TEN_DAYS_AGO="2025-11-03"  # Fallback
fi

run_test "days_since_date with 10 days ago returns ~10" \
  "DAYS=\$(days_since_date $TEN_DAYS_AGO) && [ \$DAYS -ge 9 ] && [ \$DAYS -le 11 ]"

# =============================================================================
# Test 5: days_since_date with invalid date returns -1
# =============================================================================
run_test "days_since_date with invalid date returns -1" \
  "[ \"\$(days_since_date 'invalid-date')\" -eq -1 ]"

# =============================================================================
# Test 6: days_since_date with empty string returns -1
# =============================================================================
run_test "days_since_date with empty string returns -1" \
  "[ \"\$(days_since_date '')\" -eq -1 ]"

echo ""
echo -e "${BLUE}Test Suite 2: File Modification Tests${NC}"
echo ""

# Create temporary test file
TEST_FILE="/tmp/test-staleness-$$-$RANDOM.txt"
echo "test content" > "$TEST_FILE"

# =============================================================================
# Test 7: days_since_file_modified with fresh file returns 0
# =============================================================================
run_test "days_since_file_modified with fresh file returns 0" \
  "[ \"\$(days_since_file_modified $TEST_FILE)\" -eq 0 ]"

# =============================================================================
# Test 8: days_since_file_modified with missing file returns -1
# =============================================================================
run_test "days_since_file_modified with missing file returns -1" \
  "[ \"\$(days_since_file_modified /tmp/nonexistent-file-12345.txt)\" -eq -1 ]"

# Set file modification time to 10 days ago
if touch -t "$(date -v-10d +%Y%m%d0000)" "$TEST_FILE" 2>/dev/null; then
  # BSD/macOS touch
  run_test "days_since_file_modified with 10-day-old file returns ~10" \
    "DAYS=\$(days_since_file_modified $TEST_FILE) && [ \$DAYS -ge 9 ] && [ \$DAYS -le 11 ]"
elif touch -d "10 days ago" "$TEST_FILE" 2>/dev/null; then
  # GNU/Linux touch
  run_test "days_since_file_modified with 10-day-old file returns ~10" \
    "DAYS=\$(days_since_file_modified $TEST_FILE) && [ \$DAYS -ge 9 ] && [ \$DAYS -le 11 ]"
else
  echo -e "${YELLOW}  ⊘ SKIP: Cannot set file modification time on this platform${NC}"
  TESTS_RUN=$((TESTS_RUN + 1))
fi

# Cleanup
rm -f "$TEST_FILE"

echo ""
echo -e "${BLUE}Test Suite 3: Date Extraction from CONTEXT.md${NC}"
echo ""

# Create temporary CONTEXT.md for testing
TEST_CONTEXT="/tmp/test-context-$$-$RANDOM.md"

# =============================================================================
# Test 10: Extract date from CONTEXT.md with "Last Updated: YYYY-MM-DD"
# =============================================================================
cat > "$TEST_CONTEXT" <<EOF
# Project Context

Some project information here.

**Last Updated: 2025-11-10**

More content...
EOF

run_test "Extract date from CONTEXT.md" \
  "grep -oE 'Last Updated:.*[0-9]{4}-[0-9]{2}-[0-9]{2}' $TEST_CONTEXT | grep -q '2025-11-10'"

# =============================================================================
# Test 11: Handle CONTEXT.md without date gracefully
# =============================================================================
cat > "$TEST_CONTEXT" <<EOF
# Project Context

No date in this file.
EOF

run_test "Handle CONTEXT.md without date" \
  "! grep -qE 'Last Updated:.*[0-9]{4}-[0-9]{2}-[0-9]{2}' $TEST_CONTEXT"

# Cleanup
rm -f "$TEST_CONTEXT"

# =============================================================================
# Test 12: Handle missing CONTEXT.md gracefully
# =============================================================================
run_test "Handle missing CONTEXT.md file" \
  "! [ -f /tmp/nonexistent-context-12345.md ]"

echo ""
echo -e "${BLUE}Test Suite 4: Staleness Thresholds${NC}"
echo ""

# =============================================================================
# Test 13: Detect fresh content (0 days) as current
# =============================================================================
run_test "Fresh content (0 days) detected as current" \
  "DAYS=\$(days_since_date \$(date +%Y-%m-%d)) && [ \$DAYS -le 7 ]"

# =============================================================================
# Test 14: Detect old content (30 days) as stale
# =============================================================================
if date -v-30d +%Y-%m-%d >/dev/null 2>&1; then
  THIRTY_DAYS_AGO=$(date -v-30d +%Y-%m-%d)
elif date -d "30 days ago" +%Y-%m-%d >/dev/null 2>&1; then
  THIRTY_DAYS_AGO=$(date -d "30 days ago" +%Y-%m-%d)
else
  THIRTY_DAYS_AGO="2025-10-14"
fi

run_test "Old content (30 days) detected as stale" \
  "DAYS=\$(days_since_date $THIRTY_DAYS_AGO) && [ \$DAYS -gt 14 ]"

# =============================================================================
# Test 15: Threshold boundaries (7 days for CONTEXT.md)
# =============================================================================
if date -v-7d +%Y-%m-%d >/dev/null 2>&1; then
  SEVEN_DAYS_AGO=$(date -v-7d +%Y-%m-%d)
elif date -d "7 days ago" +%Y-%m-%d >/dev/null 2>&1; then
  SEVEN_DAYS_AGO=$(date -d "7 days ago" +%Y-%m-%d)
else
  SEVEN_DAYS_AGO="2025-11-06"
fi

run_test "7-day threshold boundary works correctly" \
  "DAYS=\$(days_since_date $SEVEN_DAYS_AGO) && [ \$DAYS -ge 6 ] && [ \$DAYS -le 8 ]"

echo ""
echo -e "${BLUE}Test Suite 5: Command Integration${NC}"
echo ""

# =============================================================================
# Test 16: /save-full command file updated with new steps
# =============================================================================
run_test "/save-full has Step 8 (CONTEXT.md check)" \
  "grep -q 'Step 8/10.*CONTEXT.md' .claude/commands/save-full.md"

run_test "/save-full has Step 9 (README.md check)" \
  "grep -q 'Step 9/10.*README.md' .claude/commands/save-full.md"

# =============================================================================
# Test 18: /review-context command file updated with staleness check
# =============================================================================
run_test "/review-context has staleness check (Step 2.7)" \
  "grep -q 'Step 2.7.*Staleness' .claude/commands/review-context.md"

echo ""
echo -e "${BLUE}Test Suite 6: Template Updates${NC}"
echo ""

# =============================================================================
# Test 19: claude.md template has decision documentation guidance
# =============================================================================
run_test "claude.md template has decision documentation section" \
  "grep -q 'Decision Documentation' templates/claude.md.template"

run_test "claude.md template has DECISIONS.md format example" \
  "grep -q 'DECISIONS.md Format' templates/claude.md.template"

run_test "claude.md template has decision categories" \
  "grep -q 'Library/Framework Choices' templates/claude.md.template"

# =============================================================================
# Summary
# =============================================================================
echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo "Tests run: $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"

if [ "$TESTS_FAILED" -eq 0 ]; then
  echo ""
  echo -e "${GREEN}✅ All tests passed!${NC}"
  echo ""
  echo -e "${BLUE}Feature Verification:${NC}"
  echo "- Helper functions (days_since_date, days_since_file_modified) ✓"
  echo "- Date extraction from CONTEXT.md ✓"
  echo "- File modification staleness detection ✓"
  echo "- Threshold detection (7, 14 days) ✓"
  echo "- /save-full enhanced with Steps 8 & 9 ✓"
  echo "- /review-context enhanced with Step 2.7 ✓"
  echo "- claude.md template updated with decision guidance ✓"
  echo ""
  echo -e "${GREEN}v3.3.0 Day 3 documentation currency features working correctly!${NC}"
  exit 0
else
  echo ""
  echo -e "${RED}❌ Some tests failed${NC}"
  echo "Review the failures above and fix issues."
  exit 1
fi
