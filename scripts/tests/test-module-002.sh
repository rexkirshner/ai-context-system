#!/bin/bash
# Test MODULE-002: Version Detection in /update-context-system
# Issue: BUG-1 - Config version not updated during system upgrade

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Test 1: Version update on upgrade
test_version_update_on_upgrade() {
  echo "Test 1: Config version should update when system is upgraded"

  # Setup - simulate existing v3.4.0 project
  setup_test_env
  echo "3.4.0" > VERSION
  mkdir -p context

  # Create config with old version
  cat > context/.context-config.json << 'EOF'
{
  "version": "3.4.0",
  "configVersion": "3.4.0"
}
EOF

  # Simulate upgrade to v3.5.0
  echo "3.5.0" > VERSION

  # Apply the update logic (this is what we'll implement)
  SYSTEM_VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
  if [ "$SYSTEM_VERSION" != "unknown" ]; then
    # macOS/Linux compatible sed
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
      sed -i '' "s/\"configVersion\": \"[^\"]*\"/\"configVersion\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
    else
      sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
      sed -i "s/\"configVersion\": \"[^\"]*\"/\"configVersion\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
    fi
  fi

  # Verify version was updated
  CONFIG_VERSION=$(extract_version context/.context-config.json)
  assert_equal "$CONFIG_VERSION" "3.5.0" "Config should update to new version"

  # Verify configVersion was also updated
  CONFIG_VERSION_META=$(grep '"configVersion":' context/.context-config.json | sed 's/.*"configVersion": "\([^"]*\)".*/\1/')
  assert_equal "$CONFIG_VERSION_META" "3.5.0" "configVersion should also update"

  # Cleanup
  cleanup_test_env
}

# Test 2: Multiple version updates
test_multiple_version_updates() {
  echo ""
  echo "Test 2: Should handle multiple version updates correctly"

  # Setup
  setup_test_env
  mkdir -p context

  # Start with v3.0.0
  echo "3.0.0" > VERSION
  cat > context/.context-config.json << 'EOF'
{
  "version": "3.0.0",
  "configVersion": "3.0.0"
}
EOF

  # Upgrade to v3.4.0
  echo "3.4.0" > VERSION
  SYSTEM_VERSION=$(cat VERSION)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
    sed -i '' "s/\"configVersion\": \"[^\"]*\"/\"configVersion\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
  else
    sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
    sed -i "s/\"configVersion\": \"[^\"]*\"/\"configVersion\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
  fi

  CONFIG_VERSION=$(extract_version context/.context-config.json)
  assert_equal "$CONFIG_VERSION" "3.4.0" "First upgrade to 3.4.0 should work"

  # Upgrade to v3.5.0
  echo "3.5.0" > VERSION
  SYSTEM_VERSION=$(cat VERSION)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
    sed -i '' "s/\"configVersion\": \"[^\"]*\"/\"configVersion\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
  else
    sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
    sed -i "s/\"configVersion\": \"[^\"]*\"/\"configVersion\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
  fi

  CONFIG_VERSION=$(extract_version context/.context-config.json)
  assert_equal "$CONFIG_VERSION" "3.5.0" "Second upgrade to 3.5.0 should work"

  # Cleanup
  cleanup_test_env
}

# Test 3: Preserves other config settings
test_preserves_other_settings() {
  echo ""
  echo "Test 3: Version update should preserve other configuration settings"

  # Setup
  setup_test_env
  echo "3.5.0" > VERSION
  mkdir -p context

  # Create config with various settings
  cat > context/.context-config.json << 'EOF'
{
  "version": "3.4.0",
  "owner": "Test User",
  "projectName": "Test Project",
  "configVersion": "3.4.0",
  "preferences": {
    "workflow": "test-workflow"
  }
}
EOF

  # Apply update
  SYSTEM_VERSION=$(cat VERSION)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
    sed -i '' "s/\"configVersion\": \"[^\"]*\"/\"configVersion\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
  else
    sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
    sed -i "s/\"configVersion\": \"[^\"]*\"/\"configVersion\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
  fi

  # Verify version updated
  CONFIG_VERSION=$(extract_version context/.context-config.json)
  assert_equal "$CONFIG_VERSION" "3.5.0" "Version should be updated"

  # Verify other settings preserved
  OWNER=$(grep '"owner":' context/.context-config.json | sed 's/.*"owner": "\([^"]*\)".*/\1/')
  assert_equal "$OWNER" "Test User" "Owner should be preserved"

  PROJECT_NAME=$(grep '"projectName":' context/.context-config.json | sed 's/.*"projectName": "\([^"]*\)".*/\1/')
  assert_equal "$PROJECT_NAME" "Test Project" "Project name should be preserved"

  # Cleanup
  cleanup_test_env
}

# Test 4: Handles missing VERSION file gracefully
test_missing_version_file() {
  echo ""
  echo "Test 4: Should handle missing VERSION file gracefully"

  # Setup
  setup_test_env
  # Don't create VERSION file
  mkdir -p context

  cat > context/.context-config.json << 'EOF'
{
  "version": "3.4.0",
  "configVersion": "3.4.0"
}
EOF

  # Try to update (should skip if VERSION missing)
  SYSTEM_VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
  if [ "$SYSTEM_VERSION" != "unknown" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
      sed -i '' "s/\"configVersion\": \"[^\"]*\"/\"configVersion\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
    else
      sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
      sed -i "s/\"configVersion\": \"[^\"]*\"/\"configVersion\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
    fi
  fi

  # Verify version unchanged (update was skipped)
  CONFIG_VERSION=$(extract_version context/.context-config.json)
  assert_equal "$CONFIG_VERSION" "3.4.0" "Version should remain unchanged when VERSION file missing"

  # Cleanup
  cleanup_test_env
}

# Run all tests
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  MODULE-002: Version Detection in /update-context-system  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_version_update_on_upgrade
test_multiple_version_updates
test_preserves_other_settings
test_missing_version_file

print_test_summary
