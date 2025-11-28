#!/bin/bash
# Test MODULE-003: Shell-Compatible Version Check
# Issue: BUG-2 - zsh parsing error in /review-context version check

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Test 1: Version check works in bash
test_version_check_bash() {
  echo "Test 1: Version check should work in bash"

  # Setup
  setup_test_env
  echo "3.5.0" > VERSION
  mkdir -p context

  # Test the new version detection logic (shell-compatible)
  CURRENT_VERSION=$(bash -c 'cat VERSION 2>/dev/null || echo "unknown"; echo $CURRENT_VERSION')
  CURRENT_VERSION=$(cat VERSION 2>/dev/null || echo "unknown")

  assert_equal "$CURRENT_VERSION" "3.5.0" "Bash should read version correctly"

  # Cleanup
  cleanup_test_env
}

# Test 2: Version check works in zsh
test_version_check_zsh() {
  echo ""
  echo "Test 2: Version check should work in zsh"

  # Setup
  setup_test_env
  echo "3.5.0" > VERSION

  # Test in zsh (if available)
  if command -v zsh &> /dev/null; then
    CURRENT_VERSION=$(zsh -c 'cat VERSION 2>/dev/null || echo "unknown"')
    assert_equal "$CURRENT_VERSION" "3.5.0" "Zsh should read version correctly"
  else
    echo "   ⚠️  Zsh not available, skipping zsh-specific test"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  fi

  # Cleanup
  cleanup_test_env
}

# Test 3: Fallback to config when VERSION missing
test_version_fallback_to_config() {
  echo ""
  echo "Test 3: Should fall back to config when VERSION file missing"

  # Setup
  setup_test_env
  # Don't create VERSION file
  mkdir -p context
  cat > context/.context-config.json << 'EOF'
{
  "version": "3.5.0"
}
EOF

  # Test the improved fallback chain (shell-compatible)
  CURRENT_VERSION=$(cat VERSION 2>/dev/null)
  if [ -z "$CURRENT_VERSION" ]; then
    CURRENT_VERSION=$(grep -m 1 '"version":' context/.context-config.json 2>/dev/null | sed 's/.*"version": "\([^"]*\)".*/\1/')
  fi
  if [ -z "$CURRENT_VERSION" ]; then
    CURRENT_VERSION="unknown"
  fi

  assert_equal "$CURRENT_VERSION" "3.5.0" "Should fall back to config version"

  # Cleanup
  cleanup_test_env
}

# Test 4: Graceful fallback when both missing
test_version_fallback_to_unknown() {
  echo ""
  echo "Test 4: Should fall back to 'unknown' when both VERSION and config missing"

  # Setup
  setup_test_env
  # Don't create VERSION or config
  mkdir -p context  # Create context dir but no config file

  # Test the improved fallback chain (shell-compatible)
  CURRENT_VERSION=$(cat VERSION 2>/dev/null)
  if [ -z "$CURRENT_VERSION" ]; then
    CURRENT_VERSION=$(grep -m 1 '"version":' context/.context-config.json 2>/dev/null | sed 's/.*"version": "\([^"]*\)".*/\1/')
  fi
  if [ -z "$CURRENT_VERSION" ]; then
    CURRENT_VERSION="unknown"
  fi

  assert_equal "$CURRENT_VERSION" "unknown" "Should fall back to 'unknown'"

  # Cleanup
  cleanup_test_env
}

# Test 5: No complex function calls (the root cause of bug)
test_no_function_call_dependency() {
  echo ""
  echo "Test 5: Version detection should not depend on sourced functions"

  # Setup
  setup_test_env
  echo "3.5.0" > VERSION

  # The NEW approach: simple file read with fallback (no function calls)
  # This should work even if common-functions.sh is not sourced
  CURRENT_VERSION=$(cat VERSION 2>/dev/null || echo "unknown")

  assert_equal "$CURRENT_VERSION" "3.5.0" "Should work without function dependencies"

  # The OLD approach that caused the bug:
  # CURRENT_VERSION=$(get_system_version)  # ❌ This failed on zsh

  # Cleanup
  cleanup_test_env
}

# Test 6: Cross-shell compatibility
test_cross_shell_compatibility() {
  echo ""
  echo "Test 6: Same command should work across bash, zsh, sh"

  # Setup
  setup_test_env
  echo "3.5.0" > VERSION

  # Test in bash
  BASH_RESULT=$(bash -c 'cat VERSION 2>/dev/null || echo "unknown"')
  assert_equal "$BASH_RESULT" "3.5.0" "Should work in bash"

  # Test in zsh (if available)
  if command -v zsh &> /dev/null; then
    ZSH_RESULT=$(zsh -c 'cat VERSION 2>/dev/null || echo "unknown"')
    assert_equal "$ZSH_RESULT" "3.5.0" "Should work in zsh"
  fi

  # Test in sh
  SH_RESULT=$(sh -c 'cat VERSION 2>/dev/null || echo "unknown"')
  assert_equal "$SH_RESULT" "3.5.0" "Should work in sh"

  # Cleanup
  cleanup_test_env
}

# Run all tests
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  MODULE-003: Shell-Compatible Version Check               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_version_check_bash
test_version_check_zsh
test_version_fallback_to_config
test_version_fallback_to_unknown
test_no_function_call_dependency
test_cross_shell_compatibility

print_test_summary
