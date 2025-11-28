#!/bin/bash
# Test MODULE-005: ORGANIZATION.md Download Fix
# Issue: BUG-4 - Installation fails on small file

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Test 1: ORGANIZATION.md has sufficient content
test_organization_file_size() {
  echo "Test 1: ORGANIZATION.md should be >100 bytes"

  FILE_SIZE=$(wc -c < reference/ORGANIZATION.md | tr -d ' ')

  assert_greater_than "$FILE_SIZE" "100" "ORGANIZATION.md should be >100 bytes"
}

# Test 2: Optional files list includes ORGANIZATION.md
test_optional_files_defined() {
  echo ""
  echo "Test 2: install.sh should mark ORGANIZATION.md as optional"

  # Check if install.sh defines OPTIONAL_FILES array
  if grep -q "OPTIONAL_FILES=" install.sh; then
    # Check if ORGANIZATION.md is in the array
    if grep -A 3 "OPTIONAL_FILES=" install.sh | grep -q "reference/ORGANIZATION.md"; then
      echo -e "\033[0;32m✓\033[0m ORGANIZATION.md is in OPTIONAL_FILES"
      TESTS_RUN=$((TESTS_RUN + 1))
      TESTS_PASSED=$((TESTS_PASSED + 1))
    else
      echo -e "\033[0;31m✗\033[0m ORGANIZATION.md not in OPTIONAL_FILES"
      TESTS_RUN=$((TESTS_RUN + 1))
    fi
  else
    echo -e "\033[0;31m✗\033[0m OPTIONAL_FILES not defined in install.sh"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 3: is_optional function exists
test_is_optional_function() {
  echo ""
  echo "Test 3: install.sh should have is_optional() function"

  if grep -q "is_optional()" install.sh; then
    echo -e "\033[0;32m✓\033[0m is_optional() function exists"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m is_optional() function not found"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 4: Optional file download doesn't increment FAILED_DOWNLOADS
test_optional_file_handling() {
  echo ""
  echo "Test 4: Optional file failures should not increment error counter"

  # This is a logic test - check that optional files aren't counted in FAILED_DOWNLOADS
  # Look for the pattern where ORGANIZATION.md download doesn't use ((FAILED_DOWNLOADS++))

  # Extract the ORGANIZATION.md download section (around line 518-521)
  ORG_DOWNLOAD_SECTION=$(sed -n '515,525p' install.sh)

  # Check if it uses the optional file pattern
  if echo "$ORG_DOWNLOAD_SECTION" | grep -q "reference/ORGANIZATION.md"; then
    # Check that it doesn't increment FAILED_DOWNLOADS in the normal way
    # It should either:
    # 1. Use is_optional check before incrementing
    # 2. Not increment FAILED_DOWNLOADS at all for this file
    if echo "$ORG_DOWNLOAD_SECTION" | grep -A 3 "reference/ORGANIZATION.md" | grep -q "FAILED_DOWNLOADS"; then
      # If it mentions FAILED_DOWNLOADS, it should be conditional on is_optional
      if echo "$ORG_DOWNLOAD_SECTION" | grep -B 5 "FAILED_DOWNLOADS" | grep -q "is_optional"; then
        echo -e "\033[0;32m✓\033[0m Optional file handling is conditional"
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
      else
        # This is the current state - it will fail after we implement the fix
        echo "   ℹ️  Currently increments FAILED_DOWNLOADS (will be fixed)"
        TESTS_RUN=$((TESTS_RUN + 1))
      fi
    else
      echo -e "\033[0;32m✓\033[0m ORGANIZATION.md download doesn't increment FAILED_DOWNLOADS"
      TESTS_RUN=$((TESTS_RUN + 1))
      TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
  fi
}

# Test 5: Verify file content quality
test_organization_content_quality() {
  echo ""
  echo "Test 5: ORGANIZATION.md should have meaningful content"

  # Check for key sections that should exist
  SECTIONS_FOUND=0

  if grep -q "Project Organization" reference/ORGANIZATION.md; then
    ((SECTIONS_FOUND++))
  fi

  if grep -q "Core Structure" reference/ORGANIZATION.md; then
    ((SECTIONS_FOUND++))
  fi

  if grep -q "context/" reference/ORGANIZATION.md; then
    ((SECTIONS_FOUND++))
  fi

  if grep -q "docs/" reference/ORGANIZATION.md; then
    ((SECTIONS_FOUND++))
  fi

  assert_greater_than "$SECTIONS_FOUND" "2" "Should have at least 3 key sections"
}

# Run all tests
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  MODULE-005: ORGANIZATION.md Download Fix                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_organization_file_size
test_optional_files_defined
test_is_optional_function
test_optional_file_handling
test_organization_content_quality

print_test_summary
