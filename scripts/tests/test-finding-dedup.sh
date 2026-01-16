#!/bin/bash
# Test finding deduplication functions from common-functions.sh
# Phase 0.3 of v5.1.0 implementation
#
# Test cases:
# 1. Location dedup: Identical file:line merged
# 2. Location dedup: Highest severity wins
# 3. Location dedup: detectedBy array created
# 4. Location dedup: mergedFrom array preserves original IDs
# 5. Pattern grouping: 3+ similar findings creates GROUP entry
# 6. Pattern grouping: <3 similar findings not grouped
# 7. Integration: Full pipeline reduces finding count

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Source common functions
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Test fixtures directory
FIXTURES_DIR="$PROJECT_ROOT/test/fixtures/findings"

# =============================================================================
# Test 1: Location dedup merges findings at same file:line
# =============================================================================
test_location_dedup_merges() {
  echo "Test 1: Findings at same file:line should be merged"

  local result
  result=$(cat "$FIXTURES_DIR/raw-sample.json" | dedupe_by_location)

  # Validate JSON
  echo "$result" | jq . > /dev/null 2>&1
  assert_equal "$?" "0" "Output should be valid JSON"

  # Original has 15 findings, with overlaps at:
  # - PhotoGallery:363 (3 findings → 1)
  # - validation.ts:1 (2 findings → 1)
  # - Header.astro:15 (2 findings → 1)
  # After dedup: 15 - 2 - 1 - 1 = 11
  local count
  count=$(echo "$result" | jq 'length')
  assert_equal "$count" "11" "Should have 11 findings after location-based dedup"
}

# =============================================================================
# Test 2: Location dedup - highest severity wins
# =============================================================================
test_location_dedup_severity() {
  echo ""
  echo "Test 2: Merged findings should have highest severity"

  local result
  result=$(cat "$FIXTURES_DIR/raw-sample.json" | dedupe_by_location)

  # PhotoGallery:363 has HIGH, MEDIUM, LOW → should become high (lowercase)
  local merged_severity
  merged_severity=$(echo "$result" | jq -r '.[] | select(.location.file == "src/components/PhotoGallery.astro" and .location.line == 363) | .severity')
  assert_equal "$merged_severity" "high" "Merged finding should have high severity (highest of high, medium, low)"
}

# =============================================================================
# Test 3: Location dedup creates detectedBy array
# =============================================================================
test_location_dedup_detected_by() {
  echo ""
  echo "Test 3: Merged findings should have detectedBy array"

  local result
  result=$(cat "$FIXTURES_DIR/raw-sample.json" | dedupe_by_location)

  # PhotoGallery:363 was detected by SEC, A11Y, PERF
  local detected_by
  detected_by=$(echo "$result" | jq -r '.[] | select(.location.file == "src/components/PhotoGallery.astro" and .location.line == 363) | .detectedBy | sort | join(",")')
  assert_equal "$detected_by" "A11Y,PERF,SEC" "detectedBy should contain SEC, A11Y, PERF"
}

# =============================================================================
# Test 4: Location dedup preserves mergedFrom array
# =============================================================================
test_location_dedup_merged_from() {
  echo ""
  echo "Test 4: Merged findings should have mergedFrom array with original IDs"

  local result
  result=$(cat "$FIXTURES_DIR/raw-sample.json" | dedupe_by_location)

  # PhotoGallery:363 was SEC-001, A11Y-012, PERF-007
  local merged_from
  merged_from=$(echo "$result" | jq -r '.[] | select(.location.file == "src/components/PhotoGallery.astro" and .location.line == 363) | .mergedFrom | sort | join(",")')
  assert_contains "$merged_from" "SEC-001" "mergedFrom should contain SEC-001"
  assert_contains "$merged_from" "A11Y-012" "mergedFrom should contain A11Y-012"
  assert_contains "$merged_from" "PERF-007" "mergedFrom should contain PERF-007"
}

# =============================================================================
# Test 5: Location dedup appends -MERGED to ID
# =============================================================================
test_location_dedup_merged_id() {
  echo ""
  echo "Test 5: Merged findings should have -MERGED suffix on ID"

  local result
  result=$(cat "$FIXTURES_DIR/raw-sample.json" | dedupe_by_location)

  # Find the merged finding and check its ID ends with -MERGED
  local merged_id
  merged_id=$(echo "$result" | jq -r '.[] | select(.location.file == "src/components/PhotoGallery.astro" and .location.line == 363) | .id')

  # Check that the ID ends with "-MERGED" using bash pattern matching
  local has_suffix="no"
  if [[ "$merged_id" == *-MERGED ]]; then
    has_suffix="yes"
  fi
  assert_equal "$has_suffix" "yes" "Merged finding ID should end with -MERGED suffix (got: $merged_id)"
}

# =============================================================================
# Test 6: Pattern grouping creates GROUP entry for 3+ similar findings
# =============================================================================
test_pattern_grouping_creates_group() {
  echo ""
  echo "Test 6: 3+ similar findings should create GROUP entry"

  local result
  result=$(cat "$FIXTURES_DIR/raw-sample.json" | group_similar_findings 3)

  # Validate JSON
  echo "$result" | jq . > /dev/null 2>&1
  assert_equal "$?" "0" "Output should be valid JSON"

  # Should have GROUP entries for "Missing tests" (4 findings) and "Missing alt text" (3 findings)
  local group_count
  group_count=$(echo "$result" | jq '[.[] | select(.type == "group")] | length')

  # Should have at least 1 group entry
  local has_groups
  has_groups=$(echo "$group_count" | awk '{print ($1 >= 1) ? "yes" : "no"}')
  assert_equal "$has_groups" "yes" "Should have at least 1 GROUP entry"
}

# =============================================================================
# Test 7: Pattern grouping includes memberIds array
# =============================================================================
test_pattern_grouping_member_ids() {
  echo ""
  echo "Test 7: GROUP entry should include memberIds array"

  local result
  result=$(cat "$FIXTURES_DIR/raw-sample.json" | group_similar_findings 3)

  # Get a group entry and check for memberIds
  local has_member_ids
  has_member_ids=$(echo "$result" | jq '[.[] | select(.type == "group") | .memberIds | length > 0] | any')
  assert_equal "$has_member_ids" "true" "GROUP entries should have memberIds array"
}

# =============================================================================
# Test 8: Pattern grouping does not group <3 similar findings
# =============================================================================
test_pattern_grouping_threshold() {
  echo ""
  echo "Test 8: <3 similar findings should not create GROUP"

  # Test with threshold of 10 - should create no groups since no pattern has 10+ findings
  local result
  result=$(cat "$FIXTURES_DIR/raw-sample.json" | group_similar_findings 10)

  local group_count
  group_count=$(echo "$result" | jq '[.[] | select(.type == "group")] | length')
  assert_equal "$group_count" "0" "Should have no GROUP entries with threshold 10"
}

# =============================================================================
# Test 9: Single finding is not modified
# =============================================================================
test_single_finding_unchanged() {
  echo ""
  echo "Test 9: Single finding at unique location should not be modified"

  local result
  result=$(cat "$FIXTURES_DIR/raw-sample.json" | dedupe_by_location)

  # SEC-002 (hardcoded API key) is at unique location, should be unchanged
  local sec_002
  sec_002=$(echo "$result" | jq '.[] | select(.id == "SEC-002")')

  local id
  id=$(echo "$sec_002" | jq -r '.id')
  assert_equal "$id" "SEC-002" "Single finding should retain original ID"

  # Should not have mergedFrom array
  local has_merged_from
  has_merged_from=$(echo "$sec_002" | jq 'has("mergedFrom")')
  assert_equal "$has_merged_from" "false" "Single finding should not have mergedFrom array"
}

# =============================================================================
# Test 10: Full pipeline integration
# =============================================================================
test_full_pipeline() {
  echo ""
  echo "Test 10: Full dedup pipeline should reduce finding count"

  local original_count
  original_count=$(cat "$FIXTURES_DIR/raw-sample.json" | jq 'length')

  # Run full pipeline
  local result
  result=$(cat "$FIXTURES_DIR/raw-sample.json" | dedupe_by_location | group_similar_findings 3)

  # Count non-group findings
  local final_count
  final_count=$(echo "$result" | jq '[.[] | select(.type != "group")] | length')

  # Verify reduction (original 15, after location dedup 12)
  local reduced
  reduced=$(awk -v orig="$original_count" -v final="$final_count" 'BEGIN { print (final < orig) ? "yes" : "no" }')
  assert_equal "$reduced" "yes" "Pipeline should reduce finding count"
}

# =============================================================================
# Test 11: Empty input returns empty array
# =============================================================================
test_empty_input() {
  echo ""
  echo "Test 11: Empty input should return empty array"

  local result
  result=$(echo "[]" | dedupe_by_location)
  assert_equal "$result" "[]" "Empty input should return empty array"

  result=$(echo "[]" | group_similar_findings)
  assert_equal "$result" "[]" "Empty input to group_similar_findings should return empty array"
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 0.3: Finding Deduplication Tests                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_location_dedup_merges
test_location_dedup_severity
test_location_dedup_detected_by
test_location_dedup_merged_from
test_location_dedup_merged_id
test_pattern_grouping_creates_group
test_pattern_grouping_member_ids
test_pattern_grouping_threshold
test_single_finding_unchanged
test_full_pipeline
test_empty_input

print_test_summary
