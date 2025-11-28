#!/bin/bash
# Master Test Runner for AI Context System v3.5.0
# Runs all module tests and reports comprehensive results

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  AI Context System v3.5.0 - Comprehensive Test Suite     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Test counters
TOTAL_MODULES=0
MODULES_PASSED=0
MODULES_FAILED=0
TOTAL_TESTS=0
TESTS_PASSED=0
TESTS_FAILED=0

# Array to track failed modules
FAILED_MODULES=()

# Run all module tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 UNIT TESTS - Running all module tests..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

for test_file in "$SCRIPT_DIR"/test-module-*.sh; do
  # Skip if no test files found
  [ -e "$test_file" ] || continue

  MODULE_NAME=$(basename "$test_file" .sh)
  TOTAL_MODULES=$((TOTAL_MODULES + 1))

  echo "Testing: $MODULE_NAME"

  # Run test and capture output
  if OUTPUT=$(bash "$test_file" 2>&1); then
    # Extract test counts from output
    MODULE_TOTAL=$(echo "$OUTPUT" | grep "Total tests:" | awk '{print $3}')
    MODULE_PASSED=$(echo "$OUTPUT" | grep "Passed:" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $2}')

    if [ -n "$MODULE_TOTAL" ]; then
      TOTAL_TESTS=$((TOTAL_TESTS + MODULE_TOTAL))
      TESTS_PASSED=$((TESTS_PASSED + MODULE_PASSED))

      # Check if all tests passed
      if [ "$MODULE_PASSED" -eq "$MODULE_TOTAL" ]; then
        echo -e "  ${GREEN}✓${NC} $MODULE_PASSED/$MODULE_TOTAL tests passed"
        MODULES_PASSED=$((MODULES_PASSED + 1))
      else
        MODULE_FAILED=$((MODULE_TOTAL - MODULE_PASSED))
        TESTS_FAILED=$((TESTS_FAILED + MODULE_FAILED))
        echo -e "  ${RED}✗${NC} $MODULE_PASSED/$MODULE_TOTAL tests passed ($MODULE_FAILED failed)"
        MODULES_FAILED=$((MODULES_FAILED + 1))
        FAILED_MODULES+=("$MODULE_NAME")
      fi
    else
      echo -e "  ${YELLOW}⚠${NC} Could not parse test results"
    fi
  else
    echo -e "  ${RED}✗${NC} Test script failed to run"
    MODULES_FAILED=$((MODULES_FAILED + 1))
    FAILED_MODULES+=("$MODULE_NAME")
  fi

  echo ""
done

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 TEST SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Module Summary:"
echo "  Total modules tested: $TOTAL_MODULES"
echo -e "  Modules passed: ${GREEN}$MODULES_PASSED${NC}"
if [ "$MODULES_FAILED" -gt 0 ]; then
  echo -e "  Modules failed: ${RED}$MODULES_FAILED${NC}"
fi
echo ""
echo "Test Summary:"
echo "  Total tests run: $TOTAL_TESTS"
echo -e "  Tests passed: ${GREEN}$TESTS_PASSED${NC}"
if [ "$TESTS_FAILED" -gt 0 ]; then
  echo -e "  Tests failed: ${RED}$TESTS_FAILED${NC}"
fi
echo ""

# Report failures
if [ "$MODULES_FAILED" -gt 0 ]; then
  echo -e "${RED}Failed Modules:${NC}"
  for module in "${FAILED_MODULES[@]}"; do
    echo "  - $module"
  done
  echo ""
  echo -e "${RED}❌ SOME TESTS FAILED${NC}"
  exit 1
else
  echo -e "${GREEN}✅ ALL TESTS PASSED (${TESTS_PASSED}/${TOTAL_TESTS})${NC}"
  echo ""
  echo "Success Rate: 100%"
  exit 0
fi
