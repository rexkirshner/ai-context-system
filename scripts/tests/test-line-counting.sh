#!/bin/bash
# Test Phase 7.1: Line Counting for Codebase Scanner
# Version: See VERSION file at repository root
#
# Tests the line counting functions used by the codebase scanner
# to accurately report linesScanned metadata.
#
# Test cases:
# 1. count_file_lines() counts text files correctly
# 2. count_file_lines() returns 0 for binary files
# 3. count_file_lines() handles empty files
# 4. count_file_lines() handles files with only blank lines
# 5. count_file_lines() handles large files (10,000+ lines)
# 6. is_binary_file() correctly detects binary files
# 7. is_binary_file() correctly identifies text files
# 8. get_file_complexity() returns correct complexity level
# 9. aggregate_file_metadata() aggregates totals correctly
# 10. count_non_blank_lines() excludes blank lines

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Source common functions
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Test fixtures directory
TEST_DIR=""

setup_line_count_test_env() {
  TEST_DIR=$(mktemp -d -t acs-line-count-test.XXXXXX)
}

cleanup_line_count_test_env() {
  if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
  fi
}

# =============================================================================
# Test 1: count_file_lines() counts text files correctly
# =============================================================================
test_count_text_file() {
  echo "Test 1: count_file_lines() should count text files correctly"

  setup_line_count_test_env

  # Create a simple text file with 10 lines
  for i in {1..10}; do
    echo "Line $i of content"
  done > "$TEST_DIR/test.txt"

  local count
  count=$(count_file_lines "$TEST_DIR/test.txt")

  assert_equal "$count" "10" "Text file should have 10 lines"

  cleanup_line_count_test_env
}

# =============================================================================
# Test 2: count_file_lines() returns 0 for binary files
# =============================================================================
test_count_binary_file() {
  echo ""
  echo "Test 2: count_file_lines() should return 0 for binary files"

  setup_line_count_test_env

  # Create a binary file (PNG header)
  printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00' > "$TEST_DIR/image.png"

  local count
  count=$(count_file_lines "$TEST_DIR/image.png")

  assert_equal "$count" "0" "Binary file should return 0 lines"

  cleanup_line_count_test_env
}

# =============================================================================
# Test 3: count_file_lines() handles empty files
# =============================================================================
test_count_empty_file() {
  echo ""
  echo "Test 3: count_file_lines() should return 0 for empty files"

  setup_line_count_test_env

  # Create an empty file
  touch "$TEST_DIR/empty.txt"

  local count
  count=$(count_file_lines "$TEST_DIR/empty.txt")

  assert_equal "$count" "0" "Empty file should return 0 lines"

  cleanup_line_count_test_env
}

# =============================================================================
# Test 4: count_file_lines() handles files with only blank lines
# =============================================================================
test_count_blank_lines_only() {
  echo ""
  echo "Test 4: count_file_lines() should return 0 for files with only blank lines"

  setup_line_count_test_env

  # Create a file with only blank lines (newlines and whitespace)
  printf '\n\n   \n\t\n\n' > "$TEST_DIR/blank.txt"

  local count
  count=$(count_file_lines "$TEST_DIR/blank.txt")

  assert_equal "$count" "0" "File with only blank lines should return 0"

  cleanup_line_count_test_env
}

# =============================================================================
# Test 5: count_file_lines() handles large files
# =============================================================================
test_count_large_file() {
  echo ""
  echo "Test 5: count_file_lines() should handle large files (10,000+ lines)"

  setup_line_count_test_env

  # Create a file with 10,000 lines
  for i in $(seq 1 10000); do
    echo "Line $i"
  done > "$TEST_DIR/large.txt"

  local count
  count=$(count_file_lines "$TEST_DIR/large.txt")

  assert_equal "$count" "10000" "Large file should have 10000 lines"

  cleanup_line_count_test_env
}

# =============================================================================
# Test 6: is_binary_file() correctly detects binary files
# =============================================================================
test_is_binary_file_true() {
  echo ""
  echo "Test 6: is_binary_file() should return true for binary files"

  setup_line_count_test_env

  # Create various binary files
  printf '\x89PNG\r\n\x1a\n' > "$TEST_DIR/image.png"
  printf 'GIF89a' > "$TEST_DIR/image.gif"
  printf '\x00\x01\x02\x03\x04\x05' > "$TEST_DIR/binary.dat"

  local is_png is_gif is_dat
  is_png=$(is_binary_file "$TEST_DIR/image.png")
  is_gif=$(is_binary_file "$TEST_DIR/image.gif")
  is_dat=$(is_binary_file "$TEST_DIR/binary.dat")

  assert_equal "$is_png" "true" "PNG should be detected as binary"
  assert_equal "$is_gif" "true" "GIF should be detected as binary"
  assert_equal "$is_dat" "true" "Binary data should be detected as binary"

  cleanup_line_count_test_env
}

# =============================================================================
# Test 7: is_binary_file() correctly identifies text files
# =============================================================================
test_is_binary_file_false() {
  echo ""
  echo "Test 7: is_binary_file() should return false for text files"

  setup_line_count_test_env

  # Create various text files
  echo "function hello() { return 'world'; }" > "$TEST_DIR/code.js"
  echo "# Comment\nprint('hello')" > "$TEST_DIR/script.py"
  echo '{"key": "value"}' > "$TEST_DIR/data.json"
  echo "# Markdown heading" > "$TEST_DIR/readme.md"

  local is_js is_py is_json is_md
  is_js=$(is_binary_file "$TEST_DIR/code.js")
  is_py=$(is_binary_file "$TEST_DIR/script.py")
  is_json=$(is_binary_file "$TEST_DIR/data.json")
  is_md=$(is_binary_file "$TEST_DIR/readme.md")

  assert_equal "$is_js" "false" "JavaScript should be text"
  assert_equal "$is_py" "false" "Python should be text"
  assert_equal "$is_json" "false" "JSON should be text"
  assert_equal "$is_md" "false" "Markdown should be text"

  cleanup_line_count_test_env
}

# =============================================================================
# Test 8: get_file_complexity() returns correct complexity level
# =============================================================================
test_file_complexity() {
  echo ""
  echo "Test 8: get_file_complexity() should return correct complexity levels"

  setup_line_count_test_env

  # Create files with different sizes
  # Low: <50 lines
  for i in {1..25}; do echo "line $i"; done > "$TEST_DIR/small.txt"

  # Medium: 50-200 lines
  for i in {1..100}; do echo "line $i"; done > "$TEST_DIR/medium.txt"

  # High: >200 lines
  for i in {1..250}; do echo "line $i"; done > "$TEST_DIR/large.txt"

  local low_complexity medium_complexity high_complexity
  low_complexity=$(get_file_complexity 25)
  medium_complexity=$(get_file_complexity 100)
  high_complexity=$(get_file_complexity 250)

  assert_equal "$low_complexity" "low" "25 lines should be low complexity"
  assert_equal "$medium_complexity" "medium" "100 lines should be medium complexity"
  assert_equal "$high_complexity" "high" "250 lines should be high complexity"

  # Boundary tests
  local boundary_49 boundary_50 boundary_200 boundary_201
  boundary_49=$(get_file_complexity 49)
  boundary_50=$(get_file_complexity 50)
  boundary_200=$(get_file_complexity 200)
  boundary_201=$(get_file_complexity 201)

  assert_equal "$boundary_49" "low" "49 lines should be low"
  assert_equal "$boundary_50" "medium" "50 lines should be medium"
  assert_equal "$boundary_200" "medium" "200 lines should be medium"
  assert_equal "$boundary_201" "high" "201 lines should be high"

  cleanup_line_count_test_env
}

# =============================================================================
# Test 9: aggregate_file_metadata() aggregates totals correctly
# =============================================================================
test_aggregate_metadata() {
  echo ""
  echo "Test 9: aggregate_file_metadata() should aggregate totals correctly"

  setup_line_count_test_env

  # Create test files
  for i in {1..50}; do echo "line $i"; done > "$TEST_DIR/file1.ts"
  for i in {1..100}; do echo "line $i"; done > "$TEST_DIR/file2.ts"
  for i in {1..75}; do echo "line $i"; done > "$TEST_DIR/file3.ts"
  printf '\x89PNG\r\n\x1a\n' > "$TEST_DIR/image.png"

  # Aggregate metadata
  local result
  result=$(aggregate_file_metadata "$TEST_DIR")

  # Parse results
  local files_scanned lines_scanned binary_skipped
  files_scanned=$(echo "$result" | jq -r '.filesScanned')
  lines_scanned=$(echo "$result" | jq -r '.linesScanned')
  binary_skipped=$(echo "$result" | jq -r '.binaryFilesSkipped')

  assert_equal "$files_scanned" "3" "Should scan 3 text files"
  assert_equal "$lines_scanned" "225" "Should count 225 total lines (50+100+75)"
  assert_equal "$binary_skipped" "1" "Should skip 1 binary file"

  cleanup_line_count_test_env
}

# =============================================================================
# Test 10: count_non_blank_lines() excludes blank lines
# =============================================================================
test_count_non_blank_lines() {
  echo ""
  echo "Test 10: count_non_blank_lines() should exclude blank lines"

  setup_line_count_test_env

  # Create a file with mixed content and blank lines
  cat > "$TEST_DIR/mixed.txt" << 'EOF'
Line 1

Line 3

Line 5


Line 8
EOF

  local count
  count=$(count_non_blank_lines "$TEST_DIR/mixed.txt")

  assert_equal "$count" "4" "Should count only 4 non-blank lines"

  cleanup_line_count_test_env
}

# =============================================================================
# Test 11: get_language_from_extension() returns correct language
# =============================================================================
test_language_from_extension() {
  echo ""
  echo "Test 11: get_language_from_extension() should return correct language"

  local ts js py go rs java unknown

  ts=$(get_language_from_extension "file.ts")
  js=$(get_language_from_extension "file.js")
  py=$(get_language_from_extension "file.py")
  go=$(get_language_from_extension "file.go")
  rs=$(get_language_from_extension "file.rs")
  java=$(get_language_from_extension "file.java")
  unknown=$(get_language_from_extension "file.xyz")

  assert_equal "$ts" "typescript" "Should detect TypeScript"
  assert_equal "$js" "javascript" "Should detect JavaScript"
  assert_equal "$py" "python" "Should detect Python"
  assert_equal "$go" "go" "Should detect Go"
  assert_equal "$rs" "rust" "Should detect Rust"
  assert_equal "$java" "java" "Should detect Java"
  assert_equal "$unknown" "unknown" "Should return unknown for unrecognized"

  # Test with paths
  local path_ts path_nested
  path_ts=$(get_language_from_extension "src/components/Button.tsx")
  path_nested=$(get_language_from_extension "packages/lib/index.mjs")

  assert_equal "$path_ts" "typescript" "Should handle full paths (.tsx)"
  assert_equal "$path_nested" "javascript" "Should handle .mjs extension"
}

# =============================================================================
# Test 12: scan_file_for_lines() returns full file metadata
# =============================================================================
test_scan_file_for_lines() {
  echo ""
  echo "Test 12: scan_file_for_lines() should return full file metadata"

  setup_line_count_test_env

  # Create a test TypeScript file
  cat > "$TEST_DIR/component.tsx" << 'EOF'
import React from 'react';

export function Button() {
  return <button>Click me</button>;
}

export default Button;
EOF

  local result
  result=$(scan_file_for_lines "$TEST_DIR/component.tsx" "$TEST_DIR")

  local path lines language complexity
  path=$(echo "$result" | jq -r '.path')
  lines=$(echo "$result" | jq -r '.lines')
  language=$(echo "$result" | jq -r '.language')
  complexity=$(echo "$result" | jq -r '.complexity')

  assert_equal "$path" "component.tsx" "Path should be relative"
  assert_equal "$lines" "5" "Should have 5 non-blank lines"
  assert_equal "$language" "typescript" "Should detect TypeScript"
  assert_equal "$complexity" "low" "5 lines should be low complexity"

  cleanup_line_count_test_env
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 7.1: Line Counting Tests                           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_count_text_file
test_count_binary_file
test_count_empty_file
test_count_blank_lines_only
test_count_large_file
test_is_binary_file_true
test_is_binary_file_false
test_file_complexity
test_aggregate_metadata
test_count_non_blank_lines
test_language_from_extension
test_scan_file_for_lines

print_test_summary
