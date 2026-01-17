#!/bin/bash
# Test report generation functions
# Phase 5.2 of v5.1.0 implementation
#
# Test cases:
# 1. First audit of day → audit-YYYY-MM-DD.md
# 2. Second audit same day → audit-YYYY-MM-DD-002.md
# 3. Atomic write: temp files renamed atomically
# 4. JSON validates against schema
# 5. Empty findings → still generates valid report
# 6. Markdown structure is correct
# 7. INDEX.md updated with new row
# 8. Cleanup of .tmp files on startup

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Source common functions
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Test fixtures directory
FIXTURES_DIR="$PROJECT_ROOT/test/fixtures"

# Temp directory for test outputs
TEST_OUTPUT_DIR=""

setup_report_test_env() {
  TEST_OUTPUT_DIR=$(mktemp -d -t acs-report-test.XXXXXX)
  mkdir -p "$TEST_OUTPUT_DIR/docs/audits"
  mkdir -p "$TEST_OUTPUT_DIR/templates"

  # Copy the template if it exists
  if [ -f "$PROJECT_ROOT/templates/AUDIT_REPORT.template.md" ]; then
    cp "$PROJECT_ROOT/templates/AUDIT_REPORT.template.md" "$TEST_OUTPUT_DIR/templates/"
  fi
}

cleanup_report_test_env() {
  if [ -n "$TEST_OUTPUT_DIR" ] && [ -d "$TEST_OUTPUT_DIR" ]; then
    rm -rf "$TEST_OUTPUT_DIR"
  fi
}

# =============================================================================
# Test 1: First audit of day gets simple date-based filename
# =============================================================================
test_first_audit_filename() {
  echo "Test 1: First audit of day should get date-based filename"

  setup_report_test_env

  local today
  today=$(date +%Y-%m-%d)

  local filename
  filename=$(get_next_audit_filename "$TEST_OUTPUT_DIR/docs/audits")

  assert_equal "$filename" "audit-${today}" "First audit should have simple date-based name"

  cleanup_report_test_env
}

# =============================================================================
# Test 2: Second audit same day gets numbered suffix
# =============================================================================
test_second_audit_filename() {
  echo ""
  echo "Test 2: Second audit same day should get numbered suffix"

  setup_report_test_env

  local today
  today=$(date +%Y-%m-%d)

  # Create first audit file
  touch "$TEST_OUTPUT_DIR/docs/audits/audit-${today}.md"
  touch "$TEST_OUTPUT_DIR/docs/audits/audit-${today}.json"

  local filename
  filename=$(get_next_audit_filename "$TEST_OUTPUT_DIR/docs/audits")

  assert_equal "$filename" "audit-${today}-002" "Second audit should have -002 suffix"

  cleanup_report_test_env
}

# =============================================================================
# Test 3: Third audit same day increments counter
# =============================================================================
test_third_audit_filename() {
  echo ""
  echo "Test 3: Third audit should increment counter"

  setup_report_test_env

  local today
  today=$(date +%Y-%m-%d)

  # Create first two audit files
  touch "$TEST_OUTPUT_DIR/docs/audits/audit-${today}.md"
  touch "$TEST_OUTPUT_DIR/docs/audits/audit-${today}-002.md"

  local filename
  filename=$(get_next_audit_filename "$TEST_OUTPUT_DIR/docs/audits")

  assert_equal "$filename" "audit-${today}-003" "Third audit should have -003 suffix"

  cleanup_report_test_env
}

# =============================================================================
# Test 4: Generate markdown report produces valid structure
# =============================================================================
test_markdown_report_structure() {
  echo ""
  echo "Test 4: Generated markdown report should have correct structure"

  setup_report_test_env

  # Sample synthesized report
  local report='{
    "metadata": {
      "schemaVersion": "1.0.0",
      "timestamp": "2026-01-16T12:00:00Z",
      "projectName": "test-project",
      "agentsRun": ["security", "performance"],
      "filesScanned": 42
    },
    "summary": {
      "grade": "B+",
      "criticalCount": 0,
      "highCount": 1,
      "mediumCount": 3,
      "lowCount": 5
    },
    "findings": [
      {
        "id": "SEC-001",
        "severity": "high",
        "category": "security",
        "title": "Hardcoded API key",
        "description": "Found hardcoded API key in source",
        "location": {"file": "src/api.ts", "line": 15},
        "remediation": "Use environment variables"
      }
    ],
    "positives": ["TypeScript with strict mode", "Good file organization"],
    "stats": {
      "rawFindings": 20,
      "afterLocationDedup": 12,
      "afterPatternGrouping": 9,
      "reductionPercent": 55
    }
  }'

  local output_dir="$TEST_OUTPUT_DIR/docs/audits"
  local md_file
  md_file=$(generate_audit_markdown "$report" "$output_dir")

  # Check file was created
  local file_exists
  file_exists=$([ -f "$md_file" ] && echo "yes" || echo "no")
  assert_equal "$file_exists" "yes" "Markdown file should be created"

  # Check structure
  local has_title
  has_title=$(grep -c "# Code Audit Report" "$md_file" 2>/dev/null || echo "0")
  assert_equal "$has_title" "1" "Should have title heading"

  local has_grade
  has_grade=$(grep -c "Grade:" "$md_file" 2>/dev/null || echo "0")
  assert_equal "$has_grade" "1" "Should have grade"

  local has_findings
  has_findings=$(grep -c "## Findings" "$md_file" 2>/dev/null || echo "0")
  assert_equal "$has_findings" "1" "Should have findings section"

  cleanup_report_test_env
}

# =============================================================================
# Test 5: Generate JSON report validates against schema
# =============================================================================
test_json_report_validates() {
  echo ""
  echo "Test 5: Generated JSON report should be valid"

  setup_report_test_env

  local report='{
    "metadata": {
      "schemaVersion": "1.0.0",
      "timestamp": "2026-01-16T12:00:00Z",
      "projectName": "test-project",
      "agentsRun": ["security"],
      "filesScanned": 10
    },
    "summary": {
      "grade": "A",
      "criticalCount": 0,
      "highCount": 0,
      "mediumCount": 0,
      "lowCount": 2
    },
    "findings": [],
    "positives": []
  }'

  local output_dir="$TEST_OUTPUT_DIR/docs/audits"
  local json_file
  json_file=$(generate_audit_json "$report" "$output_dir")

  # Check file was created
  local file_exists
  file_exists=$([ -f "$json_file" ] && echo "yes" || echo "no")
  assert_equal "$file_exists" "yes" "JSON file should be created"

  # Validate JSON syntax
  local is_valid
  is_valid=$(jq . "$json_file" > /dev/null 2>&1 && echo "yes" || echo "no")
  assert_equal "$is_valid" "yes" "JSON should be syntactically valid"

  # Check required fields
  local has_metadata
  has_metadata=$(jq 'has("metadata")' "$json_file")
  assert_equal "$has_metadata" "true" "Should have metadata field"

  local has_summary
  has_summary=$(jq 'has("summary")' "$json_file")
  assert_equal "$has_summary" "true" "Should have summary field"

  local has_findings
  has_findings=$(jq 'has("findings")' "$json_file")
  assert_equal "$has_findings" "true" "Should have findings field"

  cleanup_report_test_env
}

# =============================================================================
# Test 6: Empty findings produces valid report
# =============================================================================
test_empty_findings_report() {
  echo ""
  echo "Test 6: Empty findings should produce valid report"

  setup_report_test_env

  local report='{
    "metadata": {
      "schemaVersion": "1.0.0",
      "timestamp": "2026-01-16T12:00:00Z",
      "projectName": "clean-project",
      "agentsRun": ["security", "performance"],
      "filesScanned": 100
    },
    "summary": {
      "grade": "A+",
      "criticalCount": 0,
      "highCount": 0,
      "mediumCount": 0,
      "lowCount": 0
    },
    "findings": [],
    "positives": ["No issues found!"]
  }'

  local output_dir="$TEST_OUTPUT_DIR/docs/audits"
  local md_file
  md_file=$(generate_audit_markdown "$report" "$output_dir")

  # Check file was created
  local file_exists
  file_exists=$([ -f "$md_file" ] && echo "yes" || echo "no")
  assert_equal "$file_exists" "yes" "Markdown file should be created for empty findings"

  # Check grade is A+
  local has_a_plus
  has_a_plus=$(grep -c "A+" "$md_file" 2>/dev/null || echo "0")
  assert_equal "$has_a_plus" "1" "Should show A+ grade"

  cleanup_report_test_env
}

# =============================================================================
# Test 7: Atomic write uses temp file
# =============================================================================
test_atomic_write() {
  echo ""
  echo "Test 7: Atomic write should use temp file then rename"

  setup_report_test_env

  local report='{
    "metadata": {"schemaVersion": "1.0.0", "timestamp": "2026-01-16T12:00:00Z", "projectName": "test", "agentsRun": [], "filesScanned": 1},
    "summary": {"grade": "A", "criticalCount": 0, "highCount": 0, "mediumCount": 0, "lowCount": 0},
    "findings": []
  }'

  local output_dir="$TEST_OUTPUT_DIR/docs/audits"

  # Generate reports
  generate_audit_markdown "$report" "$output_dir" > /dev/null
  generate_audit_json "$report" "$output_dir" > /dev/null

  # Check no .tmp files remain
  local tmp_count
  tmp_count=$(find "$output_dir" -name "*.tmp" 2>/dev/null | wc -l | tr -d ' ')
  assert_equal "$tmp_count" "0" "No .tmp files should remain after successful write"

  cleanup_report_test_env
}

# =============================================================================
# Test 8: Cleanup removes stale .tmp files
# =============================================================================
test_cleanup_tmp_files() {
  echo ""
  echo "Test 8: Cleanup should remove stale .tmp files"

  setup_report_test_env

  local output_dir="$TEST_OUTPUT_DIR/docs/audits"

  # Create stale .tmp files
  echo "partial content" > "$output_dir/audit-2026-01-15.md.tmp"
  echo "{}" > "$output_dir/audit-2026-01-15.json.tmp"

  # Run cleanup
  cleanup_audit_tmp_files "$output_dir"

  # Check .tmp files are gone
  local tmp_count
  tmp_count=$(find "$output_dir" -name "*.tmp" 2>/dev/null | wc -l | tr -d ' ')
  assert_equal "$tmp_count" "0" "All .tmp files should be removed"

  cleanup_report_test_env
}

# =============================================================================
# Test 9: Findings sorted by severity in markdown
# =============================================================================
test_findings_sorted_by_severity() {
  echo ""
  echo "Test 9: Findings should be sorted by severity (critical first)"

  setup_report_test_env

  local report='{
    "metadata": {"schemaVersion": "1.0.0", "timestamp": "2026-01-16T12:00:00Z", "projectName": "test", "agentsRun": ["security"], "filesScanned": 10},
    "summary": {"grade": "C", "criticalCount": 1, "highCount": 1, "mediumCount": 1, "lowCount": 1},
    "findings": [
      {"id": "SEC-001", "severity": "low", "category": "security", "title": "Low issue", "location": {"file": "a.ts", "line": 1}},
      {"id": "SEC-002", "severity": "critical", "category": "security", "title": "Critical issue", "location": {"file": "b.ts", "line": 2}},
      {"id": "SEC-003", "severity": "high", "category": "security", "title": "High issue", "location": {"file": "c.ts", "line": 3}},
      {"id": "SEC-004", "severity": "medium", "category": "security", "title": "Medium issue", "location": {"file": "d.ts", "line": 4}}
    ]
  }'

  local output_dir="$TEST_OUTPUT_DIR/docs/audits"
  local md_file
  md_file=$(generate_audit_markdown "$report" "$output_dir")

  # Check that critical appears before high appears before medium appears before low
  local critical_line high_line medium_line low_line
  critical_line=$(grep -n "Critical issue" "$md_file" | head -1 | cut -d: -f1)
  high_line=$(grep -n "High issue" "$md_file" | head -1 | cut -d: -f1)
  medium_line=$(grep -n "Medium issue" "$md_file" | head -1 | cut -d: -f1)
  low_line=$(grep -n "Low issue" "$md_file" | head -1 | cut -d: -f1)

  local order_correct="yes"
  if [ -n "$critical_line" ] && [ -n "$high_line" ] && [ "$critical_line" -gt "$high_line" ]; then
    order_correct="no"
  fi
  if [ -n "$high_line" ] && [ -n "$medium_line" ] && [ "$high_line" -gt "$medium_line" ]; then
    order_correct="no"
  fi
  if [ -n "$medium_line" ] && [ -n "$low_line" ] && [ "$medium_line" -gt "$low_line" ]; then
    order_correct="no"
  fi

  assert_equal "$order_correct" "yes" "Findings should be sorted by severity (critical > high > medium > low)"

  cleanup_report_test_env
}

# =============================================================================
# Test 10: Positives section included
# =============================================================================
test_positives_included() {
  echo ""
  echo "Test 10: Positives should be included in report"

  setup_report_test_env

  local report='{
    "metadata": {"schemaVersion": "1.0.0", "timestamp": "2026-01-16T12:00:00Z", "projectName": "test", "agentsRun": ["security"], "filesScanned": 10},
    "summary": {"grade": "B", "criticalCount": 0, "highCount": 0, "mediumCount": 1, "lowCount": 0},
    "findings": [],
    "positives": ["TypeScript with strict mode", "Good test coverage", "Proper error handling"]
  }'

  local output_dir="$TEST_OUTPUT_DIR/docs/audits"
  local md_file
  md_file=$(generate_audit_markdown "$report" "$output_dir")

  local has_positives
  has_positives=$(grep -c "TypeScript with strict mode" "$md_file" 2>/dev/null || echo "0")
  assert_equal "$has_positives" "1" "Should include positives in report"

  cleanup_report_test_env
}

# =============================================================================
# Test 11: Deduplication stats included
# =============================================================================
test_dedup_stats_included() {
  echo ""
  echo "Test 11: Deduplication stats should be included"

  setup_report_test_env

  local report='{
    "metadata": {"schemaVersion": "1.0.0", "timestamp": "2026-01-16T12:00:00Z", "projectName": "test", "agentsRun": ["security"], "filesScanned": 10},
    "summary": {"grade": "B", "criticalCount": 0, "highCount": 0, "mediumCount": 1, "lowCount": 0},
    "findings": [],
    "stats": {
      "rawFindings": 100,
      "afterLocationDedup": 60,
      "afterPatternGrouping": 45,
      "reductionPercent": 55
    }
  }'

  local output_dir="$TEST_OUTPUT_DIR/docs/audits"
  local md_file
  md_file=$(generate_audit_markdown "$report" "$output_dir")

  # 55% appears in both Executive Summary and Deduplication Statistics - check for at least 1
  local has_reduction
  has_reduction=$(grep -c "55%" "$md_file" 2>/dev/null || echo "0")
  local reduction_present
  reduction_present=$([ "$has_reduction" -ge 1 ] && echo "yes" || echo "no")
  assert_equal "$reduction_present" "yes" "Should show reduction percentage"

  cleanup_report_test_env
}

# =============================================================================
# Test 12: Full report generation (both MD and JSON)
# =============================================================================
test_full_report_generation() {
  echo ""
  echo "Test 12: Full report generation should create both files"

  setup_report_test_env

  local report='{
    "metadata": {"schemaVersion": "1.0.0", "timestamp": "2026-01-16T12:00:00Z", "projectName": "full-test", "agentsRun": ["security", "performance"], "filesScanned": 50},
    "summary": {"grade": "B+", "criticalCount": 0, "highCount": 1, "mediumCount": 2, "lowCount": 3},
    "findings": [{"id": "SEC-001", "severity": "high", "category": "security", "title": "Test finding", "location": {"file": "test.ts", "line": 1}}],
    "positives": ["Good practices"],
    "stats": {"rawFindings": 10, "afterLocationDedup": 8, "afterPatternGrouping": 6, "reductionPercent": 40}
  }'

  local output_dir="$TEST_OUTPUT_DIR/docs/audits"
  local result
  result=$(generate_audit_report "$report" "$output_dir")

  # Check both files exist
  local md_exists json_exists
  local today
  today=$(date +%Y-%m-%d)
  md_exists=$([ -f "$output_dir/audit-${today}.md" ] && echo "yes" || echo "no")
  json_exists=$([ -f "$output_dir/audit-${today}.json" ] && echo "yes" || echo "no")

  assert_equal "$md_exists" "yes" "Markdown file should exist"
  assert_equal "$json_exists" "yes" "JSON file should exist"

  cleanup_report_test_env
}

# =============================================================================
# Test 13: Missing location in finding (regression test)
# =============================================================================
test_missing_location() {
  echo ""
  echo "Test 13: Finding without location should not produce ':null'"

  setup_report_test_env

  # Finding with no location field at all
  local report='{
    "metadata": {"schemaVersion": "1.0.0", "timestamp": "2026-01-16T12:00:00Z", "projectName": "test", "agentsRun": ["security"], "filesScanned": 10},
    "summary": {"grade": "B", "criticalCount": 0, "highCount": 0, "mediumCount": 1, "lowCount": 0},
    "findings": [
      {"id": "SEC-001", "severity": "medium", "category": "security", "title": "Missing location test"}
    ]
  }'

  local output_dir="$TEST_OUTPUT_DIR/docs/audits"
  local md_file
  md_file=$(generate_audit_markdown "$report" "$output_dir")

  # Should not contain ':null' (the bug we fixed)
  local has_null
  has_null=$(grep -c ":null" "$md_file" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$has_null" "0" "Should not have :null in output"

  # Should still have the finding title
  local has_title
  has_title=$(grep -c "Missing location test" "$md_file" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$has_title" "1" "Should still include finding title"

  cleanup_report_test_env
}

# =============================================================================
# Test 14: Partial location (file only, no line)
# =============================================================================
test_partial_location() {
  echo ""
  echo "Test 14: Finding with file but no line should handle gracefully"

  setup_report_test_env

  # Finding with file but no line number
  local report='{
    "metadata": {"schemaVersion": "1.0.0", "timestamp": "2026-01-16T12:00:00Z", "projectName": "test", "agentsRun": ["security"], "filesScanned": 10},
    "summary": {"grade": "B", "criticalCount": 0, "highCount": 0, "mediumCount": 1, "lowCount": 0},
    "findings": [
      {"id": "SEC-001", "severity": "medium", "category": "security", "title": "Partial location", "location": {"file": "test.ts"}}
    ]
  }'

  local output_dir="$TEST_OUTPUT_DIR/docs/audits"
  local md_file
  md_file=$(generate_audit_markdown "$report" "$output_dir")

  # Should include the file path without :null
  local has_file
  has_file=$(grep -c "test.ts" "$md_file" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$has_file" "1" "Should include file path"

  # Should not have :null anywhere
  local has_null
  has_null=$(grep -c ":null" "$md_file" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$has_null" "0" "Should not have :null for missing line"

  cleanup_report_test_env
}

# =============================================================================
# Test 15: Null location object (regression test)
# =============================================================================
test_null_location_object() {
  echo ""
  echo "Test 15: Finding with explicit null location should handle gracefully"

  setup_report_test_env

  # Finding with explicit null location
  local report='{
    "metadata": {"schemaVersion": "1.0.0", "timestamp": "2026-01-16T12:00:00Z", "projectName": "test", "agentsRun": ["security"], "filesScanned": 10},
    "summary": {"grade": "B", "criticalCount": 0, "highCount": 0, "mediumCount": 1, "lowCount": 0},
    "findings": [
      {"id": "SEC-001", "severity": "medium", "category": "security", "title": "Null location", "location": null}
    ]
  }'

  local output_dir="$TEST_OUTPUT_DIR/docs/audits"
  local md_file
  md_file=$(generate_audit_markdown "$report" "$output_dir")

  # Should not contain ':null' or produce errors
  local has_null
  has_null=$(grep -c ":null" "$md_file" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$has_null" "0" "Should not have :null for null location"

  # Should have the finding
  local has_finding
  has_finding=$(grep -c "SEC-001" "$md_file" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$has_finding" "1" "Should still include finding ID"

  cleanup_report_test_env
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 5.2: Report Generation Tests                        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_first_audit_filename
test_second_audit_filename
test_third_audit_filename
test_markdown_report_structure
test_json_report_validates
test_empty_findings_report
test_atomic_write
test_cleanup_tmp_files
test_findings_sorted_by_severity
test_positives_included
test_dedup_stats_included
test_full_report_generation
test_missing_location
test_partial_location
test_null_location_object

print_test_summary
