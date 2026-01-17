#!/bin/bash
set -e

echo "=== V5.0 Code Review Completion Verification ==="
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

# Helper: extract contract JSON from agent file
extract_contract() {
  local file="$1"
  sed -n '/## Agent Contract/,/^## /p' "$file" | \
    sed -n '/```json/,/```/p' | \
    sed '1d;$d'
}

# Helper: validate contract has required fields and expected id
validate_contract() {
  local file="$1"
  local expected_id="$2"
  extract_contract "$file" | \
    jq -e ".id == \"$expected_id\" and has(\"prefix\") and has(\"category\") and has(\"applicability\")" > /dev/null 2>&1
}

echo "--- Phase 1: Schema Files ---"
check "test -f .claude/schemas/agent-contract.json" "agent-contract.json exists"
check "jq -e '.properties.applicability.required | length == 3' .claude/schemas/agent-contract.json" "agent-contract schema has required fields"
check "jq -e '.properties.category.type == \"string\"' .claude/schemas/audit-finding.json" "audit-finding.category is string"
check "jq -e '.properties.metadata.properties.agentsSkipped' .claude/schemas/audit-report.json" "audit-report has agentsSkipped"

echo ""
echo "--- Phase 2: Scanner Updates ---"
check "grep -q 'hasDatabase' .claude/agents/codebase-scanner.md" "Scanner detects hasDatabase"
check "grep -q 'hasUI' .claude/agents/codebase-scanner.md" "Scanner detects hasUI"
check "grep -q 'hasCI' .claude/agents/codebase-scanner.md" "Scanner detects hasCI"
check "grep -q 'isGitRepo' .claude/agents/codebase-scanner.md" "Scanner tracks isGitRepo"
check "grep -q 'git ls-files' .claude/agents/codebase-scanner.md" "Scanner documents git ls-files"
check "grep -q 'securityRelevant' .claude/agents/codebase-scanner.md" "Scanner has securityRelevant list"
check "grep -q 'databaseFiles' .claude/agents/codebase-scanner.md" "Scanner has databaseFiles list"
check "grep -q 'uiComponents' .claude/agents/codebase-scanner.md" "Scanner has uiComponents list"
check "grep -q 'ciWorkflows' .claude/agents/codebase-scanner.md" "Scanner has ciWorkflows list"

echo ""
echo "--- Phase 3 & 4: Specialist Agent Files ---"
SPECIALISTS="security performance accessibility type-safety test-coverage seo database infrastructure"
for name in $SPECIALISTS; do
  check "test -f .claude/agents/${name}-reviewer.md" "${name}-reviewer exists"
done

echo ""
echo "--- Agent Contracts ---"
check "validate_contract .claude/agents/security-reviewer.md security" "security contract valid"
check "validate_contract .claude/agents/performance-reviewer.md performance" "performance contract valid"
check "validate_contract .claude/agents/accessibility-reviewer.md accessibility" "accessibility contract valid"
check "validate_contract .claude/agents/type-safety-reviewer.md typescript" "typescript contract valid"
check "validate_contract .claude/agents/test-coverage-reviewer.md testing" "testing contract valid"
check "validate_contract .claude/agents/seo-reviewer.md seo" "seo contract valid"
check "validate_contract .claude/agents/database-reviewer.md database" "database contract valid"
check "validate_contract .claude/agents/infrastructure-reviewer.md infrastructure" "infrastructure contract valid"

echo ""
echo "--- Agent Uniqueness (no duplicate IDs) ---"
ALL_IDS=$(for f in .claude/agents/*-reviewer.md; do extract_contract "$f" 2>/dev/null | jq -r '.id // empty'; done | sort)
UNIQUE_IDS=$(echo "$ALL_IDS" | uniq)
check "[ \"$ALL_IDS\" = \"$UNIQUE_IDS\" ]" "All agent IDs are unique"

echo ""
echo "--- File Scope Documentation ---"
check "grep -qE 'securityRelevant|File Scope' .claude/agents/security-reviewer.md" "security-reviewer documents file scope"
check "grep -qE 'databaseFiles|File Scope' .claude/agents/database-reviewer.md" "database-reviewer documents file scope"
check "grep -qE 'uiComponents|File Scope' .claude/agents/seo-reviewer.md" "seo-reviewer documents file scope"
check "grep -qE 'ciWorkflows|File Scope' .claude/agents/infrastructure-reviewer.md" "infrastructure-reviewer documents file scope"

echo ""
echo "--- Phase 5: Code Reviewer Updates ---"
check "grep -qiE 'discover|discovery' .claude/agents/code-reviewer.md" "code-reviewer has discovery"
check "grep -qE 'duplicate|Duplicate|unique' .claude/agents/code-reviewer.md" "code-reviewer checks uniqueness"
check "grep -qE ':contains|:in' .claude/agents/code-reviewer.md" "code-reviewer supports condition operators"
check "grep -q 'fallback' .claude/agents/code-reviewer.md" "code-reviewer has fallback"
check "grep -q 'agentsSkipped' .claude/agents/code-reviewer.md" "code-reviewer tracks skipped agents"
check "grep -qE 'audit-NN\|incrementing|next available' .claude/agents/code-reviewer.md" "code-reviewer uses incrementing output"

echo ""
echo "--- Framework-Aware SEO ---"
check "grep -q 'generateMetadata' .claude/agents/seo-reviewer.md" "SEO reviewer handles Next.js metadata"
check "grep -q 'projectType:in' .claude/agents/seo-reviewer.md" "SEO reviewer uses :in operator"

echo ""
echo "--- Phase 6: Command Integration ---"
check "grep -q 'code-reviewer' .claude/commands/code-review.md" "/code-review mentions code-reviewer"
check "! grep -q 'A01: Broken Access' .claude/commands/code-review.md" "/code-review has no OWASP checklists"
check "! grep -q 'grep -rn' .claude/commands/code-review.md" "/code-review has no inline grep"

echo ""
echo "--- Deprecation Notices ---"
DEPRECATED=$(grep -l "DEPRECATED" .claude/commands/code-review-*.md 2>/dev/null | wc -l | tr -d ' ')
check "[ $DEPRECATED -eq 8 ]" "All 8 old commands deprecated ($DEPRECATED/8)"

echo ""
echo "--- Extensibility Test ---"
# Create temporary agent, verify it would be discovered, clean up
TEMP_AGENT=".claude/agents/i18n-reviewer.md"
cat > "$TEMP_AGENT" << 'TEMPEOF'
# i18n Reviewer Agent

Temporary test agent.

## Agent Contract

```json
{
  "id": "i18n",
  "prefix": "I18N",
  "category": "i18n",
  "applicability": {
    "always": false,
    "requires": {},
    "presets": ["prelaunch"]
  }
}
```
TEMPEOF

check "validate_contract '$TEMP_AGENT' i18n" "Temp i18n-reviewer has valid contract"
check "ls .claude/agents/*-reviewer.md | grep -q i18n" "Temp agent discoverable by glob"
rm -f "$TEMP_AGENT"
check "! test -f '$TEMP_AGENT'" "Temp agent cleaned up"

echo ""
echo "=== Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "✅ ALL CHECKS PASSED"
  echo ""
  echo "Extensibility verified: Adding i18n-reviewer required only creating one file."
else
  echo "❌ SOME CHECKS FAILED"
fi

exit $FAIL
