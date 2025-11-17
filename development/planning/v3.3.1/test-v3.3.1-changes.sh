#!/bin/bash
# Test suite for v3.3.1 changes
# Validates all bug fixes and enhancements

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test result tracking
FAILED_TESTS=()

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  AI Context System v3.3.1 Test Suite${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Change to repo root
cd "$(dirname "$0")/../../.."

# Helper functions
pass() {
  echo -e "${GREEN}✓${NC} $1"
  TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
  echo -e "${RED}✗${NC} $1"
  TESTS_FAILED=$((TESTS_FAILED + 1))
  FAILED_TESTS+=("$1")
}

test_start() {
  TESTS_RUN=$((TESTS_RUN + 1))
  echo -en "${BLUE}Test $TESTS_RUN:${NC} $1... "
}

# =============================================================================
# Test 1: Counter fields removed from config template
# =============================================================================

test_start "Counter fields removed from config template"
if grep -q "nextDecisionId\|sessionCount" config/.context-config.template.json; then
  fail "Counter fields still present in config template"
else
  pass "Counter fields successfully removed"
fi

# =============================================================================
# Test 2: find-context-folder.sh in installer manifest
# =============================================================================

test_start "find-context-folder.sh added to installer"
if grep -q "find-context-folder.sh" install.sh; then
  pass "find-context-folder.sh in installer manifest"
else
  fail "find-context-folder.sh missing from installer"
fi

# =============================================================================
# Test 3: update-quick-reference.sh in installer manifest
# =============================================================================

test_start "update-quick-reference.sh added to installer"
if grep -q "update-quick-reference.sh" install.sh; then
  pass "update-quick-reference.sh in installer manifest"
else
  fail "update-quick-reference.sh missing from installer"
fi

# =============================================================================
# Test 4: update_config_version function exists
# =============================================================================

test_start "update_config_version function exists"
if grep -q "^update_config_version()" install.sh; then
  pass "update_config_version function present"
else
  fail "update_config_version function missing"
fi

# =============================================================================
# Test 5: update_config_version uses temp file (not sed -i)
# =============================================================================

test_start "update_config_version uses portable sed"
if grep -q "sed.*-i.*context-config" install.sh; then
  # Check if it's in a comment or the old code
  if grep -A 5 "update_config_version()" install.sh | grep -q "sed.*-i"; then
    fail "update_config_version still uses sed -i (not portable)"
  else
    pass "sed -i usage is only in comments/old code"
  fi
else
  pass "No sed -i usage found (portable implementation)"
fi

# =============================================================================
# Test 6: Download retry logic implemented
# =============================================================================

test_start "download_file has retry logic"
if grep -A 20 "^download_file()" install.sh | grep -q "max_attempts"; then
  pass "Retry logic present in download_file"
else
  fail "Retry logic missing from download_file"
fi

# =============================================================================
# Test 7: Exponential backoff in download
# =============================================================================

test_start "Download uses exponential backoff"
if grep -A 30 "^download_file()" install.sh | grep -q "sleep_time.*\*.*2"; then
  pass "Exponential backoff implemented"
else
  fail "Exponential backoff missing"
fi

# =============================================================================
# Test 8: post_install_validation function exists
# =============================================================================

test_start "post_install_validation function exists"
if grep -q "^post_install_validation()" install.sh; then
  pass "post_install_validation function present"
else
  fail "post_install_validation function missing"
fi

# =============================================================================
# Test 9: post_install_validation checks version sync
# =============================================================================

test_start "post_install_validation checks version sync"
if grep -A 30 "^post_install_validation()" install.sh | grep -q "version_file.*config_version"; then
  pass "Version sync validation present"
else
  fail "Version sync validation missing"
fi

# =============================================================================
# Test 10: post_install_validation checks script permissions
# =============================================================================

test_start "post_install_validation checks permissions"
if grep -A 40 "^post_install_validation()" install.sh | grep -q "chmod.*x.*script"; then
  pass "Permission check and fix present"
else
  fail "Permission check missing"
fi

# =============================================================================
# Test 11: Backup includes VERSION file
# =============================================================================

test_start "Backup includes VERSION file"
if grep -A 15 "Backing up existing installation" install.sh | grep -q "cp VERSION"; then
  pass "VERSION file backed up"
else
  fail "VERSION file not backed up"
fi

# =============================================================================
# Test 12: Backup includes context directory
# =============================================================================

test_start "Backup includes context directory"
if grep -A 15 "Backing up existing installation" install.sh | grep -q "cp.*context"; then
  pass "context directory backed up"
else
  fail "context directory not backed up"
fi

# =============================================================================
# Test 13: Rollback restores VERSION file
# =============================================================================

test_start "Rollback restores VERSION file"
if grep -A 30 "^rollback_installation()" install.sh | grep -q "cp.*BACKUP_DIR/VERSION"; then
  pass "Rollback restores VERSION"
else
  fail "Rollback doesn't restore VERSION"
fi

# =============================================================================
# Test 14: Rollback restores context directory
# =============================================================================

test_start "Rollback restores context directory"
if grep -A 30 "^rollback_installation()" install.sh | grep -q "cp.*BACKUP_DIR/context"; then
  pass "Rollback restores context"
else
  fail "Rollback doesn't restore context"
fi

# =============================================================================
# Test 15: Critical files list updated
# =============================================================================

test_start "Critical files includes new scripts"
if grep -A 15 "CRITICAL_FILES=" install.sh | grep -q "find-context-folder.sh"; then
  pass "find-context-folder.sh in CRITICAL_FILES"
else
  fail "find-context-folder.sh missing from CRITICAL_FILES"
fi

# =============================================================================
# Test Summary
# =============================================================================

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Test Results${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Total tests run: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
  echo -e "${RED}Failed: $TESTS_FAILED${NC}"
  echo ""
  echo -e "${RED}Failed tests:${NC}"
  for test in "${FAILED_TESTS[@]}"; do
    echo "  - $test"
  done
  echo ""
  exit 1
else
  echo -e "${GREEN}All tests passed! ✓${NC}"
  echo ""
  exit 0
fi
