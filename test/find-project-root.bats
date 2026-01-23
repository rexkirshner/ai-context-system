#!/usr/bin/env bats
# Tests for find_project_root() function in common-functions.sh
# Verifies that ACS commands can work from any subdirectory

# Get the directory containing this test file
SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

setup() {
  # Create test directory structure
  TEST_DIR=$(mktemp -d)
  mkdir -p "$TEST_DIR/project/context"
  echo '{}' > "$TEST_DIR/project/context/.context-config.json"
  mkdir -p "$TEST_DIR/project/src/components/deep/nested"

  # Source the function
  source "$PROJECT_ROOT/scripts/common-functions.sh"
}

teardown() {
  cd /
  rm -rf "$TEST_DIR"
}

@test "find_project_root from project root" {
  cd "$TEST_DIR/project"
  result=$(find_project_root)
  [ "$result" = "$TEST_DIR/project" ]
}

@test "find_project_root from subdirectory" {
  cd "$TEST_DIR/project/src"
  result=$(find_project_root)
  [ "$result" = "$TEST_DIR/project" ]
}

@test "find_project_root from deep subdirectory" {
  cd "$TEST_DIR/project/src/components/deep/nested"
  result=$(find_project_root)
  [ "$result" = "$TEST_DIR/project" ]
}

@test "find_project_root fails outside project" {
  cd /tmp
  run find_project_root
  [ "$status" -eq 1 ]
  [[ "$output" == *"No ACS project found"* ]]
}

@test "find_project_root fails when too deep" {
  # Create very deep structure without context
  mkdir -p "$TEST_DIR/a/b/c/d/e/f/g"
  cd "$TEST_DIR/a/b/c/d/e/f/g"
  run find_project_root
  [ "$status" -eq 1 ]
}

@test "find_project_root returns absolute path" {
  cd "$TEST_DIR/project/src"
  result=$(find_project_root)
  # Absolute paths start with /
  [[ "$result" == /* ]]
}
