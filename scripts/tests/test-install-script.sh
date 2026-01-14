#!/bin/bash
# test-install-script.sh - Validate install.sh structure and logic
# Tests that install script is safe and complete

set -e

echo "=== Install Script Tests ==="
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

INSTALL_SCRIPT="install.sh"

echo "--- Script Structure ---"
check "test -f '$INSTALL_SCRIPT'" "install.sh exists"
check "test -x '$INSTALL_SCRIPT'" "install.sh is executable"
check "head -1 '$INSTALL_SCRIPT' | grep -q '#!/bin/bash'" "Has bash shebang"
check "grep -q 'set -e' '$INSTALL_SCRIPT'" "Uses set -e for safety"
check "bash -n '$INSTALL_SCRIPT'" "Script syntax is valid"

echo ""
echo "--- Version Handling ---"
check "grep -q 'VERSION=' '$INSTALL_SCRIPT'" "Sets VERSION variable"
check "grep -q 'VERSION.*curl' '$INSTALL_SCRIPT'" "Fetches version from GitHub"
check "grep -qE 'VERSION.*[0-9]+\.[0-9]+\.[0-9]+' '$INSTALL_SCRIPT'" "Has fallback version"
check "grep -q 'grep.*[0-9].*[0-9].*[0-9]' '$INSTALL_SCRIPT'" "Validates version format"

echo ""
echo "--- Required Functions ---"
check "grep -q 'color_echo()' '$INSTALL_SCRIPT'" "Has color_echo function"
check "grep -q 'validate_file()' '$INSTALL_SCRIPT'" "Has validate_file function"
check "grep -q 'download_file()' '$INSTALL_SCRIPT'" "Has download_file function"
check "grep -q 'is_optional()' '$INSTALL_SCRIPT'" "Has is_optional function"

echo ""
echo "--- Backup Handling ---"
check "grep -q 'backup\|BACKUP' '$INSTALL_SCRIPT'" "Creates backups"
check "grep -q '.claude-backup' '$INSTALL_SCRIPT'" "Uses standard backup naming"

echo ""
echo "--- Directory Creation ---"
check "grep -q 'mkdir -p' '$INSTALL_SCRIPT'" "Creates directories"
check "grep -q '.claude/commands' '$INSTALL_SCRIPT'" "Creates .claude/commands"
check "grep -q '.claude/schemas\|schema' '$INSTALL_SCRIPT'" "Handles schema files"
check "grep -q 'templates' '$INSTALL_SCRIPT'" "Handles templates directory"
check "grep -q 'scripts' '$INSTALL_SCRIPT'" "Handles scripts directory"

echo ""
echo "--- File Download Lists ---"
# Check that key files are in download lists
check "grep -q 'CONTEXT.template.md' '$INSTALL_SCRIPT'" "Downloads CONTEXT template"
check "grep -q 'STATUS.template.md' '$INSTALL_SCRIPT'" "Downloads STATUS template"
check "grep -q 'SESSIONS.template.md' '$INSTALL_SCRIPT'" "Downloads SESSIONS template"
check "grep -q 'DECISIONS.template.md' '$INSTALL_SCRIPT'" "Downloads DECISIONS template"
check "grep -q 'common-functions.sh' '$INSTALL_SCRIPT'" "Downloads common-functions.sh"

echo ""
echo "--- Error Handling ---"
check "grep -q 'curl.*-L\|curl.*-sL' '$INSTALL_SCRIPT'" "Uses curl with redirect follow"
check "grep -q '404\|error' '$INSTALL_SCRIPT'" "Handles 404 errors"
check "grep -q 'retry\|RETRY\|attempt' '$INSTALL_SCRIPT'" "Has retry logic"
check "grep -q 'OPTIONAL_FILES' '$INSTALL_SCRIPT'" "Defines optional files"

echo ""
echo "--- Post-Install Validation ---"
check "grep -q 'validation\|verify\|check' '$INSTALL_SCRIPT'" "Has validation step"

echo ""
echo "--- Security ---"
# No unsafe patterns (exclude comments which are usage examples)
UNSAFE_CURL=$(grep -v '^#' "$INSTALL_SCRIPT" | grep -c 'curl.*| bash\|curl.*|bash' 2>/dev/null || true)
check "[ '${UNSAFE_CURL:-0}' -eq 0 ]" "No unsafe curl|bash patterns (excludes comments)"

echo ""
echo "=== Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "✅ ALL INSTALL SCRIPT TESTS PASSED"
else
  echo "❌ SOME TESTS FAILED"
fi

exit $FAIL
