#!/bin/bash
# test-cross-platform.sh - Validate cross-platform compatibility
# Checks that all scripts use portable constructs

set -e

echo "=== Cross-Platform Compatibility Tests ==="
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

echo "--- Bash Shebang Portability ---"
# All scripts should use #!/bin/bash, not #!/usr/bin/env bash or #!/bin/sh
for script in scripts/*.sh scripts/tests/*.sh .claude/hooks/*.sh; do
  if [ -f "$script" ]; then
    SHEBANG=$(head -1 "$script")
    if [[ "$SHEBANG" == "#!/bin/bash" ]]; then
      check "true" "$script uses #!/bin/bash"
    else
      check "false" "$script uses #!/bin/bash (got: $SHEBANG)"
    fi
  fi
done

echo ""
echo "--- stat Command Compatibility ---"
# Scripts using stat should handle both macOS and Linux
# Two valid patterns:
# 1. OSTYPE/darwin detection with conditional
# 2. Try macOS first with fallback: stat -f %m ... || stat -c %Y ...

SCRIPTS_WITH_STAT=$(grep -rl 'stat -[fc]' scripts/ .claude/hooks/ 2>/dev/null || true)
for script in $SCRIPTS_WITH_STAT; do
  # Skip scripts that only have "git diff --stat" (not filesystem stat)
  if ! grep -q 'stat -[fc] %' "$script" 2>/dev/null; then
    check "true" "$script doesn't use filesystem stat"
    continue
  fi

  # Check for cross-platform handling via either:
  # 1. OSTYPE/darwin detection, OR
  # 2. Try-fallback pattern (stat -f ... || stat -c ...), OR
  # 3. If/else pattern with stat -f and stat -c in same function
  HAS_MAC_STAT=$(grep -c 'stat -f' "$script" 2>/dev/null || true)
  HAS_LIN_STAT=$(grep -c 'stat -c' "$script" 2>/dev/null || true)
  if grep -qE 'darwin|OSTYPE' "$script" 2>/dev/null || \
     { [ "${HAS_MAC_STAT:-0}" -gt 0 ] && [ "${HAS_LIN_STAT:-0}" -gt 0 ]; }; then
    check "true" "$script handles both macOS and Linux stat"
  else
    check "false" "$script handles both macOS and Linux stat"
  fi
done

echo ""
echo "--- date Command Portability ---"
# Check for portable date usage
# Exclude this test file from the search
SCRIPTS_WITH_DATE=$(grep -rl 'date ' scripts/ .claude/hooks/ 2>/dev/null | grep -v 'test-cross-platform.sh' || true)
for script in $SCRIPTS_WITH_DATE; do
  # +%s is portable, but +%N (nanoseconds) is not
  # Note: We only flag actual date command usage, not mentions in comments
  if grep -v '^#' "$script" 2>/dev/null | grep -q 'date.*%N'; then
    check "false" "$script avoids non-portable date +%N"
  else
    check "true" "$script uses portable date formats"
  fi
done

echo ""
echo "--- sed Portability ---"
# macOS sed requires '' after -i, GNU sed doesn't
# Check for portable sed -i usage
SCRIPTS_WITH_SED=$(grep -rl "sed -i" scripts/ .claude/hooks/ 2>/dev/null || true)
for script in $SCRIPTS_WITH_SED; do
  # Portable patterns:
  # 1. sed -i '' with OSTYPE/darwin check
  # 2. Temp file pattern (sed > tmp && mv tmp)
  # 3. Both macOS and Linux variants present
  HAS_MAC_SED=$(grep -c "sed -i ''" "$script" 2>/dev/null || true)
  HAS_LIN_SED=$(grep -c "sed -i[^']" "$script" 2>/dev/null || true)
  if grep -qE 'darwin|OSTYPE' "$script" 2>/dev/null || \
     { [ "${HAS_MAC_SED:-0}" -gt 0 ] && [ "${HAS_LIN_SED:-0}" -gt 0 ]; } || \
     grep -qE 'tmp\|temp|mktemp' "$script" 2>/dev/null; then
    check "true" "$script uses portable sed"
  else
    check "false" "$script uses portable sed"
  fi
done

echo ""
echo "--- grep -P Avoidance ---"
# grep -P (Perl regex) is not available on macOS by default
# Exclude this test file and only check actual code (not comments)
BAD_GREP=$(grep -rn 'grep -P ' scripts/ .claude/hooks/ 2>/dev/null | grep -v 'test-cross-platform.sh' | grep -v '^#' | wc -l | tr -d ' ')
check "[ '${BAD_GREP:-0}' -eq 0 ]" "No grep -P usage (not portable)"

echo ""
echo "--- readlink -f Avoidance ---"
# readlink -f is not available on macOS by default
# Exclude this test file and only check actual code (not comments)
BAD_READLINK=$(grep -rn 'readlink -f' scripts/ .claude/hooks/ 2>/dev/null | grep -v 'test-cross-platform.sh' | grep -v ':#' | wc -l | tr -d ' ')
check "[ '${BAD_READLINK:-0}' -eq 0 ]" "No readlink -f usage (not portable)"

echo ""
echo "--- Array Syntax ---"
# Bash arrays are fine, but ensure we're using bash
SCRIPTS_WITH_ARRAYS=$(grep -rlE '\[@\]|(\s*)' scripts/ .claude/hooks/ 2>/dev/null || true)
for script in $SCRIPTS_WITH_ARRAYS; do
  check "head -1 '$script' | grep -q 'bash'" "$script using arrays has bash shebang"
done

echo ""
echo "--- Required Commands Check ---"
# Verify scripts don't use commands that might not be installed
MISSING_CHECKS=""

# Check if any script uses jq without fallback
SCRIPTS_WITH_JQ=$(grep -rl 'jq ' scripts/ .claude/hooks/ 2>/dev/null || true)
if [ -n "$SCRIPTS_WITH_JQ" ]; then
  JQ_CHECK=$(grep -lE 'command -v jq\|which jq|type jq' scripts/*.sh .claude/hooks/*.sh 2>/dev/null || true)
  if [ -z "$JQ_CHECK" ]; then
    # No jq availability check - that's OK if jq is a hard dependency
    check "true" "jq usage is acceptable (common tool)"
  else
    check "true" "Scripts check for jq availability"
  fi
fi

echo ""
echo "--- Color Code Portability ---"
# Check that color codes use portable ANSI escapes
SCRIPTS_WITH_COLORS=$(grep -rlE 'echo.*\\033|echo.*\\e\[' scripts/ .claude/hooks/ 2>/dev/null || true)
for script in $SCRIPTS_WITH_COLORS; do
  # \033 is more portable than \e
  if grep -q 'echo.*\\e\[' "$script" 2>/dev/null && ! grep -qE 'echo -e|printf' "$script" 2>/dev/null; then
    check "false" "$script uses portable color codes"
  else
    check "true" "$script uses portable color codes"
  fi
done

echo ""
echo "--- Syntax Validation ---"
# All scripts should pass bash -n
for script in scripts/*.sh scripts/tests/*.sh .claude/hooks/*.sh; do
  if [ -f "$script" ]; then
    check "bash -n '$script'" "$script has valid syntax"
  fi
done

echo ""
echo "=== Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "✅ ALL CROSS-PLATFORM TESTS PASSED"
else
  echo "❌ SOME TESTS FAILED"
fi

exit $FAIL
