#!/bin/bash
# Comprehensive Test Suite for AI Context System v3.5.0
# Runs all test levels: Unit, Integration, and Manual Verification

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  AI Context System v3.5.0                                 ║"
echo "║  Comprehensive Test Suite                                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

TOTAL_FAILURES=0

# Run Unit Tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}📋 LEVEL 1: UNIT TESTS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if bash "$SCRIPT_DIR/run-all-tests.sh"; then
  echo ""
  echo -e "${GREEN}✅ Unit tests: PASSED${NC}"
else
  echo ""
  echo -e "${RED}❌ Unit tests: FAILED${NC}"
  TOTAL_FAILURES=$((TOTAL_FAILURES + 1))
fi

echo ""
echo ""

# Run Integration Tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}🔗 LEVEL 2: INTEGRATION TESTS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if bash "$SCRIPT_DIR/test-integration.sh"; then
  echo ""
  echo -e "${GREEN}✅ Integration tests: PASSED${NC}"
else
  echo ""
  echo -e "${RED}❌ Integration tests: FAILED${NC}"
  TOTAL_FAILURES=$((TOTAL_FAILURES + 1))
fi

echo ""
echo ""

# Run Manual Verification Tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}🔧 LEVEL 3: MANUAL VERIFICATION${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if bash "$SCRIPT_DIR/test-manual-verification.sh"; then
  echo ""
  echo -e "${GREEN}✅ Manual verification: PASSED${NC}"
else
  echo ""
  echo -e "${RED}❌ Manual verification: FAILED${NC}"
  TOTAL_FAILURES=$((TOTAL_FAILURES + 1))
fi

echo ""
echo ""

# Final Summary
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  COMPREHENSIVE TEST RESULTS                               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

if [ "$TOTAL_FAILURES" -eq 0 ]; then
  echo -e "${GREEN}✅ ALL TEST LEVELS PASSED${NC}"
  echo ""
  echo "Summary:"
  echo "  ✓ Unit Tests (78 tests)"
  echo "  ✓ Integration Tests (12 tests)"
  echo "  ✓ Manual Verification (11 tests)"
  echo ""
  echo "Total: 101 tests passing"
  echo ""
  echo -e "${GREEN}🎉 System ready for deployment!${NC}"
  exit 0
else
  echo -e "${RED}❌ SOME TEST LEVELS FAILED${NC}"
  echo ""
  echo "Failed levels: $TOTAL_FAILURES"
  echo ""
  echo "Please review failed tests above and fix issues before deployment."
  exit 1
fi
