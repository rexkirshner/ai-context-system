#!/bin/bash
# Test Phase 9.1: Upgrade Protection - Custom File Detection
# Version: See VERSION file at repository root
#
# Tests the install manifest and modification detection system that
# protects user customizations during upgrades.
#
# Test cases:
# 1. record_install() creates valid manifest
# 2. Unmodified files detected correctly
# 3. Modified files detected correctly
# 4. New files (not in manifest) handled correctly
# 5. Deleted files handled correctly
# 6. Missing manifest treated as new installation
# 7. Hash computation is consistent
# 8. Manifest version tracking works

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Source common functions
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Test fixtures directory
TEST_DIR=""

setup_upgrade_test_env() {
  TEST_DIR=$(mktemp -d -t acs-upgrade-protection-test.XXXXXX)
  mkdir -p "$TEST_DIR/.claude/agents"
  mkdir -p "$TEST_DIR/.claude/commands"
  mkdir -p "$TEST_DIR/.claude/schemas"
}

cleanup_upgrade_test_env() {
  if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
  fi
}

# =============================================================================
# Test 1: record_install() creates valid manifest
# =============================================================================
test_record_install_creates_manifest() {
  echo "Test 1: record_install() should create valid manifest"

  setup_upgrade_test_env

  # Create some test files
  echo "# Security Reviewer Agent" > "$TEST_DIR/.claude/agents/security-reviewer.md"
  echo "# Build Check Command" > "$TEST_DIR/.claude/commands/build-check.md"
  echo '{"type": "object"}' > "$TEST_DIR/.claude/schemas/audit-finding.json"

  # Record installation
  record_install "$TEST_DIR" "5.1.0"

  # Check manifest exists
  local manifest="$TEST_DIR/.claude/.install-manifest.json"
  assert_file_exists "$manifest" "Install manifest"

  # Check manifest is valid JSON
  if jq -e '.' "$manifest" >/dev/null 2>&1; then
    echo -e "\033[0;32m✓\033[0m Manifest is valid JSON"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Manifest is not valid JSON"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi

  # Check required fields exist
  local has_version has_installed_at has_files
  has_version=$(jq -r '.version // "missing"' "$manifest")
  has_installed_at=$(jq -r '.installedAt // "missing"' "$manifest")
  has_files=$(jq -r '.files | type' "$manifest")

  assert_equal "$has_version" "5.1.0" "Manifest should have correct version"
  assert_equal "$has_files" "array" "Manifest should have files array"

  # Check that files were recorded
  local file_count
  file_count=$(jq '.files | length' "$manifest")
  local has_files_recorded
  has_files_recorded=$([ "$file_count" -gt 0 ] && echo "yes" || echo "no")
  assert_equal "$has_files_recorded" "yes" "Manifest should have recorded files"

  cleanup_upgrade_test_env
}

# =============================================================================
# Test 2: Unmodified files detected correctly
# =============================================================================
test_unmodified_file_detection() {
  echo ""
  echo "Test 2: Unmodified files should be detected as unchanged"

  setup_upgrade_test_env

  # Create test file
  echo "# Original Content" > "$TEST_DIR/.claude/agents/test-agent.md"

  # Record installation
  record_install "$TEST_DIR" "5.1.0"

  # Check if file is modified (should be false)
  local is_modified
  is_modified=$(is_file_modified "$TEST_DIR/.claude/agents/test-agent.md" "$TEST_DIR")

  assert_equal "$is_modified" "false" "Unmodified file should be detected as unchanged"

  cleanup_upgrade_test_env
}

# =============================================================================
# Test 3: Modified files detected correctly
# =============================================================================
test_modified_file_detection() {
  echo ""
  echo "Test 3: Modified files should be detected as changed"

  setup_upgrade_test_env

  # Create test file
  echo "# Original Content" > "$TEST_DIR/.claude/agents/test-agent.md"

  # Record installation
  record_install "$TEST_DIR" "5.1.0"

  # Modify the file
  echo "# Modified Content" >> "$TEST_DIR/.claude/agents/test-agent.md"

  # Check if file is modified (should be true)
  local is_modified
  is_modified=$(is_file_modified "$TEST_DIR/.claude/agents/test-agent.md" "$TEST_DIR")

  assert_equal "$is_modified" "true" "Modified file should be detected as changed"

  cleanup_upgrade_test_env
}

# =============================================================================
# Test 4: New files (not in manifest) handled correctly
# =============================================================================
test_new_file_handling() {
  echo ""
  echo "Test 4: New files not in manifest should return 'new'"

  setup_upgrade_test_env

  # Create one file and record installation
  echo "# Original" > "$TEST_DIR/.claude/agents/original.md"
  record_install "$TEST_DIR" "5.1.0"

  # Create a new file NOT in manifest
  echo "# New File" > "$TEST_DIR/.claude/agents/new-agent.md"

  # Check if new file is detected
  local is_modified
  is_modified=$(is_file_modified "$TEST_DIR/.claude/agents/new-agent.md" "$TEST_DIR")

  assert_equal "$is_modified" "new" "New file should be detected as 'new'"

  cleanup_upgrade_test_env
}

# =============================================================================
# Test 5: Missing manifest treated as new installation
# =============================================================================
test_missing_manifest() {
  echo ""
  echo "Test 5: Missing manifest should treat files as new"

  setup_upgrade_test_env

  # Create file but NO manifest
  echo "# Some Content" > "$TEST_DIR/.claude/agents/test.md"

  # Check modification status (should be "new" since no manifest)
  local is_modified
  is_modified=$(is_file_modified "$TEST_DIR/.claude/agents/test.md" "$TEST_DIR")

  assert_equal "$is_modified" "new" "Missing manifest should treat files as new"

  cleanup_upgrade_test_env
}

# =============================================================================
# Test 6: Hash computation is consistent
# =============================================================================
test_hash_consistency() {
  echo ""
  echo "Test 6: Hash computation should be consistent"

  setup_upgrade_test_env

  # Create test file
  echo "Test content for hashing" > "$TEST_DIR/test-file.txt"

  # Compute hash twice
  local hash1 hash2
  hash1=$(compute_file_hash "$TEST_DIR/test-file.txt")
  hash2=$(compute_file_hash "$TEST_DIR/test-file.txt")

  assert_equal "$hash1" "$hash2" "Same file should produce same hash"

  # Modify file
  echo "Modified content" >> "$TEST_DIR/test-file.txt"
  local hash3
  hash3=$(compute_file_hash "$TEST_DIR/test-file.txt")

  local hashes_differ
  hashes_differ=$([ "$hash1" != "$hash3" ] && echo "yes" || echo "no")
  assert_equal "$hashes_differ" "yes" "Modified file should produce different hash"

  cleanup_upgrade_test_env
}

# =============================================================================
# Test 7: get_modified_files returns correct list
# =============================================================================
test_get_modified_files() {
  echo ""
  echo "Test 7: get_modified_files should return correct list"

  setup_upgrade_test_env

  # Create test files
  echo "# Agent 1" > "$TEST_DIR/.claude/agents/agent1.md"
  echo "# Agent 2" > "$TEST_DIR/.claude/agents/agent2.md"
  echo "# Agent 3" > "$TEST_DIR/.claude/agents/agent3.md"

  # Record installation
  record_install "$TEST_DIR" "5.1.0"

  # Modify agent2 only
  echo "# Modified" >> "$TEST_DIR/.claude/agents/agent2.md"

  # Get modified files
  local modified_files
  modified_files=$(get_modified_files "$TEST_DIR")

  # Check that agent2 is in the list
  if echo "$modified_files" | grep -q "agent2.md"; then
    echo -e "\033[0;32m✓\033[0m Modified file agent2.md is in the list"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Modified file agent2.md should be in the list"
    echo "   Got: $modified_files"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi

  # Check that unmodified files are NOT in the list
  local has_agent1 has_agent3
  has_agent1=$(echo "$modified_files" | grep -c "agent1.md" || true)
  has_agent3=$(echo "$modified_files" | grep -c "agent3.md" || true)

  if [ "$has_agent1" -eq 0 ] && [ "$has_agent3" -eq 0 ]; then
    echo -e "\033[0;32m✓\033[0m Unmodified files not in the list"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Unmodified files should not be in the list"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi

  cleanup_upgrade_test_env
}

# =============================================================================
# Test 8: Manifest includes file paths relative to project root
# =============================================================================
test_manifest_relative_paths() {
  echo ""
  echo "Test 8: Manifest should use relative paths"

  setup_upgrade_test_env

  # Create test file
  echo "# Test" > "$TEST_DIR/.claude/agents/test.md"

  # Record installation
  record_install "$TEST_DIR" "5.1.0"

  # Check that paths are relative (not absolute)
  local manifest="$TEST_DIR/.claude/.install-manifest.json"
  local first_path
  first_path=$(jq -r '.files[0].path' "$manifest")

  # Path should start with .claude/ not /
  local is_relative
  is_relative=$(echo "$first_path" | grep -q "^\.claude/" && echo "yes" || echo "no")

  assert_equal "$is_relative" "yes" "Manifest paths should be relative"

  cleanup_upgrade_test_env
}

# =============================================================================
# Test 9: update_manifest_file updates hash for specific file
# =============================================================================
test_update_manifest_file() {
  echo ""
  echo "Test 9: update_manifest_file should update hash for specific file"

  setup_upgrade_test_env

  # Create test file
  echo "# Original" > "$TEST_DIR/.claude/agents/test.md"

  # Record installation
  record_install "$TEST_DIR" "5.1.0"

  # Get original hash
  local manifest="$TEST_DIR/.claude/.install-manifest.json"
  local original_hash
  original_hash=$(jq -r '.files[] | select(.path == ".claude/agents/test.md") | .installedHash' "$manifest")

  # Modify file
  echo "# Modified" > "$TEST_DIR/.claude/agents/test.md"

  # Update manifest for this file
  update_manifest_file ".claude/agents/test.md" "$TEST_DIR"

  # Get new hash
  local new_hash
  new_hash=$(jq -r '.files[] | select(.path == ".claude/agents/test.md") | .installedHash' "$manifest")

  local hashes_differ
  hashes_differ=$([ "$original_hash" != "$new_hash" ] && echo "yes" || echo "no")
  assert_equal "$hashes_differ" "yes" "Manifest should have updated hash"

  cleanup_upgrade_test_env
}

# =============================================================================
# Test 10: Manifest tracks installation timestamp
# =============================================================================
test_manifest_timestamps() {
  echo ""
  echo "Test 10: Manifest should track installation timestamps"

  setup_upgrade_test_env

  # Create test file
  echo "# Test" > "$TEST_DIR/.claude/agents/test.md"

  # Record installation
  record_install "$TEST_DIR" "5.1.0"

  # Check manifest has installedAt
  local manifest="$TEST_DIR/.claude/.install-manifest.json"
  local installed_at
  installed_at=$(jq -r '.installedAt' "$manifest")

  # Should be an ISO 8601 timestamp
  if echo "$installed_at" | grep -qE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T"; then
    echo -e "\033[0;32m✓\033[0m Manifest has valid timestamp: $installed_at"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Manifest should have ISO 8601 timestamp"
    echo "   Got: $installed_at"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi

  cleanup_upgrade_test_env
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 9.1: Upgrade Protection Tests                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_record_install_creates_manifest
test_unmodified_file_detection
test_modified_file_detection
test_new_file_handling
test_missing_manifest
test_hash_consistency
test_get_modified_files
test_manifest_relative_paths
test_update_manifest_file
test_manifest_timestamps

print_test_summary
