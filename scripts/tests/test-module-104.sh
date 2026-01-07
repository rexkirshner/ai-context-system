#!/bin/bash
# Test MODULE-104: Cross-Document Consistency Automation
# Issue: PERF-3 - Manual consistency checking

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Test 1: review-context.md has consistency check code
test_has_consistency_check_code() {
  echo "Test 1: review-context.md should have bash code for consistency checks"

  if grep -q "cross-document consistency\|Cross-Document Consistency\|Checking cross-document" "$PROJECT_ROOT/.claude/commands/review-context.md"; then
    echo -e "\033[0;32m✓\033[0m review-context.md has consistency check section"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m review-context.md missing consistency check section"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 2: Checks Last Updated dates from files
test_checks_last_updated_dates() {
  echo ""
  echo "Test 2: Should extract Last Updated dates from context files"

  # Check for grep patterns for Last Updated
  if grep -q "Last Updated.*CONTEXT\|grep.*Last Updated.*context/CONTEXT\.md" "$PROJECT_ROOT/.claude/commands/review-context.md"; then
    echo -e "\033[0;32m✓\033[0m Checks CONTEXT.md Last Updated date"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Missing CONTEXT.md date check"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 3: Checks Phase consistency
test_checks_phase_consistency() {
  echo ""
  echo "Test 3: Should check Phase field across files"

  # Check for Phase extraction
  if grep -q "Phase.*CONTEXT\|grep.*Phase.*context/CONTEXT\.md\|CONTEXT_PHASE" "$PROJECT_ROOT/.claude/commands/review-context.md"; then
    echo -e "\033[0;32m✓\033[0m Checks Phase fields"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Phase consistency check missing"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 4: Mentions phase consistency checking
test_warns_phase_drift() {
  echo ""
  echo "Test 4: Should mention phase consistency concept"

  # Check for phase consistency/drift concept (may be in comments or checklists)
  if grep -qi "phase.*drift\|phase.*consistency\|phase.*progress" "$PROJECT_ROOT/.claude/commands/review-context.md"; then
    echo -e "\033[0;32m✓\033[0m Phase consistency concept mentioned"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Phase consistency concept missing"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 5: Checks session count
test_checks_session_count() {
  echo ""
  echo "Test 6: Should count sessions in SESSIONS.md"

  # Check for session counting
  if grep -q "grep.*Session.*SESSIONS\.md\|SESSION_COUNT\|session count" "$PROJECT_ROOT/.claude/commands/review-context.md"; then
    echo -e "\033[0;32m✓\033[0m Session count check exists"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Session count check missing"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 6: Uses sed or similar for extraction
test_uses_extraction_tools() {
  echo ""
  echo "Test 6: Should use sed or similar for field extraction"

  # Check for sed usage
  if grep -q "sed.*Last Updated\|sed.*Phase" "$PROJECT_ROOT/.claude/commands/review-context.md"; then
    echo -e "\033[0;32m✓\033[0m Uses sed for extraction"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Missing sed extraction"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 7: Shows consistency results to user
test_shows_results() {
  echo ""
  echo "Test 7: Should echo consistency check results"

  # Check for echo output of dates
  if grep -q "echo.*Last Updated\|echo.*CONTEXT_DATE\|echo.*STATUS_DATE" "$PROJECT_ROOT/.claude/commands/review-context.md"; then
    echo -e "\033[0;32m✓\033[0m Shows results to user"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Missing result output"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 8: Integration - has section header or emoji
test_has_section_header() {
  echo ""
  echo "Test 8: Should have clear section header"

  # Check for section marker
  if grep -q "🔍.*[Cc]onsistency\|## .*[Cc]onsistency\|### .*[Cc]onsistency" "$PROJECT_ROOT/.claude/commands/review-context.md"; then
    echo -e "\033[0;32m✓\033[0m Has section header"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Section header missing"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Run all tests
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  MODULE-104: Cross-Document Consistency Automation       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_has_consistency_check_code
test_checks_last_updated_dates
test_checks_phase_consistency
test_warns_phase_drift
test_checks_session_count
test_uses_extraction_tools
test_shows_results
test_has_section_header

print_test_summary
