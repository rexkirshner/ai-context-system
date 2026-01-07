#!/bin/bash
# Test MODULE-103: Modular Code Review System (v4.0.0+)
# Tests the new modular audit command structure

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Test 1: code-review.md is an orchestrator (not monolithic)
test_is_orchestrator() {
  echo "Test 1: code-review.md should be an interactive orchestrator"

  # Check for orchestrator patterns
  if grep -q "interactive\|menu\|select\|choose" "$PROJECT_ROOT/.claude/commands/code-review.md"; then
    echo -e "\033[0;32m✓\033[0m code-review.md is an orchestrator"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m code-review.md missing orchestrator patterns"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 2: All 8 specialized audit commands exist
test_specialized_commands_exist() {
  echo ""
  echo "Test 2: All 8 specialized audit commands should exist"

  local missing=0
  local commands=(
    "code-review-security.md"
    "code-review-performance.md"
    "code-review-accessibility.md"
    "code-review-seo.md"
    "code-review-database.md"
    "code-review-infrastructure.md"
    "code-review-typescript.md"
    "code-review-testing.md"
  )

  for cmd in "${commands[@]}"; do
    if [ ! -f "$PROJECT_ROOT/.claude/commands/$cmd" ]; then
      echo "  Missing: $cmd"
      missing=$((missing + 1))
    fi
  done

  if [ "$missing" -eq 0 ]; then
    echo -e "\033[0;32m✓\033[0m All 8 specialized audit commands exist"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Missing $missing audit commands"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 3: Audit commands use docs/audits/ directory
test_uses_docs_audits() {
  echo ""
  echo "Test 3: Audit commands should use docs/audits/ directory"

  # Check if audit commands reference docs/audits/
  if grep -q "docs/audits" "$PROJECT_ROOT/.claude/commands/code-review-security.md"; then
    echo -e "\033[0;32m✓\033[0m Uses docs/audits/ directory"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Not using docs/audits/ directory"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 4: Audit commands have REPO_ROOT detection
test_repo_root_detection() {
  echo ""
  echo "Test 4: Audit commands should have REPO_ROOT detection"

  if grep -q "REPO_ROOT=\$(git rev-parse --show-toplevel" "$PROJECT_ROOT/.claude/commands/code-review-security.md"; then
    echo -e "\033[0;32m✓\033[0m Has REPO_ROOT detection"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Missing REPO_ROOT detection"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 5: Audit report naming follows type-audit-NN.md format
test_audit_naming_format() {
  echo ""
  echo "Test 5: Reports should follow {type}-audit-NN.md format"

  # Check for the new naming pattern
  if grep -q "security-audit-\|performance-audit-\|audit-.*\.md" "$PROJECT_ROOT/.claude/commands/code-review-security.md"; then
    echo -e "\033[0;32m✓\033[0m Correct audit naming format"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Incorrect naming format"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 6: code-review-helpers.sh exists and sources common-functions.sh
test_helpers_script() {
  echo ""
  echo "Test 6: code-review-helpers.sh should exist and be properly configured"

  if [ -f "$PROJECT_ROOT/scripts/code-review-helpers.sh" ]; then
    if grep -q "source.*common-functions\.sh" "$PROJECT_ROOT/scripts/code-review-helpers.sh"; then
      echo -e "\033[0;32m✓\033[0m code-review-helpers.sh is properly configured"
      TESTS_RUN=$((TESTS_RUN + 1))
      TESTS_PASSED=$((TESTS_PASSED + 1))
    else
      echo -e "\033[0;31m✗\033[0m code-review-helpers.sh doesn't source common-functions.sh"
      TESTS_RUN=$((TESTS_RUN + 1))
    fi
  else
    echo -e "\033[0;31m✗\033[0m code-review-helpers.sh missing"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 7: audits-index.template.md exists
test_index_template() {
  echo ""
  echo "Test 7: audits-index.template.md should exist"

  if [ -f "$PROJECT_ROOT/templates/audits-index.template.md" ]; then
    echo -e "\033[0;32m✓\033[0m audits-index.template.md exists"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m audits-index.template.md missing"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 8: Audit commands have Grade field
test_grade_field() {
  echo ""
  echo "Test 8: Audit commands should include Grade field"

  if grep -q "Grade:\|Overall Grade:" "$PROJECT_ROOT/.claude/commands/code-review-security.md"; then
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
echo "║  MODULE-103: Modular Code Review System (v4.0.0+)         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_is_orchestrator
test_specialized_commands_exist
test_uses_docs_audits
test_repo_root_detection
test_audit_naming_format
test_helpers_script
test_index_template
test_grade_field

print_test_summary
