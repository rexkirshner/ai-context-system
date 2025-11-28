#!/bin/bash
# AI Context System v3.5.0 - Test Helpers
# Shared assertion functions for modular tests

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test environment
TEST_ENV_DIR=""

# Setup test environment
setup_test_env() {
  TEST_ENV_DIR=$(mktemp -d -t acs-test.XXXXXX)
  cd "$TEST_ENV_DIR" || exit 1

  # Copy necessary files from ai-context-system
  mkdir -p .claude/commands
  mkdir -p scripts
  mkdir -p config
  mkdir -p templates
  mkdir -p reference

  echo "✓ Test environment created: $TEST_ENV_DIR"
}

# Cleanup test environment
cleanup_test_env() {
  if [ -n "$TEST_ENV_DIR" ] && [ -d "$TEST_ENV_DIR" ]; then
    cd /
    rm -rf "$TEST_ENV_DIR"
    echo "✓ Test environment cleaned up"
  fi
}

# Assertions

assert_equal() {
  local actual="$1"
  local expected="$2"
  local message="${3:-Values should be equal}"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [ "$actual" = "$expected" ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $message"
    echo "  Expected: '$expected'"
    echo "  Actual:   '$actual'"
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message"
    echo "  Expected: '$expected'"
    echo "  Actual:   '$actual'"
    return 1
  fi
}

assert_not_equal() {
  local actual="$1"
  local expected="$2"
  local message="${3:-Values should not be equal}"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [ "$actual" != "$expected" ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $message"
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message"
    echo "  Should not equal: '$expected'"
    echo "  Actual:           '$actual'"
    return 1
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local message="${3:-String should contain substring}"

  TESTS_RUN=$((TESTS_RUN + 1))

  if echo "$haystack" | grep -q "$needle"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $message"
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message"
    echo "  Should contain: '$needle'"
    echo "  Actual string: '$haystack'"
    return 1
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local message="${3:-String should not contain substring}"

  TESTS_RUN=$((TESTS_RUN + 1))

  if ! echo "$haystack" | grep -q "$needle"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $message"
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message"
    echo "  Should not contain: '$needle'"
    echo "  Found in: '$haystack'"
    return 1
  fi
}

assert_file_exists() {
  local file="$1"
  local message="${2:-File should exist}"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [ -f "$file" ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $message: $file"
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message: $file"
    return 1
  fi
}

assert_file_not_exists() {
  local file="$1"
  local message="${2:-File should not exist}"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [ ! -f "$file" ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $message: $file"
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message: $file"
    return 1
  fi
}

assert_directory_exists() {
  local dir="$1"
  local message="${2:-Directory should exist}"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [ -d "$dir" ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $message: $dir"
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message: $dir"
    return 1
  fi
}

assert_success() {
  local message="${1:-Command should succeed}"
  local exit_code=$?

  TESTS_RUN=$((TESTS_RUN + 1))

  if [ $exit_code -eq 0 ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $message"
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message (exit code: $exit_code)"
    return 1
  fi
}

assert_failure() {
  local message="${1:-Command should fail}"
  local exit_code=$?

  TESTS_RUN=$((TESTS_RUN + 1))

  if [ $exit_code -ne 0 ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $message"
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message (expected failure but succeeded)"
    return 1
  fi
}

assert_greater_than() {
  local actual="$1"
  local expected="$2"
  local message="${3:-Value should be greater than threshold}"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [ "$actual" -gt "$expected" ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $message"
    echo "  Expected > $expected"
    echo "  Actual:    $actual"
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message"
    echo "  Expected > $expected"
    echo "  Actual:    $actual"
    return 1
  fi
}

assert_less_than() {
  local actual="$1"
  local expected="$2"
  local message="${3:-Value should be less than threshold}"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [ "$actual" -lt "$expected" ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $message"
    echo "  Expected < $expected"
    echo "  Actual:    $actual"
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message"
    echo "  Expected < $expected"
    echo "  Actual:    $actual"
    return 1
  fi
}

# Helper functions

extract_version() {
  local file="${1:-context/.context-config.json}"
  grep -m 1 '"version":' "$file" | sed 's/.*"version": "\([^"]*\)".*/\1/' || echo "unknown"
}

create_test_sessions() {
  local count=$1
  local sessions_file="${2:-context/SESSIONS.md}"

  mkdir -p "$(dirname "$sessions_file")"

  cat > "$sessions_file" << 'EOF'
# Sessions

## Session Index
[Index here]

---

EOF

  for i in $(seq 1 "$count"); do
    cat >> "$sessions_file" << EOF
## Session $i | 2025-11-$(printf "%02d" $((i % 30 + 1))) | Test Session

**TL;DR:** Test session number $i for testing purposes.

### Accomplishments
- Test accomplishment 1
- Test accomplishment 2

### Git Operations
- 1 commit

---

EOF
  done

  echo "Created test SESSIONS.md with $count sessions"
}

create_large_sessions_file() {
  local lines=$1
  local sessions_file="${2:-context/SESSIONS.md}"

  mkdir -p "$(dirname "$sessions_file")"

  # Each session is ~50 lines, so calculate sessions needed
  local sessions=$((lines / 50))
  create_test_sessions "$sessions" "$sessions_file"
}

# Test result reporting

print_test_summary() {
  echo ""
  echo "════════════════════════════════════════════════════════════"
  echo "Test Summary"
  echo "════════════════════════════════════════════════════════════"
  echo "Total tests:  $TESTS_RUN"
  echo -e "Passed:       ${GREEN}$TESTS_PASSED${NC}"
  echo -e "Failed:       ${RED}$TESTS_FAILED${NC}"

  if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ ALL TESTS PASSED${NC}"
    return 0
  else
    echo -e "\n${RED}✗ SOME TESTS FAILED${NC}"
    return 1
  fi
}

# Run tests function
run_tests() {
  local test_file="$1"

  echo "════════════════════════════════════════════════════════════"
  echo "Running tests: $test_file"
  echo "════════════════════════════════════════════════════════════"
  echo ""

  # Source the test file if provided
  if [ -n "$test_file" ] && [ -f "$test_file" ]; then
    source "$test_file"
  fi

  # Print summary
  print_test_summary
}

# Export functions for use in tests
export -f setup_test_env
export -f cleanup_test_env
export -f assert_equal
export -f assert_not_equal
export -f assert_contains
export -f assert_not_contains
export -f assert_file_exists
export -f assert_file_not_exists
export -f assert_directory_exists
export -f assert_success
export -f assert_failure
export -f assert_greater_than
export -f assert_less_than
export -f extract_version
export -f create_test_sessions
export -f create_large_sessions_file
export -f print_test_summary
export -f run_tests
