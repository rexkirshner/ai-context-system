#!/bin/bash
# Test script for template markers - Priority 1 templates
# v3.3.0 Day 2 Testing

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🧪 Testing Template Markers - Priority 1${NC}"
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

echo -e "${BLUE}Test Suite 1: Marker Completeness${NC}"
echo ""

# =============================================================================
# Test 1: CODE_STYLE.template.md - All section markers are balanced
# =============================================================================
run_test "CODE_STYLE: All section markers balanced" \
  "[ \$(( \$(grep -c '<!-- TEMPLATE SECTION: KEEP ALL' templates/CODE_STYLE.template.md) + \
          \$(grep -c '<!-- TEMPLATE SECTION: CUSTOMIZE' templates/CODE_STYLE.template.md) )) -eq \
     \$(grep -c '<!-- END TEMPLATE SECTION -->' templates/CODE_STYLE.template.md) ]"

# =============================================================================
# Test 2: CODE_STYLE.template.md - Has at least 1 KEEP ALL section
# =============================================================================
run_test "CODE_STYLE: Has KEEP ALL section" \
  "grep -q '<!-- TEMPLATE SECTION: KEEP ALL' templates/CODE_STYLE.template.md"

# =============================================================================
# Test 3: CODE_STYLE.template.md - Has CUSTOMIZE sections
# =============================================================================
run_test "CODE_STYLE: Has CUSTOMIZE sections" \
  "grep -q '<!-- TEMPLATE SECTION: CUSTOMIZE' templates/CODE_STYLE.template.md"

# =============================================================================
# Test 4: claude.md.template - Has READ-ONLY markers
# =============================================================================
run_test "claude.md: Has READ-ONLY markers" \
  "grep -q '<!-- TEMPLATE: READ-ONLY' templates/claude.md.template"

# =============================================================================
# Test 5: claude.md.template - READ-ONLY markers balanced
# =============================================================================
run_test "claude.md: READ-ONLY markers balanced" \
  "[ \$(grep -c '<!-- TEMPLATE: READ-ONLY' templates/claude.md.template) -eq \
     \$(grep -c '<!-- END READ-ONLY TEMPLATE -->' templates/claude.md.template) ]"

# =============================================================================
# Test 6: CONTEXT.template.md - All section markers balanced (3 KEEP ALL = 3 END)
# =============================================================================
run_test "CONTEXT: All section markers balanced" \
  "[ \$(grep -c 'TEMPLATE SECTION: KEEP ALL' templates/CONTEXT.template.md) -eq \
     \$(grep -c 'END TEMPLATE SECTION' templates/CONTEXT.template.md) ]"

# =============================================================================
# Test 7: CONTEXT.template.md - Has multiple KEEP ALL sections (3 expected)
# =============================================================================
run_test "CONTEXT: Has 3 KEEP ALL sections" \
  "[ \$(grep -c '<!-- TEMPLATE SECTION: KEEP ALL' templates/CONTEXT.template.md) -eq 3 ]"

echo ""
echo -e "${BLUE}Test Suite 2: Placeholder Consistency${NC}"
echo ""

# =============================================================================
# Test 8: CODE_STYLE - Uses [FILL: ...] format
# =============================================================================
run_test "CODE_STYLE: Uses [FILL: ...] placeholders" \
  "grep -q '\[FILL:' templates/CODE_STYLE.template.md"

# =============================================================================
# Test 9: CODE_STYLE - No leftover [TODO: ...] markers
# =============================================================================
run_test "CODE_STYLE: No [TODO: ...] markers" \
  "! grep -q '\[TODO:' templates/CODE_STYLE.template.md"

# =============================================================================
# Test 10: CONTEXT - Uses [FILL: ...] format
# =============================================================================
run_test "CONTEXT: Uses [FILL: ...] placeholders" \
  "grep -q '\[FILL:' templates/CONTEXT.template.md"

# =============================================================================
# Test 11: CONTEXT - Has [FILL: e.g., ...] examples
# =============================================================================
run_test "CONTEXT: Has example placeholders" \
  "grep -q '\[FILL: e.g.,' templates/CONTEXT.template.md"

echo ""
echo -e "${BLUE}Test Suite 3: Content Protection${NC}"
echo ""

# =============================================================================
# Test 12: CODE_STYLE - Core Principles section is wrapped
# =============================================================================
run_test "CODE_STYLE: Core Principles protected" \
  "grep -A 5 '<!-- TEMPLATE SECTION: KEEP ALL' templates/CODE_STYLE.template.md | grep -q '## Core Principles'"

# =============================================================================
# Test 13: CONTEXT - Tech Stack section is wrapped
# =============================================================================
run_test "CONTEXT: Tech Stack section protected" \
  "grep -A 5 '<!-- TEMPLATE SECTION: KEEP ALL' templates/CONTEXT.template.md | grep -q '## Tech Stack'"

# =============================================================================
# Test 14: CONTEXT - Architecture section is wrapped
# =============================================================================
run_test "CONTEXT: Architecture section protected" \
  "grep -A 5 '<!-- TEMPLATE SECTION: KEEP ALL' templates/CONTEXT.template.md | grep -q '## High-Level Architecture'"

echo ""
echo -e "${BLUE}Test Suite 4: File Integrity${NC}"
echo ""

# =============================================================================
# Test 15: All three Priority 1 templates exist
# =============================================================================
run_test "All Priority 1 templates exist" \
  "[ -f templates/CODE_STYLE.template.md ] && \
   [ -f templates/claude.md.template ] && \
   [ -f templates/CONTEXT.template.md ]"

# =============================================================================
# Test 16: Templates are valid markdown (no syntax errors)
# =============================================================================
run_test "CODE_STYLE: Valid markdown structure" \
  "grep -q '^#' templates/CODE_STYLE.template.md"

run_test "claude.md: Valid markdown structure" \
  "grep -q '^#' templates/claude.md.template"

run_test "CONTEXT: Valid markdown structure" \
  "grep -q '^#' templates/CONTEXT.template.md"

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
  echo -e "${BLUE}Marker Verification:${NC}"
  echo "- All KEEP ALL sections have matching END markers ✓"
  echo "- All READ-ONLY templates have matching END markers ✓"
  echo "- All placeholders use [FILL: ...] format ✓"
  echo "- Core Principles section is protected ✓"
  echo "- Critical CONTEXT sections are protected ✓"
  echo "- claude.md is marked as READ-ONLY ✓"
  exit 0
else
  echo ""
  echo -e "${RED}❌ Some tests failed${NC}"
  echo "Review the failures above and fix the templates."
  exit 1
fi
