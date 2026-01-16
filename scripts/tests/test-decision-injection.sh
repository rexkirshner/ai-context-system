#!/bin/bash
# Test decision injection for code review agents
# Phase 4.1 of v5.1.0 implementation
#
# Test cases:
# 1. No DECISIONS.md → returns empty block indicator
# 2. Empty DECISIONS.md → returns empty decisions table
# 3. Valid DECISIONS.md → returns formatted decisions table
# 4. Malformed DECISIONS.md → graceful handling with warning
# 5. Decision keywords are extracted correctly
# 6. Multiple decisions format correctly

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Source common functions
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Test fixtures directory
FIXTURES_DIR="$PROJECT_ROOT/test/fixtures"

# =============================================================================
# Test 1: No DECISIONS.md file
# =============================================================================
test_no_decisions_file() {
  echo "Test 1: No DECISIONS.md should return empty indicator"

  local result
  result=$(format_decisions_for_agents "/nonexistent/path/DECISIONS.md")

  # Should return empty indicator
  assert_equal "$result" "" "Missing file should return empty string"
}

# =============================================================================
# Test 2: Empty DECISIONS.md file
# =============================================================================
test_empty_decisions_file() {
  echo ""
  echo "Test 2: Empty DECISIONS.md should return empty table header"

  local result
  result=$(format_decisions_for_agents "$FIXTURES_DIR/decisions/empty.md")

  # Should return table structure with no rows
  assert_contains "$result" "Known Project Decisions" "Should contain section header"
  assert_contains "$result" "No decisions documented" "Should indicate no decisions"
}

# =============================================================================
# Test 3: Valid DECISIONS.md with single decision
# =============================================================================
test_single_decision() {
  echo ""
  echo "Test 3: Single decision should format as table row"

  local result
  result=$(format_decisions_for_agents "$FIXTURES_DIR/decisions/single.md")

  # Should contain table header
  assert_contains "$result" "Known Project Decisions" "Should contain section header"
  assert_contains "$result" "| ID | Decision | Keywords |" "Should contain table header"

  # Should contain the decision
  assert_contains "$result" "D001" "Should contain decision ID"
}

# =============================================================================
# Test 4: Valid DECISIONS.md with multiple decisions
# =============================================================================
test_multiple_decisions() {
  echo ""
  echo "Test 4: Multiple decisions should all appear in table"

  local result
  result=$(format_decisions_for_agents "$FIXTURES_DIR/decisions/multiple.md")

  # Should contain all decision IDs
  assert_contains "$result" "D001" "Should contain first decision ID"
  assert_contains "$result" "D002" "Should contain second decision ID"
  assert_contains "$result" "D003" "Should contain third decision ID"
}

# =============================================================================
# Test 5: Malformed DECISIONS.md
# =============================================================================
test_malformed_decisions() {
  echo ""
  echo "Test 5: Malformed DECISIONS.md should handle gracefully"

  local result
  result=$(format_decisions_for_agents "$FIXTURES_DIR/decisions/malformed.md")

  # Should still return valid output (may be empty or partial)
  # Key is it shouldn't crash
  assert_not_equal "$?" "1" "Should not error on malformed file"

  # Should contain header even if no valid decisions found
  assert_contains "$result" "Known Project Decisions" "Should contain section header"
}

# =============================================================================
# Test 6: Keywords are extracted from decision content
# =============================================================================
test_keyword_extraction() {
  echo ""
  echo "Test 6: Keywords should be extracted from decision content"

  local result
  result=$(format_decisions_for_agents "$FIXTURES_DIR/decisions/single.md")

  # Keywords column should have content (not empty)
  # The single.md fixture has decision about "No test framework"
  # We expect keywords like "test", "testing", "framework" etc.
  local keywords_present
  keywords_present=$(echo "$result" | grep -c "|.*|.*|")
  assert_greater_than "$keywords_present" "0" "Table should have keyword columns"
}

# =============================================================================
# Test 7: Special characters in decisions are handled
# =============================================================================
test_special_characters() {
  echo ""
  echo "Test 7: Special characters in decisions should be handled"

  local result
  result=$(format_decisions_for_agents "$FIXTURES_DIR/decisions/special-chars.md")

  # Should not crash on special characters
  assert_contains "$result" "Known Project Decisions" "Should contain section header"
}

# =============================================================================
# Test 8: Output format matches agent input requirements
# =============================================================================
test_output_format() {
  echo ""
  echo "Test 8: Output should match agent input format"

  local result
  result=$(format_decisions_for_agents "$FIXTURES_DIR/decisions/multiple.md")

  # Should have markdown section header
  assert_contains "$result" "## Known Project Decisions" "Should have markdown h2"

  # Should have explanation text
  assert_contains "$result" "documented in DECISIONS.md" "Should explain purpose"
  assert_contains "$result" "intentional" "Should mention intentional decisions"

  # Should have properly formatted markdown table
  assert_contains "$result" "| ID | Decision | Keywords |" "Should have table header"
  assert_contains "$result" "|----|----------|----------|" "Should have table separator"
}

# =============================================================================
# Test 9: get_decision_keywords extracts correct keywords
# =============================================================================
test_get_decision_keywords() {
  echo ""
  echo "Test 9: get_decision_keywords should extract meaningful keywords"

  local text="No test framework - This project uses manual testing only"
  local keywords
  keywords=$(get_decision_keywords "$text")

  # Should contain relevant keywords (lowercase, no stopwords)
  assert_contains "$keywords" "test" "Should contain 'test'"
  assert_contains "$keywords" "manual" "Should contain 'manual'"
  assert_contains "$keywords" "project" "Should contain 'project'"

  # Should not contain stopwords
  assert_not_contains "$keywords" " a " "Should not contain stopword 'a'"
  assert_not_contains "$keywords" " the " "Should not contain stopword 'the'"
}

# =============================================================================
# Test 10: Empty decision content handled
# =============================================================================
test_empty_decision_content() {
  echo ""
  echo "Test 10: Decisions with empty content should still format"

  # Create a temp file with a decision that has empty content
  local temp_file
  temp_file=$(mktemp)
  cat > "$temp_file" << 'EOF'
# Decisions

## D001 - Empty Content Decision

EOF

  local result
  result=$(format_decisions_for_agents "$temp_file")

  # Should contain the decision ID
  assert_contains "$result" "D001" "Should contain decision ID even with empty content"

  rm -f "$temp_file"
}

# =============================================================================
# Test 11: Verify table row count matches decision count
# =============================================================================
test_row_count_matches_decisions() {
  echo ""
  echo "Test 11: Table row count should match decision count"

  local result
  result=$(format_decisions_for_agents "$FIXTURES_DIR/decisions/multiple.md")

  # multiple.md has 3 decisions, so should have 3 data rows
  # Count lines that start with "| D" (decision rows)
  local row_count
  row_count=$(echo "$result" | grep -c "^| D[0-9]")

  assert_equal "$row_count" "3" "Should have 3 decision rows for 3 decisions"
}

# =============================================================================
# Test 12: load_decisions_context returns full context block
# =============================================================================
test_load_decisions_context() {
  echo ""
  echo "Test 12: load_decisions_context should return complete context block"

  local result
  result=$(load_decisions_context "$FIXTURES_DIR/decisions/multiple.md")

  # Should include separator lines (use pattern that grep won't interpret as flags)
  local has_separator
  has_separator=$(echo "$result" | grep -c "^---$" || true)
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ "$has_separator" -ge "1" ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} Should have markdown separators"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} Should have markdown separators"
  fi

  # Should include both the header and table
  assert_contains "$result" "## Known Project Decisions" "Should have section header"
  assert_contains "$result" "| ID | Decision | Keywords |" "Should have table"
}

# =============================================================================
# Test 13: load_decisions_context with missing file returns empty
# =============================================================================
test_load_decisions_context_missing_file() {
  echo ""
  echo "Test 13: load_decisions_context with missing file returns empty"

  local result
  result=$(load_decisions_context "/nonexistent/DECISIONS.md")

  # Should return empty string for missing file
  assert_equal "$result" "" "Missing file should return empty context"
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 4.1: Decision Injection Tests                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_no_decisions_file
test_empty_decisions_file
test_single_decision
test_multiple_decisions
test_malformed_decisions
test_keyword_extraction
test_special_characters
test_output_format
test_get_decision_keywords
test_empty_decision_content
test_row_count_matches_decisions
test_load_decisions_context
test_load_decisions_context_missing_file

print_test_summary
