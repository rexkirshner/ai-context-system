#!/bin/bash
# Test MODULE-103: Code Review Auto-Report Generation
# Issue: PERF-2 - Manual report creation friction

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Test 1: code-review.md has report generation code
test_has_report_generation_code() {
  echo "Test 1: code-review.md should have bash code to generate report"

  if grep -q "mkdir -p artifacts/code-reviews\|cat > .*artifacts/code-reviews/session.*review\.md" "$PROJECT_ROOT/.claude/commands/code-review.md"; then
    echo -e "\033[0;32m✓\033[0m code-review.md has report generation bash code"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m code-review.md missing report generation bash code"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 2: Report includes session number detection
test_session_number_detection() {
  echo ""
  echo "Test 2: Should detect session number from SESSIONS.md"

  # Check for session detection logic
  if grep -q "grep.*Session.*SESSIONS\.md\|wc -l.*SESSIONS\.md" "$PROJECT_ROOT/.claude/commands/code-review.md"; then
    echo -e "\033[0;32m✓\033[0m Session number detection exists"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Session number detection missing"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 3: Report filename format is correct
test_report_filename_format() {
  echo ""
  echo "Test 3: Report filename should follow session-N-review.md format"

  # Check for correct filename pattern
  if grep -q "session.*review\.md\|REPORT_FILE.*session" "$PROJECT_ROOT/.claude/commands/code-review.md"; then
    echo -e "\033[0;32m✓\033[0m Correct filename format"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Incorrect or missing filename format"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 4: Report includes required sections
test_report_sections() {
  echo ""
  echo "Test 4: Report template should include required sections"

  # Check for key sections in the report template
  if grep -q "# Code Review Report" "$PROJECT_ROOT/.claude/commands/code-review.md" && \
     grep -q "Executive Summary" "$PROJECT_ROOT/.claude/commands/code-review.md" && \
     grep -q "Detailed Findings" "$PROJECT_ROOT/.claude/commands/code-review.md"; then
    echo -e "\033[0;32m✓\033[0m Report has required sections"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Report missing required sections"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 5: Creates artifacts directory if missing
test_creates_directory() {
  echo ""
  echo "Test 5: Should create artifacts/code-reviews directory"

  # Check for mkdir -p command
  if grep -q "mkdir -p artifacts/code-reviews" "$PROJECT_ROOT/.claude/commands/code-review.md"; then
    echo -e "\033[0;32m✓\033[0m Creates directory if missing"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Directory creation missing"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 6: Report shows confirmation message
test_confirmation_message() {
  echo ""
  echo "Test 6: Should show confirmation message after creating report"

  # Check for success message
  if grep -q "Report saved\|saved to.*artifacts/code-reviews\|✅.*artifacts/code-reviews" "$PROJECT_ROOT/.claude/commands/code-review.md"; then
    echo -e "\033[0;32m✓\033[0m Confirmation message exists"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Confirmation message missing"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 7: Report includes date stamp
test_date_stamp() {
  echo ""
  echo "Test 7: Report should include current date"

  # Check for date command in report generation
  if grep -q "date.*%Y-%m-%d\|\$(date)" "$PROJECT_ROOT/.claude/commands/code-review.md"; then
    echo -e "\033[0;32m✓\033[0m Date stamp included"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Date stamp missing"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 8: Integration test - verify report template has Grade field
test_grade_field() {
  echo ""
  echo "Test 8: Report template should include Grade field"

  # Check for Grade field in template
  if grep -q "Grade:\|Overall Grade:" "$PROJECT_ROOT/.claude/commands/code-review.md"; then
    echo -e "\033[0;32m✓\033[0m Grade field exists"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Grade field missing"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Run all tests
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  MODULE-103: Code Review Auto-Report Generation          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_has_report_generation_code
test_session_number_detection
test_report_filename_format
test_report_sections
test_creates_directory
test_confirmation_message
test_date_stamp
test_grade_field

print_test_summary
