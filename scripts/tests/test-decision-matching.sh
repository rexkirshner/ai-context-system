#!/bin/bash
# Test decision matching functions from common-functions.sh
# Phase 0.2 of v5.1.0 implementation
#
# Test cases:
# 1. Exact match → confidence 1.0
# 2. Partial match above threshold → matched:true
# 3. Partial match below threshold → matched:false
# 4. Semantic equivalents → treated as matches
# 5. No decisions → matched:false (graceful)
# 6. Empty finding → matched:false

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Source common functions
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Test fixtures directory
FIXTURES_DIR="$PROJECT_ROOT/test/fixtures/decisions"

# =============================================================================
# Test 1: Jaccard similarity with identical sets should return 1.0
# =============================================================================
test_jaccard_identical() {
  echo "Test 1: Identical keyword sets should have Jaccard similarity of 1.0"

  local result
  result=$(jaccard_similarity "test framework missing" "test framework missing")

  # Should be 1.00 (or very close)
  assert_equal "$result" "1.00" "Identical sets should have similarity 1.00"
}

# =============================================================================
# Test 2: Jaccard similarity with partial overlap
# =============================================================================
test_jaccard_partial() {
  echo ""
  echo "Test 2: Partial overlap should return value between 0 and 1"

  local result
  result=$(jaccard_similarity "no test framework" "test coverage missing")

  # "test" is common, so should be > 0 but < 1
  # Words after stopword removal: test, framework vs test, coverage, missing
  # ("no" is a stopword so it's removed)
  # Union: test, framework, coverage, missing (4 words)
  # Intersection: test (1 word)
  # Jaccard = 1/4 = 0.25
  assert_equal "$result" "0.25" "Partial overlap should give expected Jaccard value"
}

# =============================================================================
# Test 3: Jaccard similarity with no overlap
# =============================================================================
test_jaccard_no_overlap() {
  echo ""
  echo "Test 3: No overlap should return 0.00"

  local result
  result=$(jaccard_similarity "apple banana cherry" "dog elephant fox")

  assert_equal "$result" "0.00" "No overlap should have similarity 0.00"
}

# =============================================================================
# Test 4: Jaccard similarity ignores stopwords
# =============================================================================
test_jaccard_stopwords() {
  echo ""
  echo "Test 4: Stopwords should be ignored"

  # "the" and "a" and "is" are stopwords
  local result
  result=$(jaccard_similarity "the test is missing" "a test was found")

  # After removing stopwords: "test missing" vs "test found"
  # Union: test, missing, found (3)
  # Intersection: test (1)
  # Jaccard = 1/3 = 0.33
  assert_equal "$result" "0.33" "Stopwords should be filtered out"
}

# =============================================================================
# Test 5: Match finding to decisions - match found above threshold
# =============================================================================
test_match_above_threshold() {
  echo ""
  echo "Test 5: Finding matching a decision should return matched:true"

  # Use a finding that closely matches the decision content
  # Decision D001 is about "No Test Framework" and mentions "Skip test framework", "portfolio project"
  # Finding should use similar keywords to get above 0.40 threshold
  local result
  result=$(match_finding_to_decisions "Skip test framework - this is a portfolio project" "$FIXTURES_DIR/single.md")

  # Parse the result
  local matched
  matched=$(echo "$result" | jq -r '.matched')
  assert_equal "$matched" "true" "Should match decision about no tests"

  # Should reference D001
  local decision_id
  decision_id=$(echo "$result" | jq -r '.decision_id')
  assert_equal "$decision_id" "D001" "Should match D001 (No Test Framework)"
}

# =============================================================================
# Test 6: Match finding to decisions - no match below threshold
# =============================================================================
test_match_below_threshold() {
  echo ""
  echo "Test 6: Unrelated finding should not match"

  local result
  result=$(match_finding_to_decisions "Memory leak in database connection pool" "$FIXTURES_DIR/single.md")

  # Parse the result
  local matched
  matched=$(echo "$result" | jq -r '.matched')
  assert_equal "$matched" "false" "Unrelated finding should not match"
}

# =============================================================================
# Test 7: Match finding when no decisions file exists
# =============================================================================
test_match_no_decisions() {
  echo ""
  echo "Test 7: Non-existent decisions file should return matched:false"

  local result
  result=$(match_finding_to_decisions "Some finding text" "/nonexistent/DECISIONS.md")

  local matched
  matched=$(echo "$result" | jq -r '.matched')
  assert_equal "$matched" "false" "Should return matched:false for non-existent file"
}

# =============================================================================
# Test 8: Match finding with empty finding text
# =============================================================================
test_match_empty_finding() {
  echo ""
  echo "Test 8: Empty finding should return matched:false"

  local result
  result=$(match_finding_to_decisions "" "$FIXTURES_DIR/single.md")

  local matched
  matched=$(echo "$result" | jq -r '.matched')
  assert_equal "$matched" "false" "Empty finding should not match"
}

# =============================================================================
# Test 9: Match against multiple decisions returns best match
# =============================================================================
test_match_best_of_multiple() {
  echo ""
  echo "Test 9: Should return best match when multiple decisions exist"

  # Use multiple.md which has D001 (no tests), D002 (vanilla JS), D003 (static site)
  # D002 mentions "vanilla JavaScript", "simplicity", "no build step", "fundamentals"
  local result
  result=$(match_finding_to_decisions "Use vanilla JavaScript for simplicity, no build step needed" "$FIXTURES_DIR/multiple.md")

  local matched
  matched=$(echo "$result" | jq -r '.matched')
  assert_equal "$matched" "true" "Should find a match"

  # Should match D002 (vanilla JavaScript) better than others
  local decision_id
  decision_id=$(echo "$result" | jq -r '.decision_id')
  assert_equal "$decision_id" "D002" "Should match D002 (Use Vanilla JavaScript)"
}

# =============================================================================
# Test 10: Confidence value is returned
# =============================================================================
test_confidence_returned() {
  echo ""
  echo "Test 10: Match result should include confidence value"

  # Use finding with high similarity to ensure a match
  local result
  result=$(match_finding_to_decisions "Skip test framework for portfolio project" "$FIXTURES_DIR/single.md")

  # Check that confidence exists and is a number
  local confidence
  confidence=$(echo "$result" | jq -r '.confidence')

  # Confidence should be non-null
  assert_not_equal "$confidence" "null" "Confidence should be present"

  # Confidence should be > 0 for a match
  local is_positive
  is_positive=$(echo "$confidence" | awk '{print ($1 > 0) ? "yes" : "no"}')
  assert_equal "$is_positive" "yes" "Confidence should be positive for a match"
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 0.2: Decision Matching Algorithm Tests              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_jaccard_identical
test_jaccard_partial
test_jaccard_no_overlap
test_jaccard_stopwords
test_match_above_threshold
test_match_below_threshold
test_match_no_decisions
test_match_empty_finding
test_match_best_of_multiple
test_confidence_returned

print_test_summary
