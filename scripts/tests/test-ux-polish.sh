#!/bin/bash
# test-ux-polish.sh - Tests for UX polish features (v5.0.2)
#
# Part of: Phase 5 - UX Polish
#
# Tests:
# 1. color_echo TTY detection
# 2. ANSI stripping when piped
# 3. IS_UPDATE detection in install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=============================================="
echo "  UX Polish Tests (v5.0.2)"
echo "=============================================="
echo ""

ERRORS=0

# Source common-functions for color_echo
source "$SCRIPT_DIR/../common-functions.sh"

# =============================================================================
# Test 1: color_echo function exists
# =============================================================================
echo "Test 1: color_echo function exists..."

if type color_echo > /dev/null 2>&1; then
  echo "  ✓ color_echo function available"
else
  echo "  ✗ color_echo function not found"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 2: color_echo strips ANSI when piped
# =============================================================================
echo "Test 2: color_echo strips ANSI codes when piped..."

# This output goes through a pipe (subshell), so ANSI codes should be stripped
output=$(color_echo "${RED}test${NC}")

# Check if output is plain "test" (no escape sequences)
if [ "$output" = "test" ]; then
  echo "  ✓ ANSI codes stripped when piped"
else
  # Show what we got (hex for debugging)
  echo "  ✗ ANSI codes not stripped, got: '$output'"
  echo "    (Hex: $(echo -n "$output" | xxd -p | head -c 40)...)"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 3: IS_UPDATE detection in install.sh
# =============================================================================
echo "Test 3: IS_UPDATE detection exists in install.sh..."

if grep -q "IS_UPDATE=false" "$SCRIPT_DIR/../../install.sh" && \
   grep -q "IS_UPDATE=true" "$SCRIPT_DIR/../../install.sh"; then
  echo "  ✓ IS_UPDATE detection present"
else
  echo "  ✗ IS_UPDATE detection not found"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 4: Install.sh shows different messages for update vs fresh
# =============================================================================
echo "Test 4: Install.sh shows update-specific message..."

if grep -q 'if \[ "\$IS_UPDATE" = "true" \]' "$SCRIPT_DIR/../../install.sh"; then
  echo "  ✓ Update-specific messaging found"
else
  echo "  ✗ Update-specific messaging not found"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 5: perl command availability (used by color_echo)
# =============================================================================
echo "Test 5: ANSI stripping command available..."

if command -v perl > /dev/null 2>&1; then
  echo "  ✓ perl available for ANSI stripping"
elif command -v sed > /dev/null 2>&1; then
  echo "  ✓ sed available as fallback"
else
  echo "  ✗ No ANSI stripping command available"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 6: Extended ANSI sequence stripping
# =============================================================================
echo "Test 6: Extended ANSI sequences stripped..."

# Test 256-color and cursor codes (would break grep/parsing)
# These use different escape sequences that may not be stripped by simple patterns
test_string=$'\e[38;5;196mRed256\e[0m \e[?25lHidden cursor'
output=$(color_echo "$test_string" 2>/dev/null | cat)

# Check for escape character presence
if echo "$output" | grep -q $'\e'; then
  echo "  ✗ Extended ANSI codes not stripped"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✓ Extended ANSI codes stripped"
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=============================================="
if [ $ERRORS -eq 0 ]; then
  echo "  PASS: All 6 UX polish tests passed"
  echo "=============================================="
  exit 0
else
  echo "  FAIL: $ERRORS test(s) failed"
  echo "=============================================="
  exit 1
fi
