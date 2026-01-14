#!/bin/bash
# test-template-improvements.sh - Verify template enhancements
# Tests for Invariants/Non-goals section and Open Loops field

set -e

echo "=== Template Improvements Verification ==="
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

echo "--- CONTEXT.template.md: Invariants & Non-goals ---"
check "grep -q '## Invariants & Non-goals' templates/CONTEXT.template.md" "Section heading exists"
check "grep -q 'Do Not Change Without Discussion' templates/CONTEXT.template.md" "Invariants subsection exists"
check "grep -q 'Non-goals (Not Now)' templates/CONTEXT.template.md" "Non-goals subsection exists"
check "grep -q 'When to Update' templates/CONTEXT.template.md" "Update guidance exists"
check "grep -q 'helpfully' templates/CONTEXT.template.md" "Explains AI behavior context"
check "grep -q 'No Redux' templates/CONTEXT.template.md" "Has example invariant"
check "grep -q 'Mobile app' templates/CONTEXT.template.md" "Has example non-goal"

echo ""
echo "--- SESSIONS.template.md: Open Loops ---"
check "grep -q '### Open Loops' templates/SESSIONS.template.md" "Section heading exists"
check "[ \$(grep -c '### Open Loops' templates/SESSIONS.template.md) -ge 2 ]" "Appears in both main template and code block"
check "grep -q 'Unresolved questions' templates/SESSIONS.template.md" "Describes purpose"
check "grep -q 'uncertainties' templates/SESSIONS.template.md" "Mentions uncertainties"
check "grep -q 'continuity' templates/SESSIONS.template.md" "Explains why it matters"

echo ""
echo "--- SESSIONS.template.md: Tips Section ---"
check "grep -q 'Open Loops.*Unresolved questions' templates/SESSIONS.template.md" "Listed in Key sections for AI"

echo ""
echo "--- Template Structure Integrity ---"
# Verify templates have expected section counts
CONTEXT_SECTIONS=$(grep -c '^## ' templates/CONTEXT.template.md)
SESSIONS_SECTIONS=$(grep -c '^## ' templates/SESSIONS.template.md)

check "[ $CONTEXT_SECTIONS -ge 12 ]" "CONTEXT.template.md has expected sections ($CONTEXT_SECTIONS)"
check "[ $SESSIONS_SECTIONS -ge 4 ]" "SESSIONS.template.md has expected sections ($SESSIONS_SECTIONS)"

# Verify no broken markdown (unclosed code blocks)
check "[ \$(grep -c '\`\`\`' templates/CONTEXT.template.md) -eq \$(grep -c '\`\`\`' templates/CONTEXT.template.md | awk '{print int(\$1/2)*2}') ]" "CONTEXT.template.md code blocks balanced"
check "[ \$(grep -c '\`\`\`' templates/SESSIONS.template.md) -eq \$(grep -c '\`\`\`' templates/SESSIONS.template.md | awk '{print int(\$1/2)*2}') ]" "SESSIONS.template.md code blocks balanced"

echo ""
echo "=== Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "✅ ALL TEMPLATE IMPROVEMENT TESTS PASSED"
else
  echo "❌ SOME TESTS FAILED"
fi

exit $FAIL
