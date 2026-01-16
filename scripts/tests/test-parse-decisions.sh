#!/bin/bash
# Test parse_decisions() function from common-functions.sh
# Phase 0.1 of v5.1.0 implementation
#
# Test cases:
# 1. Empty file → returns []
# 2. Single decision → returns array with 1 element
# 3. Multiple decisions → returns array with correct count
# 4. Malformed headers → skips gracefully
# 5. Special characters in content → properly escaped

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Source common functions (contains parse_decisions)
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Test fixtures directory
FIXTURES_DIR="$PROJECT_ROOT/test/fixtures/decisions"

# =============================================================================
# Test 1: Empty file returns empty array
# =============================================================================
test_empty_file() {
  echo "Test 1: Empty DECISIONS.md should return empty JSON array"

  local result
  result=$(parse_decisions "$FIXTURES_DIR/empty.md")

  # Should be valid JSON
  echo "$result" | jq . > /dev/null 2>&1
  assert_equal "$?" "0" "Output should be valid JSON"

  # Should be empty array
  local count
  count=$(echo "$result" | jq 'length')
  assert_equal "$count" "0" "Empty file should return array with 0 elements"
}

# =============================================================================
# Test 2: Single decision returns array with 1 element
# =============================================================================
test_single_decision() {
  echo ""
  echo "Test 2: Single decision should return array with 1 element"

  local result
  result=$(parse_decisions "$FIXTURES_DIR/single.md")

  # Should be valid JSON
  echo "$result" | jq . > /dev/null 2>&1
  assert_equal "$?" "0" "Output should be valid JSON"

  # Should have 1 element
  local count
  count=$(echo "$result" | jq 'length')
  assert_equal "$count" "1" "Single decision file should return 1 element"

  # Check the decision ID
  local id
  id=$(echo "$result" | jq -r '.[0].id')
  assert_equal "$id" "D001" "First decision should have ID D001"

  # Check the title
  local title
  title=$(echo "$result" | jq -r '.[0].title')
  assert_contains "$title" "No Test Framework" "Title should contain 'No Test Framework'"
}

# =============================================================================
# Test 3: Multiple decisions returns correct count
# =============================================================================
test_multiple_decisions() {
  echo ""
  echo "Test 3: Multiple decisions should return correct count"

  local result
  result=$(parse_decisions "$FIXTURES_DIR/multiple.md")

  # Should be valid JSON
  echo "$result" | jq . > /dev/null 2>&1
  assert_equal "$?" "0" "Output should be valid JSON"

  # Should have 3 elements
  local count
  count=$(echo "$result" | jq 'length')
  assert_equal "$count" "3" "Multiple decisions file should return 3 elements"

  # Check all IDs are present
  local ids
  ids=$(echo "$result" | jq -r '.[].id' | sort | tr '\n' ' ')
  assert_contains "$ids" "D001" "Should contain D001"
  assert_contains "$ids" "D002" "Should contain D002"
  assert_contains "$ids" "D003" "Should contain D003"
}

# =============================================================================
# Test 4: Malformed headers are skipped gracefully
# =============================================================================
test_malformed_headers() {
  echo ""
  echo "Test 4: Malformed headers should be skipped gracefully"

  local result
  result=$(parse_decisions "$FIXTURES_DIR/malformed.md")

  # Should be valid JSON (not crash)
  echo "$result" | jq . > /dev/null 2>&1
  assert_equal "$?" "0" "Output should be valid JSON even with malformed input"

  # Should only have 1 valid decision (D001)
  local count
  count=$(echo "$result" | jq 'length')
  assert_equal "$count" "1" "Should only find 1 valid decision, skipping malformed headers"

  # The valid decision should be D001
  local id
  id=$(echo "$result" | jq -r '.[0].id')
  assert_equal "$id" "D001" "Valid decision should be D001"
}

# =============================================================================
# Test 5: Special characters are properly escaped
# =============================================================================
test_special_characters() {
  echo ""
  echo "Test 5: Special characters should be properly escaped in JSON"

  local result
  result=$(parse_decisions "$FIXTURES_DIR/special-chars.md")

  # Should be valid JSON (this is the key test - invalid escaping breaks JSON)
  echo "$result" | jq . > /dev/null 2>&1
  assert_equal "$?" "0" "Output should be valid JSON with special characters"

  # Should have 1 element
  local count
  count=$(echo "$result" | jq 'length')
  assert_equal "$count" "1" "Should parse decision with special characters"

  # Content should be preserved (check for quotes mention - lowercase in content)
  local content
  content=$(echo "$result" | jq -r '.[0].content')
  assert_contains "$content" "quotes" "Content should preserve text about quotes"

  # Title should be preserved with special chars
  local title
  title=$(echo "$result" | jq -r '.[0].title')
  assert_contains "$title" "Quotes" "Title should preserve text with quotes"
}

# =============================================================================
# Test 6: Non-existent file returns empty array (graceful)
# =============================================================================
test_nonexistent_file() {
  echo ""
  echo "Test 6: Non-existent file should return empty array"

  local result
  result=$(parse_decisions "/nonexistent/path/DECISIONS.md")

  # Should be valid JSON
  echo "$result" | jq . > /dev/null 2>&1
  assert_equal "$?" "0" "Output should be valid JSON for non-existent file"

  # Should be empty array
  local count
  count=$(echo "$result" | jq 'length')
  assert_equal "$count" "0" "Non-existent file should return empty array"
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 0.1: parse_decisions() Function Tests               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_empty_file
test_single_decision
test_multiple_decisions
test_malformed_headers
test_special_characters
test_nonexistent_file

print_test_summary
