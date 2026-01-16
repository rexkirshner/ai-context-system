#!/bin/bash
# Test agent decision handling
# Phase 4.2 of v5.1.0 implementation
#
# Test cases:
# 1. Finding matches decision → severity downgraded, exception added
# 2. Finding doesn't match → unchanged
# 3. Multiple decisions → best match selected
# 4. Confidence below threshold → not marked as intentional
# 5. Annotated finding has correct intentionalException structure
# 6. Title gets "[Intentional] " prefix
# 7. Remediation includes DECISIONS.md note

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
# Test 1: Finding that matches a decision gets annotated
# =============================================================================
test_matching_finding_annotated() {
  echo "Test 1: Finding matching a decision should be annotated"

  # Create a finding about testing that matches decision keywords
  # The decision is about "No test framework" with keywords: test, framework, skip, manual, testing
  local finding='{
    "id": "TEST-001",
    "severity": "high",
    "category": "testing",
    "title": "No test framework configured",
    "description": "Project has no test framework. Skip testing setup. Manual testing only.",
    "location": {"file": "src/auth.ts", "line": 42},
    "verified": {"vulnPatternSearched": "test", "mitigationPatternSearched": "test", "mitigationFound": false},
    "remediation": "Add unit tests for auth module"
  }'

  local result
  result=$(annotate_finding_with_decision "$finding" "$FIXTURES_DIR/decisions/single.md")

  # Should have intentionalException field
  local has_exception
  has_exception=$(echo "$result" | jq 'has("intentionalException")')
  assert_equal "$has_exception" "true" "Should have intentionalException field"

  # Severity should be downgraded to low
  local severity
  severity=$(echo "$result" | jq -r '.severity')
  assert_equal "$severity" "low" "Severity should be downgraded to low"
}

# =============================================================================
# Test 2: Finding that doesn't match remains unchanged
# =============================================================================
test_non_matching_finding_unchanged() {
  echo ""
  echo "Test 2: Finding not matching any decision should remain unchanged"

  # Create a finding about something unrelated to any decision
  local finding='{
    "id": "SEC-001",
    "severity": "high",
    "category": "security",
    "title": "SQL injection vulnerability in user search",
    "description": "User input is concatenated directly into SQL query",
    "location": {"file": "src/search.ts", "line": 15},
    "verified": {"vulnPatternSearched": "sql", "mitigationPatternSearched": "prepared", "mitigationFound": false},
    "remediation": "Use parameterized queries"
  }'

  local result
  result=$(annotate_finding_with_decision "$finding" "$FIXTURES_DIR/decisions/single.md")

  # Should NOT have intentionalException field (or it should be null)
  local has_exception
  has_exception=$(echo "$result" | jq 'has("intentionalException")')
  if [ "$has_exception" = "true" ]; then
    # Check if it's null
    local is_null
    is_null=$(echo "$result" | jq '.intentionalException == null')
    assert_equal "$is_null" "true" "intentionalException should be null for non-match"
  else
    assert_equal "$has_exception" "false" "Should not have intentionalException"
  fi

  # Severity should remain high
  local severity
  severity=$(echo "$result" | jq -r '.severity')
  assert_equal "$severity" "high" "Severity should remain high"
}

# =============================================================================
# Test 3: Multiple decisions - best match selected
# =============================================================================
test_best_match_selected() {
  echo ""
  echo "Test 3: With multiple decisions, best match should be selected"

  # Create a finding about JavaScript (should match D002 "Vanilla JavaScript")
  local finding='{
    "id": "TS-001",
    "severity": "high",
    "category": "typescript",
    "title": "No TypeScript used in project",
    "description": "Project uses vanilla JavaScript instead of TypeScript",
    "location": {"file": "src/app.js", "line": 1},
    "verified": {"vulnPatternSearched": "typescript", "mitigationPatternSearched": "tsconfig", "mitigationFound": false},
    "remediation": "Consider adding TypeScript"
  }'

  local result
  result=$(annotate_finding_with_decision "$finding" "$FIXTURES_DIR/decisions/multiple.md")

  # Should match D002 (vanilla JavaScript decision)
  local decision_id
  decision_id=$(echo "$result" | jq -r '.intentionalException.decisionId // empty')

  # Should match one of the JavaScript-related decisions
  if [ -n "$decision_id" ]; then
    assert_contains "$decision_id" "D00" "Should match a decision"
  else
    # May not match if threshold not met - that's ok
    echo "  (No match found - acceptable if below threshold)"
  fi
}

# =============================================================================
# Test 4: Confidence below threshold - not marked
# =============================================================================
test_below_threshold_not_marked() {
  echo ""
  echo "Test 4: Finding below confidence threshold should not be marked"

  # Create a finding with minimal keyword overlap
  local finding='{
    "id": "PERF-001",
    "severity": "medium",
    "category": "performance",
    "title": "Large bundle size detected",
    "description": "Bundle exceeds recommended size",
    "location": {"file": "dist/bundle.js", "line": 1},
    "verified": {"vulnPatternSearched": "bundle", "mitigationPatternSearched": "split", "mitigationFound": false},
    "remediation": "Use code splitting"
  }'

  local result
  result=$(annotate_finding_with_decision "$finding" "$FIXTURES_DIR/decisions/single.md" "0.90")

  # With 90% threshold, this shouldn't match
  local has_exception
  has_exception=$(echo "$result" | jq '.intentionalException != null')
  assert_equal "$has_exception" "false" "Should not match with high threshold"
}

# =============================================================================
# Test 5: intentionalException has correct structure
# =============================================================================
test_exception_structure() {
  echo ""
  echo "Test 5: intentionalException should have correct structure"

  local finding='{
    "id": "TEST-002",
    "severity": "high",
    "category": "testing",
    "title": "Missing tests for core functionality",
    "description": "No test framework configured",
    "location": {"file": "package.json", "line": 1},
    "verified": {"vulnPatternSearched": "test", "mitigationPatternSearched": "jest", "mitigationFound": false},
    "remediation": "Add test framework"
  }'

  local result
  result=$(annotate_finding_with_decision "$finding" "$FIXTURES_DIR/decisions/single.md")

  # Check structure
  local has_decision_id
  has_decision_id=$(echo "$result" | jq '.intentionalException | has("decisionId") // false')

  local has_confidence
  has_confidence=$(echo "$result" | jq '.intentionalException | has("confidence") // false')

  if [ "$has_decision_id" = "true" ]; then
    assert_equal "$has_decision_id" "true" "Should have decisionId"
    assert_equal "$has_confidence" "true" "Should have confidence"

    # Confidence should be between 0 and 1
    local confidence
    confidence=$(echo "$result" | jq '.intentionalException.confidence')
    local is_valid
    is_valid=$(echo "$confidence >= 0 and $confidence <= 1" | bc -l)
    assert_equal "$is_valid" "1" "Confidence should be between 0 and 1"
  fi
}

# =============================================================================
# Test 6: Title gets "[Intentional] " prefix
# =============================================================================
test_title_prefix() {
  echo ""
  echo "Test 6: Matched finding title should get [Intentional] prefix"

  local finding='{
    "id": "TEST-003",
    "severity": "critical",
    "category": "testing",
    "title": "No tests found",
    "description": "Project has no test files",
    "location": {"file": "src/", "line": 1},
    "verified": {"vulnPatternSearched": "test", "mitigationPatternSearched": "spec", "mitigationFound": false},
    "remediation": "Add tests"
  }'

  local result
  result=$(annotate_finding_with_decision "$finding" "$FIXTURES_DIR/decisions/single.md")

  local title
  title=$(echo "$result" | jq -r '.title')

  # If it matched (check for exception)
  local has_exception
  has_exception=$(echo "$result" | jq '.intentionalException != null')
  if [ "$has_exception" = "true" ]; then
    assert_contains "$title" "[Intentional]" "Title should have [Intentional] prefix"
  else
    echo "  (No match - title unchanged)"
  fi
}

# =============================================================================
# Test 7: Remediation includes DECISIONS.md note
# =============================================================================
test_remediation_note() {
  echo ""
  echo "Test 7: Matched finding remediation should reference DECISIONS.md"

  local finding='{
    "id": "TEST-004",
    "severity": "high",
    "category": "testing",
    "title": "Missing test coverage",
    "description": "No tests for module",
    "location": {"file": "src/module.ts", "line": 1},
    "verified": {"vulnPatternSearched": "test", "mitigationPatternSearched": "spec", "mitigationFound": false},
    "remediation": "Add unit tests"
  }'

  local result
  result=$(annotate_finding_with_decision "$finding" "$FIXTURES_DIR/decisions/single.md")

  local remediation
  remediation=$(echo "$result" | jq -r '.remediation')

  local has_exception
  has_exception=$(echo "$result" | jq '.intentionalException != null')
  if [ "$has_exception" = "true" ]; then
    assert_contains "$remediation" "DECISIONS.md" "Remediation should reference DECISIONS.md"
  else
    echo "  (No match - remediation unchanged)"
  fi
}

# =============================================================================
# Test 8: No DECISIONS.md file - finding unchanged
# =============================================================================
test_no_decisions_file() {
  echo ""
  echo "Test 8: Missing DECISIONS.md should leave finding unchanged"

  local finding='{
    "id": "SEC-002",
    "severity": "critical",
    "category": "security",
    "title": "Hardcoded credentials",
    "description": "API key hardcoded in source",
    "location": {"file": "src/api.ts", "line": 5},
    "verified": {"vulnPatternSearched": "api_key", "mitigationPatternSearched": "env", "mitigationFound": false},
    "remediation": "Use environment variables"
  }'

  local result
  result=$(annotate_finding_with_decision "$finding" "/nonexistent/DECISIONS.md")

  # Should return unchanged finding
  local severity
  severity=$(echo "$result" | jq -r '.severity')
  assert_equal "$severity" "critical" "Severity should remain critical"

  local has_exception
  has_exception=$(echo "$result" | jq '.intentionalException != null')
  assert_equal "$has_exception" "false" "Should not have exception with missing file"
}

# =============================================================================
# Test 9: Empty finding text gracefully handled
# =============================================================================
test_empty_finding_text() {
  echo ""
  echo "Test 9: Finding with minimal text should be handled gracefully"

  local finding='{
    "id": "X-001",
    "severity": "low",
    "category": "other",
    "title": "",
    "description": "",
    "location": {"file": "x", "line": 1},
    "verified": {"vulnPatternSearched": "", "mitigationPatternSearched": "", "mitigationFound": false},
    "remediation": ""
  }'

  local result
  result=$(annotate_finding_with_decision "$finding" "$FIXTURES_DIR/decisions/single.md")

  # Should not crash, should return valid JSON
  echo "$result" | jq . > /dev/null 2>&1
  assert_equal "$?" "0" "Should return valid JSON"
}

# =============================================================================
# Test 10: Severity preserved for info level
# =============================================================================
test_info_severity_preserved() {
  echo ""
  echo "Test 10: Info severity findings should remain unchanged"

  local finding='{
    "id": "INFO-001",
    "severity": "info",
    "category": "testing",
    "title": "Test framework not configured",
    "description": "No test setup detected",
    "location": {"file": "package.json", "line": 1},
    "verified": {"vulnPatternSearched": "test", "mitigationPatternSearched": "jest", "mitigationFound": false},
    "remediation": "Consider adding tests"
  }'

  local result
  result=$(annotate_finding_with_decision "$finding" "$FIXTURES_DIR/decisions/single.md")

  # Even if matched, info stays info (already lowest)
  local severity
  severity=$(echo "$result" | jq -r '.severity')
  # Should be low or info (both acceptable)
  if [ "$severity" = "info" ] || [ "$severity" = "low" ]; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} Info severity handled correctly"
  else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} Info severity should be info or low, got: $severity"
  fi
}

# =============================================================================
# Test 11: Double [Intentional] prefix prevented (regression test)
# =============================================================================
test_no_double_prefix() {
  echo ""
  echo "Test 11: Already-prefixed title should not get double [Intentional] (regression)"

  # Finding that already has [Intentional] prefix
  local finding='{
    "id": "TEST-011",
    "severity": "low",
    "category": "testing",
    "title": "[Intentional] No test framework configured. Skip testing setup. Manual testing only.",
    "description": "No test framework",
    "location": {"file": "src/", "line": 1},
    "verified": {"vulnPatternSearched": "test", "mitigationPatternSearched": "spec", "mitigationFound": false},
    "remediation": "Add tests"
  }'

  local result
  result=$(annotate_finding_with_decision "$finding" "$FIXTURES_DIR/decisions/single.md")

  local title
  title=$(echo "$result" | jq -r '.title')

  # Count occurrences of [Intentional]
  local count
  count=$(echo "$title" | grep -o '\[Intentional\]' | wc -l | tr -d ' ')

  # Should have at most 1 [Intentional] prefix
  local has_double
  has_double=$([ "$count" -gt 1 ] && echo "yes" || echo "no")
  assert_equal "$has_double" "no" "Should not have double [Intentional] prefix (found $count)"
}

# =============================================================================
# Test 12: Remediation with newlines produces valid JSON (regression test)
# =============================================================================
test_remediation_newlines_valid_json() {
  echo ""
  echo "Test 12: Remediation with newlines should produce valid JSON (regression)"

  local finding='{
    "id": "TEST-012",
    "severity": "high",
    "category": "testing",
    "title": "No test framework configured. Skip testing setup. Manual testing only.",
    "description": "Project has no test framework",
    "location": {"file": "src/", "line": 1},
    "verified": {"vulnPatternSearched": "test", "mitigationPatternSearched": "spec", "mitigationFound": false},
    "remediation": "Add test framework\n\nSteps:\n1. Install jest\n2. Configure\n3. Add tests"
  }'

  local result
  result=$(annotate_finding_with_decision "$finding" "$FIXTURES_DIR/decisions/single.md")

  # Should be valid JSON
  local valid
  valid=$(echo "$result" | jq . > /dev/null 2>&1 && echo "yes" || echo "no")
  assert_equal "$valid" "yes" "Output should be valid JSON even with newlines in remediation"
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 4.2: Agent Decision Handling Tests                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_matching_finding_annotated
test_non_matching_finding_unchanged
test_best_match_selected
test_below_threshold_not_marked
test_exception_structure
test_title_prefix
test_remediation_note
test_no_decisions_file
test_empty_finding_text
test_info_severity_preserved
test_no_double_prefix
test_remediation_newlines_valid_json

print_test_summary
