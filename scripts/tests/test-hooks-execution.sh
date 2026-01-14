#!/bin/bash
# test-hooks-execution.sh - Validate hooks execute correctly
# Tests session-start.sh hook behavior

set -e

echo "=== Hooks Execution Tests ==="
echo ""

PASS=0
FAIL=0

check() {
  if eval "$1" > /dev/null 2>&1; then
    echo "✓ $2"
    PASS=$((PASS + 1))
  else
    echo "✗ $2"
    FAIL=$((FAIL + 1))
  fi
}

HOOK_SCRIPT=".claude/hooks/session-start.sh"

echo "--- Hook Structure ---"
check "test -f '$HOOK_SCRIPT'" "session-start.sh exists"
check "test -x '$HOOK_SCRIPT'" "session-start.sh is executable"
check "head -1 '$HOOK_SCRIPT' | grep -q '#!/bin/bash'" "Has bash shebang"
check "grep -q 'set -e' '$HOOK_SCRIPT'" "Uses set -e for safety"
check "bash -n '$HOOK_SCRIPT'" "Script syntax is valid"

echo ""
echo "--- Safety Features ---"
check "grep -q 'Exit code 1' '$HOOK_SCRIPT'" "Documents exit codes"
check "grep -q 'Timeout' '$HOOK_SCRIPT'" "Documents timeout"
check "grep -q 'Idempotent' '$HOOK_SCRIPT'" "Documents idempotency"
check "grep -q 'No writes' '$HOOK_SCRIPT'" "Documents read-only nature"

echo ""
echo "--- Context Detection ---"
check "grep -q 'context' '$HOOK_SCRIPT'" "Checks for context directory"
check "grep -q '.context' '$HOOK_SCRIPT'" "Checks for .context directory"
check "grep -q 'exit 0' '$HOOK_SCRIPT'" "Exits gracefully when no context"

echo ""
echo "--- Health Checks ---"
check "grep -q 'STATUS.md' '$HOOK_SCRIPT'" "Checks STATUS.md"
check "grep -q 'SESSIONS.md' '$HOOK_SCRIPT'" "Checks SESSIONS.md"
check "grep -q 'WARNINGS' '$HOOK_SCRIPT'" "Tracks warnings"
check "grep -q 'Quick Reference' '$HOOK_SCRIPT'" "Checks Quick Reference"
check "grep -q 'Current Focus' '$HOOK_SCRIPT'" "Checks Current Focus"

echo ""
echo "--- Cross-Platform ---"
check "grep -q 'darwin' '$HOOK_SCRIPT'" "Has macOS detection"
check "grep -q 'stat -f' '$HOOK_SCRIPT'" "Uses macOS stat format"
check "grep -q 'stat -c' '$HOOK_SCRIPT'" "Uses Linux stat format"

echo ""
echo "--- Profile Support ---"
check "grep -q 'settings.json' '$HOOK_SCRIPT'" "Reads settings"
check "grep -q 'profile' '$HOOK_SCRIPT'" "Checks profile setting"
check "grep -q 'minimal' '$HOOK_SCRIPT'" "Respects minimal profile"

echo ""
echo "--- Simulated Execution Tests ---"

# Create temp directory with mock context
TEST_DIR=$(mktemp -d)
mkdir -p "$TEST_DIR/context"
mkdir -p "$TEST_DIR/.claude/hooks"
cp "$HOOK_SCRIPT" "$TEST_DIR/.claude/hooks/"

# Create mock STATUS.md
cat > "$TEST_DIR/context/STATUS.md" << 'EOF'
# STATUS

## Current Focus
Testing the system

<!-- BEGIN AUTO:QUICK_REFERENCE -->
Quick reference content
<!-- END AUTO:QUICK_REFERENCE -->
EOF

# Create mock SESSIONS.md with balanced markers
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Sessions

<!-- BEGIN SESSION -->
Session 1
<!-- END SESSION -->
EOF

# Run hook in test directory
cd "$TEST_DIR"
OUTPUT=$(bash .claude/hooks/session-start.sh 2>&1 || true)
cd - > /dev/null

# Check output contains expected content
check "echo '$OUTPUT' | grep -q 'ACS:'" "Hook outputs ACS prefix"
check "echo '$OUTPUT' | grep -q 'Context health'" "Hook outputs health check header"
check "echo '$OUTPUT' | grep -q 'Status:'" "Hook outputs status"

# Test with missing STATUS.md
rm "$TEST_DIR/context/STATUS.md"
cd "$TEST_DIR"
OUTPUT_NO_STATUS=$(bash .claude/hooks/session-start.sh 2>&1 || true)
cd - > /dev/null
check "echo '$OUTPUT_NO_STATUS' | grep -q 'No STATUS.md'" "Reports missing STATUS.md"

# Test with no context directory
rm -rf "$TEST_DIR/context"
cd "$TEST_DIR"
OUTPUT_NO_CONTEXT=$(bash .claude/hooks/session-start.sh 2>&1 || true)
cd - > /dev/null
# Should exit silently
check "[ -z '$OUTPUT_NO_CONTEXT' ]" "Exits silently without context"

# Test unclosed session detection
mkdir -p "$TEST_DIR/context"
cat > "$TEST_DIR/context/STATUS.md" << 'EOF'
# STATUS
## Current Focus
Testing
<!-- BEGIN AUTO:QUICK_REFERENCE -->
<!-- END AUTO:QUICK_REFERENCE -->
EOF
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
<!-- BEGIN SESSION -->
Unclosed session
EOF
cd "$TEST_DIR"
OUTPUT_UNCLOSED=$(bash .claude/hooks/session-start.sh 2>&1 || true)
cd - > /dev/null
check "echo '$OUTPUT_UNCLOSED' | grep -q 'Unclosed session'" "Detects unclosed sessions"

# Cleanup
rm -rf "$TEST_DIR"

echo ""
echo "=== Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "✅ ALL HOOKS EXECUTION TESTS PASSED"
else
  echo "❌ SOME TESTS FAILED"
fi

exit $FAIL
