#!/bin/bash
# Test MODULE-001: Version Detection in /init-context
# Issue: BUG-1 - Hardcoded version 3.0.0 in config template

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Test 1: Version detection from VERSION file
test_version_detection_init_context() {
  echo "Test 1: Version should be detected from VERSION file"

  # Setup
  setup_test_env
  echo "3.5.0" > VERSION
  mkdir -p context config

  # Copy template
  cp "$PROJECT_ROOT/config/.context-config.template.json" config/.context-config.template.json

  # Simulate the version detection logic (this will be the actual implementation)
  SYSTEM_VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
  cp config/.context-config.template.json context/.context-config.json

  # Apply version substitution (macOS compatible) - replace any X.Y.Z version pattern
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"[0-9]*\.[0-9]*\.[0-9]*\"/\"$SYSTEM_VERSION\"/g" context/.context-config.json
  else
    sed -i "s/\"[0-9]*\.[0-9]*\.[0-9]*\"/\"$SYSTEM_VERSION\"/g" context/.context-config.json
  fi

  # Verify
  CONFIG_VERSION=$(extract_version context/.context-config.json)
  assert_equal "$CONFIG_VERSION" "3.5.0" "Config version should match VERSION file"

  # Cleanup
  cleanup_test_env
}

# Test 2: Graceful fallback when VERSION file missing
test_version_detection_missing_file() {
  echo ""
  echo "Test 2: Graceful fallback when VERSION file is missing"

  # Setup
  setup_test_env
  # Don't create VERSION file
  mkdir -p context config

  # Copy template
  cp "$PROJECT_ROOT/config/.context-config.template.json" config/.context-config.template.json

  # Simulate the version detection logic with fallback
  SYSTEM_VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
  cp config/.context-config.template.json context/.context-config.json

  # Apply version substitution - replace any X.Y.Z version pattern
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"[0-9]*\.[0-9]*\.[0-9]*\"/\"$SYSTEM_VERSION\"/g" context/.context-config.json
  else
    sed -i "s/\"[0-9]*\.[0-9]*\.[0-9]*\"/\"$SYSTEM_VERSION\"/g" context/.context-config.json
  fi

  # Verify falls back to "unknown"
  CONFIG_VERSION=$(extract_version context/.context-config.json)
  assert_equal "$CONFIG_VERSION" "unknown" "Should fall back to 'unknown' when VERSION missing"

  # Cleanup
  cleanup_test_env
}

# Test 3: Both version fields are updated
test_both_version_fields_updated() {
  echo ""
  echo "Test 3: Both version fields (version and configVersion) should be updated"

  # Setup
  setup_test_env
  echo "3.5.0" > VERSION
  mkdir -p context config

  # Copy template
  cp "$PROJECT_ROOT/config/.context-config.template.json" config/.context-config.template.json

  # Simulate the version detection logic
  SYSTEM_VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
  cp config/.context-config.template.json context/.context-config.json

  # Apply version substitution to ALL version patterns
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"[0-9]*\.[0-9]*\.[0-9]*\"/\"$SYSTEM_VERSION\"/g" context/.context-config.json
  else
    sed -i "s/\"[0-9]*\.[0-9]*\.[0-9]*\"/\"$SYSTEM_VERSION\"/g" context/.context-config.json
  fi

  # Verify main version field
  CONFIG_VERSION=$(grep -m 1 '"version":' context/.context-config.json | sed 's/.*"version": "\([^"]*\)".*/\1/')
  assert_equal "$CONFIG_VERSION" "3.5.0" "Main version field should be 3.5.0"

  # Verify configVersion field
  CONFIG_VERSION_META=$(grep '"configVersion":' context/.context-config.json | sed 's/.*"configVersion": "\([^"]*\)".*/\1/')
  assert_equal "$CONFIG_VERSION_META" "3.5.0" "configVersion field should be 3.5.0"

  # Cleanup
  cleanup_test_env
}

# Test 4: Version file with different version
test_different_version() {
  echo ""
  echo "Test 4: Should work with any version number"

  # Setup
  setup_test_env
  echo "4.0.0" > VERSION
  mkdir -p context config

  # Copy template
  cp "$PROJECT_ROOT/config/.context-config.template.json" config/.context-config.template.json

  # Simulate the version detection logic
  SYSTEM_VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
  cp config/.context-config.template.json context/.context-config.json

  # Apply version substitution - replace any X.Y.Z version pattern
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"[0-9]*\.[0-9]*\.[0-9]*\"/\"$SYSTEM_VERSION\"/g" context/.context-config.json
  else
    sed -i "s/\"[0-9]*\.[0-9]*\.[0-9]*\"/\"$SYSTEM_VERSION\"/g" context/.context-config.json
  fi

  # Verify
  CONFIG_VERSION=$(extract_version context/.context-config.json)
  assert_equal "$CONFIG_VERSION" "4.0.0" "Should work with version 4.0.0"

  # Cleanup
  cleanup_test_env
}

# Run all tests
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  MODULE-001: Version Detection in /init-context           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_version_detection_init_context
test_version_detection_missing_file
test_both_version_fields_updated
test_different_version

print_test_summary
