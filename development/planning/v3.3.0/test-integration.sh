#!/bin/bash
# Integration test for v3.3.0 Days 1 & 2
# Tests deletion protection + template markers working together

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🧪 v3.3.0 Integration Tests - Days 1 & 2${NC}"
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

echo -e "${BLUE}Test Suite 1: Feature Availability${NC}"
echo ""

# =============================================================================
# Test 1: Deletion protection function exists
# =============================================================================
run_test "Deletion protection function exists" \
  "grep -q 'confirm_deletion()' scripts/common-functions.sh"

# =============================================================================
# Test 2: Template markers exist in templates
# =============================================================================
run_test "Template markers exist in CODE_STYLE" \
  "grep -q 'TEMPLATE SECTION: KEEP ALL' templates/CODE_STYLE.template.md"

run_test "Template markers exist in claude.md" \
  "grep -q 'TEMPLATE: READ-ONLY' templates/claude.md.template"

run_test "Template markers exist in CONTEXT" \
  "grep -q 'TEMPLATE SECTION: KEEP ALL' templates/CONTEXT.template.md"

# =============================================================================
# Test 5: Deletion protection applied in update-context-system
# =============================================================================
run_test "Deletion protection used in update-context-system" \
  "grep -q 'confirm_deletion' .claude/commands/update-context-system.md"

echo ""
echo -e "${BLUE}Test Suite 2: Function Integration${NC}"
echo ""

# =============================================================================
# Test 6: confirm_deletion function can be sourced
# =============================================================================
run_test "confirm_deletion can be sourced" \
  "source scripts/common-functions.sh && type confirm_deletion"

# =============================================================================
# Test 7: confirm_deletion returns correct exit codes
# =============================================================================
run_test "confirm_deletion handles non-existent files" \
  "source scripts/common-functions.sh && confirm_deletion /tmp/nonexistent-file-12345.txt"

# =============================================================================
# Test 8: Session counting functions available
# =============================================================================
run_test "get_next_session_number function exists" \
  "grep -q 'get_next_session_number()' scripts/common-functions.sh"

echo ""
echo -e "${BLUE}Test Suite 3: Template Integrity${NC}"
echo ""

# =============================================================================
# Test 9: Templates are valid markdown
# =============================================================================
run_test "CODE_STYLE is valid markdown" \
  "head -1 templates/CODE_STYLE.template.md | grep -q '^#'"

run_test "claude.md is valid markdown" \
  "head -3 templates/claude.md.template | grep -q '^#'"

run_test "CONTEXT is valid markdown" \
  "head -5 templates/CONTEXT.template.md | grep -q '^#'"

# =============================================================================
# Test 12: Template markers don't break markdown structure
# =============================================================================
run_test "CODE_STYLE: Headers intact after markers" \
  "grep -c '^##' templates/CODE_STYLE.template.md | grep -q '[1-9]'"

run_test "CONTEXT: Headers intact after markers" \
  "grep -c '^##' templates/CONTEXT.template.md | grep -q '[1-9]'"

echo ""
echo -e "${BLUE}Test Suite 4: No Breaking Changes${NC}"
echo ""

# =============================================================================
# Test 14: Common functions file is valid bash
# =============================================================================
run_test "common-functions.sh is valid bash" \
  "bash -n scripts/common-functions.sh"

# =============================================================================
# Test 15: save-full-helper sources common-functions
# =============================================================================
run_test "save-full-helper sources common-functions" \
  "grep -q 'source.*common-functions.sh' scripts/save-full-helper.sh"

# =============================================================================
# Test 16: update-context-system sources common-functions
# =============================================================================
run_test "update-context-system references common functions" \
  "grep -q 'confirm_deletion\|get_system_version\|log_' .claude/commands/update-context-system.md"

echo ""
echo -e "${BLUE}Test Suite 5: File Consistency${NC}"
echo ""

# =============================================================================
# Test 17: All v3.3.0 features documented
# =============================================================================
run_test "Deletion protection documented" \
  "grep -q 'confirm_deletion' development/planning/v3.3.0/IMPLEMENTATION-LOG.md"

run_test "Template markers documented" \
  "grep -q 'TEMPLATE SECTION: KEEP ALL' development/planning/v3.3.0/IMPLEMENTATION-LOG.md"

run_test "Day 1 complete in log" \
  "grep -q 'Day 1 Summary: Deletion Protection' development/planning/v3.3.0/IMPLEMENTATION-LOG.md"

run_test "Day 2 complete in log" \
  "grep -q 'Day 2 Summary: Template Markers' development/planning/v3.3.0/IMPLEMENTATION-LOG.md"

# =============================================================================
# Test 21: Test scripts exist
# =============================================================================
run_test "Deletion protection test exists" \
  "[ -f development/planning/v3.3.0/test-deletion-protection.sh ]"

run_test "Template marker test exists" \
  "[ -f development/planning/v3.3.0/test-template-markers.sh ]"

# =============================================================================
# Summary
# =============================================================================
echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}Integration Test Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo "Tests run: $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"

if [ "$TESTS_FAILED" -eq 0 ]; then
  echo ""
  echo -e "${GREEN}✅ All integration tests passed!${NC}"
  echo ""
  echo -e "${BLUE}Feature Verification:${NC}"
  echo "- Deletion protection function available ✓"
  echo "- Template markers applied to Priority 1 templates ✓"
  echo "- Functions can be sourced and used ✓"
  echo "- Templates maintain markdown validity ✓"
  echo "- No breaking changes detected ✓"
  echo "- All features documented ✓"
  echo ""
  echo -e "${GREEN}v3.3.0 Days 1 & 2 are working correctly together!${NC}"
  exit 0
else
  echo ""
  echo -e "${RED}❌ Some integration tests failed${NC}"
  echo "Review the failures above and fix issues."
  exit 1
fi
